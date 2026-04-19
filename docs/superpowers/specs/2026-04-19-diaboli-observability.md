---
name: diaboli-observability
description: Spec for surfacing advocatus-diaboli activity as descriptive stats in /superpowers-status and the harness-health snapshot — observability-before-enforcement, no new constraints or thresholds
date: 2026-04-19
status: approved
---

# Diaboli Observability

## Objection resolution notes

*Applied after advocatus-diaboli review of this spec:*

- **O2/O7 (implementation/scope/high+medium):** "Specs reviewed" and "Specs without a
  record" must filter to post-feature specs only. A spec is in-scope for diaboli
  coverage if its filename date is on or after 2026-04-19 (the date advocatus-diaboli
  shipped). Pre-feature specs are counted separately as exempt. Metrics table updated;
  artefact descriptions updated to specify the filter.
- **O3 (specification quality/high):** `harness-health.md` step 7 hardcodes "12
  section headings." The spec must explicitly call out updating this to "13" and adding
  "Diaboli" to the enumerated list. Artefact #4 description updated.
- **O4 (risk/medium):** `/superpowers-status` summary line must use `OK/WARNING/MISSING`
  for CI compatibility. Since no threshold exists: `OK` when at least one in-scope
  objection record exists, `MISSING` when none. Updated in Surfaces and metric
  definitions.
- **O5 (specification quality/medium):** "Disposition rate" renamed to
  "Fully-resolved record rate" to remove ambiguity. Definition clarified to make
  explicit it is a record-level ratio (all objections non-pending / total records).
- **O8 (alternatives/low):** `observability.md` reference file scope narrowed to
  metric computation definitions and interpretive notes only. The observability-before-
  enforcement arch decision and revisit conditions belong exclusively in AGENTS.md.
- **O9 (implementation/low):** Error handling added: if a file at
  `docs/superpowers/objections/` fails YAML parse during metric computation, report
  it by name in the Details section as "parse error" and exclude from all metrics.
- **O1 (implementation/high): leave** — the median-days metric uses git log on the
  objection file; the fact that regeneration resets this is acceptable. We are not
  trying to police dispositions.
- **O6 (premise/medium): accept** — launching with "insufficient data" for several
  metrics is expected and fine; the data grows as the practice matures.
- **O10 (scope/low): accepted** — taxonomy fix bundled in this PR is acknowledged
  as a latent risk; proceeding with inclusion.

---

## Problem

The advocatus-diaboli is live and running. Objection records are accumulating in
`docs/superpowers/objections/`. But the patterns across specs are invisible: we
cannot see whether dispositions cluster toward a single bucket, whether objection
counts are trending toward zero (signal of rubber-stamping) or toward maximum
(signal of charter over-firing), whether any spec slipped through without a
record, or whether time-to-disposition is growing (signal of friction increasing).

The existing observability surfaces — `/superpowers-status` and
`/harness-health` — check whether the framework is wired correctly but say
nothing about how the diaboli discipline is operating in practice.

Without visibility, the only way to notice a problem is a post-hoc audit.
With visibility, patterns emerge across the normal observability cadence.

## Approach

Surface diaboli stats in two existing observability surfaces. No new GC rule,
no new constraint, no new command.

### Scope boundary

A spec is **in-scope** for diaboli coverage if its filename date is on or after
`2026-04-19` — the date the advocatus-diaboli feature shipped. Specs predating
this date are **exempt** and are counted separately. All metrics that compare
specs to objection records use only in-scope specs.

### Surfaces

**`/superpowers-status`** gains a new Section 7: Diaboli Activity. It reads
in-scope specs from `docs/superpowers/specs/` and records from
`docs/superpowers/objections/`, computes the metrics below, and reports them in
the Details block. The summary line uses the standard token format:
`Diaboli [OK]` when at least one in-scope objection record exists,
`Diaboli [MISSING]` when none exist. No `WARNING` state yet — no threshold is
defined.

**`/harness-health` snapshot** gains a new Diaboli section after Session Quality
and before Operational Cadence. The section follows the existing `- Field: Value`
format used by all other sections. It is included in the mandatory section list
so the validation checkpoint enforces its presence. `harness-health.md` step 7
must be updated: change "All 12 section headings" to "All 13 section headings"
and add "Diaboli" to the enumerated list between "Session Quality" and
"Operational Cadence."

**`skills/harness-observability/references/snapshot-format.md`** gets the
canonical Diaboli section definition, including field-by-field computation
instructions, so future snapshots can be generated and validated against a
reference.

### Metrics

All metrics are descriptive. No pass/fail status, no thresholds.

| Metric | Definition | Source |
|---|---|---|
| In-scope specs | Count of `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-19 | filesystem |
| Exempt specs (pre-feature) | Count of specs with filename date < 2026-04-19 | filesystem |
| Objection records present | Count of `docs/superpowers/objections/*.md` (excluding `.gitkeep`) | filesystem |
| In-scope specs without a record | In-scope spec slugs with no matching objection file | slug comparison |
| Fully-resolved record rate | Records where all `disposition` fields are non-`pending` / total records (record-level ratio: a record counts only when every objection within it is resolved) | YAML frontmatter |
| Objections total | Sum of all `objections` list lengths across all records | YAML frontmatter |
| Severity breakdown | Count of critical/high/medium/low across all objections | YAML frontmatter |
| Mean objections per spec | Total objections / count of objection records (1 decimal) | derived |
| Disposition distribution | Among non-`pending` dispositions: accepted% / deferred% / rejected% | YAML frontmatter |
| Median days spec-to-disposition | Spec date from filename; resolution date from git log on objection file; median across fully-resolved records | git log + filename |

"Insufficient data" is reported for median when fewer than 3 fully-resolved
records exist.

A spec slug is derived from the spec filename by stripping the date prefix
(`YYYY-MM-DD-`) and the `.md` extension. A matching objection record is a file
at `docs/superpowers/objections/<slug>.md`.

**Error handling:** If a file at `docs/superpowers/objections/` fails YAML parse
during metric computation, report it by name in the Details section as a
"parse error" and exclude it from all metrics.

### Side fix: diaboli.md validation checkpoint

`ai-literacy-superpowers/commands/diaboli.md` step 5 validation checkpoint still
references the old category taxonomy (`premise|design|threat|failure|operational|cost`)
and old severity values (`major|minor`). `SKILL.md` was updated to the new taxonomy
in a prior PR. The command's checkpoint must be corrected to match:

- Categories: `premise|scope|implementation|risk|alternatives|specification quality`
- Severity: `critical|high|medium|low`

### New reference file

`ai-literacy-superpowers/skills/advocatus-diaboli/references/observability.md`
documents the metric computation definitions and interpretive notes: what each
metric means, what it does NOT mean, and the watch-for patterns worth a reflection
entry. Arch decisions and revisit conditions belong in AGENTS.md, not here.

### AGENTS.md

Add an ARCH_DECISION capturing the observability-before-enforcement principle
and the revisit conditions.

## Expected outcome

After this change:

- `/superpowers-status` shows a Diaboli Activity section with all metrics;
  summary uses `OK` / `MISSING` (no `WARNING` — no threshold defined yet)
- `/harness-health` generates a snapshot with a Diaboli panel in the correct
  section order (after Session Quality, before Operational Cadence); step 7
  validation enforces all 13 sections including Diaboli
- `snapshot-format.md` defines the Diaboli section so future snapshots can be
  generated and validated against a reference
- A reader who wants the metric computation reference consults
  `skills/advocatus-diaboli/references/observability.md`; a reader who wants the
  design rationale and revisit conditions consults AGENTS.md
- `commands/diaboli.md` validation checkpoint uses the correct taxonomy
- An ARCH_DECISION in AGENTS.md records the observability-before-enforcement
  decision and the revisit conditions; observability.md is the metric reference only

No new constraints or GC rules are added. The revisit evaluation is triggered
at 10 fully-resolved objection records or 2026-07-19, whichever comes first.

## Artefacts

1. `ai-literacy-superpowers/commands/superpowers-status.md` — add Section 7; summary
   line uses `OK` / `MISSING` tokens; includes in-scope/exempt split and error handling
2. `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
   — add Diaboli section definition with field computation table
3. `ai-literacy-superpowers/skills/harness-observability/SKILL.md` — add reference to
   Diaboli panel
4. `ai-literacy-superpowers/commands/harness-health.md` — add Diaboli to required
   section list; update step 7 from "12" to "13" and add "Diaboli" to the enumerated
   heading list between "Session Quality" and "Operational Cadence"
5. `ai-literacy-superpowers/skills/advocatus-diaboli/references/observability.md` — new
   metric reference file (computation definitions and interpretive notes only; no arch
   decision content)
6. `ai-literacy-superpowers/commands/diaboli.md` — fix validation checkpoint taxonomy
7. `AGENTS.md` — add ARCH_DECISION (observability-before-enforcement principle,
   revisit conditions)
8. `ai-literacy-superpowers/.claude-plugin/plugin.json` — 0.24.0 → 0.25.0
9. `README.md` — badge bump
10. `.claude-plugin/marketplace.json` — plugin_version bump
11. `CHANGELOG.md` — new version entry

## Exemptions

None. This is a plugin behavioral change (new output sections in two commands)
warranting a minor version bump per CLAUDE.md semver rules.
