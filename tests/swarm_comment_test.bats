#!/usr/bin/env bats

# Test suite for verifying the one-line comment addition to swarm script
# These tests verify the implementation of the ticket: "add a one-line comment to swarm"

setup() {
    # Get the project root directory
    SWARM_SCRIPT="${BATS_TEST_DIRNAME}/../swarm"

    # Verify the swarm script exists
    if [[ ! -f "$SWARM_SCRIPT" ]]; then
        skip "swarm script not found at $SWARM_SCRIPT"
    fi
}

@test "swarm script has shebang on line 1" {
    # Verify the shebang is still in place
    local line1=$(sed -n '1p' "$SWARM_SCRIPT")
    [[ "$line1" == "#!/usr/bin/env bash" ]]
}

@test "swarm script has one-line comment on line 2" {
    # Test that line 2 contains the expected one-line comment
    local line2=$(sed -n '2p' "$SWARM_SCRIPT")

    # Verify it's a comment (starts with #)
    [[ "$line2" =~ ^#[[:space:]] ]]

    # Verify it contains key descriptive terms about the swarm's purpose
    # The comment should describe: orchestration, multi-agent, pipeline, tmux, tickets, planning to PR
    [[ "$line2" =~ [Oo]rchestrate ]] || [[ "$line2" =~ pipeline ]]
}

@test "swarm script has the specific expected comment text on line 2" {
    # Test for the exact comment text specified in the implementation plan
    local line2=$(sed -n '2p' "$SWARM_SCRIPT")
    local expected="# Orchestrates multi-agent coding pipeline through tmux to implement tickets from planning to PR"

    [[ "$line2" == "$expected" ]]
}

@test "swarm script has 'set -euo pipefail' on line 3 (shifted from line 2)" {
    # After adding the comment, the set command should move to line 3
    local line3=$(sed -n '3p' "$SWARM_SCRIPT")
    [[ "$line3" == "set -euo pipefail" ]]
}

@test "swarm script has blank line on line 4" {
    # Verify the blank line is preserved after the set command
    local line4=$(sed -n '4p' "$SWARM_SCRIPT")
    [[ "$line4" == "" ]]
}

@test "swarm script maintains existing multi-line comment block starting at line 5" {
    # The existing comment block should now start at line 5 (was line 4)
    local line5=$(sed -n '5p' "$SWARM_SCRIPT")
    [[ "$line5" =~ ^#.*Swarm.*Pipeline.*Orchestrator ]] || [[ "$line5" =~ ─── ]]
}

@test "swarm script line count increased by exactly 1" {
    # Original line count was 1119, should now be 1120
    local current_count=$(wc -l < "$SWARM_SCRIPT")
    current_count=$(echo "$current_count" | tr -d '[:space:]')

    [[ "$current_count" == "1120" ]]
}

@test "swarm script has valid bash syntax" {
    # Verify the script passes bash syntax check
    bash -n "$SWARM_SCRIPT"
}

@test "swarm script is executable" {
    # Verify the script has execute permissions
    [[ -x "$SWARM_SCRIPT" ]]
}

@test "swarm script runs without errors (help command)" {
    # Verify the script can execute without runtime errors
    # Using --help as a safe, non-destructive command
    skip "Skipping execution test - requires full environment setup"
    # Uncomment when environment is ready:
    # run "$SWARM_SCRIPT" --help
    # [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]  # Accept both success and expected error codes
}

@test "comment formatting follows bash conventions" {
    # Verify the comment has proper formatting:
    # - Starts with # followed by a single space
    # - No trailing whitespace
    local line2=$(sed -n '2p' "$SWARM_SCRIPT")

    # Should start with "# " (hash followed by single space)
    [[ "$line2" =~ ^#[[:space:]] ]]

    # Should not have trailing whitespace
    [[ ! "$line2" =~ [[:space:]]$ ]]
}

@test "comment is a single line (no ASCII art decoration)" {
    # Verify the comment is simple and doesn't use ASCII art like the existing multi-line comment
    local line2=$(sed -n '2p' "$SWARM_SCRIPT")

    # Should not contain box-drawing characters (─, │, etc.)
    [[ ! "$line2" =~ ─ ]]
    [[ ! "$line2" =~ ═ ]]
    [[ ! "$line2" =~ │ ]]
}

@test "no other changes were made to the script" {
    # Verify that only one line was added and nothing else changed
    # We check this by verifying key structural elements are still present

    # Check that SWARM_DIR definition exists (should be around line 8-9 now)
    grep -q 'SWARM_DIR="$(cd "$(dirname "$0")" && pwd)"' "$SWARM_SCRIPT"

    # Check that the error recovery section comment exists
    grep -q "Error Recovery" "$SWARM_SCRIPT"

    # Check that the script still contains the main function
    grep -q "^main()" "$SWARM_SCRIPT" || grep -q "^main ()" "$SWARM_SCRIPT"
}
