---
name: diaboli-observability
description: Spec for surfacing advocatus-diaboli activity as descriptive stats in /superpowers-status and the harness-health snapshot — observability-before-enforcement, no new constraints or thresholds
date: 2026-04-19
status: draft
---

# Diaboli Observability

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

### Surfaces

**`/superpowers-status`** gains a new Section 7: Diaboli Activity. It reads
`docs/superpowers/specs/` and `docs/superpowers/objections/`, computes the
metrics below, and reports them in the Details block. The summary line shows
`Diaboli [ACTIVE — N records]` or `[NO DATA]` — explicitly not OK/WARNING/MISSING,
since we have no threshold yet.

**`/harness-health` snapshot** gains a new Diaboli section after Session Quality
and before Operational Cadence. The section follows the existing `- Field: Value`
format used by all other sections. It is included in the mandatory section list
so the validation checkpoint enforces its presence.

**`skills/harness-observability/references/snapshot-format.md`** gets the
canonical Diaboli section definition, including field-by-field computation
instructions, so future snapshots can be generated and validated against a
reference.

### Metrics

All metrics are descriptive. No pass/fail status, no thresholds.

| Metric | Definition | Source |
|---|---|---|
| Specs reviewed | Count of `docs/superpowers/specs/*.md` | filesystem |
| Objection records present | Count of `docs/superpowers/objections/*.md` (excluding `.gitkeep`) | filesystem |
| Specs without a record | Spec slugs with no matching objection file | slug comparison |
| Disposition rate | Records where all `disposition` fields are non-`pending` / total records | YAML frontmatter |
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

### Side fix: diaboli.md validation checkpoint

`ai-literacy-superpowers/commands/diaboli.md` step 5 validation checkpoint still
references the old category taxonomy (`premise|design|threat|failure|operational|cost`)
and old severity values (`major|minor`). `SKILL.md` was updated to the new taxonomy
in a prior PR. The command's checkpoint must be corrected to match:

- Categories: `premise|scope|implementation|risk|alternatives|specification quality`
- Severity: `critical|high|medium|low`

### New reference file

`ai-literacy-superpowers/skills/advocatus-diaboli/references/observability.md`
documents what each metric means, what it does NOT mean, and the watch-for
patterns worth a reflection entry.

### AGENTS.md

Add an ARCH_DECISION capturing the observability-before-enforcement principle
and the revisit conditions.

## Expected outcome

After this change:

- `/superpowers-status` shows a Diaboli Activity section with all metrics, no
  pass/fail status
- `/harness-health` generates a snapshot with a Diaboli panel in the correct
  section order; the validation checkpoint enforces its presence
- `snapshot-format.md` defines the Diaboli section so future snapshots can be
  generated and validated against a reference
- A reader who wants to understand what each metric means or does not mean can
  consult `skills/advocatus-diaboli/references/observability.md`
- `commands/diaboli.md` validation checkpoint uses the correct taxonomy
- An ARCH_DECISION in AGENTS.md records the observability-before-enforcement
  decision and the revisit conditions

No new constraints or GC rules are added. The revisit evaluation is triggered
at 10 fully-resolved objection records or 2026-07-19, whichever comes first.

## Artefacts

1. `ai-literacy-superpowers/commands/superpowers-status.md` — add Section 7
2. `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md` — add Diaboli section
3. `ai-literacy-superpowers/skills/harness-observability/SKILL.md` — add reference to Diaboli panel
4. `ai-literacy-superpowers/commands/harness-health.md` — add Diaboli to required section list and section order
5. `ai-literacy-superpowers/skills/advocatus-diaboli/references/observability.md` — new reference file
6. `ai-literacy-superpowers/commands/diaboli.md` — fix validation checkpoint taxonomy
7. `AGENTS.md` — add ARCH_DECISION
8. `ai-literacy-superpowers/.claude-plugin/plugin.json` — 0.24.0 → 0.25.0
9. `README.md` — badge bump
10. `.claude-plugin/marketplace.json` — plugin_version bump
11. `CHANGELOG.md` — new version entry

## Exemptions

None. This is a plugin behavioral change (new output sections in two commands)
warranting a minor version bump per CLAUDE.md semver rules.
