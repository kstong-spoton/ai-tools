#!/usr/bin/env bash
#
# Test suite for swarm script - validates syntax and AUTH_FAILURE_PATTERNS
# This test suite ensures documentation changes don't break functionality
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_SCRIPT="$SCRIPT_DIR/../swarm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${RED}Error: $2${NC}"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

test_banner() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Test 1: Verify swarm script exists
test_swarm_exists() {
    test_banner "Test: Swarm script exists"
    if [[ -f "$SWARM_SCRIPT" ]]; then
        pass "Swarm script exists at $SWARM_SCRIPT"
        return 0
    else
        fail "Swarm script exists" "File not found at $SWARM_SCRIPT"
        return 1
    fi
}

# Test 2: Verify bash syntax is valid
test_bash_syntax() {
    test_banner "Test: Bash syntax validation"
    if bash -n "$SWARM_SCRIPT" 2>/dev/null; then
        pass "Swarm script has valid bash syntax"
        return 0
    else
        local error_output
        error_output=$(bash -n "$SWARM_SCRIPT" 2>&1)
        fail "Bash syntax validation" "$error_output"
        return 1
    fi
}

# Test 3: Verify AUTH_FAILURE_PATTERNS array is defined
test_auth_patterns_defined() {
    test_banner "Test: AUTH_FAILURE_PATTERNS array is defined"
    if grep -q "^AUTH_FAILURE_PATTERNS=" "$SWARM_SCRIPT"; then
        pass "AUTH_FAILURE_PATTERNS array is defined"
        return 0
    else
        fail "AUTH_FAILURE_PATTERNS defined" "Array declaration not found in script"
        return 1
    fi
}

# Test 4: Verify AUTH_FAILURE_PATTERNS contains expected patterns
test_auth_patterns_content() {
    test_banner "Test: AUTH_FAILURE_PATTERNS contains expected patterns"
    local expected_patterns=(
        "Authentication failed"
        "Invalid API key"
        "Unauthorized"
        "401"
        "403"
        "ExpiredToken"
        "ExpiredTokenException"
        "InvalidAccessKeyId"
        "AccessDenied"
        "cannot be launched inside another Claude Code session"
    )

    local missing_patterns=()
    for pattern in "${expected_patterns[@]}"; do
        if ! grep -q "\"$pattern\"" "$SWARM_SCRIPT"; then
            missing_patterns+=("$pattern")
        fi
    done

    if [[ ${#missing_patterns[@]} -eq 0 ]]; then
        pass "AUTH_FAILURE_PATTERNS contains all expected patterns (${#expected_patterns[@]} patterns)"
        return 0
    else
        fail "AUTH_FAILURE_PATTERNS content" "Missing patterns: ${missing_patterns[*]}"
        return 1
    fi
}

# Test 5: Verify is_auth_failure function exists
test_auth_failure_function_exists() {
    test_banner "Test: is_auth_failure() function exists"
    if grep -q "^is_auth_failure()" "$SWARM_SCRIPT"; then
        pass "is_auth_failure() function is defined"
        return 0
    else
        fail "is_auth_failure() function exists" "Function declaration not found"
        return 1
    fi
}

# Test 6: Verify is_auth_failure function uses AUTH_FAILURE_PATTERNS
test_auth_failure_uses_patterns() {
    test_banner "Test: is_auth_failure() uses AUTH_FAILURE_PATTERNS"
    # Extract the function and check if it references the patterns array
    if grep -A 15 "^is_auth_failure()" "$SWARM_SCRIPT" | grep -q "AUTH_FAILURE_PATTERNS"; then
        pass "is_auth_failure() function references AUTH_FAILURE_PATTERNS array"
        return 0
    else
        fail "is_auth_failure() uses patterns" "Function doesn't reference AUTH_FAILURE_PATTERNS array"
        return 1
    fi
}

# Test 7: Verify AUTH_FAILURE_PATTERNS has documentation (comment)
test_auth_patterns_documented() {
    test_banner "Test: AUTH_FAILURE_PATTERNS is documented with comments"
    # Look for comments near the AUTH_FAILURE_PATTERNS declaration
    # This test checks if there's at least one comment line within 5 lines before the array
    local line_num
    line_num=$(grep -n "^AUTH_FAILURE_PATTERNS=" "$SWARM_SCRIPT" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        fail "AUTH_FAILURE_PATTERNS documentation" "Could not find AUTH_FAILURE_PATTERNS declaration"
        return 1
    fi

    # Check if there are comments in the 5 lines before the array declaration
    local start_line=$((line_num - 5))
    [[ $start_line -lt 1 ]] && start_line=1

    if sed -n "${start_line},${line_num}p" "$SWARM_SCRIPT" | grep -q "^#.*[Pp]attern\|^#.*auth\|^#.*detect\|^#.*fail"; then
        pass "AUTH_FAILURE_PATTERNS has documentation comments"
        return 0
    else
        fail "AUTH_FAILURE_PATTERNS documentation" "No explanatory comments found near array declaration"
        return 1
    fi
}

# Test 8: Verify script is executable
test_script_executable() {
    test_banner "Test: Swarm script is executable"
    if [[ -x "$SWARM_SCRIPT" ]]; then
        pass "Swarm script has executable permissions"
        return 0
    else
        fail "Script executable" "Script does not have executable permissions"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  Swarm Script Test Suite - Syntax & Documentation     ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"

    # Run all tests
    test_swarm_exists
    test_bash_syntax
    test_auth_patterns_defined
    test_auth_patterns_content
    test_auth_failure_function_exists
    test_auth_failure_uses_patterns
    test_auth_patterns_documented
    test_script_executable

    # Print summary
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  Test Results Summary                                  ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "Tests run:    ${TESTS_RUN}"
    echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}\n"
        return 0
    else
        echo -e "\n${RED}✗ Some tests failed!${NC}\n"
        return 1
    fi
}

# Run tests
main
