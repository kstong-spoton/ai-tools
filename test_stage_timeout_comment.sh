#!/usr/bin/env bash
# Test suite for STAGE_TIMEOUT variable documentation
# This follows TDD - tests should FAIL until the comment is added

set -uo pipefail

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWARM_SCRIPT="$SCRIPT_DIR/swarm"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helpers
pass_test() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail_test() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${YELLOW}Reason:${NC} $2"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

test_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Test 1: Verify swarm script exists
test_swarm_script_exists() {
    if [[ -f "$SWARM_SCRIPT" ]]; then
        pass_test "Swarm script exists"
    else
        fail_test "Swarm script exists" "File not found at $SWARM_SCRIPT"
    fi
}

# Test 2: Verify swarm script has valid bash syntax
test_bash_syntax_valid() {
    if bash -n "$SWARM_SCRIPT" 2>/dev/null; then
        pass_test "Swarm script has valid bash syntax"
    else
        fail_test "Swarm script has valid bash syntax" "Syntax errors detected"
    fi
}

# Test 3: Verify STAGE_TIMEOUT variable exists
test_stage_timeout_variable_exists() {
    if grep -q "^STAGE_TIMEOUT=" "$SWARM_SCRIPT"; then
        pass_test "STAGE_TIMEOUT variable exists"
    else
        fail_test "STAGE_TIMEOUT variable exists" "Variable not found"
    fi
}

# Test 4: Verify STAGE_TIMEOUT has correct default value (1800)
test_stage_timeout_default_value() {
    if grep -q "^STAGE_TIMEOUT=1800" "$SWARM_SCRIPT"; then
        pass_test "STAGE_TIMEOUT has correct default value (1800)"
    else
        fail_test "STAGE_TIMEOUT has correct default value (1800)" "Expected STAGE_TIMEOUT=1800"
    fi
}

# Test 5: Verify comment exists above STAGE_TIMEOUT
test_comment_exists_above_stage_timeout() {
    # Get the line number of STAGE_TIMEOUT
    local line_num=$(grep -n "^STAGE_TIMEOUT=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail_test "Comment exists above STAGE_TIMEOUT" "STAGE_TIMEOUT variable not found"
        return
    fi

    # Check if there are comments in the 3 lines immediately before STAGE_TIMEOUT
    local start_line=$((line_num - 3))
    local end_line=$((line_num - 1))

    if [[ $start_line -lt 1 ]]; then
        start_line=1
    fi

    local comment_lines=$(sed -n "${start_line},${end_line}p" "$SWARM_SCRIPT" | grep -c "^#" || true)

    if [[ $comment_lines -ge 2 ]]; then
        pass_test "Multi-line comment exists above STAGE_TIMEOUT"
    else
        fail_test "Multi-line comment exists above STAGE_TIMEOUT" "Expected at least 2 comment lines before STAGE_TIMEOUT, found $comment_lines"
    fi
}

# Test 6: Verify comment mentions "Maximum execution time" or similar
test_comment_mentions_purpose() {
    local line_num=$(grep -n "^STAGE_TIMEOUT=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail_test "Comment mentions purpose" "STAGE_TIMEOUT variable not found"
        return
    fi

    # Check 5 lines before STAGE_TIMEOUT for purpose description
    local start_line=$((line_num - 5))
    if [[ $start_line -lt 1 ]]; then
        start_line=1
    fi
    local end_line=$((line_num - 1))

    local comment_content=$(sed -n "${start_line},${end_line}p" "$SWARM_SCRIPT")

    if echo "$comment_content" | grep -iq -E "(maximum execution time|execution time|timeout|stage)"; then
        pass_test "Comment mentions timeout purpose"
    else
        fail_test "Comment mentions timeout purpose" "Comment should explain what STAGE_TIMEOUT controls"
    fi
}

# Test 7: Verify comment mentions default value (1800 or 30 minutes)
test_comment_mentions_default_value() {
    local line_num=$(grep -n "^STAGE_TIMEOUT=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail_test "Comment mentions default value" "STAGE_TIMEOUT variable not found"
        return
    fi

    local start_line=$((line_num - 5))
    if [[ $start_line -lt 1 ]]; then
        start_line=1
    fi
    local end_line=$((line_num - 1))

    local comment_content=$(sed -n "${start_line},${end_line}p" "$SWARM_SCRIPT")

    if echo "$comment_content" | grep -iq -E "(1800|30 minutes|default)"; then
        pass_test "Comment mentions default value"
    else
        fail_test "Comment mentions default value" "Comment should mention 1800 seconds or 30 minutes"
    fi
}

# Test 8: Verify comment mentions how to override (--timeout flag)
test_comment_mentions_override_method() {
    local line_num=$(grep -n "^STAGE_TIMEOUT=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail_test "Comment mentions override method" "STAGE_TIMEOUT variable not found"
        return
    fi

    local start_line=$((line_num - 5))
    if [[ $start_line -lt 1 ]]; then
        start_line=1
    fi
    local end_line=$((line_num - 1))

    local comment_content=$(sed -n "${start_line},${end_line}p" "$SWARM_SCRIPT")

    if echo "$comment_content" | grep -iq -E "(--timeout|override|command-line|CLI|flag)"; then
        pass_test "Comment mentions override method"
    else
        fail_test "Comment mentions override method" "Comment should mention --timeout flag or override method"
    fi
}

# Test 9: Verify comment mentions timeout behavior
test_comment_mentions_timeout_behavior() {
    local line_num=$(grep -n "^STAGE_TIMEOUT=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail_test "Comment mentions timeout behavior" "STAGE_TIMEOUT variable not found"
        return
    fi

    local start_line=$((line_num - 5))
    if [[ $start_line -lt 1 ]]; then
        start_line=1
    fi
    local end_line=$((line_num - 1))

    local comment_content=$(sed -n "${start_line},${end_line}p" "$SWARM_SCRIPT")

    if echo "$comment_content" | grep -iq -E "(exceeded|marked|timeout|stops|behavior)"; then
        pass_test "Comment mentions timeout behavior"
    else
        fail_test "Comment mentions timeout behavior" "Comment should explain what happens when timeout is exceeded"
    fi
}

# Test 10: Verify no inline comment remains on STAGE_TIMEOUT line
test_no_inline_comment_on_variable_line() {
    local stage_timeout_line=$(grep "^STAGE_TIMEOUT=" "$SWARM_SCRIPT")

    # Check if there's a comment after the value on the same line
    if echo "$stage_timeout_line" | grep -q "#"; then
        fail_test "No inline comment on STAGE_TIMEOUT line" "Inline comment found: $stage_timeout_line (should be removed in favor of multi-line comment)"
    else
        pass_test "No inline comment on STAGE_TIMEOUT line"
    fi
}

# Run all tests
main() {
    test_header "STAGE_TIMEOUT Documentation Tests (TDD)"

    echo "Testing documentation for STAGE_TIMEOUT variable..."
    echo "These tests verify the comment block above STAGE_TIMEOUT."
    echo ""

    test_swarm_script_exists
    test_bash_syntax_valid
    test_stage_timeout_variable_exists
    test_stage_timeout_default_value
    test_comment_exists_above_stage_timeout
    test_comment_mentions_purpose
    test_comment_mentions_default_value
    test_comment_mentions_override_method
    test_comment_mentions_timeout_behavior
    test_no_inline_comment_on_variable_line

    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total tests run:    $TESTS_RUN"
    echo -e "Tests passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed:       ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed. Implementation needed.${NC}"
        exit 1
    fi
}

main "$@"
