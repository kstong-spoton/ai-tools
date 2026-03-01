# Plan: Add Jira Integration to Swarm via Atlassian MCP

## Context

The swarm pipeline currently supports tickets from inline strings, files, or GitHub issues. The user wants to:
1. Process Jira tickets (single or batch via JQL)
2. Enable agents to **update Jira** (add comments, transition status, close issues)

Each ticket is processed sequentially in its own worktree, producing a separate PR.

## Approach

Use the official `atlassian/atlassian-mcp-server` for full Jira integration. This provides:
- Read: fetch issues, search via JQL
- Write: add comments, transition status, update fields

## Changes

### 1. Install & Configure Atlassian MCP Server

**Setup commands:**
```bash
npm install -g @anthropic/atlassian-mcp-server
```

**Create `~/.config/claude-code/mcp.json`** (or add to existing):
```json
{
  "mcpServers": {
    "atlassian": {
      "command": "atlassian-mcp-server",
      "env": {
        "ATLASSIAN_SITE_URL": "${JIRA_URL}",
        "ATLASSIAN_USER_EMAIL": "${JIRA_USER}",
        "ATLASSIAN_API_TOKEN": "${JIRA_TOKEN}"
      }
    }
  }
}
```

### 2. Add Helper Script for Jira Queries

**File:** `jira-query` (new file)

A small helper that uses the MCP server to fetch ticket data in a format swarm can consume:

```bash
#!/usr/bin/env bash
# Fetch Jira issues via claude + MCP

MODE="$1"  # "issue" or "jql"
QUERY="$2"

case "$MODE" in
    issue)
        claude -p --output-format json \
            "Use the Jira MCP tool to get issue $QUERY. Return JSON: {key, summary, description}" \
            | jq -r '"# " + .summary + "\n\n" + .description'
        ;;
    jql)
        claude -p --output-format json \
            "Use the Jira MCP tool to search: $QUERY. Return JSON array of issue keys only." \
            | jq -r '.[]'
        ;;
esac
```

### 3. Update Swarm Script

**File:** `swarm`

**Add new CLI options** (in `parse_args`):
```bash
--jira-issue)
    [[ $# -ge 2 ]] || die "--jira-issue requires an issue key"
    TICKET_SOURCE="jira"
    JIRA_ISSUE="$2"
    shift 2
    ;;
--jira-jql)
    [[ $# -ge 2 ]] || die "--jira-jql requires a JQL query"
    TICKET_SOURCE="jira-jql"
    JIRA_JQL="$2"
    shift 2
    ;;
```

**Add ticket resolution** (in `parse_args`):
```bash
jira)
    info "fetching Jira issue $JIRA_ISSUE..."
    TICKET=$("$SWARM_DIR/jira-query" issue "$JIRA_ISSUE") \
        || die "failed to fetch Jira issue"
    ;;
jira-jql)
    info "fetching Jira issues matching: $JIRA_JQL"
    mapfile -t JIRA_ISSUES < <("$SWARM_DIR/jira-query" jql "$JIRA_JQL")
    [[ ${#JIRA_ISSUES[@]} -gt 0 ]] || die "no issues found"
    info "found ${#JIRA_ISSUES[@]} issues: ${JIRA_ISSUES[*]}"
    ;;
```

**Add batch loop** (in `main`):
```bash
if [[ "$TICKET_SOURCE" == "jira-jql" ]]; then
    local total=${#JIRA_ISSUES[@]}
    for ((i = 0; i < total; i++)); do
        info "[$((i+1))/$total] processing ${JIRA_ISSUES[$i]}"
        JIRA_CURRENT="${JIRA_ISSUES[$i]}"
        TICKET=$("$SWARM_DIR/jira-query" issue "$JIRA_CURRENT")
        setup_worktree
        setup_tmux
        run_pipeline || warn "pipeline failed for $JIRA_CURRENT"
    done
else
    setup_worktree
    setup_tmux
    run_pipeline
fi
```

**Update usage:**
```
Options:
  --jira-issue KEY       Fetch single Jira issue (e.g., PROJ-123)
  --jira-jql QUERY       Process multiple issues via JQL query

Examples:
  swarm ~/repos/myapp --jira-issue PROJ-123
  swarm ~/repos/myapp --jira-jql "project = PROJ AND sprint in openSprints()"

Environment Variables:
  JIRA_URL               Jira site URL (e.g., https://company.atlassian.net)
  JIRA_USER              Jira email
  JIRA_TOKEN             Jira API token
```

### 4. Update Role Prompts for Jira Actions

**File:** `roles/validator.md` - Add Jira integration:

```markdown
## Jira Integration

After creating the PR:
1. Add a comment to the Jira issue with the PR link
2. Transition the issue to "In Review" (if that status exists)

Use the Jira MCP tools:
- `jira_add_comment` - Add the PR URL as a comment
- `jira_transition_issue` - Move to review status
```

**File:** `roles/coder.md` - Optional progress updates:

```markdown
## Jira Updates (Optional)

If the implementation takes significant time, you may add a brief progress comment to the Jira issue using `jira_add_comment`.
```

### 5. Store Issue Key in Runtime Metadata

**File:** `swarm` - Track current issue for agents:

In `setup_worktree()`, add issue key to metadata:
```bash
jq -n \
    --arg ticket "$TICKET" \
    --arg jira_key "${JIRA_CURRENT:-}" \
    --arg branch "$BRANCH_NAME" \
    ...
```

Agents can read `.swarm/run.json` to get the Jira issue key for updates.

## Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `~/.config/claude-code/mcp.json` | Create/Update | MCP server configuration |
| `jira-query` | Create | Helper script for Jira queries via MCP |
| `swarm` | Update | CLI args, batch loop, metadata |
| `roles/validator.md` | Update | Add Jira comment/transition instructions |
| `roles/coder.md` | Update | Optional progress updates |

## Verification

1. **Setup MCP:**
   ```bash
   export JIRA_URL="https://yourcompany.atlassian.net"
   export JIRA_USER="you@company.com"
   export JIRA_TOKEN="your-api-token"
   ```

2. **Test single issue:**
   ```bash
   ./swarm ~/repos/test-repo --jira-issue PROJ-123
   ```

3. **Test JQL batch:**
   ```bash
   ./swarm ~/repos/test-repo --jira-jql "project = PROJ AND status = 'To Do' AND sprint in openSprints()"
   ```

4. **Verify Jira updates:**
   - Check that validator adds PR link as comment
   - Check issue transitions to "In Review"
