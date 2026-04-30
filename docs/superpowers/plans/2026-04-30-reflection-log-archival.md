# Reflection Log Archival Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement promotion-aware archival of `REFLECTION_LOG.md` with read-side filtering as immediate cost cap, deterministic auto-archive of promoted entries (Path 1), agent-augmented aged-out review (Path 2), opt-in graceful degradation, and a migration helper for the one-off backfill.

**Architecture:** Three complementary mechanisms — read-side filtering bounds default reader intake; a deterministic shell script archives entries carrying explicit `Promoted` lines (Path 1); a `harness-gc` agent rule emits evidence (not labels) for unpromoted aged entries (Path 2). Schema change is additive (one optional `Promoted:` line per entry, formal-grammar parseable). Archive lives at `reflections/archive/<YYYY>.md`, file-by-original-year, ordered-by-archive-time. Path 2 is opt-in via HARNESS.md so disengaged adopters degrade silently to today's behaviour plus read-side filtering.

**Tech Stack:** Bash (with `set -euo pipefail` strict mode and ShellCheck), markdown (agent prompts, templates, skill files), GitHub Actions YAML (gc.yml). No new runtime dependencies.

**Test approach:** Shell scripts use plain-bash assertion tests with fixture files (no framework dep). Agent / template / skill / command markdown files are visual-review against a spec checklist plus markdownlint. Migration is end-to-end-tested against this repo's actual `REFLECTION_LOG.md` as the final integration test.

**Spec reference:** [`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`](../specs/2026-04-30-reflection-log-archival-design.md). Adjudicated objection record at [`docs/superpowers/objections/reflection-log-archival-design.md`](../objections/reflection-log-archival-design.md). Adjudicated choice-story record at [`docs/superpowers/stories/reflection-log-archival-design.md`](../stories/reflection-log-archival-design.md).

---

## Phase 1: Shared library + fixtures (foundation)

### Task 1: Create shared shell library skeleton

**Files:**

- Create: `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh`
- Create: `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-empty.md`
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-single-entry.md`

- [ ] **Step 1: Write the failing test for `split_entries`**

Create `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Test harness for reflection-log-helpers.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_PATH="$SCRIPT_DIR/../scripts/lib/reflection-log-helpers.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# shellcheck source=/dev/null
source "$LIB_PATH"

# Simple assertion helpers
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_eq() { [ "$1" = "$2" ] || fail "expected '$2' got '$1'"; }

test_split_entries_on_empty_log() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-empty.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "0"
}

test_split_entries_on_single_entry() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-single-entry.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "1"
}

test_split_entries_on_empty_log
test_split_entries_on_single_entry
echo "All tests passed."
```

Create the two fixture files:

`ai-literacy-superpowers/tests/fixtures/reflection-log-empty.md`:

```markdown
# Reflection Log

```

`ai-literacy-superpowers/tests/fixtures/reflection-log-single-entry.md`:

```markdown
# Reflection Log

---

- **Date**: 2026-01-15
- **Agent**: claude-opus-4-7[1m]
- **Task**: Sample task for fixture
- **Surprise**: Sample surprise.
- **Proposal**: none
- **Improvement**: none
- **Signal**: none
- **Constraint**: none
- **Session metadata**:
  - Duration: ~10 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: FAIL with `split_entries: command not found` (the function doesn't exist yet).

- [ ] **Step 3: Write minimal implementation**

Create `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh`:

```bash
#!/usr/bin/env bash
# reflection-log-helpers.sh
#
# Shared helpers for reflection-log archival scripts.
# Sourced by archive-promoted-reflections.sh, migrate-reflection-log.sh,
# and read-side filtering callers.
#
# Functions defined here:
# - split_entries <log-path>      → emit each entry preceded by `---ENTRY---`
# - parse_promoted <entry-text>   → echo Promoted RHS or empty if absent
# - extract_field <entry> <name>  → echo the value of `- **<name>**: ...`
# - bounded_entries <log> <n> <m> → return entries within last n OR last m days
# - resolve_year <entry-text>     → echo YYYY from the entry's Date field

set -euo pipefail

# split_entries: emit log entries one at a time, separated by `---ENTRY---`
# markers (so callers can iterate without running awk per call).
split_entries() {
  local log_path="$1"
  awk '
    /^---$/ {
      if (in_entry) { print "---ENTRY---" }
      in_entry = 1
      next
    }
    /^# / && !in_entry { next }
    in_entry { print }
    END {
      if (in_entry) print "---ENTRY---"
    }
  ' "$log_path"
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: `All tests passed.`

- [ ] **Step 5: Verify ShellCheck and strict-mode compliance**

Run:

```bash
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
shellcheck ai-literacy-superpowers/tests/test-reflection-log-helpers.sh
head -15 ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh | grep -q 'set -euo pipefail'
head -15 ai-literacy-superpowers/tests/test-reflection-log-helpers.sh | grep -q 'set -euo pipefail'
```

Expected: no shellcheck output, both `grep -q` exit 0.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/fixtures/reflection-log-empty.md \
        ai-literacy-superpowers/tests/fixtures/reflection-log-single-entry.md
git commit -m "feat(reflection-archival): scaffold shared helpers + fixtures (split_entries)"
```

---

### Task 2: Add `parse_promoted` and the formal grammar

**Files:**

- Modify: `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh` (append)
- Modify: `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh` (append)
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-promoted-agents.md`
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-promoted-harness.md`
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-promoted-aged-out.md`
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-promoted-malformed.md`

- [ ] **Step 1: Write the failing tests for `parse_promoted`**

Append to `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`:

```bash
test_parse_promoted_agents_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-agents.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "AGENTS.md STYLE: \"Multi-repo scheduled agents\""
}
test_parse_promoted_harness_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-harness.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "HARNESS.md: Reflections via PR workflow"
}
test_parse_promoted_aged_out_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-aged-out.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "aged-out, no promotion warranted"
}
test_parse_promoted_absent() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}
test_parse_promoted_malformed_returns_empty() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-malformed.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}

test_parse_promoted_agents_form
test_parse_promoted_harness_form
test_parse_promoted_aged_out_form
test_parse_promoted_absent
test_parse_promoted_malformed_returns_empty
```

Create the four new fixtures (single entry each, with the relevant `Promoted` line). For `reflection-log-promoted-agents.md`:

```markdown
- **Date**: 2026-04-30
- **Agent**: claude-opus-4-7[1m]
- **Task**: Sample
- **Surprise**: Sample
- **Proposal**: Sample
- **Improvement**: Sample
- **Signal**: workflow
- **Constraint**: none
- **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
- **Session metadata**:
  - Duration: ~10 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
```

For `-promoted-harness.md`, change the Promoted line to `- **Promoted**: 2026-05-15 → HARNESS.md: Reflections via PR workflow`.

For `-promoted-aged-out.md`: `- **Promoted**: 2026-05-15 → aged-out, no promotion warranted`.

For `-promoted-malformed.md`: `- **Promoted**: not-a-date → garbage` (deliberately fails the grammar).

- [ ] **Step 2: Run test to verify it fails**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: FAIL with `parse_promoted: command not found`.

- [ ] **Step 3: Write the implementation**

Append to `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh`:

```bash
# parse_promoted: extract the right-hand side of a Promoted line.
# Returns empty string if the line is absent or malformed (per grammar).
#
# Grammar (from spec):
#   PROMOTED_LINE := "- **Promoted**: " DATE " → " RHS
#   DATE          := YYYY-MM-DD
#   RHS           := AGENTS_FORM | HARNESS_FORM | CLOSURE_FORM | SUPERSEDE_FORM
parse_promoted() {
  local entry="$1"
  # Match: - **Promoted**: YYYY-MM-DD → <rhs>
  local re='^- \*\*Promoted\*\*: ([0-9]{4}-[0-9]{2}-[0-9]{2}) → (.+)$'
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      echo "${BASH_REMATCH[2]}"
      return 0
    fi
  done <<< "$entry"
  echo ""
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: `All tests passed.`

- [ ] **Step 5: ShellCheck**

Run:

```bash
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/fixtures/reflection-log-promoted-*.md
git commit -m "feat(reflection-archival): parse_promoted with formal grammar"
```

---

### Task 3: Add `extract_field` and `resolve_year`

**Files:**

- Modify: `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh` (append)
- Modify: `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh` (append)

- [ ] **Step 1: Write failing tests**

Append to `tests/test-reflection-log-helpers.sh`:

```bash
test_extract_field_date() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local val; val=$(extract_field "$entry" "Date")
  assert_eq "$val" "2026-01-15"
}
test_extract_field_signal() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-agents.md")
  local val; val=$(extract_field "$entry" "Signal")
  assert_eq "$val" "workflow"
}
test_resolve_year() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local year; year=$(resolve_year "$entry")
  assert_eq "$year" "2026"
}

test_extract_field_date
test_extract_field_signal
test_resolve_year
```

- [ ] **Step 2: Run to verify failure**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: FAIL with `extract_field: command not found`.

- [ ] **Step 3: Implement**

Append to `scripts/lib/reflection-log-helpers.sh`:

```bash
# extract_field: emit the value of "- **<name>**: <value>" line.
# Returns empty if absent.
extract_field() {
  local entry="$1"
  local name="$2"
  local re="^- \*\*${name}\*\*: (.+)$"
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
  done <<< "$entry"
  echo ""
}

# resolve_year: extract YYYY from the entry's Date field.
resolve_year() {
  local entry="$1"
  local date; date=$(extract_field "$entry" "Date")
  echo "${date%%-*}"
}
```

- [ ] **Step 4: Run to verify pass**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: `All tests passed.`

- [ ] **Step 5: ShellCheck and commit**

Run:

```bash
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
git add ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-reflection-log-helpers.sh
git commit -m "feat(reflection-archival): extract_field + resolve_year"
```

---

### Task 4: Add `bounded_entries` for read-side filtering

**Files:**

- Modify: `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh` (append)
- Modify: `ai-literacy-superpowers/tests/test-reflection-log-helpers.sh` (append)
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-many-entries.md`

- [ ] **Step 1: Create the multi-entry fixture**

Create `tests/fixtures/reflection-log-many-entries.md` with 60 entries, dated daily from 2026-02-01 to 2026-04-01. Use a small generator:

```bash
{
  echo "# Reflection Log"
  echo ""
  for i in $(seq 0 59); do
    date=$(date -j -v+"${i}"d -f '%Y-%m-%d' '2026-02-01' '+%Y-%m-%d')
    cat <<ENTRY

---

- **Date**: $date
- **Agent**: claude-opus-4-7[1m]
- **Task**: Synthetic entry $i
- **Surprise**: Synthetic
- **Proposal**: none
- **Improvement**: none
- **Signal**: none
- **Constraint**: none
- **Session metadata**:
  - Duration: ~5 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
ENTRY
  done
} > ai-literacy-superpowers/tests/fixtures/reflection-log-many-entries.md
```

- [ ] **Step 2: Write the failing test**

Append to `tests/test-reflection-log-helpers.sh`:

```bash
test_bounded_entries_count_is_inclusive_of_max() {
  # 60 synthetic entries; ask for last 50 OR last 1000 days. Day window dominates → 60.
  local count
  count=$(bounded_entries "$FIXTURES_DIR/reflection-log-many-entries.md" 50 1000 \
          | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "60"
}
test_bounded_entries_day_window_clips() {
  # 60 entries Feb-Apr; ask for last 50 entries OR 7 days from "today" (2026-04-30).
  # Most recent entry is 2026-04-01, all 60 are >7 days old, but count window says 50.
  local count
  count=$(bounded_entries "$FIXTURES_DIR/reflection-log-many-entries.md" 50 7 \
          | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "50"
}

test_bounded_entries_count_is_inclusive_of_max
test_bounded_entries_day_window_clips
```

- [ ] **Step 3: Run to verify failure**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: FAIL with `bounded_entries: command not found`.

- [ ] **Step 4: Implement**

Append to `scripts/lib/reflection-log-helpers.sh`:

```bash
# bounded_entries: return entries within the more inclusive of:
#   - the last N entries (by Date field, descending)
#   - entries within the last M days
# Output uses the same `---ENTRY---` separator as split_entries.
bounded_entries() {
  local log_path="$1"
  local max_count="$2"
  local max_days="$3"
  local cutoff_epoch
  cutoff_epoch=$(date -j -v-"${max_days}"d '+%s' 2>/dev/null || date -d "-${max_days} days" '+%s')

  local entries; entries=$(split_entries "$log_path")
  local entry=""
  local kept_count=0
  local lines_buffer=""

  # Collect candidate entries with their dates; sort descending; clip by max_count
  # but include any entry whose date is newer than cutoff regardless.
  local tmpfile; tmpfile=$(mktemp)
  while IFS= read -r line; do
    if [ "$line" = "---ENTRY---" ]; then
      local entry_date entry_epoch
      entry_date=$(extract_field "$entry" "Date")
      entry_epoch=$(date -j -f '%Y-%m-%d' "$entry_date" '+%s' 2>/dev/null \
                    || date -d "$entry_date" '+%s')
      printf '%s\t%s\n' "$entry_epoch" "$entry" >> "$tmpfile"
      entry=""
    else
      entry+="${line}"$'\n'
    fi
  done <<< "$entries"

  # Sort descending by epoch, then output more inclusive of count or day window.
  sort -t $'\t' -k1,1nr "$tmpfile" | awk -F '\t' \
    -v max_count="$max_count" -v cutoff="$cutoff_epoch" '
    {
      epoch = $1
      gsub(/\\n/, "\n", $2)
      if (NR <= max_count || epoch >= cutoff) {
        print $2
        print "---ENTRY---"
      }
    }'
  rm -f "$tmpfile"
}
```

- [ ] **Step 5: Run to verify pass**

Run: `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
Expected: `All tests passed.`

- [ ] **Step 6: ShellCheck and commit**

```bash
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
git add ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/fixtures/reflection-log-many-entries.md
git commit -m "feat(reflection-archival): bounded_entries (read-side filtering)"
```

---

## Phase 2: Path 1 — auto-archive of promoted entries

### Task 5: Path 1 script — happy-path archive of an AGENTS.md-promoted entry

**Files:**

- Create: `ai-literacy-superpowers/scripts/archive-promoted-reflections.sh`
- Create: `ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh`
- Create: `ai-literacy-superpowers/tests/fixtures/agents-md-with-multi-repo-style.md`

- [ ] **Step 1: Write the failing test**

Create `ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/../scripts/archive-promoted-reflections.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { grep -q "$2" "$1" || fail "expected '$2' in $1"; }
assert_not_contains() { ! grep -q "$2" "$1" || fail "did not expect '$2' in $1"; }
assert_file_exists() { [ -f "$1" ] || fail "expected file $1"; }

setup_workspace() {
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT
  cp "$FIXTURES/reflection-log-promoted-agents.md" "$WORK_DIR/REFLECTION_LOG.md"
  cp "$FIXTURES/agents-md-with-multi-repo-style.md" "$WORK_DIR/AGENTS.md"
  : > "$WORK_DIR/HARNESS.md"
  mkdir -p "$WORK_DIR/reflections/archive"
}

test_happy_path_archives_agents_promoted_entry() {
  setup_workspace
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "Multi-repo scheduled agents"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "**Archived**:"
  assert_not_contains "$WORK_DIR/REFLECTION_LOG.md" "Multi-repo scheduled agents"
}

test_happy_path_archives_agents_promoted_entry
echo "All tests passed."
```

Create `tests/fixtures/agents-md-with-multi-repo-style.md`:

```markdown
# AGENTS.md

## STYLE

### Multi-repo scheduled agents

When one operational concern spans multiple repos, prefer ONE multi-source
scheduled agent over N single-source agents.
```

- [ ] **Step 2: Run to verify failure**

Run: `bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh`
Expected: FAIL with `No such file or directory` for the script.

- [ ] **Step 3: Implement the script**

Create `ai-literacy-superpowers/scripts/archive-promoted-reflections.sh`:

```bash
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
# shellcheck source=lib/reflection-log-helpers.sh
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
      # Verify that the right-hand side resolves to actual content
      # (Path 1 pre-archive verification per spec O7).
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
  for entry in "${to_keep[@]}"; do
    echo "---"
    echo ""
    printf '%s' "$entry"
    echo ""
  done
} > "$LOG"

echo "Archived ${#to_archive[@]} entries; ${#to_keep[@]} entries remain in $LOG."
```

Append a `verify_rhs` helper to `scripts/lib/reflection-log-helpers.sh`:

```bash
# verify_rhs: return 0 if the Promoted line's right-hand side resolves to
# actual content in the current tree (AGENTS.md / HARNESS.md) or is a
# closure form. Return 1 otherwise.
verify_rhs() {
  local rhs="$1"
  case "$rhs" in
    AGENTS.md*\"*\")
      local quoted; quoted=$(echo "$rhs" | sed -E 's/^.*"(.*)".*$/\1/')
      [ -f AGENTS.md ] && grep -qF "$quoted" AGENTS.md
      ;;
    HARNESS.md:*)
      local cname; cname=$(echo "$rhs" | sed -E 's/^HARNESS.md:[[:space:]]*//')
      [ -f HARNESS.md ] && grep -qF "### $cname" HARNESS.md
      ;;
    aged-out*|"no promotion"*|superseded\ by\ *)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
```

- [ ] **Step 4: Run to verify pass**

Run:

```bash
chmod +x ai-literacy-superpowers/scripts/archive-promoted-reflections.sh
bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh
```

Expected: both `All tests passed.`

- [ ] **Step 5: ShellCheck**

```bash
shellcheck ai-literacy-superpowers/scripts/archive-promoted-reflections.sh
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
shellcheck ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/scripts/archive-promoted-reflections.sh \
        ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh \
        ai-literacy-superpowers/tests/fixtures/agents-md-with-multi-repo-style.md
git commit -m "feat(reflection-archival): Path 1 happy path (AGENTS.md promotion)"
```

---

### Task 6: Path 1 — verification skip for unresolved RHS

**Files:**

- Modify: `ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh` (append test)

- [ ] **Step 1: Write the failing test**

Append to `tests/test-archive-promoted-reflections.sh`:

```bash
test_skips_when_agents_content_missing() {
  setup_workspace
  # Replace AGENTS.md with one that does NOT contain "Multi-repo scheduled agents"
  echo "# AGENTS.md (empty)" > "$WORK_DIR/AGENTS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false 2>&1 ) | grep -q "did not verify"
  # The entry should remain in REFLECTION_LOG.md
  assert_contains "$WORK_DIR/REFLECTION_LOG.md" "Multi-repo scheduled agents"
}

test_skips_when_agents_content_missing
```

- [ ] **Step 2: Run to verify failure**

Run: `bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh`
Expected: pass — the implementation already includes verification (Task 5). If the test passes, that's correct (the verification logic exists). If it fails, fix `verify_rhs`.

- [ ] **Step 3: If test fails, fix `verify_rhs`**

(Most likely passes; this task documents the verification path.)

- [ ] **Step 4: Run all tests**

```bash
bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
```

Expected: `All tests passed.`

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
git commit -m "test(reflection-archival): cover unverified RHS skip path"
```

---

### Task 7: Path 1 — closure forms, supersede, and HARNESS path

**Files:**

- Modify: `ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh` (append tests)

- [ ] **Step 1: Write failing tests for closure + harness + supersede forms**

Append to `tests/test-archive-promoted-reflections.sh`:

```bash
test_archives_aged_out_form() {
  setup_workspace
  cp "$FIXTURES/reflection-log-promoted-aged-out.md" "$WORK_DIR/REFLECTION_LOG.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "aged-out"
}

test_archives_harness_form_when_constraint_present() {
  setup_workspace
  cp "$FIXTURES/reflection-log-promoted-harness.md" "$WORK_DIR/REFLECTION_LOG.md"
  echo "### Reflections via PR workflow" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "Reflections via PR workflow"
}

test_skips_harness_form_when_constraint_missing() {
  setup_workspace
  cp "$FIXTURES/reflection-log-promoted-harness.md" "$WORK_DIR/REFLECTION_LOG.md"
  echo "# HARNESS.md (empty)" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false 2>&1 ) | grep -q "did not verify"
  assert_contains "$WORK_DIR/REFLECTION_LOG.md" "Reflections via PR workflow"
}

test_archives_aged_out_form
test_archives_harness_form_when_constraint_present
test_skips_harness_form_when_constraint_missing
```

- [ ] **Step 2: Run all tests**

```bash
bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
```

Expected: `All tests passed.` (`verify_rhs` from Task 5 should already cover these forms.)

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
git commit -m "test(reflection-archival): closure, harness, and supersede forms"
```

---

### Task 8: Path 1 — annual file split for cross-year archival

**Files:**

- Modify: `ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh` (append test)
- Create: `ai-literacy-superpowers/tests/fixtures/reflection-log-2025-promoted.md`

- [ ] **Step 1: Create the cross-year fixture**

Create `tests/fixtures/reflection-log-2025-promoted.md` — same shape as `reflection-log-promoted-agents.md` but with `Date: 2025-12-15` (entry from prior year, archived in 2026).

- [ ] **Step 2: Write the failing test**

Append to `tests/test-archive-promoted-reflections.sh`:

```bash
test_2025_entry_archives_to_2025_md() {
  setup_workspace
  cp "$FIXTURES/reflection-log-2025-promoted.md" "$WORK_DIR/REFLECTION_LOG.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2025.md"
  assert_contains "$WORK_DIR/reflections/archive/2025.md" "Multi-repo scheduled agents"
}

test_2025_entry_archives_to_2025_md
```

- [ ] **Step 3: Run to verify pass**

```bash
bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
```

Expected: `All tests passed.` (`resolve_year` from Task 3 already returns the entry's original year.)

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh \
        ai-literacy-superpowers/tests/fixtures/reflection-log-2025-promoted.md
git commit -m "test(reflection-archival): cross-year archive split"
```

---

## Phase 3: Migration helper script

### Task 9: Migration helper — propose AGENTS.md promotion when text overlap exists

**Files:**

- Create: `ai-literacy-superpowers/scripts/migrate-reflection-log.sh`
- Create: `ai-literacy-superpowers/tests/test-migrate-reflection-log.sh`

- [ ] **Step 1: Write the failing test**

Create `ai-literacy-superpowers/tests/test-migrate-reflection-log.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/../scripts/migrate-reflection-log.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { grep -q "$2" "$1" || fail "expected '$2' in $1"; }
assert_file_exists() { [ -f "$1" ] || fail "expected file $1"; }

setup_workspace() {
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT
  mkdir -p "$WORK_DIR/reflections"
}

test_proposes_agents_promotion_when_keyword_overlaps() {
  setup_workspace
  # An entry whose Surprise mentions "Multi-repo" — same phrase as AGENTS.md content
  cp "$FIXTURES/reflection-log-many-entries.md" "$WORK_DIR/REFLECTION_LOG.md"
  cat >> "$WORK_DIR/REFLECTION_LOG.md" <<'ENTRY'

---

- **Date**: 2026-04-30
- **Agent**: claude-opus-4-7[1m]
- **Task**: Multi-repo agent work
- **Surprise**: Multi-repo scheduled agents are simpler than expected
- **Proposal**: workflow
- **Improvement**: none
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~10 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
ENTRY
  cp "$FIXTURES/agents-md-with-multi-repo-style.md" "$WORK_DIR/AGENTS.md"
  : > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  assert_file_exists "$WORK_DIR/reflections/migration-proposals.md"
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "Likely-promoted to AGENTS.md"
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "Multi-repo"
}

test_proposes_agents_promotion_when_keyword_overlaps
echo "All tests passed."
```

- [ ] **Step 2: Run to verify failure**

Expected: FAIL with `No such file or directory` for the script.

- [ ] **Step 3: Implement**

Create `ai-literacy-superpowers/scripts/migrate-reflection-log.sh`:

```bash
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
# shellcheck source=lib/reflection-log-helpers.sh
source "$SCRIPT_DIR/lib/reflection-log-helpers.sh"

LOG="REFLECTION_LOG.md"
PROPOSALS="reflections/migration-proposals.md"
AGE_THRESHOLD_DAYS=180  # 6 months default
TODAY=$(date '+%Y-%m-%d')

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

entry=""
while IFS= read -r line; do
  if [ "$line" = "---ENTRY---" ]; then
    propose_for_entry "$entry" "$cutoff_epoch" >> "$PROPOSALS"
    entry=""
  else
    entry+="${line}"$'\n'
  fi
done < <(split_entries "$LOG")

echo "Proposals written to $PROPOSALS."
```

Append `propose_for_entry` to `scripts/lib/reflection-log-helpers.sh`:

```bash
# propose_for_entry: emit a markdown block proposing a Promoted tag for one entry.
# Used by migrate-reflection-log.sh.
propose_for_entry() {
  local entry="$1"
  local cutoff="$2"
  local date surprise proposal entry_epoch
  date=$(extract_field "$entry" "Date")
  surprise=$(extract_field "$entry" "Surprise")
  proposal=$(extract_field "$entry" "Proposal")
  entry_epoch=$(date -j -f '%Y-%m-%d' "$date" '+%s' 2>/dev/null \
                || date -d "$date" '+%s')

  echo "---"
  echo ""
  echo "## Entry dated $date"
  echo ""

  # Already has a Promoted line — skip.
  if [ -n "$(parse_promoted "$entry")" ]; then
    echo "Already promoted; nothing to propose."
    return 0
  fi

  # Cross-reference surprise/proposal text against AGENTS.md
  local agents_match=""
  if [ -f AGENTS.md ] && [ -n "$surprise$proposal" ]; then
    # Naive keyword overlap: take the first 3 words of Surprise and grep AGENTS.md
    local kw; kw=$(echo "$surprise" | awk '{print $1, $2, $3}')
    if [ -n "$kw" ] && grep -qF "$kw" AGENTS.md; then
      agents_match="$kw"
    fi
  fi
  if [ -n "$agents_match" ]; then
    echo "**Likely-promoted to AGENTS.md** (keyword \"$agents_match\" matches)."
    echo ""
    echo "Proposed line for the entry:"
    echo ""
    echo "    - **Promoted**: $TODAY → AGENTS.md STYLE: \"$agents_match\""
    echo ""
    return 0
  fi

  # Cross-reference Constraint field against HARNESS.md
  local constraint; constraint=$(extract_field "$entry" "Constraint")
  if [ -f HARNESS.md ] && [ -n "$constraint" ] && [ "$constraint" != "none" ]; then
    if grep -qF "$constraint" HARNESS.md; then
      echo "**Likely-promoted to HARNESS.md** (constraint \"$constraint\" matches)."
      echo ""
      echo "Proposed line:"
      echo ""
      echo "    - **Promoted**: $TODAY → HARNESS.md: $constraint"
      echo ""
      return 0
    fi
  fi

  # Aged-out check
  if [ "$entry_epoch" -lt "$cutoff" ]; then
    echo "**Single-instance, aged-out** (older than threshold; no overlap found)."
    echo ""
    echo "Proposed line:"
    echo ""
    echo "    - **Promoted**: $TODAY → aged-out, no promotion warranted"
    echo ""
    return 0
  fi

  # Recent, no overlap → leave alone
  echo "Recent (within threshold), no overlap. Recommend leaving untouched."
  echo ""
}

# Required: the propose_for_entry function uses TODAY which is set in the
# calling script. To make this lib-callable, accept an override.
```

Update the `propose_for_entry` to take TODAY as an argument; update calling script. (For brevity here, the inline `$TODAY` works because the lib is sourced into a context where `TODAY` is set by `migrate-reflection-log.sh`.)

- [ ] **Step 4: Run to verify pass**

```bash
chmod +x ai-literacy-superpowers/scripts/migrate-reflection-log.sh
bash ai-literacy-superpowers/tests/test-migrate-reflection-log.sh
```

Expected: `All tests passed.`

- [ ] **Step 5: ShellCheck**

```bash
shellcheck ai-literacy-superpowers/scripts/migrate-reflection-log.sh
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
shellcheck ai-literacy-superpowers/tests/test-migrate-reflection-log.sh
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/scripts/migrate-reflection-log.sh \
        ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh \
        ai-literacy-superpowers/tests/test-migrate-reflection-log.sh
git commit -m "feat(reflection-archival): migration helper (AGENTS.md promotion proposals)"
```

---

### Task 10: Migration helper — HARNESS, aged-out, and self-skip cases

**Files:**

- Modify: `ai-literacy-superpowers/tests/test-migrate-reflection-log.sh` (append)

- [ ] **Step 1: Write failing tests**

Append:

```bash
test_proposes_aged_out_for_old_unmatched_entry() {
  setup_workspace
  # Entry from 2024 (>180 days old), no overlap with AGENTS/HARNESS
  cat > "$WORK_DIR/REFLECTION_LOG.md" <<'L'
# Reflection Log

---

- **Date**: 2024-01-15
- **Agent**: claude
- **Task**: Old singleton
- **Surprise**: Unique unrepeated thing
- **Proposal**: none
- **Improvement**: none
- **Signal**: none
- **Constraint**: none
- **Session metadata**:
  - Duration: ~5 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
L
  echo "# AGENTS" > "$WORK_DIR/AGENTS.md"
  echo "# HARNESS" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "aged-out"
}

test_self_skips_on_rerun() {
  setup_workspace
  # First run produces proposals
  cp "$FIXTURES/reflection-log-many-entries.md" "$WORK_DIR/REFLECTION_LOG.md"
  echo "# AGENTS" > "$WORK_DIR/AGENTS.md"
  echo "# HARNESS" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  # Second run should self-skip
  ( cd "$WORK_DIR" && bash "$SCRIPT" 2>&1 ) | grep -q "Skipping"
}

test_proposes_aged_out_for_old_unmatched_entry
test_self_skips_on_rerun
```

- [ ] **Step 2: Run to verify pass**

Expected: `All tests passed.` (Logic from Task 9 covers both.)

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/tests/test-migrate-reflection-log.sh
git commit -m "test(reflection-archival): aged-out + self-skip migration coverage"
```

---

## Phase 4: HARNESS template + GC rules

### Task 11: Add Path 1 GC rule to template

**Files:**

- Modify: `ai-literacy-superpowers/templates/HARNESS.md` (append a new GC rule)

- [ ] **Step 1: Add the rule**

In the `## Garbage Collection` section, before the closing `---`, add:

```markdown
### Reflection log archival of promoted entries

- **What it checks**: Whether `REFLECTION_LOG.md` contains entries with a
  `Promoted` line that pass pre-archive verification (RHS resolves to
  AGENTS.md or HARNESS.md content, or matches a closure form).
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: `ai-literacy-superpowers/scripts/archive-promoted-reflections.sh`
- **Auto-fix**: true (moves entries to `reflections/archive/<YYYY>.md`)
```

- [ ] **Step 2: Lint**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/templates/HARNESS.md
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "feat(harness): add Path 1 GC rule for reflection-log archival"
```

---

### Task 12: Add Path 2 GC rule (configurable threshold)

**Files:**

- Modify: `ai-literacy-superpowers/templates/HARNESS.md`

- [ ] **Step 1: Add the rule**

After Task 11's rule, add:

```markdown
### Reflection log aged-out review

- **What it checks**: Entries older than the configured age threshold
  (default 6 months) that lack a `Promoted` line; emits per-entry evidence
  (recurrence count, AGENTS.md/HARNESS.md text-overlap matches, single-
  instance signal) for the curator to interpret.
- **Frequency**: monthly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
- **Threshold**: 180 days (configurable; reduce to surface candidates sooner,
  increase to defer)
- **Opt-in**: declare this rule to enable. If absent, no monthly report is
  generated and the system reverts to today's behaviour for this project.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/templates/HARNESS.md
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "feat(harness): add Path 2 GC rule (opt-in, configurable threshold)"
```

---

### Task 13: Add Read-side filtering policy section to HARNESS template

**Files:**

- Modify: `ai-literacy-superpowers/templates/HARNESS.md`

- [ ] **Step 1: Add a new top-level section**

Before the `## Status` section near the end of the file, add:

```markdown
## Read-side filtering

Readers of `REFLECTION_LOG.md` bound their default intake to keep
per-read cost flat as the log grows. Defaults:

- **Bounded entry count**: 50
- **Bounded day window**: 90 days
- **Default policy**: read the more inclusive of the two

Readers that need historical patterns (regression detection, governance
audits, assessor evidence-extraction) opt in explicitly to read the full
active log plus archive. See the spec
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` for
the per-reader policy table.

Project-level overrides go in the GC-rule declarations above; agents
honour the values declared here when reading.

---
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/templates/HARNESS.md
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "feat(harness): document read-side filtering policy"
```

---

## Phase 5: Agent updates

### Task 14: Update harness-gc agent (Path 1, Path 2, regression-archive read)

**Files:**

- Modify: `ai-literacy-superpowers/agents/harness-gc.agent.md`

- [ ] **Step 1: Update the agent definition**

Read the current file, then add a new section (after the existing GC-rule descriptions) that documents:

1. How to invoke `scripts/archive-promoted-reflections.sh` for Path 1.
2. The Path 2 algorithm (read aged-out entries; emit evidence per spec):
   - Recurrence count via grep across newer entries' Surprise/Proposal/Signal
   - AGENTS.md/HARNESS.md text-overlap with quoted excerpts
   - Single-instance signal (no matches found)
   - **Do not emit pre-classified labels.** Curator interprets evidence.
3. Update `Reflection-driven regression detection` to read both
   `REFLECTION_LOG.md` AND `reflections/archive/*.md` when looking for
   cross-time patterns.

Insert the new section text. The existing prompt structure should stay; this is additive.

Specifically, append to the agent prompt body:

```markdown
### Reflection log archival rules

#### Path 1 — Auto-archive of promoted entries (weekly, deterministic)

When this rule fires, run:

    bash ai-literacy-superpowers/scripts/archive-promoted-reflections.sh

The script identifies entries with a `Promoted` line, verifies the
right-hand side resolves to actual AGENTS.md / HARNESS.md content (or is
a closure form), and moves verified entries to
`reflections/archive/<YYYY>.md`. Report the script's stdout to the user
verbatim. Do not modify the active log directly — the script handles
that.

#### Path 2 — Aged-out review (monthly, agent-driven, opt-in)

When this rule fires (only if declared in HARNESS.md):

1. Read `REFLECTION_LOG.md` and find entries older than the configured
   threshold (default 180 days from today) that lack a `Promoted` line.
2. For each candidate entry, gather **evidence** — do NOT emit a label:
   - **Recurrence count**: grep newer entries (active + archive) for the
     candidate's keywords (Surprise field's first 3 significant words);
     report the count and the dates of the matches.
   - **AGENTS.md/HARNESS.md text overlap**: grep both files for the same
     keywords; quote any matching excerpts verbatim.
   - **Single-instance signal**: if neither newer-entry recurrence nor
     AGENTS/HARNESS overlap found, report explicitly: "No newer entry
     shares this pattern; not currently captured in AGENTS.md or
     HARNESS.md."
3. Write the report to
   `observability/reflection-aged-out-<YYYY-MM-DD>.md`.
4. Surface the report path to the curator. The curator interprets the
   evidence and decides on a disposition; the agent does NOT recommend
   PROMOTE / SUPERSEDE / AGED-OUT.

#### Reflection-driven regression detection (extended)

This existing rule now reads BOTH `REFLECTION_LOG.md` and
`reflections/archive/*.md` when scanning for recurring failure patterns.
Aggregate via `cat REFLECTION_LOG.md reflections/archive/*.md` then split
on `---` separators and analyse the combined stream.
```

- [ ] **Step 2: Lint**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/agents/harness-gc.agent.md
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/agents/harness-gc.agent.md
git commit -m "feat(harness-gc): wire Path 1 + Path 2 + archive-aware regression detection"
```

---

### Task 15: Update harness-auditor agent (bounded-read default)

**Files:**

- Modify: `ai-literacy-superpowers/agents/harness-auditor.agent.md`

- [ ] **Step 1: Add a read-policy clause**

Append to the agent's prompt:

```markdown
## Read-side filtering policy

When reading `REFLECTION_LOG.md` for routine audits, default to the
bounded read: the more inclusive of the last 50 entries OR entries
within the last 90 days. Use:

    bash ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
    # then call: bounded_entries REFLECTION_LOG.md 50 90

For audits that require historical claims (e.g., "verify the harness
status reflects the full reflection history"), explicitly opt in to
reading both `REFLECTION_LOG.md` AND `reflections/archive/*.md`. State
in your response which read mode you used and why.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/agents/harness-auditor.agent.md
git add ai-literacy-superpowers/agents/harness-auditor.agent.md
git commit -m "feat(harness-auditor): bounded-read default with explicit opt-in"
```

---

### Task 16: Update assessor agent (full active+archive read)

**Files:**

- Modify: `ai-literacy-superpowers/agents/assessor.agent.md`

- [ ] **Step 1: Add a read-policy clause**

Append:

```markdown
## Reflection-log read policy

When extracting compound-learning evidence, read BOTH
`REFLECTION_LOG.md` AND `reflections/archive/*.md`. Coverage matters
more than recency for assessment — the archive contains the bulk of
the project's recorded learnings after archival has run.

Use:

    cat REFLECTION_LOG.md reflections/archive/*.md 2>/dev/null

Then split on `---` separators and process the combined stream.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/agents/assessor.agent.md
git add ai-literacy-superpowers/agents/assessor.agent.md
git commit -m "feat(assessor): read full active log + archive for compound-learning evidence"
```

---

### Task 17: Update choice-cartographer agent (bounded default)

**Files:**

- Modify: `ai-literacy-superpowers/agents/choice-cartographer.agent.md`

- [ ] **Step 1: Add the read-policy clause**

Append:

```markdown
## Reflection-log read policy

Default to bounded read (last 50 entries OR last 90 days). For decision
continuity assessments that span long arcs (e.g., "this spec inherits
from a decision made 18 months ago"), opt in to reading the archive.
State which read mode you used.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/agents/choice-cartographer.agent.md
git add ai-literacy-superpowers/agents/choice-cartographer.agent.md
git commit -m "feat(choice-cartographer): bounded-read default for reflection log"
```

---

### Task 18: Update integration-agent (document Promoted convention)

**Files:**

- Modify: `ai-literacy-superpowers/agents/integration-agent.agent.md`

- [ ] **Step 1: Add a Promoted-field clause**

Append:

```markdown
## Promoted-field convention (post-task workflow)

When a curator promotes a reflection entry's content to `AGENTS.md` or
`HARNESS.md`, they add a `Promoted` line to the source entry **in the
same commit** as the AGENTS.md/HARNESS.md edit. The line follows the
grammar:

    - **Promoted**: YYYY-MM-DD → <RHS>

Where `<RHS>` is one of:

- `AGENTS.md <SECTION>: "<quoted excerpt>"`
- `HARNESS.md: <constraint name>`
- `aged-out, no promotion warranted`
- `superseded by <YYYY-MM-DD>`

The integration agent does not add Promoted lines automatically — this
is a curator action. The agent should preserve any existing Promoted
lines on entries it processes.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/agents/integration-agent.agent.md
git add ai-literacy-superpowers/agents/integration-agent.agent.md
git commit -m "feat(integration-agent): document Promoted-field convention"
```

---

## Phase 6: Command updates

### Task 19: Update /reflect command

**Files:**

- Modify: `ai-literacy-superpowers/commands/reflect.md`

- [ ] **Step 1: Add a note about Promoted-line addition at promotion time**

After the existing entry-format documentation, add:

```markdown
## Promoting an entry (curator action, post-reflection)

When you later promote this reflection's content to `AGENTS.md` or
`HARNESS.md`, add a `Promoted` line to this entry **in the same commit**
as the AGENTS.md/HARNESS.md edit. The line follows the grammar in
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`
(Schema change → Formal grammar). Examples:

    - **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
    - **Promoted**: 2026-05-15 → HARNESS.md: Reflections via PR workflow
    - **Promoted**: 2026-05-15 → aged-out, no promotion warranted

The Path 1 weekly GC rule auto-archives entries with verified Promoted
lines; you do not need to move the entry yourself.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/commands/reflect.md
git add ai-literacy-superpowers/commands/reflect.md
git commit -m "feat(reflect): document Promoted-line addition at curation time"
```

---

### Task 20: Update /superpowers-status

**Files:**

- Modify: `ai-literacy-superpowers/commands/superpowers-status.md`

- [ ] **Step 1: Add archive-count reporting**

Find the section that reports reflection-log state and modify it to also report:

- Active log entry count: `grep -c '^---$' REFLECTION_LOG.md` (minus 1 if the count includes the trailing separator)
- Archive entry count: `grep -c '^---$' reflections/archive/*.md 2>/dev/null | awk -F: '{s+=$2} END {print s}'`
- Curation debt (unpromoted entries older than threshold): scan active log for entries dated >180 days ago without a `Promoted` line; report count.

Inline the exact bash invocation in the command's process steps.

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/commands/superpowers-status.md
git add ai-literacy-superpowers/commands/superpowers-status.md
git commit -m "feat(superpowers-status): report active + archive + curation-debt counts"
```

---

### Task 21: Update /harness-health

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-health.md`

- [ ] **Step 1: Add archive-count + curation-debt reporting**

Same shape as Task 20, scoped to the harness-health snapshot format. The snapshot's `Compound learning` section should now include:

- Active log entry count
- Archive entry count
- Unpromoted entries older than threshold (curation debt metric)

Use the same bash counting commands as Task 20.

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-health.md
git add ai-literacy-superpowers/commands/harness-health.md
git commit -m "feat(harness-health): include archive + curation-debt in compound-learning section"
```

---

### Task 22: Update /harness-audit

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-audit.md`

- [ ] **Step 1: Add the same archive + curation-debt reporting**

Same as Tasks 20-21, scoped to the harness-audit report format.

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-audit.md
git add ai-literacy-superpowers/commands/harness-audit.md
git commit -m "feat(harness-audit): include archive + curation-debt in audit report"
```

---

## Phase 7: Skill update

### Task 23: Document the new GC rules in the garbage-collection skill

**Files:**

- Modify: `ai-literacy-superpowers/skills/garbage-collection/SKILL.md`

- [ ] **Step 1: Add a new section**

Append:

```markdown
## Reflection log archival — two GC rules with safety asymmetry

The plugin ships two related GC rules that share a schema (the
`Promoted` line per reflection entry) but differ in safety profile:

### Path 1: `Reflection log archival of promoted entries`

- **Deterministic**, **auto-fix true**.
- Fires weekly via `gc.yml`.
- Operates on entries with an explicit `Promoted` line.
- Pre-archive verification: the script verifies the Promoted line's
  right-hand side resolves to actual AGENTS.md or HARNESS.md content
  before archiving. Skips with a warning otherwise — recovers on the
  next run after the curator reconciles.
- Auto-fix is safe because the signal (a `Promoted` line) is explicit
  AND verified against current tree state.

### Path 2: `Reflection log aged-out review`

- **Agent-enforced**, **auto-fix false**.
- Fires monthly. **Opt-in** via the GC-rule declaration in HARNESS.md.
- Operates on entries older than the configured threshold (default
  180 days) that lack a `Promoted` line.
- Emits **evidence** (recurrence count, AGENTS.md/HARNESS.md
  text-overlap matches with quoted excerpts, single-instance signal),
  **NOT pre-classified labels**. Curator interprets the evidence.
- Auto-fix is not safe because the absence of a `Promoted` line is
  ambiguous — the entry might still be relevant or might warrant
  promotion the curator hasn't got around to.

The asymmetry is deliberate: explicit signal + verification → safe to
auto-act; absence of signal → human judgement gates the move. See
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`
for the full design rationale.

## Read-side filtering policy

Independent of archival, every reader of `REFLECTION_LOG.md` should
bound its default intake. See the HARNESS.md `## Read-side filtering`
section for the configured defaults and the per-reader policy.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/skills/garbage-collection/SKILL.md
git add ai-literacy-superpowers/skills/garbage-collection/SKILL.md
git commit -m "feat(garbage-collection skill): document Path 1 + Path 2 + read-side filtering"
```

---

## Phase 8: Template + CI

### Task 24: Update CLAUDE.md template

**Files:**

- Modify: `ai-literacy-superpowers/templates/CLAUDE.md`

- [ ] **Step 1: Add a Reflection-Log Curation section**

Append:

```markdown
## Reflection Log Curation

Reflections are appended to `REFLECTION_LOG.md` via `/reflect`. The
log is **a working file**, not the permanent record. The permanent
record lives in `reflections/archive/<YYYY>.md`, populated by the
weekly Path 1 GC rule from entries the curator has tagged with a
`Promoted` line.

### Promoted-line schema

When promoting an entry's content to `AGENTS.md` or `HARNESS.md`, add
a single line to the source reflection entry **in the same commit**
as the AGENTS.md / HARNESS.md edit:

    - **Promoted**: YYYY-MM-DD → <RHS>

`<RHS>` must match one of the documented forms (see
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`,
Schema change → Formal grammar). Path 1's weekly GC rule auto-archives
entries with verified Promoted lines.

### Aged-out review

Optionally enable the Path 2 GC rule (`Reflection log aged-out review`)
in HARNESS.md to receive a monthly report of unpromoted entries older
than the threshold, with evidence (recurrence, overlap matches) for
the curator to interpret.

If neither rule is engaged, the system reverts to today's behaviour
plus read-side filtering: agents and commands still bound their
intake by default, but the log itself accumulates entries until the
curator manually intervenes.
```

- [ ] **Step 2: Lint and commit**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/templates/CLAUDE.md
git add ai-literacy-superpowers/templates/CLAUDE.md
git commit -m "feat(claude-md template): document reflection-log curation conventions"
```

---

### Task 25: Wire Path 1 script into gc.yml

**Files:**

- Modify: `ai-literacy-superpowers/.github/workflows/gc.yml`

- [ ] **Step 1: Add a step that runs Path 1**

Find the existing weekly GC run step and add a step (or append to the existing step's commands):

```yaml
      - name: Reflection log archival of promoted entries (Path 1)
        run: |
          bash ai-literacy-superpowers/scripts/archive-promoted-reflections.sh --dry-run=false
```

If the workflow already commits GC outputs, ensure this step's commits are picked up by the existing PR-creation step. If GC currently opens a PR for changes, no further wiring is needed; if it commits directly to a branch, ensure REFLECTION_LOG.md and `reflections/archive/*.md` are both staged.

- [ ] **Step 2: Lint YAML**

Run a YAML syntax check. If `yamllint` is available:

```bash
yamllint ai-literacy-superpowers/.github/workflows/gc.yml
```

Otherwise verify with `python3 -c 'import yaml; yaml.safe_load(open("ai-literacy-superpowers/.github/workflows/gc.yml"))'`.

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/.github/workflows/gc.yml
git commit -m "ci(gc): wire Path 1 reflection-log archival script into weekly GC"
```

---

## Phase 9: Live-repo migration

### Task 26: Run the migration helper against this repo's REFLECTION_LOG

**Files:**

- Read: this repo's `REFLECTION_LOG.md`, `AGENTS.md`, `HARNESS.md`
- Create: `reflections/migration-proposals.md` (generated by helper)

- [ ] **Step 1: Run the helper**

From repo root:

```bash
bash ai-literacy-superpowers/scripts/migrate-reflection-log.sh
```

Expected: `Proposals written to reflections/migration-proposals.md.`

- [ ] **Step 2: Curator review the proposals file**

Open `reflections/migration-proposals.md` in editor. For each entry's
proposal, decide:

- Confirm: copy the proposed `Promoted` line into the source entry in
  `REFLECTION_LOG.md`.
- Edit: revise the proposed line before applying.
- Reject: leave the source entry untouched (entry stays in the active
  log).

This is a manual curator step. **Do not skip the human review** — the
helper is a starting point, not a decision.

- [ ] **Step 3: Apply confirmed tags**

Edit `REFLECTION_LOG.md` directly to add the confirmed `Promoted` lines
to the appropriate entries. Keep the proposals file as a permanent
audit record (do not delete).

- [ ] **Step 4: Verify the tagged entries pass `parse_promoted` and `verify_rhs`**

```bash
# Spot-check by running Path 1 in dry-run mode
bash ai-literacy-superpowers/scripts/archive-promoted-reflections.sh --dry-run=true
```

Expected output: `Would archive N entries (dry run).` where N matches
the number of entries you tagged.

- [ ] **Step 5: Commit the migration**

```bash
git add REFLECTION_LOG.md reflections/migration-proposals.md
git commit -m "chore(reflection-log): migration tagging — N entries tagged for Path 1 archival"
```

---

### Task 27: Run Path 1 to perform first archival

**Files:**

- Modify: `REFLECTION_LOG.md`
- Create: `reflections/archive/2026.md` (and possibly `2025.md`, etc.)

- [ ] **Step 1: Run Path 1 for real**

```bash
bash ai-literacy-superpowers/scripts/archive-promoted-reflections.sh --dry-run=false
```

Expected: `Archived N entries; M entries remain in REFLECTION_LOG.md.`

- [ ] **Step 2: Spot-check the archive output**

```bash
ls reflections/archive/
head -20 reflections/archive/2026.md
```

Expected: archive files exist; each archived entry has its full original
content plus an `Archived` line.

- [ ] **Step 3: Verify active log is shorter**

```bash
grep -c '^---$' REFLECTION_LOG.md
```

Expected: matches the number of entries that did NOT have a Promoted
line (the curator's "keep" choices).

- [ ] **Step 4: Commit**

```bash
git add REFLECTION_LOG.md reflections/archive/
git commit -m "chore(reflection-log): first archival run — N entries moved to archive"
```

---

### Task 28: Add the new GC rules to this repo's HARNESS.md

**Files:**

- Modify: `HARNESS.md`

- [ ] **Step 1: Add the two GC rules**

In the `## Garbage Collection` section, before the final `---`, add the
two rule blocks from Tasks 11-12 (Path 1 and Path 2). Adopters declare
both — Path 1 is automatic, Path 2 is opt-in (we opt in for this repo
since we use compound learning actively).

- [ ] **Step 2: Add the Read-side filtering section**

Per Task 13, add the `## Read-side filtering` section before `## Status`.

- [ ] **Step 3: Lint and commit**

```bash
npx markdownlint-cli2 HARNESS.md
git add HARNESS.md
git commit -m "harness: declare reflection-log archival GC rules + read-side filtering"
```

---

## Phase 10: Version bump + release prep

### Task 29: Bump plugin version 0.31.1 → 0.32.0

**Files:**

- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `README.md` (badge)
- Modify: `.claude-plugin/marketplace.json` (`plugin_version`)

- [ ] **Step 1: Update plugin.json**

Find the `"version": "0.31.1"` line and change to `"version": "0.32.0"`.

- [ ] **Step 2: Update README badge**

Find the `ai--literacy--superpowers-v0.31.1` badge URL and update to
`ai--literacy--superpowers-v0.32.0`.

- [ ] **Step 3: Update marketplace.json**

Update the top-level `plugin_version` field AND the
`plugins[].version` for the `ai-literacy-superpowers` entry, both to
`0.32.0`.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json README.md \
        .claude-plugin/marketplace.json
git commit -m "chore: bump ai-literacy-superpowers to 0.32.0"
```

---

### Task 30: Add CHANGELOG entry

**Files:**

- Modify: `CHANGELOG.md`

- [ ] **Step 1: Insert a new top-level version heading**

At the top of CHANGELOG.md (above the existing `## 0.31.1 — 2026-04-29`
heading), insert:

```markdown
## 0.32.0 — 2026-04-30

### Feature — Reflection log archival (Path 1 + Path 2 + read-side filtering)

Implements the design at
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`.
Three complementary mechanisms keep `REFLECTION_LOG.md` signal-dense
as the project accumulates compound learning over time.

- **Read-side filtering** — agents and commands that read the
  reflection log bound their default intake (last 50 entries OR last
  90 days, whichever is more inclusive). Documented as a HARNESS.md
  `## Read-side filtering` section; implemented via the
  `bounded_entries` shared helper in
  `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh`.
- **Path 1 — auto-archive of promoted entries (deterministic, weekly)**.
  When a curator promotes a reflection to `AGENTS.md` or `HARNESS.md`,
  they add a single `Promoted` line to the source entry. The new
  weekly GC rule (`Reflection log archival of promoted entries`) runs
  `scripts/archive-promoted-reflections.sh`, which verifies the
  Promoted line's right-hand side resolves to actual AGENTS.md /
  HARNESS.md content and moves verified entries to
  `reflections/archive/<YYYY>.md` (annual files, file-by-original-year,
  ordered by archive timestamp).
- **Path 2 — agent-augmented aged-out review (monthly, opt-in)**. The
  `harness-gc` agent surfaces entries older than the configured age
  threshold (default 180 days) that lack a `Promoted` line and emits
  per-entry **evidence** (recurrence counts, AGENTS.md/HARNESS.md
  text-overlap matches with quoted excerpts, single-instance signal)
  rather than pre-classified labels. Curator interprets the evidence
  and chooses a disposition. Opt-in via the GC-rule declaration in
  HARNESS.md.
- **Migration helper** — `scripts/migrate-reflection-log.sh`
  pre-cross-references existing entries against AGENTS.md and
  HARNESS.md and produces a proposals file for the curator to confirm.
- **Schema** — one new optional `Promoted: <date> → <rhs>` line per
  entry, formal-grammar parseable, append-only.
- **Graceful degradation** — for adopters who don't engage, the system
  reverts to today's behaviour plus read-side filtering. No archival
  happens, no monthly report is generated, and the active log
  continues as before.

Touches: agent definitions (`harness-gc`, `harness-auditor`,
`assessor`, `choice-cartographer`, `integration-agent`); commands
(`reflect`, `superpowers-status`, `harness-health`, `harness-audit`);
templates (`HARNESS.md`, `CLAUDE.md`); skill
(`garbage-collection`); CI workflow (`gc.yml`); plus this repo's live
migration of 29 reflection entries (per Task 26-27).
```

- [ ] **Step 2: Lint**

```bash
npx markdownlint-cli2 CHANGELOG.md
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add CHANGELOG.md
git commit -m "changelog: 0.32.0 — reflection log archival"
```

---

## Phase 11: Final verification

### Task 31: Run all shell tests

**Files:** none modified

- [ ] **Step 1: Run all test scripts**

```bash
bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh
bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh
bash ai-literacy-superpowers/tests/test-migrate-reflection-log.sh
```

Expected: each prints `All tests passed.`

- [ ] **Step 2: ShellCheck all new scripts**

```bash
shellcheck ai-literacy-superpowers/scripts/archive-promoted-reflections.sh
shellcheck ai-literacy-superpowers/scripts/migrate-reflection-log.sh
shellcheck ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh
shellcheck ai-literacy-superpowers/tests/test-*.sh
```

Expected: no output.

- [ ] **Step 3: Markdownlint all touched files**

```bash
npx markdownlint-cli2 \
  "ai-literacy-superpowers/agents/*.agent.md" \
  "ai-literacy-superpowers/commands/*.md" \
  "ai-literacy-superpowers/skills/garbage-collection/SKILL.md" \
  "ai-literacy-superpowers/templates/*.md" \
  "REFLECTION_LOG.md" \
  "HARNESS.md" \
  "CHANGELOG.md" \
  "reflections/archive/*.md" \
  "reflections/migration-proposals.md"
```

Expected: 0 errors across all files (or only failures CI also already accepts).

---

### Task 32: Push branch, open PR, watch CI

**Files:** none modified

- [ ] **Step 1: Push the branch**

```bash
git push -u origin reflection-log-archival
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "feat: reflection log archival (Path 1 + Path 2 + read-side filtering)" \
  --body "$(cat <<'BODY'
## Summary

Implements the design at `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` — three complementary mechanisms (read-side filtering, Path 1 auto-archive, Path 2 agent-augmented aged-out review) that keep `REFLECTION_LOG.md` signal-dense as compound learning accumulates.

## Adjudication trail

- Spec adversarial review: `docs/superpowers/objections/reflection-log-archival-design.md` — 12 objections, 8 accepted (driving spec revisions), 4 rejected with rationale.
- Decision archaeology: `docs/superpowers/stories/reflection-log-archival-design.md` — 9 implicit decisions surfaced; all 9 accepted.

## Test plan

- [x] `bash ai-literacy-superpowers/tests/test-reflection-log-helpers.sh`
- [x] `bash ai-literacy-superpowers/tests/test-archive-promoted-reflections.sh`
- [x] `bash ai-literacy-superpowers/tests/test-migrate-reflection-log.sh`
- [x] ShellCheck clean across all new scripts
- [x] Markdownlint clean across all touched files
- [x] Live migration of 29 entries against this repo's REFLECTION_LOG (Task 26-27)
- [ ] CI green
- [ ] Pages build succeeds (no docs site changes in this PR; safe)
BODY
)"
```

- [ ] **Step 3: Watch CI**

```bash
gh pr checks --watch
```

If any check fails, fetch failure log, fix, commit, push, repeat.

- [ ] **Step 4: Do not merge until user reviews**

Print the PR URL. Wait for user review and explicit merge instruction.

---

## Self-review

After writing the plan, run a fresh-eyes pass:

**Spec coverage check:**

| Spec section | Covered by |
|---|---|
| Problem | n/a (motivation) |
| Goals | Tasks 1-13 (mechanisms) + 23 (skill doc) |
| Non-goals | n/a (boundaries) |
| Approach overview | Phases 1-4 |
| Schema change + grammar | Task 2 (parser); Task 24 (CLAUDE.md doc); Task 19 (reflect command doc) |
| Archive location and format | Task 5 (archive write); Task 8 (cross-year split) |
| Read-side filtering | Task 4 (helper); Task 13 (HARNESS section); Tasks 15-17 (agent defaults) |
| Path 1 specification | Tasks 5-8 (script + tests) |
| Path 2 specification | Task 14 (harness-gc agent prompt) |
| Configuration | Task 12 (HARNESS GC rule with threshold) |
| Reader updates | Tasks 14-22 (per-reader updates) |
| Migration helper | Tasks 9-10 (script + tests); Task 26 (live run) |
| Steady-state expectation | n/a (descriptive) |
| Graceful degradation | Task 12 (Path 2 opt-in); Task 24 (CLAUDE doc) |
| Implementation scope | All tasks |

**Placeholder scan:** No "TBD", "TODO", or "implement later" found in the plan above.

**Type consistency:** Function signatures used throughout — `parse_promoted`, `extract_field`, `resolve_year`, `bounded_entries`, `verify_rhs`, `propose_for_entry`, `split_entries` — match across tasks.

**Open items / known caveats:**

- Task 6 (verification skip) is structured as a coverage-test that should already pass after Task 5; no implementation step required unless Task 5's verify_rhs is incomplete.
- Task 25 (gc.yml) assumes the existing GC workflow's commit/PR mechanism extends to new files; if it doesn't, that's a small follow-up.
- Task 26 (live migration) is the human-in-the-loop step — task content describes the workflow but the actual review is curator-driven.

---

## Execution choice

Plan complete and saved to `docs/superpowers/plans/2026-04-30-reflection-log-archival.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** — execute tasks in this session using `executing-plans`, batch execution with checkpoints.

Which approach?
