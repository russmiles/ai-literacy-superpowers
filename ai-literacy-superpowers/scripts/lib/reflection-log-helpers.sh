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
      local rhs="${BASH_REMATCH[2]}"
      # Trim trailing whitespace — protects downstream grep verification
      # against curator typos that add invisible trailing spaces.
      rhs="${rhs%"${rhs##*[![:space:]]}"}"
      echo "$rhs"
      return 0
    fi
  done <<< "$entry"
  echo ""
}

# extract_field: emit the value of "- **<name>**: <value>" line.
# Returns empty if absent.
extract_field() {
  local entry="$1"
  local name="$2"
  local re="^- \*\*${name}\*\*: (.+)$"
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
  done <<< "$entry"
  echo ""
}

# resolve_year: extract YYYY from the entry's Date field.
resolve_year() {
  local entry="$1"
  local date; date=$(extract_field "$entry" "Date")
  echo "${date%%-*}"
}

# bounded_entries: return entries within the more inclusive of:
#   - the last N entries (by Date field, descending)
#   - entries within the last M days
# Output uses the same `---ENTRY---` separator as split_entries.
bounded_entries() {
  local log_path="$1"
  local max_count="$2"
  local max_days="$3"
  local cutoff_epoch
  cutoff_epoch=$(date -j -v-"${max_days}"d '+%s' 2>/dev/null || date -d "-${max_days} days" '+%s')

  local entries; entries=$(split_entries "$log_path")
  local entry=""

  # Collect candidate entries with their dates; sort descending; clip by max_count
  # but include any entry whose date is newer than cutoff regardless.
  local tmpfile; tmpfile=$(mktemp)
  while IFS= read -r line; do
    if [ "$line" = "---ENTRY---" ]; then
      local entry_date entry_epoch
      entry_date=$(extract_field "$entry" "Date")
      entry_epoch=$(date -j -f '%Y-%m-%d' "$entry_date" '+%s' 2>/dev/null \
                    || date -d "$entry_date" '+%s')
      printf '%s\t%s\n' "$entry_epoch" "$entry" >> "$tmpfile"
      entry=""
    else
      entry+="${line}"$'\n'
    fi
  done <<< "$entries"

  # Sort descending by epoch, then output more inclusive of count or day window.
  sort -t $'\t' -k1,1nr "$tmpfile" | awk -F '\t' \
    -v max_count="$max_count" -v cutoff="$cutoff_epoch" '
    {
      epoch = $1
      gsub(/\\n/, "\n", $2)
      if (NR <= max_count || epoch >= cutoff) {
        print $2
        print "---ENTRY---"
      }
    }'
  rm -f "$tmpfile"
}
