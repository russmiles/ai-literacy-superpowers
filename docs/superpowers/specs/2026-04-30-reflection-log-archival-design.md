# Spec: Reflection log archival

**Date**: 2026-04-30
**Author**: Russ Miles + assistant (via brainstorming skill)
**Driving signal**: User concern that `REFLECTION_LOG.md` will grow over time, costing tokens at every read by the seven plugin agents and several commands that consume it; and that signal-to-noise will degrade as old/promoted entries accumulate alongside fresh ones. Cost compounds across the plugin's adopter base.
**Status**: design — awaiting spec-mode `/diaboli` and user review

## Problem

`REFLECTION_LOG.md` is the append-only output of the plugin's
compound-learning loop. The integration-agent appends a structured
reflection after each task; the human curator periodically reviews
entries and promotes worthy ones to `AGENTS.md` (or to a HARNESS.md
constraint). Promoted content then reaches every agent at session
start via `AGENTS.md`.

The log itself is **not** loaded at session start (no `SessionStart`
hook reads it; no priming convention requires it), but it **is** read
on-demand by:

- 7 agents (orchestrator, harness-enforcer, harness-gc,
  harness-auditor, assessor, choice-cartographer, integration-agent)
- 2 Stop hooks (`reflection-prompt`, `curation-nudge`)
- Several commands (`/reflect`, `/assess`, `/harness-health`,
  `/harness-audit`, `/superpowers-status`, `/governance-audit`)

At the time of writing the log is **457 lines / ~29 entries**.
Annualised growth at current cadence is roughly 100–200 entries / year.
Three failure modes follow, ranked by user emphasis:

1. **Signal-to-noise degradation (primary).** When an agent or
   command reads the log to look for recent learnings or recurring
   patterns, stale entries — particularly entries whose learning has
   already been promoted to `AGENTS.md` and is reaching agents that
   way already — drown out fresh signal. The reader's attention is
   the bottleneck, not the tokens themselves.

2. **Per-read cost compounds across many adopters (secondary).** The
   plugin is recommended to many users. Each adopter's project pays
   the same growing per-read cost. Aggregate token spend across
   thousands of installs is meaningful even when any single read is
   cheap.

3. **Per-project growth is unbounded over years (tertiary).** Inside
   any one long-lived project, the log grows linearly forever absent
   intervention.

## Goals

1. **Reduce signal-to-noise** in the active reflection log.
2. **Bound per-read token cost** across the adopter base.
3. **Bound per-project growth** over years.

## Non-goals

- Don't lose history. **Archive ≠ delete.** Every reflection ever
  appended remains queryable.
- Don't break existing readers. They should still find historical
  context when they need it (via the archive).
- Don't burden the curator beyond what fits in the existing monthly
  review cadence.
- Don't change `AGENTS.md` semantics. That file remains pure human
  curation; this spec touches only `REFLECTION_LOG.md` and
  introduces `reflections/archive/`.
- Don't change the append path. `/reflect` continues to write to the
  active log via PR per the existing `Reflections via PR workflow`
  constraint.

## Approach overview

A two-path archival model that matches the **safety profile** of the
signal driving the archival:

- **Path 1 — explicit promotion signal → auto-archive.** When a
  curator promotes a reflection to `AGENTS.md` or `HARNESS.md`, they
  add a one-line `Promoted` field to the source entry. A weekly,
  deterministic GC rule moves any entry with that field into the
  appropriate annual archive file. Auto-fix is safe because the
  signal is explicit.

- **Path 2 — absence of promotion signal → agent-augmented review.**
  Entries older than 6 months without a `Promoted` field are surfaced
  monthly by the `harness-gc` agent, which cross-references against
  newer entries and against `AGENTS.md` / `HARNESS.md` to recommend
  one of three dispositions (PROMOTE / SUPERSEDE / AGED-OUT). The
  curator decides. Auto-fix is **not** safe here because the absence
  of a promotion line is ambiguous — the entry might still be
  relevant, or it might warrant promotion that the curator has not
  yet got around to. Human judgement gates the move.

The asymmetry between Path 1 (auto-archive) and Path 2
(human-decided) is deliberate: it preserves the curation-nudge
forcing function that exists today (the active log keeps prompting
review) while still making the active log small in steady state.

## Schema change

Each reflection entry gains an **optional** `Promoted` field, added by
the curator at promotion time:

```markdown
- **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
```

Other valid right-hand sides:

- `→ HARNESS.md: <constraint name>` (when the learning became a
  constraint)
- `→ no promotion (single-instance learning)` (when the curator
  judges the entry not promotable but acknowledges its lifecycle is
  closed)
- `→ aged-out, no promotion warranted` (when Path 2 surfaces an
  aged-out entry the curator chooses to close)
- `→ superseded by <reflection-date>` (when a newer reflection
  carries the learning forward)

The `Promoted` line is **append-only** — once added, it is not
modified except to extend it (e.g., adding a second destination).
The curator adds it in the same commit as the AGENTS.md / HARNESS.md
edit, so the two changes are atomic.

The schema change is **backwards-compatible**: existing 29 entries
without a `Promoted` field continue to be valid; they're simply
ineligible for Path 1 auto-archive until tagged.

## Archive location and format

Annual files at:

```text
reflections/
└── archive/
    ├── 2026.md
    ├── 2027.md
    └── ...
```

**Annual granularity** chosen over quarterly because:

- File count stays manageable for decades (10–20 files in 10 years).
- Date-windowed queries are still trivial (`grep "Multi-repo"
  reflections/archive/*.md`).
- Quarterly would multiply file count by 4 with no commensurate
  benefit at current entry volume.

**Each archived entry preserves:**

- The full original text of the reflection (Date, Agent, Task,
  Surprise, Proposal, Improvement, Signal, Constraint, Session
  metadata).
- The `Promoted` field that triggered the archive.
- An additional `Archived` field added at archive time:
  `- **Archived**: 2026-05-22 (auto, Path 1)` or
  `(curator-confirmed, Path 2)`.

The archive file is itself a markdown document with the same
`---`-separated entry format as the active log, so any reader that
can parse the active log can parse the archive.

**Append order in the archive**: entries are appended in the order
they're archived, NOT re-sorted by original date. Chronological
order by archive timestamp is sufficient for query and avoids
re-write conflicts.

## Path 1 — Auto-archive of promoted entries

### Specification

| Field | Value |
|---|---|
| GC rule name | `Reflection log archival of promoted entries` |
| Frequency | weekly |
| Enforcement | deterministic |
| Tool | shell script (or `harness-gc` agent in script-mode) |
| Auto-fix | true |
| Scope | `REFLECTION_LOG.md` |

### Algorithm

1. Read `REFLECTION_LOG.md`.
2. Split into entries on `---` separators.
3. For each entry that contains a `Promoted` field:
   a. Determine the entry's original year from the `Date` field.
   b. Append the entry (with an added `Archived` line) to
      `reflections/archive/<YYYY>.md`, creating the file if missing.
   c. Remove the entry from `REFLECTION_LOG.md`.
4. Write back the trimmed `REFLECTION_LOG.md`.
5. Commit both files in a single commit titled
   `chore: auto-archive N promoted reflections`.

The script runs via the existing weekly GC workflow
(`gc.yml`) on the schedule already established for deterministic GC
rules. It operates only on entries with the explicit `Promoted`
signal — never on entries lacking it.

### Failure modes

- **Concurrent edit during the GC run**: handled via PR-based
  workflow on a branch, with rebase-and-retry on conflict. The
  script must use the `Reflections via PR workflow` constraint's
  branch-and-PR pattern.
- **Malformed `Promoted` line**: skip the entry, log a warning, do
  not block the run.
- **Archive file write failure**: abort the run before modifying
  the active log. Atomicity matters.

## Path 2 — Agent-augmented aged-out review

### Specification

| Field | Value |
|---|---|
| GC rule name | `Reflection log aged-out review` |
| Frequency | monthly |
| Enforcement | agent |
| Tool | `harness-gc` agent |
| Auto-fix | false |
| Scope | `REFLECTION_LOG.md` |

### Algorithm

1. Read `REFLECTION_LOG.md`.
2. Filter to entries older than **6 months** (calculated from the
   `Date` field) that lack a `Promoted` field.
3. For each candidate, the `harness-gc` agent:
   a. Reads the entry's `Surprise`, `Proposal`, and `Improvement`
      fields.
   b. Cross-references against newer reflection entries: does the
      same pattern recur? Count occurrences.
   c. Cross-references against current `AGENTS.md` and `HARNESS.md`:
      is this learning already implicitly captured (text overlap or
      semantic match)?
   d. Emits a per-entry recommendation:
      - **PROMOTE** if the pattern recurs in newer entries (≥1
        recurrence) and is not already in `AGENTS.md` / `HARNESS.md`.
      - **SUPERSEDE** if the learning is already captured in
        `AGENTS.md` / `HARNESS.md`.
      - **AGED-OUT** otherwise (single-instance, not captured, no
        recurrence).
   e. Writes a one-sentence rationale per recommendation.
4. Outputs a structured report at
   `observability/reflection-aged-out-<YYYY-MM-DD>.md` containing all
   candidates with recommendations and rationales.
5. Surfaces the report to the curator via the monthly cadence (same
   surfacing mechanism as other monthly GC outputs).

### Curator workflow (per entry)

For each entry in the report:

1. **Promote** — manually edit `AGENTS.md` or `HARNESS.md` (per the
   plugin's existing curation discipline), then add a `Promoted`
   line to the source entry. Path 1 archives the entry on its next
   weekly run.
2. **Mark closed** — add a `Promoted: → aged-out, no promotion
   warranted` line. Path 1 archives the entry on its next weekly
   run.
3. **Mark superseded** — add a `Promoted: → superseded by <newer
   reflection date>` line. Path 1 archives.
4. **Keep** — leave the entry untouched. The next monthly Path 2
   run will surface it again, with potentially different
   recommendations as the surrounding context evolves.

### Why agent enforcement, not deterministic

Path 2 needs cross-reference and recommendation logic that resists a
clean shell-script expression. The `harness-gc` agent already does
similar pattern-detection work (see the existing
`Reflection-driven regression detection` GC rule, which is also
agent-enforced). Adding this capability there is the natural fit.

### Failure modes

- **Agent recommendation is wrong**: curator overrides. The agent's
  recommendation is a starting point, not a decision.
- **Cross-reference produces false positives** (e.g., text overlap
  flags an entry as superseded when it's actually a different
  learning): curator catches at review time.
- **Curator does not act on the report**: entries remain in the
  active log. The same entries will be re-surfaced next month,
  giving the system a recurring forcing function rather than a
  one-shot.

## Reader updates

| Reader | Change required |
|---|---|
| `/reflect` (append) | None. Always appends to active log. |
| `curation-nudge.sh` Stop hook | None. Cleaner signal — archived entries no longer count toward the unpromoted-recent count. |
| `reflection-prompt.sh` Stop hook | None. Operates only on the current commit, not the log. |
| **`harness-gc` agent** | Adds two new GC-rule implementations: `Reflection log archival of promoted entries` (Path 1) and `Reflection log aged-out review` (Path 2). Existing `Reflection-driven regression detection` rule extended to read both `REFLECTION_LOG.md` and `reflections/archive/*.md`. |
| **`harness-auditor` agent** | When auditing reflection-related claims in `HARNESS.md` Status, also consults the archive. |
| **`governance-auditor` agent** | When looking for governance-related patterns over time, reads both active log and archive. |
| **`assessor` agent** | When extracting evidence of compound learning, counts entries across active + archive. |
| **`choice-cartographer` agent** | When assessing decision archaeology continuity, reads both. |
| **`orchestrator` agent** | None directly; downstream agents handle their own reading. |
| **`integration-agent`** | Append path unchanged; documents the `Promoted` field convention in its post-task workflow. |
| **`/superpowers-status`, `/harness-health`, `/harness-audit`** | Report active-log count and archive-entry count separately, plus the count of unpromoted entries older than 6 months as a curation-debt metric. |
| **`/assess`, `/governance-audit`** | Read both active log and archive when extracting historical evidence. |

## Migration

The existing 29 entries in `REFLECTION_LOG.md` do not have `Promoted`
fields. A one-off migration is required:

1. Curator runs `/harness-gc reflection-aged-out-review` (or its
   equivalent first-run flag) which produces a Path 2 report
   covering ALL existing entries (since none have `Promoted`).
2. Curator works through the report once:
   - Tags promoted entries with `Promoted: <today's date> →
     AGENTS.md ...` based on actual prior promotions (cross-referenced
     against current `AGENTS.md`).
   - Tags single-instance aged-out entries with `Promoted: → aged-out,
     no promotion warranted`.
   - Leaves still-relevant unpromoted recent entries (≤6 months old)
     alone.
3. Path 1 GC then runs on its next weekly schedule and migrates
   everything tagged into `reflections/archive/<YYYY>.md`.

The migration naturally fits as part of the next monthly review and
should take an hour or two of curator time. After the migration, the
two paths run continuously without further manual intervention beyond
the monthly aged-out review.

## Steady-state expectation

After one full quarterly cycle following migration:

- **Active log**: 10–20 entries (recent, plus unpromoted-but-warm).
- **`reflections/archive/2026.md`**: every entry triaged and moved.
- **Token cost per active-log read**: roughly 1/3 to 1/4 of today's
  cost (depending on actual triage volume).
- **Curator burden**: one line per promotion (already implicit in
  the existing curation flow), monthly aged-out review (already part
  of the existing monthly cadence).

The active log becomes a **working file** rather than a permanent
record. The permanent record lives in the archive.

## What this design does NOT do

- Does not change the append path or the `Reflections via PR
  workflow` constraint.
- Does not introduce a new file format (still markdown, still
  grep-able).
- Does not pre-emptively summarise or compress entries (full
  fidelity preserved in archive).
- Does not touch `AGENTS.md` semantics or content.
- Does not introduce a UI or dashboard for archival; everything is
  file-based and command-driven.
- Does not retroactively re-classify entries that were already
  promoted in the past — those need the one-off curator pass to
  acquire `Promoted` lines.

## Implementation scope

The implementation will touch:

- `ai-literacy-superpowers/agents/harness-gc.agent.md` — add Path 1
  and Path 2 GC rule implementations; update existing
  `Reflection-driven regression detection` to read archive too.
- `ai-literacy-superpowers/agents/harness-auditor.agent.md` — read
  archive for historical claims.
- `ai-literacy-superpowers/agents/assessor.agent.md` — count across
  active + archive.
- `ai-literacy-superpowers/agents/governance-auditor.agent.md` (in
  the governance plugin or via skill) — read archive for governance
  patterns.
- `ai-literacy-superpowers/agents/choice-cartographer.agent.md` —
  read archive for decision continuity.
- `ai-literacy-superpowers/agents/integration-agent.agent.md` —
  document `Promoted` convention in post-task workflow.
- `ai-literacy-superpowers/templates/HARNESS.md` — add the two new GC
  rules to the template under `## Garbage Collection`.
- `ai-literacy-superpowers/templates/REFLECTION_LOG.md` (if it
  exists) or templates/CLAUDE.md — document the `Promoted` field
  schema.
- `ai-literacy-superpowers/templates/CLAUDE.md` — document the
  archival convention and the curator workflow.
- `ai-literacy-superpowers/commands/reflect.md` — mention that
  promotion adds a `Promoted` line.
- `ai-literacy-superpowers/commands/superpowers-status.md`,
  `harness-health.md`, `harness-audit.md` — report archive counts.
- `ai-literacy-superpowers/skills/garbage-collection/SKILL.md` —
  document the two new GC rules and the safety asymmetry between
  them.
- New script: `ai-literacy-superpowers/scripts/archive-promoted-reflections.sh`
  for Path 1's deterministic execution.
- `ai-literacy-superpowers/.github/workflows/gc.yml` — wire the new
  Path 1 script into the weekly GC workflow.
- This repo's `REFLECTION_LOG.md` — perform the one-off migration.
- This repo's `HARNESS.md` — add the two new GC rules to the live
  harness.
- This repo creates: `reflections/archive/2026.md` (initially empty,
  populated by Path 1 after migration tagging).
- Plugin version bump: minor (this changes plugin behaviour and adds
  GC rules) — `0.31.1 → 0.32.0`.

## Risks

1. **Migration burden falls on existing curators.** The one-off
   tagging of 29 entries is an hour or two of work that has to
   happen before the system steady-states. Risk that curators
   defer it indefinitely. Mitigation: the Path 2 monthly run will
   keep producing the same report until tagged, providing a
   recurring forcing function.

2. **Path 2 agent recommendations may train the curator into
   acceptance.** If the agent's PROMOTE / SUPERSEDE / AGED-OUT calls
   are accepted reflexively rather than scrutinised, the agent
   becomes a single point of failure for what enters AGENTS.md.
   Mitigation: the recommendation is a starting point, not a
   decision; the curator must take an explicit action (edit
   AGENTS.md, then add Promoted line) — there is no
   one-click-accept.

3. **Archive grows unbounded.** Even if the active log is small,
   the archive grows ~100–200 entries / year, eventually reaching
   thousands. Acceptable per the design (archive is queryable, not
   loaded by default) but worth noting.

4. **Cross-reference logic in Path 2 is approximate.** Pattern
   recurrence detection by text overlap is brittle; semantic match
   against AGENTS.md is even more so. Recommendations may be
   wrong. Mitigation: curator override; recommendation includes
   rationale so curator can sanity-check.

5. **Git history bloat from frequent archival commits.** Path 1
   runs weekly; each run commits if there's anything to archive. At
   steady state this is ~1 commit/week of archival churn.
   Acceptable.

## Open questions for diaboli

The following are deliberately left for adversarial review rather
than resolved here:

1. Is 6 months the right Path 2 threshold, or should it be 3 / 12
   months? (The design picks 6 as the middle.)
2. Should Path 1 run weekly or monthly? (Weekly is more responsive;
   monthly batches more.)
3. Should the `Archived` field be added to entries when archived, or
   should the archive file's existence implicitly carry that
   information? (The design picks explicit field for self-documenting
   entries.)
4. Should aged-out entries be auto-archived after a longer threshold
   (e.g., 12 months) even without a `Promoted` field, as a final
   fallback? (The design says no — preserves human judgement; risk
   is the active log can still grow.)
5. Should the migration tagging be performed by the curator manually,
   or should an `/archive-bootstrap` command be provided to scaffold
   the work? (The design picks manual; if the migration burden
   proves prohibitive, scaffolding can be added later.)

## Success criteria

This design will be considered successful if, three months after
implementation:

- Active `REFLECTION_LOG.md` has fewer than 25 entries.
- `reflections/archive/2026.md` contains the migrated and
  subsequently archived entries.
- The monthly Path 2 report fits on one screen and surfaces actionable
  recommendations.
- No reader (agent or command) has reported missing context due to
  archival.
- The curator workflow has not added meaningful overhead beyond the
  monthly review that already exists.

If these criteria are met, the next step is to consider whether the
same archival pattern should be applied to other long-lived markdown
artefacts in the plugin (e.g., `CHANGELOG.md`, governance audit
reports). That generalisation is out of scope for this spec.
