#!/usr/bin/env bash
# reflection-log-helpers.sh
#
# Shared helpers for reflection-log archival scripts.
# Sourced by archive-promoted-reflections.sh, migrate-reflection-log.sh,
# and read-side filtering callers.
#
# Functions defined here:
# - split_entries <log-path>      → emit each entry preceded by `---ENTRY---`
# - parse_promoted <entry-text>   → echo Promoted RHS or empty if absent
# - extract_field <entry> <name>  → echo the value of `- **<name>**: ...`
# - bounded_entries <log> <n> <m> → return entries within last n OR last m days
# - resolve_year <entry-text>     → echo YYYY from the entry's Date field

set -euo pipefail

# split_entries: emit log entries one at a time, separated by `---ENTRY---`
# markers (so callers can iterate without running awk per call).
split_entries() {
  local log_path="$1"
  awk '
    /^---$/ {
      if (in_entry) { print "---ENTRY---" }
      in_entry = 1
      next
    }
    /^# / && !in_entry { next }
    in_entry { print }
    END {
      if (in_entry) print "---ENTRY---"
    }
  ' "$log_path"
}

# parse_promoted: extract the right-hand side of a Promoted line.
# Returns empty string if the line is absent or malformed (per grammar).
#
# Grammar (from spec):
#   PROMOTED_LINE := "- **Promoted**: " DATE " → " RHS
#   DATE          := YYYY-MM-DD
#   RHS           := AGENTS_FORM | HARNESS_FORM | CLOSURE_FORM | SUPERSEDE_FORM
parse_promoted() {
  local entry="$1"
  # Match: - **Promoted**: YYYY-MM-DD → <rhs>
  local re='^- \*\*Promoted\*\*: ([0-9]{4}-[0-9]{2}-[0-9]{2}) → (.+)$'
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      echo "${BASH_REMATCH[2]}"
      return 0
    fi
  done <<< "$entry"
  echo ""
}
