#!/usr/bin/env bash
# Curation nudge — runs at session end (Stop hook).
#
# Checks whether REFLECTION_LOG.md has entries that have not yet been
# reviewed for promotion to AGENTS.md. The compound learning lifecycle
# is: reflect -> curate -> benefit. Without curation, reflections
# accumulate but never improve future sessions.
#
# Heuristic: if REFLECTION_LOG.md has more date entries than AGENTS.md
# has bullet points in GOTCHAS + ARCH_DECISIONS + STYLE, curation is
# likely overdue.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
REFLECTION_LOG="${PROJECT_DIR}/REFLECTION_LOG.md"
AGENTS_FILE="${PROJECT_DIR}/AGENTS.md"

# If no REFLECTION_LOG.md exists, nothing to check
if [ ! -f "$REFLECTION_LOG" ]; then
  exit 0
fi

# Count reflection entries (lines starting with "- **Date**:")
reflection_count=$(grep -c '^\- \*\*Date\*\*:' "$REFLECTION_LOG" 2>/dev/null) || reflection_count=0

# If no reflections, nothing to curate
if [ "$reflection_count" -eq 0 ]; then
  exit 0
fi

# If no AGENTS.md exists, all reflections are unpromoted
if [ ! -f "$AGENTS_FILE" ]; then
  printf '{"systemMessage": "%d reflection(s) in REFLECTION_LOG.md but no AGENTS.md exists. Create AGENTS.md and curate learnings into GOTCHAS, STYLE, and ARCH_DECISIONS sections."}' "$reflection_count"
  exit 0
fi

# Count promoted entries (non-comment bullet points in content sections)
# Filter out HTML comments and count actual content bullets
promoted_count=$(sed '/^<!--/,/-->$/d' "$AGENTS_FILE" | grep -c '^- ' 2>/dev/null) || promoted_count=0

# If reflections significantly outnumber promoted entries, nudge
unpromoted=$((reflection_count - promoted_count))
if [ "$unpromoted" -gt 2 ]; then
  printf '{"systemMessage": "%d reflection(s) in REFLECTION_LOG.md, %d entries in AGENTS.md. %d reflection(s) may need curation. Review REFLECTION_LOG.md and promote patterns to AGENTS.md."}' "$reflection_count" "$promoted_count" "$unpromoted"
fi

exit 0
