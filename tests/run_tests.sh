#!/usr/bin/env bash
#
# Test runner for swarm script test suite
# Runs all test files in the tests directory
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running Swarm Test Suite..."
echo "=============================="
echo

# Run syntax and documentation tests
"$SCRIPT_DIR/test_swarm_syntax.sh"
exit_code=$?

echo
if [[ $exit_code -eq 0 ]]; then
    echo "✓ All test suites passed!"
    exit 0
else
    echo "✗ Some tests failed. See output above for details."
    exit 1
fi
