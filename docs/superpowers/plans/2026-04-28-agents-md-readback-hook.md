# AGENTS.md Read-Back SessionStart Hook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a SessionStart hook (`agents-md-readback.sh`) that injects the last 3 bullets per section of AGENTS.md as a `systemMessage` whenever AGENTS.md has changed since last session, with hash-based auto-dismissal. Closes the read-back stage of the compound-learning loop identified in the 2026-04-28 AI literacy assessment.

**Architecture:** A bash hook reads `$CLAUDE_PROJECT_DIR/AGENTS.md`, computes its SHA-256, compares against `$CLAUDE_PROJECT_DIR/.claude/.agents-md-last-seen`. If changed, extracts the last 3 bullets per known section using awk (handling multi-line continuations), formats as JSON via `jq -Rs`, prints to stdout, then writes the new hash. Mirrors `template-currency-check.sh`. A hand-rolled bash test runner exercises 12 fixture-based test cases. Ships in plugin's `hooks.json` so all consumers inherit the closed loop.

**Tech Stack:** Bash 4+, awk, sha256sum, jq, hand-rolled bash test runner

**Spec:** `docs/superpowers/specs/2026-04-28-agents-md-readback-hook-design.md`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh` | Create | The hook itself |
| `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh` | Create | Test runner with 12 cases |
| `ai-literacy-superpowers/hooks/scripts/test/fixtures/*.md` | Create | Fixture AGENTS.md files |
| `ai-literacy-superpowers/hooks/hooks.json` | Modify | Add SessionStart entry |
| `docs/explanation/compound-learning.md` | Extend | Add read-back subsection + diagram update |
| `docs/how-to/work-with-agents-md.md` | Create | Task-oriented guide |
| `CLAUDE.md` | Extend | Add AGENTS.md Read-Back section |
| `.github/workflows/harness.yml` | Modify | Add test runner CI job |
| `CHANGELOG.md` | Extend | v0.32.0 entry |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Modify | Bump 0.31.0 → 0.32.0 |
| `ai-literacy-superpowers/.claude-plugin/marketplace.json` | Modify | `plugin_version` sync |
| `README.md` | Modify | Plugin badge bump + Hooks count 11 → 12 |

---

## Task 1: Scaffold test runner skeleton and fixtures directory

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/.gitkeep`

- [ ] **Step 1: Create test runner skeleton with no test cases**

```bash
#!/usr/bin/env bash
# Test runner for agents-md-readback.sh. 12 fixture-based test cases
# covering slice extraction, dismissal, and edge cases.
#
# Note: -e is intentionally NOT set. The runner must continue past
# test failures to count and report them. -u and -o pipefail still apply.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="${SCRIPT_DIR}/../agents-md-readback.sh"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures"

PASSED=0
FAILED=0
FAILURES=()

assert_silent() {
  local name="$1"
  local stdout="$2"
  if [ -z "$stdout" ]; then
    PASSED=$((PASSED + 1))
    echo "PASS: $name"
  else
    FAILED=$((FAILED + 1))
    FAILURES+=("$name -- expected silent, got: $stdout")
    echo "FAIL: $name"
  fi
}

assert_emits() {
  local name="$1"
  local stdout="$2"
  local needle="$3"
  if echo "$stdout" | grep -q -- "$needle"; then
    PASSED=$((PASSED + 1))
    echo "PASS: $name"
  else
    FAILED=$((FAILED + 1))
    FAILURES+=("$name -- expected '$needle' in output, got: $stdout")
    echo "FAIL: $name"
  fi
}

run_hook_in_tmp() {
  local fixture="$1"
  local marker_content="${2:-}"

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  if [ -n "$fixture" ] && [ -f "${FIXTURES_DIR}/${fixture}" ]; then
    cp "${FIXTURES_DIR}/${fixture}" "${tmp}/AGENTS.md"
  fi

  if [ -n "$marker_content" ]; then
    mkdir -p "${tmp}/.claude"
    printf '%s' "$marker_content" > "${tmp}/.claude/.agents-md-last-seen"
  fi

  CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null
}

# Tests will be added in subsequent tasks

echo
echo "Tests: ${PASSED} passed, ${FAILED} failed"
[ "$FAILED" -eq 0 ]
```

- [ ] **Step 2: Make test runner executable and run it**

Run: `chmod +x ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh && bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `Tests: 0 passed, 0 failed` and exit 0.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh ai-literacy-superpowers/hooks/scripts/test/fixtures/.gitkeep
git commit -m "Scaffold test runner for agents-md-readback hook"
```

---

## Task 2: Test 9 (RED) — AGENTS.md missing → silent exit

**Files:**

- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh` (append before the summary block)

- [ ] **Step 1: Add the failing test**

Insert before `echo` summary block:

```bash
# Test 9: AGENTS.md missing → silent exit
out=$(run_hook_in_tmp "")
assert_silent "test-09: AGENTS.md missing → silent exit" "$out"
```

- [ ] **Step 2: Run the test runner; expect 1 fail**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `FAIL: test-09 ...` because `agents-md-readback.sh` does not exist yet (script will exit nonzero).

Note: the test runner's `run_hook_in_tmp` invokes a script that doesn't exist. The first failure will be from `bash $HOOK_SCRIPT` not finding the file. That's the "right" red state for TDD — the production code does not exist.

---

## Task 3: Test 9 (GREEN) — minimal hook script

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`

- [ ] **Step 1: Create the minimal hook script**

```bash
#!/usr/bin/env bash
# AGENTS.md read-back — runs at session start (SessionStart hook).
#
# Closes the read-back stage of the compound-learning loop. When
# AGENTS.md has changed since last seen, injects the last 3 bullets
# per section as a systemMessage. Auto-dismisses by writing the
# current hash to .claude/.agents-md-last-seen after emitting.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
AGENTS_FILE="${PROJECT_DIR}/AGENTS.md"

# Guard: AGENTS.md missing
if [ ! -f "$AGENTS_FILE" ]; then
  exit 0
fi

exit 0
```

- [ ] **Step 2: Make script executable and run test runner**

Run: `chmod +x ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh && bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `PASS: test-09: AGENTS.md missing → silent exit` and `Tests: 1 passed, 0 failed`.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: silent exit when AGENTS.md missing (test 9)"
```

---

## Task 4: Test 1 (RED) — standard slice extraction

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/standard.md`
- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`

- [ ] **Step 1: Create fixture `standard.md` with all 5 sections populated**

```markdown
# Compound Learning

## STYLE

- Style bullet 1
- Style bullet 2
- Style bullet 3
- Style bullet 4

## GOTCHAS

- Gotcha bullet 1
- Gotcha bullet 2
- Gotcha bullet 3
- Gotcha bullet 4

## ARCH_DECISIONS

- Arch bullet 1
- Arch bullet 2
- Arch bullet 3
- Arch bullet 4

## TEST_STRATEGY

- Test bullet 1
- Test bullet 2
- Test bullet 3
- Test bullet 4

## DESIGN_DECISIONS

- Design bullet 1
- Design bullet 2
- Design bullet 3
- Design bullet 4
```

- [ ] **Step 2: Add failing test 1**

Append before the summary `echo`:

```bash
# Test 1: standard 5-section AGENTS.md → emits last 3 bullets per section
out=$(run_hook_in_tmp "standard.md")
assert_emits "test-01a: emits ## STYLE heading" "$out" '## STYLE'
assert_emits "test-01b: emits Style bullet 4 (most recent)" "$out" "Style bullet 4"
# Negative check: bullet 1 should NOT appear (last-3 only)
if echo "$out" | grep -q "Style bullet 1"; then
  FAILED=$((FAILED + 1))
  FAILURES+=("test-01c: should not emit Style bullet 1")
  echo "FAIL: test-01c"
else
  PASSED=$((PASSED + 1))
  echo "PASS: test-01c: omits Style bullet 1 (last-3 only)"
fi
```

- [ ] **Step 3: Run test runner; expect FAIL on test 1a/1b**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `FAIL: test-01a` and `FAIL: test-01b` — current minimal script emits nothing. Test 9 still passes; test 1c also passes vacuously (bullet 1 not in empty output).

---

## Task 5: Test 1 (GREEN) — slice extraction implementation

**Files:**

- Modify: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`

- [ ] **Step 1: Implement slice extraction**

Replace the body of the script (after `set -euo pipefail` and `PROJECT_DIR/AGENTS_FILE` declarations) with:

```bash
#!/usr/bin/env bash
# AGENTS.md read-back — runs at session start (SessionStart hook).
#
# Closes the read-back stage of the compound-learning loop. When
# AGENTS.md has changed since last seen, injects the last 3 bullets
# per section as a systemMessage. Auto-dismisses by writing the
# current hash to .claude/.agents-md-last-seen after emitting.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
AGENTS_FILE="${PROJECT_DIR}/AGENTS.md"
MARKER_FILE="${PROJECT_DIR}/.claude/.agents-md-last-seen"
N=3

# Guard: AGENTS.md missing
if [ ! -f "$AGENTS_FILE" ]; then
  exit 0
fi

# Guard: jq missing (graceful degradation)
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Extract last N bullets per known section
extract_slice() {
  local file="$1"
  awk -v n="$N" '
    BEGIN {
      sections["STYLE"] = 1
      sections["GOTCHAS"] = 2
      sections["ARCH_DECISIONS"] = 3
      sections["TEST_STRATEGY"] = 4
      sections["DESIGN_DECISIONS"] = 5
    }
    /^## / {
      if (cur != "" && cur in sections) section_end[cur] = NR - 1
      cur = $2
      if (cur in sections) {
        section_start[cur] = NR
        bullet_count[cur] = 0
      } else {
        cur = ""
      }
      next
    }
    cur != "" {
      lines[NR] = $0
      if ($0 ~ /^- /) {
        bullet_count[cur]++
        bullet_at[cur, bullet_count[cur]] = NR
      }
    }
    END {
      if (cur != "" && cur in sections) section_end[cur] = NR
      for (s in sections) order[sections[s]] = s
      for (i = 1; i <= 5; i++) {
        s = order[i]
        if (!(s in bullet_count) || bullet_count[s] == 0) continue
        printf "## %s\n\n", s
        first_idx = (bullet_count[s] > n) ? bullet_count[s] - n + 1 : 1
        first_line = bullet_at[s, first_idx]
        end_line = section_end[s]
        for (ln = first_line; ln <= end_line; ln++) {
          if (ln in lines && lines[ln] !~ /^<!--/) print lines[ln]
        }
        print ""
      }
    }
  ' "$file"
}

slice=$(extract_slice "$AGENTS_FILE")

# Guard: no bullets extracted
if [ -z "$slice" ]; then
  exit 0
fi

message=$(printf 'AGENTS.md was updated since last session — recently curated patterns to keep in mind during this session:\n\n%s\nFull AGENTS.md is at the project root if you need older context.' "$slice")

printf '%s' "$message" | jq -Rs '{systemMessage: .}'

exit 0
```

- [ ] **Step 2: Run test runner; tests 1, 9 should pass**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `PASS: test-01a/b/c, test-09, test-12` — `Tests: 5 passed, 0 failed`.

(Test 12 now exercises the jq guard and passes correctly.)

- [ ] **Step 3: ShellCheck the new script**

Run: `shellcheck ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`
Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: implement slice extraction (tests 1, 12)"
```

---

## Task 6: Tests 2, 3, 4 (RED) — section-absent / empty / few-bullet handling

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/no-style.md`
- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/empty-gotchas.md`
- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/few-design.md`
- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`

- [ ] **Step 1: Create fixture `no-style.md` (STYLE absent)**

Same as `standard.md` but with the entire `## STYLE` section + bullets removed.

- [ ] **Step 2: Create fixture `empty-gotchas.md` (GOTCHAS heading present, zero bullets)**

Same as `standard.md` but the `## GOTCHAS` section contains only an HTML comment, no bullet lines:

```markdown
## GOTCHAS

<!-- No gotchas yet. -->

```

- [ ] **Step 3: Create fixture `few-design.md` (DESIGN_DECISIONS has only 2 bullets)**

Same as `standard.md` but `## DESIGN_DECISIONS` has only:

```markdown
## DESIGN_DECISIONS

- Design bullet 1
- Design bullet 2
```

- [ ] **Step 4: Add failing tests 2, 3, 4**

Append to test runner:

```bash
# Test 2: STYLE absent → STYLE omitted, others present
out=$(run_hook_in_tmp "no-style.md")
if echo "$out" | grep -q '"## STYLE'; then
  FAILED=$((FAILED + 1))
  FAILURES+=("test-02: STYLE should be omitted")
  echo "FAIL: test-02"
else
  PASSED=$((PASSED + 1))
  echo "PASS: test-02: STYLE absent → omitted"
fi
assert_emits "test-02b: GOTCHAS still emitted" "$out" '"## GOTCHAS'

# Test 3: GOTCHAS heading present but zero bullets → GOTCHAS omitted
out=$(run_hook_in_tmp "empty-gotchas.md")
if echo "$out" | grep -q '"## GOTCHAS'; then
  FAILED=$((FAILED + 1))
  FAILURES+=("test-03: GOTCHAS with zero bullets should be omitted")
  echo "FAIL: test-03"
else
  PASSED=$((PASSED + 1))
  echo "PASS: test-03: GOTCHAS empty → omitted"
fi

# Test 4: DESIGN_DECISIONS has only 2 bullets → both emitted
out=$(run_hook_in_tmp "few-design.md")
assert_emits "test-04a: DESIGN bullet 1 emitted" "$out" "Design bullet 1"
assert_emits "test-04b: DESIGN bullet 2 emitted" "$out" "Design bullet 2"
```

- [ ] **Step 5: Run test runner; expect 2, 3, 4 to PASS already**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: All previously-passing tests + tests 2, 3, 4 pass. Total: 10 passed.

The slice extractor in Task 6 already handles these cases — sections with zero bullets are skipped (`if (... bullet_count[s] == 0) continue`), and absent sections never get an entry in `bullet_count`. Tests 2, 3, 4 verify the implementation rather than driving new code.

- [ ] **Step 6: Commit fixtures + tests**

```bash
git add ai-literacy-superpowers/hooks/scripts/test/fixtures/no-style.md ai-literacy-superpowers/hooks/scripts/test/fixtures/empty-gotchas.md ai-literacy-superpowers/hooks/scripts/test/fixtures/few-design.md ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: tests 2,3,4 — section-absent/empty/few-bullet"
```

---

## Task 7: Test 5 (RED → GREEN) — multi-line bullets preserved

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/multi-line.md`
- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`

- [ ] **Step 1: Create fixture `multi-line.md`**

```markdown
# Compound Learning

## STYLE

- Multi-line bullet one. This bullet has a continuation
  paragraph that spans multiple lines and should be
  preserved verbatim in the slice.

- Multi-line bullet two with its
  own continuation.

- Multi-line bullet three covers
  the third position and is the
  one that should appear in the
  last-3 slice along with bullets
  one and two (which are positions 1 and 2).

## GOTCHAS

- Single line gotcha.
```

- [ ] **Step 2: Add test 5**

```bash
# Test 5: multi-line bullets → continuation lines preserved
out=$(run_hook_in_tmp "multi-line.md")
assert_emits "test-05a: continuation 'preserved verbatim' present" "$out" "preserved verbatim"
assert_emits "test-05b: continuation 'own continuation' present" "$out" "own continuation"
assert_emits "test-05c: continuation 'positions 1 and 2' present" "$out" "positions 1 and 2"
```

- [ ] **Step 3: Run test runner**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: tests 5a, 5b, 5c pass — the existing extractor emits the line range from the (count-n+1)th bullet's line through end-of-section, which captures continuations. Total: 13 passed.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/test/fixtures/multi-line.md ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: test 5 — multi-line bullet continuations"
```

---

## Task 8: Test 6 (RED) — first run creates marker

**Files:**

- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`

- [ ] **Step 1: Augment `run_hook_in_tmp` to expose the tmp dir**

Replace `run_hook_in_tmp` with a version that does not auto-cleanup so tests can inspect marker state:

```bash
run_hook_keep_tmp() {
  local fixture="$1"
  local marker_content="${2:-}"
  local tmp
  tmp=$(mktemp -d)
  if [ -n "$fixture" ] && [ -f "${FIXTURES_DIR}/${fixture}" ]; then
    cp "${FIXTURES_DIR}/${fixture}" "${tmp}/AGENTS.md"
  fi
  if [ -n "$marker_content" ]; then
    mkdir -p "${tmp}/.claude"
    printf '%s' "$marker_content" > "${tmp}/.claude/.agents-md-last-seen"
  fi
  CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null
  echo "TMP_DIR=$tmp" >&2
}
```

(For tests 6, 7, 8, 11 we use this variant. The original `run_hook_in_tmp` is left in place for tests that don't need post-run inspection.)

- [ ] **Step 2: Add test 6**

```bash
# Test 6: no marker file → injects + creates marker
tmp=$(mktemp -d)
cp "${FIXTURES_DIR}/standard.md" "${tmp}/AGENTS.md"
out=$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null)
assert_emits "test-06a: emits slice on first run" "$out" "Style bullet 4"
if [ -f "${tmp}/.claude/.agents-md-last-seen" ]; then
  PASSED=$((PASSED + 1))
  echo "PASS: test-06b: marker file created on first run"
else
  FAILED=$((FAILED + 1))
  FAILURES+=("test-06b: marker file not created")
  echo "FAIL: test-06b"
fi
rm -rf "$tmp"
```

- [ ] **Step 3: Run test runner; test 6b should FAIL**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: test 6a passes (slice still emitted), test 6b FAILS (marker file not yet written by the script).

---

## Task 9: Test 6 (GREEN) — write marker after emitting

**Files:**

- Modify: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`

- [ ] **Step 1: Add hash computation and marker write at end of script**

Replace the final block (`printf '%s' ... | jq -Rs ...; exit 0`) with:

```bash
printf '%s' "$message" | jq -Rs '{systemMessage: .}'

current_hash=$(sha256sum "$AGENTS_FILE" | cut -d' ' -f1)
mkdir -p "$(dirname "$MARKER_FILE")"
printf '%s' "$current_hash" > "$MARKER_FILE"

exit 0
```

- [ ] **Step 2: Run test runner; test 6 fully passes**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: test 6a + 6b PASS. Total: 15 passed.

- [ ] **Step 3: ShellCheck**

Run: `shellcheck ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`
Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: write marker after emit (test 6)"
```

---

## Task 10: Tests 7, 8 (RED → GREEN) — hash dismissal logic

**Files:**

- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
- Modify: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`

- [ ] **Step 1: Add tests 7, 8 to test runner**

```bash
# Test 7: marker hash matches AGENTS.md → silent exit, no stdout
tmp=$(mktemp -d)
cp "${FIXTURES_DIR}/standard.md" "${tmp}/AGENTS.md"
mkdir -p "${tmp}/.claude"
known_hash=$(sha256sum "${tmp}/AGENTS.md" | cut -d' ' -f1)
printf '%s' "$known_hash" > "${tmp}/.claude/.agents-md-last-seen"
out=$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null)
assert_silent "test-07: matching hash → silent exit" "$out"
rm -rf "$tmp"

# Test 8: stale hash → injects + updates marker
tmp=$(mktemp -d)
cp "${FIXTURES_DIR}/standard.md" "${tmp}/AGENTS.md"
mkdir -p "${tmp}/.claude"
printf 'stale_hash_value' > "${tmp}/.claude/.agents-md-last-seen"
out=$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null)
assert_emits "test-08a: stale hash → emits slice" "$out" "Style bullet 4"
new_hash=$(cat "${tmp}/.claude/.agents-md-last-seen")
expected_hash=$(sha256sum "${tmp}/AGENTS.md" | cut -d' ' -f1)
if [ "$new_hash" = "$expected_hash" ]; then
  PASSED=$((PASSED + 1))
  echo "PASS: test-08b: marker updated to current hash"
else
  FAILED=$((FAILED + 1))
  FAILURES+=("test-08b: marker not updated. Got: $new_hash, expected: $expected_hash")
  echo "FAIL: test-08b"
fi
rm -rf "$tmp"
```

- [ ] **Step 2: Run test runner; expect test 7 FAIL (script always emits)**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: test 7 FAILS (script doesn't yet check the marker). Test 8a passes (script emits regardless). Test 8b passes (marker is now written from Task 10).

- [ ] **Step 3: Add hash check at top of script (after AGENTS.md and jq guards)**

Insert after the `jq` guard:

```bash
# Compute current hash
current_hash=$(sha256sum "$AGENTS_FILE" | cut -d' ' -f1)

# Compare to stored marker
if [ -f "$MARKER_FILE" ]; then
  stored_hash=$(cat "$MARKER_FILE" 2>/dev/null || echo "")
  if [ "$stored_hash" = "$current_hash" ]; then
    exit 0
  fi
fi
```

Then update the bottom to reuse `current_hash` (don't recompute):

```bash
printf '%s' "$message" | jq -Rs '{systemMessage: .}'

mkdir -p "$(dirname "$MARKER_FILE")"
printf '%s' "$current_hash" > "$MARKER_FILE"

exit 0
```

- [ ] **Step 4: Run test runner; tests 7, 8 PASS**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `Tests: 18 passed, 0 failed`.

- [ ] **Step 5: ShellCheck**

Run: `shellcheck ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`
Expected: no warnings.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: hash-based dismissal (tests 7, 8)"
```

---

## Task 11: Tests 10, 11 (RED → GREEN) — zero-bullet and missing-.claude/

**Files:**

- Create: `ai-literacy-superpowers/hooks/scripts/test/fixtures/no-bullets.md`
- Modify: `ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`

- [ ] **Step 1: Create fixture `no-bullets.md` (all 5 sections, all empty)**

```markdown
# Compound Learning

## STYLE

<!-- No entries yet. -->

## GOTCHAS

<!-- No entries yet. -->

## ARCH_DECISIONS

<!-- No entries yet. -->

## TEST_STRATEGY

<!-- No entries yet. -->

## DESIGN_DECISIONS

<!-- No entries yet. -->
```

- [ ] **Step 2: Add tests 10 and 11**

```bash
# Test 10: AGENTS.md present but zero bullets in any section → silent exit
out=$(run_hook_in_tmp "no-bullets.md")
assert_silent "test-10: zero bullets across all sections → silent exit" "$out"

# Test 11: .claude/ directory missing → mkdir -p before writing marker
tmp=$(mktemp -d)
cp "${FIXTURES_DIR}/standard.md" "${tmp}/AGENTS.md"
# Note: no .claude/ subdir created
out=$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK_SCRIPT" 2>/dev/null)
if [ -d "${tmp}/.claude" ] && [ -f "${tmp}/.claude/.agents-md-last-seen" ]; then
  PASSED=$((PASSED + 1))
  echo "PASS: test-11: .claude/ directory created"
else
  FAILED=$((FAILED + 1))
  FAILURES+=("test-11: .claude/ directory not created")
  echo "FAIL: test-11"
fi
rm -rf "$tmp"
```

- [ ] **Step 3: Run test runner**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: tests 10 and 11 PASS already — test 10 because the slice extractor returns empty when all sections have zero bullets and the existing zero-slice guard exits silently; test 11 because `mkdir -p` was added in Task 10. `Tests: 20 passed, 0 failed`.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/test/fixtures/no-bullets.md ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
git commit -m "agents-md-readback: tests 10, 11 — zero bullets and missing .claude/"
```

---

## Task 12: Refactor pass

**Files:**

- Review/refactor: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`

- [ ] **Step 1: Re-read script for clarity, naming, comments**

Check:
- Header comment block accurate and complete
- Variable names clear (`PROJECT_DIR`, `AGENTS_FILE`, `MARKER_FILE`, `N`, `current_hash`, `stored_hash`, `slice`, `message`)
- No dead code
- ShellCheck still clean
- All 20 tests still pass

- [ ] **Step 2: Run final test suite + ShellCheck**

```bash
bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
shellcheck ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh
shellcheck ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
bash -n ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh
```

Expected: all green.

- [ ] **Step 3: Commit only if changes were made**

```bash
git diff --stat ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh
# If changes:
git add ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh
git commit -m "agents-md-readback: refactor pass for clarity"
# If no changes, skip commit
```

---

## Task 13: Register hook in hooks.json

**Files:**

- Modify: `ai-literacy-superpowers/hooks/hooks.json`

- [ ] **Step 1: Add new entry to the SessionStart array**

The `SessionStart` array currently contains one entry (`template-currency-check.sh`). Add a second:

```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/template-currency-check.sh",
        "timeout": 10
      },
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/agents-md-readback.sh",
        "timeout": 10
      }
    ]
  }
]
```

- [ ] **Step 2: Update the `description` field**

Change the file's top-level `description` from:

```json
"description": "Harness engineering hooks: ... template currency check (SessionStart) nudges on plugin upgrade"
```

to:

```json
"description": "Harness engineering hooks: ... template currency check and AGENTS.md read-back (SessionStart) nudge on plugin upgrade and inject recently-curated AGENTS.md content"
```

- [ ] **Step 3: Verify JSON well-formed**

Run: `jq . ai-literacy-superpowers/hooks/hooks.json > /dev/null && echo OK`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/hooks.json
git commit -m "Register agents-md-readback hook in hooks.json"
```

---

## Task 14: CLAUDE.md note

**Files:**

- Modify: `CLAUDE.md`

- [ ] **Step 1: Insert the AGENTS.md Read-Back section before "Sync from Source"**

Find the line `## Sync from Source` and insert before it:

```markdown
## AGENTS.md Read-Back

Every session, the SessionStart hook `agents-md-readback.sh` checks
whether `AGENTS.md` has changed since you last saw it. If so, it
injects the most recently curated patterns (last 3 bullets per section)
into the session as a `systemMessage`. This closes the compound-learning
loop — curated patterns reach future sessions without depending on
agent discretion.

The hook is auto-dismissing: it updates `.claude/.agents-md-last-seen`
after each emission. To re-trigger, edit `AGENTS.md` (any change to
the hash will do).

```

- [ ] **Step 2: Verify markdownlint clean**

Run: `npx markdownlint-cli2 CLAUDE.md`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "CLAUDE.md: document AGENTS.md read-back hook"
```

---

## Task 15: Extend docs/explanation/compound-learning.md

**Files:**

- Modify: `docs/explanation/compound-learning.md`

- [ ] **Step 1: Read current state**

Run: `cat docs/explanation/compound-learning.md | head -80`
Expected: an existing explanation page covering REFLECTION_LOG → curation → AGENTS.md.

- [ ] **Step 2: Locate the existing loop diagram**

Search for an ASCII diagram showing the loop. If present, update it; if not, add a new one.

- [ ] **Step 3: Append a new subsection at the end of the page**

```markdown
## Read-back at session start

The compound-learning loop has three stages:

```text
REFLECTION_LOG.md  →  AGENTS.md  →  next session
   (capture)         (curation)     (read-back)
```

Capture and curation are surfaced by hooks: `reflection-prompt.sh`
nudges to capture, `curation-nudge.sh` nudges to curate. Read-back is
where the loop has historically broken down — the pattern "agents
should read AGENTS.md at session start" is a convention without
enforcement.

The `agents-md-readback.sh` SessionStart hook closes that gap. When
AGENTS.md has changed since last seen, the hook injects the last 3
bullets per section as a `systemMessage`. The mechanism is:

1. Hash AGENTS.md with SHA-256
2. Compare to `.claude/.agents-md-last-seen`
3. If unchanged → silent exit
4. If changed → emit slice, update marker

The dismissal is per-AGENTS.md-version: each promotion event triggers
exactly one re-injection on the next session. After that, the hook
stays silent until AGENTS.md changes again.

See `docs/how-to/work-with-agents-md.md` for promotion flow,
verification, and customisation.
```

- [ ] **Step 4: Verify markdownlint**

Run: `npx markdownlint-cli2 docs/explanation/compound-learning.md`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add docs/explanation/compound-learning.md
git commit -m "docs: explain AGENTS.md read-back stage of compound-learning loop"
```

---

## Task 16: New docs/how-to/work-with-agents-md.md

**Files:**

- Create: `docs/how-to/work-with-agents-md.md`

- [ ] **Step 1: Create the page**

```markdown
# Work with AGENTS.md

`AGENTS.md` is the project's compound-learning memory — patterns,
gotchas, and architectural decisions curated from past sessions.
This guide covers the day-to-day flows.

## Promote a reflection

Reflections are captured in `REFLECTION_LOG.md`. When a pattern
recurs across reflections, promote it to `AGENTS.md`:

1. Identify the pattern across two or more REFLECTION_LOG entries.
2. Decide which AGENTS.md section it belongs to: STYLE (idioms),
   GOTCHAS (traps), ARCH_DECISIONS (decisions and their alternatives),
   TEST_STRATEGY (how tests are structured), DESIGN_DECISIONS
   (interface contracts).
3. Append a bullet to that section. Cite the source reflection date.
4. Commit on a branch with the `chore` label (this is a
   reflection-driven amendment, not a feature).

## What the hook does

The `agents-md-readback.sh` SessionStart hook checks AGENTS.md against
its last-seen hash. If AGENTS.md has changed, the hook emits the last
3 bullets per section as a `systemMessage`, then writes the new hash
to `.claude/.agents-md-last-seen` to silence itself until next change.

## Verify the hook is working

1. Make a trivial AGENTS.md edit (add a bullet, save).
2. Start a fresh session in the project.
3. Look for the systemMessage at session start: "AGENTS.md was updated
   since last session — recently curated patterns…"
4. Inspect the marker: `cat .claude/.agents-md-last-seen`
5. Start another session — the message should NOT re-appear.

If you don't see the message:

- Check that AGENTS.md exists at the project root.
- Check that `jq` is on PATH (`command -v jq`).
- Check the hook ran without error: `bash ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`.

## Silence the hook for the current AGENTS.md state

The hook auto-silences after one emission per AGENTS.md version. You
do not need to do anything — once you see the slice, the marker is
updated and the hook stays quiet until AGENTS.md changes again.

To force a re-trigger: edit AGENTS.md (any change to the hash will do)
or delete the marker:

```bash
rm .claude/.agents-md-last-seen
```

## Customise the slice

The hook injects the last 3 bullets per section by default. To change
this, edit `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh`
and adjust the `N` constant near the top of the file.

To recognise additional section names, modify the `sections` array in
the same script. Sections not in the array are silently ignored.

## Disable the hook entirely

The plugin's hooks.json is the source of truth for installed hooks.
To disable for a specific project without modifying the plugin, add
a project-local override at `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": []
  }
}
```

This will replace the SessionStart hooks for this project only. Note
that doing so also disables `template-currency-check.sh`. If you want
to keep that one, copy it into the override.
```

- [ ] **Step 2: Verify markdownlint**

Run: `npx markdownlint-cli2 docs/how-to/work-with-agents-md.md`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add docs/how-to/work-with-agents-md.md
git commit -m "docs: how-to for working with AGENTS.md and the read-back hook"
```

---

## Task 17: CI test job

**Files:**

- Modify: `.github/workflows/harness.yml`

- [ ] **Step 1: Read current state**

Run: `cat .github/workflows/harness.yml`
Expected: an existing GitHub Actions workflow with at least one job (likely a constraint enforcer).

- [ ] **Step 2: Add a new job for the test runner**

Append (before the final `# vim: ft=yaml` or at end of jobs block):

```yaml
  agents-md-readback-tests:
    name: AGENTS.md read-back hook tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install jq
        run: sudo apt-get update && sudo apt-get install -y jq
      - name: Run test runner
        run: bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
```

- [ ] **Step 3: Verify YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/harness.yml'))" && echo OK`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/harness.yml
git commit -m "CI: run agents-md-readback test runner on every PR"
```

---

## Task 18: Version bump

**Files:**

- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `ai-literacy-superpowers/.claude-plugin/marketplace.json` (root file at `.claude-plugin/marketplace.json`)
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump plugin.json version 0.31.0 → 0.32.0**

Edit `ai-literacy-superpowers/.claude-plugin/plugin.json`, change `"version": "0.31.0"` to `"version": "0.32.0"`.

- [ ] **Step 2: Sync marketplace.json plugin_version**

Edit `.claude-plugin/marketplace.json`, change both occurrences of `0.31.0` to `0.32.0` (top-level `plugin_version` and the entry inside the `plugins` array).

- [ ] **Step 3: Update README plugin badge**

Edit `README.md`, change `Plugin-v0.31.0` to `Plugin-v0.32.0`.

- [ ] **Step 4: Update README hook count**

Edit `README.md`:

- Change `### Hooks (11)` to `### Hooks (12)`.
- Add a new bullet at the end of the Hooks section: `- **SessionStart AGENTS.md read-back** — injects last 3 bullets per section of AGENTS.md when changed since last session`.
- Update the Mechanism Map ADVISORY LOOP block: add `│   └── SessionStart AGENTS.md read-back   When AGENTS.md hash differs, injects last 3 bullets/section` next to the existing template-currency entry.

- [ ] **Step 5: Add CHANGELOG entry**

Edit `CHANGELOG.md`. Insert at the top under a new heading:

```markdown
## 0.32.0 — 2026-04-28

### Added

- **AGENTS.md read-back SessionStart hook** (`agents-md-readback.sh`).
  Injects the last 3 bullets per section of `AGENTS.md` whenever the
  file has changed since last session. Closes the read-back stage of
  the compound-learning loop. Hash-based auto-dismissal mirrors
  `template-currency-check.sh`. Ships in plugin's hooks.json so
  downstream consumers inherit the closed loop. Spec:
  `docs/superpowers/specs/2026-04-28-agents-md-readback-hook-design.md`.
- **Test runner for read-back hook** (`hooks/scripts/test/test-agents-md-readback.sh`):
  12 fixture-based test cases covering slice extraction, hash
  dismissal, and edge cases. Wired into CI via `harness.yml`.
- **CLAUDE.md AGENTS.md Read-Back section**: documents the mechanism
  for humans reading project conventions.
- **`docs/how-to/work-with-agents-md.md`**: task-oriented guide for
  promotion, verification, customisation, and disabling the hook.
- **`docs/explanation/compound-learning.md`** extended: covers the
  read-back stage end-to-end with the updated three-stage diagram.
```

- [ ] **Step 6: Run version-consistency check locally if available**

Run: `grep -E '"version":\s*"0\.32\.0"' ai-literacy-superpowers/.claude-plugin/plugin.json && grep -E "Plugin-v0\.32\.0" README.md && grep -E "^## 0\.32\.0" CHANGELOG.md && echo OK`
Expected: `OK`.

- [ ] **Step 7: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json .claude-plugin/marketplace.json README.md CHANGELOG.md
git commit -m "v0.32.0: AGENTS.md read-back SessionStart hook"
```

---

## Task 19: Final verification

**Files:** none modified

- [ ] **Step 1: Run full test runner**

Run: `bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh`
Expected: `Tests: 20 passed, 0 failed` and exit 0.

- [ ] **Step 2: ShellCheck all .sh files in hooks/scripts/**

Run: `find ai-literacy-superpowers/hooks/scripts -name "*.sh" -exec shellcheck {} +`
Expected: no warnings.

- [ ] **Step 3: bash syntax check**

Run: `find ai-literacy-superpowers/hooks/scripts -name "*.sh" -exec bash -n {} +`
Expected: silent (no errors).

- [ ] **Step 4: markdownlint pass**

Run: `npx markdownlint-cli2 "**/*.md"`
Expected: no errors across all markdown.

- [ ] **Step 5: hooks.json validity**

Run: `jq . ai-literacy-superpowers/hooks/hooks.json > /dev/null && echo OK`
Expected: `OK`.

- [ ] **Step 6: gitleaks scan**

Run: `gitleaks detect --source . --no-banner --exit-code 1`
Expected: no leaks.

- [ ] **Step 7: Manual integration test**

In a fresh terminal:

```bash
# Edit AGENTS.md trivially
echo "" >> AGENTS.md
echo "<!-- integration test marker -->" >> AGENTS.md

# Start a Claude Code session in this repo
# Look for the systemMessage at session start
```

Confirm:
1. systemMessage appears with last-3-per-section content.
2. `.claude/.agents-md-last-seen` exists and matches `sha256sum AGENTS.md | cut -d' ' -f1`.
3. Starting a second session shows no systemMessage (auto-dismiss works).

Revert the AGENTS.md edit before commit.

- [ ] **Step 8: Open the PR**

```bash
git push -u origin agents-md-readback-hook
gh pr create --title "v0.32.0: AGENTS.md read-back SessionStart hook" --body "$(cat <<'EOF'
## Summary

Closes the half-closed compound-learning loop identified in the 2026-04-28 AI literacy assessment (Q3). New SessionStart hook `agents-md-readback.sh` injects the last 3 bullets per section of AGENTS.md whenever the file has changed since last session, with hash-based auto-dismissal mirroring `template-currency-check.sh`.

Spec: `docs/superpowers/specs/2026-04-28-agents-md-readback-hook-design.md`
Plan: `docs/superpowers/plans/2026-04-28-agents-md-readback-hook.md`

## Files

- New script + 12-case test runner + 5 fixtures (`hooks/scripts/`)
- New SessionStart entry in `hooks.json`
- New `docs/how-to/work-with-agents-md.md`
- Extended `docs/explanation/compound-learning.md`
- New CLAUDE.md section
- New CI job in `harness.yml`
- v0.32.0 bump

## Test plan

- [x] All 20 unit tests pass locally
- [x] ShellCheck clean
- [x] markdownlint clean
- [x] hooks.json well-formed
- [x] gitleaks clean
- [ ] CI green
- [x] Integration test: edit AGENTS.md, start session, see slice; second session is silent

## Pipeline

This is a feature PR. Spec-first commit ordering satisfied (PR's first commit was spec-only). Pending: spec-time `/diaboli` adjudication, `/choice-cartograph` adjudication, code-time `/diaboli` adjudication. These run before merge per the harness.
EOF
)"
```

---

## Self-Review Notes

**Coverage check** against spec:

- Goal 1 (inject content) → Tasks 4-5 (slice extraction + emission)
- Goal 2 (bound token cost) → Last-3-per-section in slice extractor (Task 5 awk implementation)
- Goal 3 (auto-silence) → Tasks 8-10 (hash-based dismissal)
- Goal 4 (ship to consumers) → Task 13 (hooks.json registration)
- Companion: CLAUDE.md → Task 14
- Companion: docs explanation → Task 15
- Companion: docs how-to → Task 16
- Verification → Tasks 1-12 (TDD cycles), Task 19 (final + integration)

All five spec sections covered.

**Type/name consistency**:

- Hook script path: `ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh` — same in spec, hooks.json reference, test runner, CI job, CLAUDE.md note, CHANGELOG, docs.
- Marker file: `.claude/.agents-md-last-seen` — same throughout.
- N=3 constant — same throughout.
- Section names: STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS — same in spec, awk script, fixture files.

**Placeholder scan**: no TBD/TODO/FIXME placeholders. Every step has actual code or actual commands.

**Scope check**: 20 tasks, single concern (AGENTS.md read-back hook), single PR. Tractable.
