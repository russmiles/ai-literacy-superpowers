#!/usr/bin/env bash
# Reflection prompt — runs at session end (Stop hook).
#
# Checks whether commits were made during this session. If so,
# nudges the user to run /reflect to capture learnings. This closes
# the gap between pipeline work (where the integration-agent captures
# reflections automatically) and direct work (where reflections are
# otherwise lost).
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
REFLECTION_LOG="${PROJECT_DIR}/REFLECTION_LOG.md"

# If no REFLECTION_LOG.md exists, nothing to prompt about
if [ ! -f "$REFLECTION_LOG" ]; then
  exit 0
fi

# Count commits made in the last 4 hours (approximate session length)
commit_count=$(git log --oneline --since="4 hours ago" 2>/dev/null | wc -l | tr -d ' ')

if [ "$commit_count" -gt 0 ]; then
  message="You made ${commit_count} commit(s) this session. Run /reflect to capture learnings for REFLECTION_LOG.md before they evaporate."

  # Output as system message for Claude
  printf '{"systemMessage": "%s"}' "$message"
fi

exit 0
