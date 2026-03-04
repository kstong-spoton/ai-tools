# Swarm Test Suite

This directory contains tests for the swarm pipeline orchestrator script.

## Running Tests

```bash
# Run all configuration tests
./tests/test_swarm_config.sh
```

## Test Files

### `test_swarm_config.sh`

Tests for swarm script configuration variables and documentation.

**Test Coverage:**
- Bash syntax validation
- Script executable permissions
- Variable definitions and values
- Inline comment formatting and conventions
- Documentation completeness (units, purpose)
- Variable usage in functions

**Expected Behavior:**
- All baseline tests should pass (syntax, values, usage)
- Documentation tests will initially fail for undocumented variables (TDD approach)
- After adding proper inline comments, all tests should pass

## Test-Driven Development (TDD) Approach

Tests in this directory follow TDD principles:

1. **Write tests first** - Define expected behavior before implementation
2. **Fail initially** - Documentation tests fail when comments are missing
3. **Implement** - Add the required comments/documentation
4. **Pass** - Tests pass once implementation matches requirements

## Adding New Tests

When adding new configuration variables or modifying existing ones:

1. Add tests for the variable definition and value
2. Add tests for inline documentation requirements
3. Add tests for variable usage in the codebase
4. Ensure tests fail before implementation (TDD)
5. Verify tests pass after implementation

## Test Output

- `✓` Green checkmark indicates passing test
- `✗` Red X indicates failing test with reason
- Summary shows total tests run, passed, and failed
- Exit code 0 for all tests passing, 1 for any failures
