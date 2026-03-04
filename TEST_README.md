# Test Suite for STAGE_TIMEOUT Documentation

## Overview

This test suite validates the documentation for the `STAGE_TIMEOUT` variable in the `swarm` script. Following Test-Driven Development (TDD) principles, these tests were written **before** the implementation to define the expected behavior.

## Running the Tests

```bash
./test_stage_timeout_comment.sh
```

## Test Coverage

The test suite includes 10 tests that verify:

### Basic Checks (Currently Passing)
1. ✓ Swarm script exists
2. ✓ Swarm script has valid bash syntax
3. ✓ STAGE_TIMEOUT variable exists
4. ✓ STAGE_TIMEOUT has correct default value (1800)

### Documentation Requirements (Currently Failing - TDD)
5. ✗ Multi-line comment exists above STAGE_TIMEOUT
6. ✗ Comment mentions timeout purpose
7. ✗ Comment mentions default value
8. ✗ Comment mentions override method
9. ✗ Comment mentions timeout behavior
10. ✗ No inline comment on STAGE_TIMEOUT line

## Expected Implementation

The tests expect a multi-line comment block above the `STAGE_TIMEOUT` variable that:

- Explains the purpose (controls per-stage execution time limit)
- Mentions the default value (1800 seconds / 30 minutes)
- Describes how to override it (--timeout flag)
- Explains timeout behavior (stage marked as TIMEOUT, pipeline stops)
- Removes the inline comment in favor of the comprehensive block comment

## Example Expected Format

```bash
# Maximum execution time allowed for each pipeline stage (reviewer, architect, qa, coder, validator).
# Default: 1800 seconds (30 minutes). Override with --timeout SECONDS command-line flag.
# When exceeded, the stage is marked as TIMEOUT and the pipeline stops for that stage.
STAGE_TIMEOUT=1800
```

## Exit Codes

- `0`: All tests pass
- `1`: Some tests failed

## Current Status

**6 out of 10 tests failing** - This is expected! The tests define the requirements and will pass once the documentation is implemented.
