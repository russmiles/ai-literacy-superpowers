#!/usr/bin/env bash
# Governance drift check — runs at session end (Stop hook).
#
# Checks whether governance-related files were modified during this
# session and whether the last governance audit is stale. Outputs a
# system message nudging the user to run /governance-audit if needed.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"
GOVERNANCE_DIR="${PROJECT_DIR}/observability/governance"

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

governance_signals=()

# Check if HARNESS.md was modified with governance-related content
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -q 'HARNESS.md'; then
  if git diff HEAD~1 HEAD -- HARNESS.md 2>/dev/null | grep -qiE '(governance|oversight|compliance|fairness|transparency|accountability|regulation)'; then
    governance_signals+=("HARNESS.md governance constraints were modified")
  fi
fi

# Check if compliance or policy documents were modified
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qiE '(compliance|policy|governance|regulation)'; then
  governance_signals+=("Compliance or policy documents were modified")
fi

# Check audit staleness (if governance directory exists)
if [ -d "$GOVERNANCE_DIR" ]; then
  latest_audit=$(find "$GOVERNANCE_DIR" -name "audit-*.md" -type f 2>/dev/null | sort -r | head -1)
  if [ -n "$latest_audit" ]; then
    audit_date=$(basename "$latest_audit" | sed 's/audit-\(.*\)\.md/\1/')
    if [ -n "$audit_date" ]; then
      audit_epoch=$(date -j -f "%Y-%m-%d" "$audit_date" "+%s" 2>/dev/null || echo "0")
      now_epoch=$(date "+%s")
      days_old=$(( (now_epoch - audit_epoch) / 86400 ))
      if [ "$days_old" -gt 90 ]; then
        governance_signals+=("Last governance audit is ${days_old} days old (threshold: 90 days)")
      fi
    fi
  fi
elif grep -qiE '(governance requirement|governance language|frame check)' "$HARNESS_FILE" 2>/dev/null; then
  governance_signals+=("Governance constraints exist but no audit has been run yet")
fi

if [ ${#governance_signals[@]} -gt 0 ]; then
  message="Governance health check needed. Signals detected:"
  for signal in "${governance_signals[@]}"; do
    message="${message}\n- ${signal}"
  done
  message="${message}\nRun /governance-audit for a full investigation or /governance-health for a quick pulse check."

  printf '{"systemMessage": "%s"}' "$(echo -e "$message" | sed 's/"/\\"/g')"
fi

exit 0
