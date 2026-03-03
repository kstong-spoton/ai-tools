#!/usr/bin/env bash
# Test runner for swarm project
# Automatically detects and runs tests using available test frameworks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "======================================"
echo "Swarm Test Runner"
echo "======================================"
echo ""

# Check if bats is available
if command -v bats &> /dev/null; then
    echo "Running tests with bats..."
    echo ""
    bats "$SCRIPT_DIR"
else
    echo "⚠️  bats not found. Install with: brew install bats-core"
    echo ""
    echo "Falling back to simple verification script..."
    echo ""

    # Run the simple verification script instead
    if [[ -x "$SCRIPT_DIR/verify_comment.sh" ]]; then
        "$SCRIPT_DIR/verify_comment.sh"
    else
        echo "❌ No test runner available"
        echo ""
        echo "To install bats:"
        echo "  macOS:  brew install bats-core"
        echo "  Linux:  sudo apt-get install bats"
        exit 1
    fi
fi
