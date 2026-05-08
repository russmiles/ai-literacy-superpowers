#!/usr/bin/env bash
#
# check-redirect-sunsets.sh — implements the Redirect sunset GC rule.
#
# Scans the given directory tree for markdown files containing a
# redirect-sunset: YYYY-MM-DD marker whose date is in the past.
# The marker may appear as a YAML comment (# redirect-sunset: YYYY-MM-DD)
# or an HTML comment (<!-- redirect-sunset: YYYY-MM-DD -->).
# Reports each finding on stdout. Exits 0 if no findings, 1 if findings
# exist, 2 on usage or environment error.
#
# Usage: check-redirect-sunsets.sh [directory]
# Defaults to docs/plugins when called from the repo root.

set -euo pipefail

target="${1:-docs/plugins}"

if [[ ! -d "$target" ]]; then
  echo "Error: directory not found: $target" >&2
  exit 2
fi

today="$(date +%Y-%m-%d)"
findings=0

while IFS= read -r -d '' file; do
  # Extract the date from the marker line. The marker format may be either:
  #   # redirect-sunset: YYYY-MM-DD          (YAML frontmatter comment)
  #   <!-- redirect-sunset: YYYY-MM-DD -->   (HTML comment)
  marker_date="$(grep -oE 'redirect-sunset: [0-9]{4}-[0-9]{2}-[0-9]{2}' "$file" \
    | head -1 \
    | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"

  if [[ -z "$marker_date" ]]; then
    continue
  fi

  if [[ "$marker_date" < "$today" ]]; then
    echo "$file: redirect sunset $marker_date has passed (today: $today)"
    findings=$((findings + 1))
  fi
done < <(find "$target" -type f -name "*.md" -print0)

if [[ "$findings" -gt 0 ]]; then
  echo "Total findings: $findings"
  exit 1
fi

exit 0
