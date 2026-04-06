#!/usr/bin/env bash
# Secrets check — runs at session end (Stop hook).
#
# If gitleaks is installed and HARNESS.md has a deterministic
# "No secrets in source" constraint, scans the working directory
# for committed secrets and warns if any are found.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# If gitleaks is not installed, exit silently
if ! command -v gitleaks &>/dev/null; then
  exit 0
fi

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

# If the "No secrets in source" constraint is not deterministic, exit
if ! grep -A2 "No secrets in source" "$HARNESS_FILE" | grep -q "deterministic"; then
  exit 0
fi

# Run gitleaks against the working directory (no git history, fast)
if ! gitleaks detect --source "$PROJECT_DIR" --no-banner --no-git 2>&1; then
  message="Gitleaks detected potential secrets in the working directory. Run 'gitleaks detect --source . --no-banner --no-git' to see details. Rotate any real secrets immediately."
  printf '{"systemMessage": "%s"}' "${message//\"/\\\"}"
  exit 0
fi

# Clean scan — exit silently
exit 0
