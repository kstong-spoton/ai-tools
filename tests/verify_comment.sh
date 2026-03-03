#!/usr/bin/env bash
# Simple verification script for the one-line comment test
# Can be run without bats installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWARM_SCRIPT="$SCRIPT_DIR/../swarm"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

# Test helper functions
test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    pass_count=$((pass_count + 1))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    fail_count=$((fail_count + 1))
}

test_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

echo "========================================="
echo "Swarm Comment Addition - Test Verification"
echo "========================================="
echo ""

# Test 1: Shebang on line 1
test_info "Test 1: Verifying shebang on line 1..."
line1=$(sed -n '1p' "$SWARM_SCRIPT")
if [[ "$line1" == "#!/usr/bin/env bash" ]]; then
    test_pass "Shebang is on line 1"
else
    test_fail "Shebang is NOT on line 1 (found: '$line1')"
fi

# Test 2: One-line comment on line 2
test_info "Test 2: Verifying one-line comment on line 2..."
line2=$(sed -n '2p' "$SWARM_SCRIPT")
expected_comment="# Orchestrates multi-agent coding pipeline through tmux to implement tickets from planning to PR"

if [[ "$line2" == "$expected_comment" ]]; then
    test_pass "Expected comment found on line 2"
elif [[ "$line2" =~ ^#[[:space:]] ]]; then
    test_fail "Line 2 has a comment, but not the expected text"
    echo "  Expected: '$expected_comment'"
    echo "  Found:    '$line2'"
else
    test_fail "Line 2 does NOT have the expected comment"
    echo "  Expected: '$expected_comment'"
    echo "  Found:    '$line2'"
fi

# Test 3: set -euo pipefail on line 3
test_info "Test 3: Verifying 'set -euo pipefail' shifted to line 3..."
line3=$(sed -n '3p' "$SWARM_SCRIPT")
if [[ "$line3" == "set -euo pipefail" ]]; then
    test_pass "'set -euo pipefail' is on line 3"
else
    test_fail "'set -euo pipefail' is NOT on line 3 (found: '$line3')"
fi

# Test 4: Line count
test_info "Test 4: Verifying line count increased to 1120..."
current_count=$(wc -l < "$SWARM_SCRIPT" | tr -d '[:space:]')
if [[ "$current_count" == "1120" ]]; then
    test_pass "Line count is 1120 (increased by 1)"
else
    test_fail "Line count is $current_count (expected 1120)"
fi

# Test 5: Bash syntax
test_info "Test 5: Verifying bash syntax..."
if bash -n "$SWARM_SCRIPT" 2>/dev/null; then
    test_pass "Script has valid bash syntax"
else
    test_fail "Script has INVALID bash syntax"
fi

# Test 6: Comment formatting
test_info "Test 6: Verifying comment formatting..."
if [[ "$line2" =~ ^#[[:space:]] ]] && [[ ! "$line2" =~ [[:space:]]$ ]]; then
    test_pass "Comment formatting is correct (starts with '# ', no trailing space)"
else
    test_fail "Comment formatting is incorrect"
fi

# Test 7: No ASCII art in the one-liner
test_info "Test 7: Verifying no ASCII art decoration..."
if [[ ! "$line2" =~ ─ ]] && [[ ! "$line2" =~ ═ ]]; then
    test_pass "Comment is a simple one-liner (no ASCII art)"
else
    test_fail "Comment contains ASCII art decoration"
fi

echo ""
echo "========================================="
echo "Test Results:"
echo "  Passed: $pass_count"
echo "  Failed: $fail_count"
echo "========================================="

if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Implementation needed.${NC}"
    exit 1
fi
