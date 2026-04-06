#!/usr/bin/env bash
# Harness snapshot staleness check — runs at session end (Stop hook).
#
# Checks whether the most recent health snapshot is older than 30 days.
# Outputs a system message nudging the user to run /harness-health if
# the snapshot is stale or missing.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SNAPSHOT_DIR="${PROJECT_DIR}/observability/snapshots"

# If no snapshot directory exists, nothing to check
if [ ! -d "$SNAPSHOT_DIR" ]; then
  exit 0
fi

# Find the most recent snapshot by filename
latest=$(ls -1 "$SNAPSHOT_DIR"/*-snapshot.md 2>/dev/null | sort -r | head -1)

if [ -z "$latest" ]; then
  # Directory exists but no snapshots yet — nudge first snapshot
  printf '{"systemMessage": "No harness health snapshots found. Run /harness-health to create the first baseline snapshot."}'
  exit 0
fi

# Extract date from filename (YYYY-MM-DD-snapshot.md)
filename=$(basename "$latest")
snapshot_date="${filename%-snapshot.md}"

# Calculate age in days
if date -d "$snapshot_date" >/dev/null 2>&1; then
  # GNU date
  snapshot_epoch=$(date -d "$snapshot_date" +%s)
else
  # macOS date
  snapshot_epoch=$(date -j -f "%Y-%m-%d" "$snapshot_date" +%s 2>/dev/null || exit 0)
fi

current_epoch=$(date +%s)
age_days=$(( (current_epoch - snapshot_epoch) / 86400 ))

if [ "$age_days" -gt 30 ]; then
  printf '{"systemMessage": "Harness health snapshot is %d days old (last: %s). Run /harness-health to update."}' "$age_days" "$snapshot_date"
fi

exit 0
