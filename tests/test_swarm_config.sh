#!/usr/bin/env bash
# Test suite for swarm script configuration variables
# Tests the POLL_INTERVAL variable documentation and value

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWARM_SCRIPT="$SCRIPT_DIR/../swarm"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${RED}Reason:${NC} $2"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

test_header() {
    echo -e "\n${YELLOW}Testing:${NC} $1"
}

# ─── Tests ───────────────────────────────────────────────────────────────────

test_header "Bash Syntax Validation"

# Test 1: Script has valid bash syntax
if bash -n "$SWARM_SCRIPT" 2>/dev/null; then
    pass "swarm script has valid bash syntax"
else
    fail "swarm script has valid bash syntax" "syntax check failed"
fi

# Test 2: Script is executable
if [[ -x "$SWARM_SCRIPT" ]]; then
    pass "swarm script is executable"
else
    fail "swarm script is executable" "missing execute permission"
fi

test_header "POLL_INTERVAL Configuration"

# Test 3: POLL_INTERVAL variable is defined
if grep -q "^POLL_INTERVAL=" "$SWARM_SCRIPT"; then
    pass "POLL_INTERVAL variable is defined"
else
    fail "POLL_INTERVAL variable is defined" "variable declaration not found"
fi

# Test 4: POLL_INTERVAL has the correct value (3)
POLL_VALUE=$(grep "^POLL_INTERVAL=" "$SWARM_SCRIPT" | cut -d'=' -f2 | cut -d'#' -f1 | tr -d ' ')
if [[ "$POLL_VALUE" == "3" ]]; then
    pass "POLL_INTERVAL value is 3"
else
    fail "POLL_INTERVAL value is 3" "expected 3, got '$POLL_VALUE'"
fi

# Test 5: POLL_INTERVAL is on the expected line (line 15)
LINE_NUM=$(grep -n "^POLL_INTERVAL=" "$SWARM_SCRIPT" | cut -d':' -f1)
if [[ "$LINE_NUM" == "15" ]]; then
    pass "POLL_INTERVAL is defined on line 15"
else
    fail "POLL_INTERVAL is defined on line 15" "found on line $LINE_NUM"
fi

test_header "Documentation Requirements"

# Test 6: POLL_INTERVAL line has an inline comment
POLL_LINE=$(sed -n '15p' "$SWARM_SCRIPT")
if (echo "$POLL_LINE" | grep -q "#"); then
    pass "POLL_INTERVAL has an inline comment"
else
    fail "POLL_INTERVAL has an inline comment" "no comment found on line 15"
fi

# Test 7: Comment follows the established pattern (two spaces before #)
if (echo "$POLL_LINE" | grep -qE "POLL_INTERVAL=3  #"); then
    pass "Comment follows the two-space formatting convention"
else
    fail "Comment follows the two-space formatting convention" "expected 'POLL_INTERVAL=3  #'"
fi

# Test 8: Comment mentions 'seconds' (unit of measurement)
if (echo "$POLL_LINE" | grep -qi "second"); then
    pass "Comment documents the unit (seconds)"
else
    fail "Comment documents the unit (seconds)" "comment should mention 'seconds'"
fi

# Test 9: Comment explains the purpose (status checks or stage completion)
# Extract only the comment part (after #) if it exists
COMMENT_PART=$(echo "$POLL_LINE" | grep -o '#.*' || true)
if [[ -n "$COMMENT_PART" ]] && (echo "$COMMENT_PART" | grep -qiE "(status|check|stage|completion|poll)"); then
    pass "Comment explains the variable's purpose"
else
    fail "Comment explains the variable's purpose" "comment should explain what POLL_INTERVAL controls"
fi

test_header "Variable Usage Validation"

# Test 10: POLL_INTERVAL is used in the run_stage function polling loop
if (grep -A 120 "^run_stage()" "$SWARM_SCRIPT" | grep -q "sleep.*POLL_INTERVAL"); then
    pass "POLL_INTERVAL is used in run_stage function"
else
    fail "POLL_INTERVAL is used in run_stage function" "usage not found"
fi

# Test 11: POLL_INTERVAL usage is correct (sleep command)
if grep -q 'sleep "$POLL_INTERVAL"' "$SWARM_SCRIPT"; then
    pass "POLL_INTERVAL is properly referenced in sleep command"
else
    fail "POLL_INTERVAL is properly referenced in sleep command" "expected 'sleep \"\$POLL_INTERVAL\"'"
fi

# ─── Test Summary ────────────────────────────────────────────────────────────

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "Total tests run:    $TESTS_RUN"
echo -e "${GREEN}Tests passed:       $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Tests failed:       $TESTS_FAILED${NC}"
fi
echo ""

# Exit with appropriate code
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
