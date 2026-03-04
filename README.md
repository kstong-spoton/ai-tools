# Swarm

A bash-based multi-agent pipeline orchestrator that runs specialized Claude Code agents through tmux panes to implement tickets end-to-end.

## Overview

Swarm coordinates a sequential pipeline of AI agents, each with a specialized role, to take a ticket from analysis to pull request. Each run creates an isolated git worktree, and agents pass context between stages via files.

```
┌─────────────────────────────────────────────────────────────────┐
│  TICKET                                                         │
│    ↓                                                            │
│  reviewer → architect → qa → coder → validator                  │
│    ↓            ↓        ↓      ↓         ↓                     │
│  review.md   plan.md   tests  impl      PR                      │
└─────────────────────────────────────────────────────────────────┘
```

## Pipeline Stages

| Stage | Role | Output |
|-------|------|--------|
| **reviewer** | Analyzes ticket and codebase, identifies scope and risks | `.swarm/review.md` |
| **architect** | Creates detailed implementation plan | `.swarm/plan.md` |
| **qa** | Writes tests based on the plan (TDD) | Test files committed |
| **coder** | Implements the solution following the plan | Code committed |
| **validator** | Runs tests, reviews changes, creates PR | Pull request |

## Requirements

- bash
- [tmux](https://github.com/tmux/tmux)
- [jq](https://jqlang.github.io/jq/)
- [claude](https://github.com/anthropics/claude-code) (Claude Code CLI)
- [gh](https://cli.github.com/) (GitHub CLI)
- git

## Installation

```bash
# Clone the repository
git clone https://github.com/SpotOnInc/swarm.git
cd swarm

# Add to PATH (symlink to ~/.local/bin)
mkdir -p ~/.local/bin
ln -sf "$(pwd)/swarm" ~/.local/bin/swarm

# Ensure ~/.local/bin is in your PATH (add to ~/.zshrc or ~/.bashrc)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Ensure `claude` is authenticated:
```bash
claude auth login
```

## Usage

### Basic

```bash
swarm --repo <path> --ticket "<description>"
```

### Examples

```bash
# Inline ticket description
swarm --repo ~/projects/myapp --ticket "add a health check endpoint"

# GitHub issue URL
swarm --repo ~/projects/myapp --ticket https://github.com/owner/repo/issues/42

# GitHub issue reference
swarm --repo ~/projects/myapp --ticket owner/repo#42

# Ticket from file
swarm --repo ~/projects/myapp --ticket ./ticket.md

# From within the repo directory
cd ~/projects/myapp
swarm --repo . --ticket "fix login bug"
```

### Options

| Option | Description |
|--------|-------------|
| `--repo PATH` | Path to the git repository |
| `--ticket TICKET` | Ticket description, GitHub URL/ref, or file path |
| `--resume PATH` | Resume a previously interrupted pipeline |
| `--session NAME` | tmux session name (default: `swarm`) |
| `--timeout SECONDS` | Per-stage timeout (default: 1800) |

### Resuming

If a pipeline is interrupted, resume from where it left off:

```bash
swarm --repo ~/projects/myapp --resume ~/projects/myapp-swarm-20250101-120000
```

## How It Works

1. **Worktree Creation** - Creates an isolated git worktree with a new branch
2. **tmux Layout** - Opens a tmux session with a main pane (70%) and sidebar panes
3. **Stage Execution** - Each stage runs in sequence, with the active stage swapped to the main pane
4. **Context Passing** - Stages read outputs from previous stages in `.swarm/`
5. **Validation** - Each stage validates its output before proceeding
6. **Retry Logic** - Failed stages retry with exponential backoff; validators can trigger cross-stage retries

## Configuration

Edit `swarm.json` to customize the pipeline:

```json
{
  "pipeline": ["reviewer", "architect", "qa", "coder", "validator"],
  "defaults": {
    "model": "sonnet",
    "max_budget_usd": 5,
    "max_retries": 3,
    "retry_backoffs": [10, 30, 60],
    "max_cross_stage_retries": 3
  },
  "stage_overrides": {
    "architect": { "model": "opus", "max_budget_usd": 3 },
    "coder": { "max_budget_usd": 10 }
  }
}
```

## Project Structure

```
.
├── swarm              # Main orchestrator script
├── swarm.json         # Pipeline configuration
└── roles/             # System prompts for each stage
    ├── reviewer.md
    ├── architect.md
    ├── qa.md
    ├── coder.md
    └── validator.md
```

## Runtime Files

Each run creates a `.swarm/` directory in the worktree:

```
.swarm/
├── run.json           # Run metadata and stage status
├── review.md          # Reviewer output
├── plan.md            # Architect output
├── verdict.json       # Cross-stage retry trigger (if any)
├── prompts/           # Generated prompts for each stage
└── log/               # Stage logs and exit codes
```

## Extending

### Adding a New Stage

1. Create `roles/mystage.md` with the system prompt
2. Add `build_prompt_mystage()` function in `swarm`
3. Register in `build_stage_prompt()` case statement
4. Add to `pipeline` array in `swarm.json`

### Adding a New Agent Type

Extend `build_agent_cmd()` with a new case to support different AI backends.

## License

MIT
