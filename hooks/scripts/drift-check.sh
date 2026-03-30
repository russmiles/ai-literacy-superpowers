#!/usr/bin/env bash
# Harness drift check — runs at session end (Stop hook).
#
# Checks whether files modified during this session suggest that
# HARNESS.md may need updating. Outputs a system message nudging
# the user to run /harness-audit if drift is likely.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

drift_signals=()

# Check if CI workflows were added or removed
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '\.github/workflows/|\.gitlab-ci\.yml|Jenkinsfile'; then
  drift_signals+=("CI workflow files were modified")
fi

# Check if linter configs were added or removed
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '\.(eslintrc|prettierrc|golangci|editorconfig|pylintrc)'; then
  drift_signals+=("Linter configuration files were modified")
fi

# Check if hook configs were added or removed
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '(\.husky/|\.pre-commit-config|hooks\.json)'; then
  drift_signals+=("Hook configuration files were modified")
fi

# Check if package manifests changed (new dependencies)
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '(go\.mod|package\.json|pom\.xml|requirements\.txt|.*\.csproj)'; then
  drift_signals+=("Dependency manifests were modified")
fi

if [ ${#drift_signals[@]} -gt 0 ]; then
  message="HARNESS.md may be out of date. Changes detected:"
  for signal in "${drift_signals[@]}"; do
    message="${message}\n- ${signal}"
  done
  message="${message}\nRun /harness-audit to check for drift."

  # Output as system message for Claude
  printf '{"systemMessage": "%s"}' "$(echo -e "$message" | sed 's/"/\\"/g')"
fi

exit 0
