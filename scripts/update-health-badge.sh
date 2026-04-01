#!/usr/bin/env bash
# Update the harness health badge and icon in README.md.
#
# Called by /harness-health after generating a snapshot. Reads the
# snapshot's Meta section to determine health status and updates the
# corresponding shields.io badge and icon link in README.md.
#
# Usage: bash update-health-badge.sh [project-dir] [snapshot-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
SNAPSHOT_FILE="${2:-}"
README_FILE="${PROJECT_DIR}/README.md"

if [ ! -f "$README_FILE" ]; then
  echo "[harness-health] No README.md found — skipping badge update"
  exit 0
fi

# Determine health status from snapshot
health_status="Healthy"
health_colour="2E8B57"  # green

if [ -n "$SNAPSHOT_FILE" ] && [ -f "$SNAPSHOT_FILE" ]; then
  # Check for overdue/stalled/silent/alert signals in Meta section
  meta_section=$(sed -n '/^## Meta$/,/^## /p' "$SNAPSHOT_FILE" | head -20)

  attention_signals=0
  if echo "$meta_section" | grep -qi "overdue"; then
    attention_signals=$((attention_signals + 1))
  fi
  if echo "$meta_section" | grep -qi "stalled"; then
    attention_signals=$((attention_signals + 1))
  fi
  if echo "$meta_section" | grep -qi "silent"; then
    attention_signals=$((attention_signals + 1))
  fi
  if echo "$meta_section" | grep -qiE "alert|declining"; then
    attention_signals=$((attention_signals + 1))
  fi

  if [ "$attention_signals" -ge 2 ]; then
    health_status="Degraded"
    health_colour="DC143C"  # crimson red
  elif [ "$attention_signals" -ge 1 ]; then
    health_status="Attention"
    health_colour="DAA520"  # goldenrod/amber
  fi

  # Also check enforcement ratio
  enforced_line=$(grep -E '^- Constraints:' "$SNAPSHOT_FILE" || echo "")
  if [ -n "$enforced_line" ]; then
    pct=$(echo "$enforced_line" | grep -oE '[0-9]+%' | tr -d '%')
    if [ -n "$pct" ] && [ "$pct" -lt 70 ]; then
      health_status="Degraded"
      health_colour="DC143C"
    fi
  fi
else
  # No snapshot provided — check if any snapshot exists
  SNAPSHOT_DIR="${PROJECT_DIR}/observability/snapshots"
  if [ ! -d "$SNAPSHOT_DIR" ] || [ -z "$(ls -A "$SNAPSHOT_DIR" 2>/dev/null)" ]; then
    health_status="Degraded"
    health_colour="DC143C"
  fi
fi

# Build badge URL
encoded_status=$(echo "$health_status" | sed 's/ /%20/g')
badge_url="https://img.shields.io/badge/Harness_Health-${encoded_status}-${health_colour}?style=flat-square"

# Determine snapshot link target
if [ -n "$SNAPSHOT_FILE" ]; then
  link_target="$SNAPSHOT_FILE"
else
  link_target="observability/snapshots/"
fi

badge_md="[![Harness Health](${badge_url})](${link_target})"

# Update or insert badge in README
if grep -q '\[!\[Harness Health\]' "$README_FILE"; then
  # Update existing badge
  sed -i.bak 's|\[!\[Harness Health\]([^]]*)\]([^)]*)|'"${badge_md}"'|' "$README_FILE"
  rm -f "${README_FILE}.bak"
  echo "[harness-health] Badge updated: ${health_status}"
else
  # Insert after harness badge if it exists, otherwise after last badge
  if grep -q '\[!\[Harness\]' "$README_FILE"; then
    harness_line=$(grep -n '\[!\[Harness\]' "$README_FILE" | head -1 | cut -d: -f1)
    sed -i.bak "${harness_line}a\\
${badge_md}" "$README_FILE"
    rm -f "${README_FILE}.bak"
  elif head -5 "$README_FILE" | grep -q '\[!\['; then
    last_badge_line=$(grep -n '\[!\[' "$README_FILE" | tail -1 | cut -d: -f1)
    sed -i.bak "${last_badge_line}a\\
${badge_md}" "$README_FILE"
    rm -f "${README_FILE}.bak"
  fi
  echo "[harness-health] Badge inserted: ${health_status}"
fi
