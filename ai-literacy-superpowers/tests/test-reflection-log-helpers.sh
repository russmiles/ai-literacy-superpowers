#!/usr/bin/env bash
set -euo pipefail
# Test harness for reflection-log-helpers.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_PATH="$SCRIPT_DIR/../scripts/lib/reflection-log-helpers.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# shellcheck source=/dev/null
source "$LIB_PATH"

# Simple assertion helpers
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_eq() { [ "$1" = "$2" ] || fail "expected '$2' got '$1'"; }

test_split_entries_on_empty_log() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-empty.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "0"
}

test_split_entries_on_single_entry() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-single-entry.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "1"
}

test_split_entries_on_empty_log
test_split_entries_on_single_entry
echo "All tests passed."
