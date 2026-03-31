#!/usr/bin/env bash
# Framework change prompt — runs at session end (Stop hook).
#
# Checks whether framework/framework.md was modified during this session.
# If so, nudges three actions:
#   1. Run /reflect to capture learnings
#   2. Run /sync-repos to roll out changes to downstream repos
#   3. Check whether downstream READMEs need updating
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FRAMEWORK_FILE="${PROJECT_DIR}/framework/framework.md"

# If no framework.md exists, nothing to check
if [ ! -f "$FRAMEWORK_FILE" ]; then
  exit 0
fi

# Check if framework.md was modified in commits made in the last 4 hours
framework_changed=$(git log --oneline --since="4 hours ago" -- framework/framework.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$framework_changed" -gt 0 ]; then
  message="framework.md was modified in ${framework_changed} commit(s) this session. Three actions needed:"
  message="${message}\n1. Run /reflect to capture what changed and why"
  message="${message}\n2. Run /sync-repos to roll out changes to ai-literacy-superpowers and ai-literacy-exemplar"
  message="${message}\n3. Check whether downstream READMEs need updating (new themes, appendices, or cross-cutting concepts)"

  printf '{"systemMessage": "%s"}' "$(echo -e "$message" | sed 's/"/\\"/g')"
fi

exit 0
