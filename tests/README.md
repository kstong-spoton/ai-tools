# Swarm Test Suite

This directory contains automated tests for the swarm script.

## Test Files

- `test_swarm_syntax.sh` - Validates bash syntax, AUTH_FAILURE_PATTERNS array, and documentation

## Running Tests

### Run all tests:
```bash
./tests/test_swarm_syntax.sh
```

### Run from project root:
```bash
bash tests/test_swarm_syntax.sh
```

## Test Coverage

The test suite validates:

1. **Script Existence** - Verifies the swarm script file exists
2. **Bash Syntax** - Validates the script has no syntax errors (`bash -n`)
3. **AUTH_FAILURE_PATTERNS Definition** - Ensures the array is declared
4. **AUTH_FAILURE_PATTERNS Content** - Verifies all expected error patterns are present
5. **is_auth_failure() Function** - Confirms the function exists
6. **Function Integration** - Validates is_auth_failure() uses AUTH_FAILURE_PATTERNS
7. **Documentation** - Checks that AUTH_FAILURE_PATTERNS has explanatory comments
8. **Executable Permissions** - Ensures the script is executable

## Test Philosophy

These tests follow TDD principles and serve as:
- **Regression tests** - Ensure documentation changes don't break functionality
- **Contract validation** - Verify the AUTH_FAILURE_PATTERNS array maintains its expected structure
- **Documentation validation** - Confirm that code documentation exists and is maintained

## Expected Behavior

- **Before comment addition**: Test #7 (documentation test) will FAIL, indicating missing comments
- **After comment addition**: All tests should PASS, confirming the documentation is present and correct
- **Syntax tests**: Should always pass unless the script structure is broken

## CI/CD Integration

To integrate with CI/CD pipelines:

```bash
# Exit with non-zero status if tests fail
./tests/test_swarm_syntax.sh || exit 1
```

## Adding New Tests

To add new tests to `test_swarm_syntax.sh`:

1. Create a new test function following the naming pattern `test_<description>`
2. Use `pass` helper for successful tests: `pass "Test description"`
3. Use `fail` helper for failed tests: `fail "Test name" "Error message"`
4. Add the test function call to the `main()` function
5. Ensure tests are idempotent and don't modify the swarm script

## Maintenance

When modifying AUTH_FAILURE_PATTERNS in the swarm script:
- Update `test_auth_patterns_content()` to reflect the new expected patterns
- Run tests to ensure all validations still pass
- Document any breaking changes in this README
