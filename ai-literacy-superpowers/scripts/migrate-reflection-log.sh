#!/usr/bin/env bash
# migrate-reflection-log.sh
#
# One-off migration helper. Reads existing REFLECTION_LOG.md entries and
# proposes Promoted-line tags by cross-referencing against AGENTS.md and
# HARNESS.md. Curator reviews proposals and applies confirmed tags.
#
# Self-skips on re-run if reflections/migration-proposals.md exists.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/reflection-log-helpers.sh"

LOG="REFLECTION_LOG.md"
PROPOSALS="reflections/migration-proposals.md"
AGE_THRESHOLD_DAYS=180  # 6 months default
TODAY=$(date '+%Y-%m-%d')
export TODAY

[ -f "$LOG" ] || { echo "No $LOG in $(pwd); nothing to do." >&2; exit 0; }

if [ -f "$PROPOSALS" ]; then
  echo "$PROPOSALS already exists; migration helper has run before. Skipping."
  exit 0
fi

mkdir -p reflections

{
  echo "# Reflection-log Migration Proposals"
  echo ""
  echo "Generated $TODAY by \`scripts/migrate-reflection-log.sh\`."
  echo ""
  echo "Each entry below is a proposal. Review and either:"
  echo ""
  echo "1. Confirm by adding the proposed Promoted line to the source entry"
  echo "   in REFLECTION_LOG.md and committing."
  echo "2. Edit the proposal before applying."
  echo "3. Reject by leaving the source entry untouched."
  echo ""
  echo "Path 1 will archive any tagged entries on its next weekly run."
  echo ""
} > "$PROPOSALS"

cutoff_epoch=$(date -j -v-"${AGE_THRESHOLD_DAYS}"d '+%s' 2>/dev/null \
              || date -d "-${AGE_THRESHOLD_DAYS} days" '+%s')

# Capture split_entries output first to avoid SIGPIPE under pipefail
# when propose_for_entry's downstream grep short-circuits.
entries=$(split_entries "$LOG")

entry=""
while IFS= read -r line; do
  if [ "$line" = "---ENTRY---" ]; then
    propose_for_entry "$entry" "$cutoff_epoch" >> "$PROPOSALS"
    entry=""
  else
    entry+="${line}"$'\n'
  fi
done <<< "$entries"

echo "Proposals written to $PROPOSALS."
