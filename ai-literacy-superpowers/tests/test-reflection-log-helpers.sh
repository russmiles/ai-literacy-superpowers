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

test_parse_promoted_agents_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-agents.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "AGENTS.md STYLE: \"Multi-repo scheduled agents\""
}
test_parse_promoted_harness_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-harness.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "HARNESS.md: Reflections via PR workflow"
}
test_parse_promoted_aged_out_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-aged-out.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "aged-out, no promotion warranted"
}
test_parse_promoted_absent() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}
test_parse_promoted_malformed_returns_empty() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-malformed.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}

test_split_entries_on_empty_log
test_split_entries_on_single_entry
test_parse_promoted_agents_form
test_parse_promoted_harness_form
test_parse_promoted_aged_out_form
test_parse_promoted_absent
test_parse_promoted_malformed_returns_empty
echo "All tests passed."
