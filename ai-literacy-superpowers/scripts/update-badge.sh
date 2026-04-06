#!/usr/bin/env bash
# Update the harness badge in README.md based on HARNESS.md Status section.
#
# Called by the harness-auditor agent after updating the Status section.
# Reads the enforcement ratio from HARNESS.md and updates (or inserts)
# the corresponding shields.io badge in README.md.
#
# Usage: bash update-badge.sh [project-dir]

set -euo pipefail

PROJECT_DIR="${1:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"
README_FILE="${PROJECT_DIR}/README.md"

if [ ! -f "$HARNESS_FILE" ]; then
  echo "[harness] No HARNESS.md found — skipping badge update"
  exit 0
fi

if [ ! -f "$README_FILE" ]; then
  echo "[harness] No README.md found — skipping badge update"
  exit 0
fi

# Parse enforcement ratio from Status section
enforced_line=$(grep -E '^Constraints enforced:' "$HARNESS_FILE" || echo "")
if [ -z "$enforced_line" ]; then
  echo "[harness] No enforcement ratio found in HARNESS.md Status section"
  exit 0
fi

# Extract N/M
ratio=$(echo "$enforced_line" | sed 's/Constraints enforced: *//' | tr -d '[:space:]')
numerator=$(echo "$ratio" | cut -d'/' -f1)
denominator=$(echo "$ratio" | cut -d'/' -f2)

# Calculate percentage
if [ "$denominator" -eq 0 ]; then
  pct=0
else
  pct=$(( (numerator * 100) / denominator ))
fi

# Determine colour
if [ "$pct" -eq 100 ]; then
  colour="2E8B57"  # green
elif [ "$pct" -ge 50 ]; then
  colour="4682B4"  # steel blue
elif [ "$pct" -ge 1 ]; then
  colour="DAA520"  # goldenrod
else
  colour="808080"  # grey
fi

# Check for drift
drift_line=$(grep -E '^Drift detected:' "$HARNESS_FILE" || echo "")
drift_suffix=""
if echo "$drift_line" | grep -qi "yes"; then
  drift_suffix="%20%E2%9A%A0%20drift"
fi

# URL-encode the ratio
encoded_ratio=$(echo "${numerator}/${denominator}" | sed 's|/|%2F|g')

# Build badge URL
badge_text="${encoded_ratio}_enforced${drift_suffix}"
badge_url="https://img.shields.io/badge/Harness-${badge_text}-${colour}?style=flat-square"
badge_md="[![Harness](${badge_url})](HARNESS.md)"

# Update or insert badge in README
if grep -q '\[!\[Harness\]' "$README_FILE"; then
  # Update existing badge
  sed -i.bak "s|\[!\[Harness\]([^]]*)\]([^)]*)|${badge_md}|" "$README_FILE"
  rm -f "${README_FILE}.bak"
  echo "[harness] Badge updated: ${numerator}/${denominator} enforced"
else
  # Insert after first line of badges (or at top)
  if head -5 "$README_FILE" | grep -q '\[!\['; then
    # Find last badge line and insert after it
    last_badge_line=$(grep -n '\[!\[' "$README_FILE" | tail -1 | cut -d: -f1)
    sed -i.bak "${last_badge_line}a\\
${badge_md}" "$README_FILE"
    rm -f "${README_FILE}.bak"
  else
    # No badges — insert after first heading
    sed -i.bak "1a\\
\\
${badge_md}" "$README_FILE"
    rm -f "${README_FILE}.bak"
  fi
  echo "[harness] Badge inserted: ${numerator}/${denominator} enforced"
fi
