# Swarm Test Suite

This directory contains tests for the swarm project, following Test-Driven Development (TDD) principles.

## Test Framework

Tests are written using [bats (Bash Automated Testing System)](https://github.com/bats-core/bats-core), the standard testing framework for bash scripts.

## Installation

### Install bats

**On macOS:**
```bash
brew install bats-core
```

**On Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install bats

# Or install from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

## Running Tests

### Run all tests
```bash
bats tests/
```

### Run a specific test file
```bash
bats tests/swarm_comment_test.bats
```

### Run with verbose output
```bash
bats -p tests/
```

## Test Files

- `swarm_comment_test.bats` - Tests for the one-line comment addition to the swarm script
  - Verifies comment placement and content
  - Ensures script syntax remains valid
  - Checks that no unintended changes were made
  - Validates formatting conventions

## Expected Test Status

These tests follow TDD principles:
- ✅ **PASS** - Tests should pass after the implementation is complete
- ❌ **FAIL** - Tests will fail initially (before implementation) - this is expected and correct for TDD

## Test Coverage

The test suite verifies:
1. Comment exists at the correct location (line 2)
2. Comment contains expected text
3. Existing code is preserved and shifted correctly
4. Script syntax remains valid
5. Line count increased by exactly 1
6. Formatting follows bash conventions
7. No ASCII art decoration in the one-line comment
8. No other unintended changes were made

## Contributing

When adding new features to swarm:
1. Write tests first (TDD)
2. Run tests to verify they fail
3. Implement the feature
4. Run tests to verify they pass
5. Commit both tests and implementation
