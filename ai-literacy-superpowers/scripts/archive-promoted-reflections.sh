#!/usr/bin/env bash
# archive-promoted-reflections.sh
#
# Path 1 of the reflection-log archival design (spec
# 2026-04-30-reflection-log-archival-design.md):
# Move entries with a `Promoted` line from REFLECTION_LOG.md to
# reflections/archive/<YYYY>.md, file-by-original-year, ordered by
# archive timestamp.
#
# Usage:
#   archive-promoted-reflections.sh [--dry-run=true|false]
#
# Run from the project root.

set -euo pipefail

DRY_RUN="false"
for arg in "$@"; do
  case "$arg" in
    --dry-run=true) DRY_RUN="true" ;;
    --dry-run=false) DRY_RUN="false" ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/reflection-log-helpers.sh"

LOG="REFLECTION_LOG.md"
ARCHIVE_DIR="reflections/archive"
TODAY=$(date '+%Y-%m-%d')

[ -f "$LOG" ] || { echo "No $LOG in $(pwd); nothing to do." >&2; exit 0; }

mkdir -p "$ARCHIVE_DIR"

# Pass 1: identify entries to archive.
to_archive=()
to_keep=()
entry=""
while IFS= read -r line; do
  if [ "$line" = "---ENTRY---" ]; then
    rhs=$(parse_promoted "$entry")
    if [ -n "$rhs" ]; then
      if verify_rhs "$rhs"; then
        to_archive+=("$entry")
      else
        echo "WARN: Promoted line did not verify; skipping entry dated $(extract_field "$entry" "Date")" >&2
        to_keep+=("$entry")
      fi
    else
      to_keep+=("$entry")
    fi
    entry=""
  else
    entry+="${line}"$'\n'
  fi
done < <(split_entries "$LOG")

if [ "${#to_archive[@]}" -eq 0 ]; then
  echo "No promoted entries to archive."
  exit 0
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Would archive ${#to_archive[@]} entries (dry run)."
  exit 0
fi

# Pass 2: write archives (split by original year, append in archive-timestamp order).
for entry in "${to_archive[@]}"; do
  year=$(resolve_year "$entry")
  archive_path="$ARCHIVE_DIR/$year.md"
  if [ ! -f "$archive_path" ]; then
    {
      echo "# Reflection Archive — $year"
      echo ""
      echo "Entries archived from \`REFLECTION_LOG.md\` after promotion."
      echo ""
    } > "$archive_path"
  fi
  {
    echo "---"
    echo ""
    printf '%s' "$entry"
    echo "- **Archived**: $TODAY (auto, Path 1)"
    echo ""
  } >> "$archive_path"
done

# Pass 3: rewrite the active log with kept entries.
{
  echo "# Reflection Log"
  echo ""
  if [ "${#to_keep[@]}" -gt 0 ]; then
    for entry in "${to_keep[@]}"; do
      echo "---"
      echo ""
      printf '%s' "$entry"
      echo ""
    done
  fi
} > "$LOG"

echo "Archived ${#to_archive[@]} entries; ${#to_keep[@]} entries remain in $LOG."
