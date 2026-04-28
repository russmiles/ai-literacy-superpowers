# Spec: AGENTS.md read-back SessionStart hook

**Date**: 2026-04-28
**Author**: Russ Miles + assistant (via brainstorming skill)
**Driving signal**: 2026-04-28 AI literacy assessment, Q3 — *originally framed
as* half-closed compound-learning loop
**Status**: **ABANDONED 2026-04-28 — premise refuted by spec-mode `/diaboli`
adjudication of O1**

## Why this spec was abandoned

The spec's premise was that AGENTS.md content does not reach agents at session
start unless an explicit injection mechanism is added. The spec-mode diaboli
pass surfaced O1 (high severity, premise category): Claude Code already loads
`AGENTS.md` as project memory at session start — it is a named project-memory
file alongside CLAUDE.md.

The Q3 finding from the 2026-04-28 assessment that motivated this spec was
about the absence of an *uptake signal* (we cannot tell whether agents used
the AGENTS.md content) rather than absence of *exposure* (the content is in
context). The spec doubled down on the wrong interpretation. The hook would
have been redundant for the exposure problem and would not have addressed
the signal problem.

See `docs/superpowers/objections/agents-md-readback-hook-design.md` for the
full adjudication. O2 was the more accurate framing all along.

The spec content below is preserved as historical record. Do not implement.

---

## Problem

The 2026-04-28 AI literacy assessment surfaced a precise gap in this
project's compound-learning loop:

> Capture and curation are textbook (25 reflections at 84% signal coverage,
> two patterns promoted to AGENTS.md ARCH_DECISIONS today). But read-back
> at session start is by convention only. The patterns curated in
> AGENTS.md cannot shape future sessions if no reliable trigger surfaces
> them when an agent boots. The plugin already demonstrates the
> architectural fix in `template-currency-check.sh` (a SessionStart hook
> with hash-based dismissal) but has never applied that pattern to its
> own AGENTS.md.

The gap is not in the AGENTS.md content (which is high-quality and well
maintained), nor in the curation discipline (which runs regularly via
the existing `curation-nudge.sh` Stop hook). The gap is in
**enforcement of read-back** — closing the third stage of the
compound-learning loop:

```text
REFLECTION_LOG.md  →  curation-nudge.sh  →  AGENTS.md  →  ???
   (capture)            (curation prompt)     (memory)     (read-back)
```

## Goals

1. **Inject recently-curated AGENTS.md content into a session at start**
   so that agents (human or LLM) reliably encounter the patterns the
   project has decided are worth carrying forward.
2. **Bound the token cost** so the injection is sustainable on every
   session — not the full AGENTS.md every time.
3. **Auto-silence after acknowledgement** so the same patterns are not
   re-injected forever; a fresh promotion re-triggers exposure once.
4. **Ship the mechanism to downstream consumers** so projects that
   adopt this plugin inherit a closed compound-learning loop, not just
   the curation prompt half of it.

## Non-goals

- This work does not redesign AGENTS.md format, sections, or curation flow.
- This work does not replace the Stop-time `curation-nudge.sh`. Curation
  prompt and read-back are distinct stages of the loop; both must run.
- This work does not introduce per-entry recency tracking. Hash-level
  dismissal (file-level granularity) is sufficient and matches existing
  plugin patterns.
- This work does not add a configuration UI for the hook. Power users
  edit the script; ordinary users get sensible defaults.

## Decisions

The design space was explored through five clarifying questions during
brainstorming. The decisions:

| # | Decision axis | Choice | Rationale |
|---|---|---|---|
| Q1 | What does the hook *do*? | **Hybrid**: inject recent slice + nudge to read full file | Pure injection wastes tokens every session; pure nudge recreates the original failure mode (relying on agent compliance with a nudge instead of a CLAUDE.md rule) |
| Q2 | What counts as "recent"? | **File-level (hash-based) dismissal** | Mirrors `template-currency-check.sh` exactly; one re-fire per promotion event; minimal state to maintain |
| Q3 | What slice does the hook inject? | **Last 3 bullets per section** (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS) | Preserves section semantics (each section is meaningfully different); empirically tracks "recently curated" because new entries are appended; bounded token cost (~3 × 5 × 150 words ≈ 2400-3000 tokens) |
| Q4a | Scope | **Ship in plugin's hooks.json** | Downstream consumers face the same half-closed-loop risk; silent-exit-on-no-AGENTS.md means consumers without it pay zero cost |
| Q4b | Dismissal automation | **Auto-dismiss** (script updates marker after emitting) | Desired behaviour is "show me what's new, then go quiet" — different from `template-currency-check.sh`'s "keep nudging until upgrade" |
| Q5 | Companion changes | **Hook + CLAUDE.md note + one docs page** | Required by "Docs site kept current" constraint; downstream consumers need explanation when the hook activates after a plugin update |

## Architecture

One new script, one hooks.json entry, two small docs changes, one
CLAUDE.md note.

```text
ai-literacy-superpowers/hooks/scripts/agents-md-readback.sh   ← new (~70 lines)
ai-literacy-superpowers/hooks/scripts/test/                   ← new directory
  test-agents-md-readback.sh                                  ← new (~150 lines)
  fixtures/                                                   ← test fixture AGENTS.md files
ai-literacy-superpowers/hooks/hooks.json                      ← +6 lines (SessionStart entry)
docs/explanation/compound-learning.md                         ← extended
docs/how-to/work-with-agents-md.md                            ← new
CLAUDE.md                                                     ← +3-line note
.github/workflows/harness.yml                                 ← +test runner job
CHANGELOG.md                                                  ← entry under v0.32.0
ai-literacy-superpowers/.claude-plugin/plugin.json            ← bump 0.31.0 → 0.32.0
ai-literacy-superpowers/.claude-plugin/marketplace.json       ← plugin_version sync
README.md                                                     ← Plugin badge bump + Hooks (11) → (12)
```

**Why a v0.32.0 minor bump (not patch)**: per CLAUDE.md semver rules, a
new hook is a behavioural change → minor bump.

### Component responsibilities

| Component | Responsibility | Reads | Writes |
|---|---|---|---|
| `agents-md-readback.sh` | Hash AGENTS.md, decide whether to inject, emit `systemMessage`, update marker | `$CLAUDE_PROJECT_DIR/AGENTS.md`, `$CLAUDE_PROJECT_DIR/.claude/.agents-md-last-seen` | stdout (JSON), `.claude/.agents-md-last-seen` |
| `test-agents-md-readback.sh` | Verify slice extraction, dismissal, edge cases (12 fixture-driven tests) | fixture AGENTS.md files in `fixtures/` | tmp dirs, exit code |
| `hooks.json` SessionStart entry | Register the hook with Claude Code | — | — |
| `docs/explanation/compound-learning.md` | Explain end-to-end loop including the new read-back stage | — | — |
| `docs/how-to/work-with-agents-md.md` | Task-oriented: promote, verify, customise, disable | — | — |
| `CLAUDE.md` note | Make the hook discoverable to humans reading project conventions | — | — |
| `harness.yml` test job | CI gate: every PR runs the test runner; fail if any test fails | — | — |

## Hook behaviour contract

### Decision flow

```text
SessionStart fires
    │
    ▼
[AGENTS.md exists at $CLAUDE_PROJECT_DIR/AGENTS.md?]
    │ no  → exit 0 silently
    │ yes
    ▼
Compute SHA-256 of AGENTS.md
    │
    ▼
[$CLAUDE_PROJECT_DIR/.claude/.agents-md-last-seen exists?]
    │ no  → first run; treat as "hash differs"
    │ yes
    ▼
[Stored hash equals current hash?]
    │ yes → exit 0 silently
    │ no
    ▼
Extract last 3 bullets per known section (STYLE, GOTCHAS,
ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS). Skip absent or
empty sections.
    │
    ▼
[Total bullets extracted equals 0?]
    │ yes → exit 0 silently (file exists but is unpopulated)
    │ no
    ▼
[jq available on PATH?]
    │ no  → exit 0 silently (graceful degradation)
    │ yes
    ▼
Format systemMessage JSON via `jq -Rs '{systemMessage: .}'`
Print JSON to stdout
mkdir -p $CLAUDE_PROJECT_DIR/.claude
Write current hash to $CLAUDE_PROJECT_DIR/.claude/.agents-md-last-seen
exit 0
```

### Slice extraction logic

AGENTS.md bullets often span multiple lines (continuation paragraphs).
The extractor must capture continuations, not just bullet-start lines.

For each known section heading:

1. Find section line range — from `## SECTION` heading to the next
   `## ` heading or EOF.
2. Within range, identify every line beginning `- ` (bullet starts);
   ignore lines inside HTML comments.
3. Find the line number of the (total − 3 + 1)th bullet start.
4. Emit lines from that line through the end of section, excluding HTML
   comments.

Implementation: `awk` block within the bash script. Subject to the
existing ShellCheck and `bash -n` constraints.

### systemMessage payload format

```text
AGENTS.md was updated since last session — recently curated patterns
to keep in mind during this session:

## STYLE

- [last 3 bullets…]

## GOTCHAS

- [last 3 bullets…]

## ARCH_DECISIONS

- [last 3 bullets…]

## TEST_STRATEGY

- [last 3 bullets…]

## DESIGN_DECISIONS

- [last 3 bullets…]

Full AGENTS.md is at the project root if you need older context.
```

The whole string lives in a JSON `systemMessage` field, with newlines
escaped (`\n`). Encoding via `jq -Rs '{systemMessage: .}'` is preferred
over manual `printf` escaping because the slice can contain quotes,
backslashes, and other JSON-active characters in arbitrary AGENTS.md
content.

### Edge cases handled silently

| Case | Behaviour |
|---|---|
| AGENTS.md missing | exit 0 silently |
| AGENTS.md present but zero `- ` bullets in any section | exit 0 silently |
| `.claude/` directory missing | `mkdir -p` before writing marker |
| Marker file unreadable / corrupt | treat as no marker; first-run path |
| `jq` not installed | exit 0 silently (graceful degradation) |
| AGENTS.md contains unexpected sections | known sections handled if present; unknown ignored |
| AGENTS.md is huge (~MB scale) | slice still bounded — last 3 bullets per section is naturally capped |

### Constraints honoured

- Always exit 0 (advisory only, never blocks) — required by hook conventions
- `set -euo pipefail` — existing constraint (shell scripts use strict mode)
- ShellCheck-clean — existing constraint
- Header comment block explaining purpose — existing convention
- Runs within hook timeout (10s) — script is O(file size) on a small file

## Companion changes

### CLAUDE.md addition

Inserted after the existing "Sync from Source" section. Three short
paragraphs (~120 words). Describes the mechanism rather than prescribing
a workflow.

### `docs/explanation/compound-learning.md` extension

- New subsection: `## Read-back at session start`
- Updated ASCII diagram of the loop (3-stage → 4-stage adding the
  readback hook)
- ~150 words explaining what the hook does, when it fires, why
  hash-based dismissal, why auto-dismiss
- Cross-link to the new how-to page

### New `docs/how-to/work-with-agents-md.md`

Task-oriented guide. Under 200 lines.

Sections:

1. Promote a reflection (mostly a cross-link to existing curation doc)
2. What the hook does (1 paragraph mirroring the CLAUDE.md note)
3. Verify the hook is working
4. Silence the hook for this AGENTS.md (auto-silences; edit the file
   to re-trigger)
5. Customise the slice (link to script; no abstraction layer)
6. Disable the hook entirely (project-level `hooks.json` override)

## Verification

The script's only non-trivial logic is slice extraction. Verification
focuses there.

### Approach

A hand-rolled bash test runner — `test-agents-md-readback.sh` — over
`bats`/`shunit2` (no test framework dependency to ship downstream).

### Test surface — 12 cases

**Slice extraction**:

| # | Fixture | Expected behaviour |
|---|---|---|
| 1 | All 4 sections populated, ≥3 bullets each | Last 3 bullets per section emitted |
| 2 | STYLE section absent | STYLE omitted; other 3 present |
| 3 | GOTCHAS present but zero bullets | GOTCHAS omitted from output |
| 4 | DESIGN_DECISIONS has only 2 bullets | All 2 emitted |
| 5 | Multi-line bullet content | Continuation lines preserved |

**Dismissal logic**:

| # | State | Expected behaviour |
|---|---|---|
| 6 | No marker file | Injects + creates marker |
| 7 | Marker hash matches AGENTS.md | Silent exit, no stdout |
| 8 | Marker hash stale | Injects + updates marker |

**Edge cases**:

| # | State | Expected behaviour |
|---|---|---|
| 9 | AGENTS.md missing | Silent exit |
| 10 | AGENTS.md present, zero bullets in any section | Silent exit |
| 11 | `.claude/` directory missing | `mkdir -p` before writing |
| 12 | `jq` not on PATH | Silent exit (graceful degradation) |

### TDD discipline

Per the global CLAUDE.md rule (no production code without a failing
test first):

1. Write the test runner with all 12 cases — every test red (script
   doesn't exist)
2. Build the script incrementally; each test goes red → green
3. Refactor while keeping all tests green

### Integration verification (manual, recorded in PR description)

- Start a fresh session in this repo with AGENTS.md unchanged → expect
  silence
- Edit AGENTS.md (e.g., add a trivial bullet) → next session shows the
  systemMessage
- Confirm no follow-up session re-fires until further AGENTS.md change

### CI integration

Add a job to `.github/workflows/harness.yml`:

```yaml
- name: AGENTS.md read-back hook tests
  run: bash ai-literacy-superpowers/hooks/scripts/test/test-agents-md-readback.sh
```

Strict-loop gate: PR fails if any test fails.

## Risks and open questions

- **Token cost surveyed but not measured**. Estimate is ~2400 tokens per
  emission. If actual session telemetry shows higher (e.g., the hook
  emits on every session due to noisy AGENTS.md edits), revisit the
  recency model — possibly add a min-interval to the dismissal logic.
- **Section names are baked into the script**. If a downstream consumer
  uses different AGENTS.md section names, the hook silently misses
  their content. Mitigation: the hook only injects sections it
  recognises; unknown sections are not an error. A future iteration
  could read section names from a config file. Not in v0.32.0 scope.
- **Hash collisions are theoretical**. SHA-256 collision odds are
  negligible for this purpose; not worth defending against.
- **Auto-dismiss may be wrong if user runs in a multi-window terminal
  setup**. If three sessions fire in the same minute, only the first
  sees the slice. Acceptable trade-off — the *purpose* is per-session
  awareness, not multi-session redundancy.

## Process

This spec is the first commit on branch `agents-md-readback-hook`.
After spec approval the project's full feature pipeline applies:

1. **Spec-time `/diaboli`** — adversarial review producing
   `docs/superpowers/objections/agents-md-readback-hook-design.md`
2. **Adjudicate** — resolve every disposition (no `pending` values)
3. **`/choice-cartograph`** — surface the implicit decision terrain;
   produces `docs/superpowers/stories/agents-md-readback-hook-design.md`
4. **Adjudicate stories** — every story has `accepted` / `revisit` /
   `promoted` disposition
5. **Plan via writing-plans skill** — implementation plan with task
   decomposition
6. **Implementation** — TDD: tests first, script second, then companion
   docs
7. **Code-time `/diaboli`** — adversarial review of implementation
   producing `docs/superpowers/objections/agents-md-readback-hook-design-code.md`
8. **Adjudicate code-mode objections** — resolve every disposition
9. **Integration** — open PR, watch CI, merge

Steps 1-4 must complete before step 5 to avoid wasted plan work if
spec changes.

## Cross-references

- 2026-04-28 AI literacy assessment, Q3 — the surfacing reflection
- `ai-literacy-superpowers/hooks/scripts/template-currency-check.sh` —
  the architectural template being mirrored
- `ai-literacy-superpowers/hooks/scripts/curation-nudge.sh` — the Stop
  hook that handles the curation half of the loop
- `docs/explanation/compound-learning.md` — existing explanation page
  being extended
- HARNESS.md constraints touched: "Docs site kept current",
  "Output validation checkpoints" (n/a here — this hook produces an
  unstructured systemMessage), "Tests must pass" (currently unverified;
  this work introduces the first executable tests in the project)
