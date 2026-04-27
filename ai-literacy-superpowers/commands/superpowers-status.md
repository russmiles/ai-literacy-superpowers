---
name: superpowers-status
description: Show the complete health of the project's AI Literacy habitat — harness enforcement, agent team, compound learning, model routing, and CI status
---

# /superpowers-status

Display a health dashboard for the project's AI Literacy habitat. Run this any
time to verify that the framework is correctly configured and that compound
learning is accumulating as expected.

## What this command checks

Work through each section below in order. For each check, report status as
one of: OK, WARNING, or MISSING. Collect all results and print the full
dashboard at the end — do not stop early if a check fails.

### Section 1: Habitat files

Check that the core habitat files exist:

| File | Expected location | Status |
| ------ | ------------------ | -------- |
| CLAUDE.md | project root | OK / MISSING |
| AGENTS.md | project root | OK / MISSING |
| MODEL_ROUTING.md | project root | OK / MISSING |
| REFLECTION_LOG.md | project root | OK / MISSING |

For each file that exists, check that it is non-empty and contains the
expected section headings (STYLE, GOTCHAS, ARCH_DECISIONS for AGENTS.md;
agent routing table for MODEL_ROUTING.md).

### Section 2: Harness health

Check for the presence and validity of the harness:

- Does `.claude/settings.json` exist?
- Are hooks configured? Check for the drift-check hook or equivalent.
- Does `.claude/HARNESS.md` exist and describe the harness?
- Are the hook scripts executable?

Use the harness-engineering skill to evaluate what is found.

### Section 3: Agent team

Check that the agent team is present and consistent:

- List all `.claude/agents/*.md` files
- For each agent, confirm it has frontmatter with `name`, `description`,
  and `tools` fields
- Confirm the orchestrator, spec-writer, tdd-agent, code-reviewer, and
  integration-agent are all present

Report any agents that are present in `.claude/agents/` but not referenced
in MODEL_ROUTING.md (potential routing gap).

### Section 4: Compound learning

Evaluate the state of AGENTS.md:

- When was it last modified? (`git log -1 --format="%ar" AGENTS.md`)
- How many entries are in GOTCHAS?
- How many entries are in ARCH_DECISIONS?
- How many reflection entries are in REFLECTION_LOG.md?
- Is the content growing (healthy) or static (potentially stale)?

Report: "Compound learning is active" if AGENTS.md or REFLECTION_LOG.md has
been modified in the last 30 days. Report "WARNING: no recent updates" if
neither has been touched in over 30 days.

### Section 5: Model routing

Check MODEL_ROUTING.md:

- Does it contain a routing table?
- Does it reference all agents present in `.claude/agents/`?
- Are token budget guidelines present?

### Section 6: CI status

Check for CI configuration:

- Does `.github/workflows/` contain any AI Literacy workflow files?
- Is `scripts/ai-literacy-check.sh` present and executable?
- If on a branch with an open PR, show the PR check status:
  `gh pr checks --json name,status,conclusion 2>/dev/null || echo "No open PR"`

### Section 7: Diaboli activity

Check `docs/superpowers/specs/` and `docs/superpowers/objections/`.

A spec is **in-scope** if its filename date is on or after `2026-04-19`. Specs with
earlier dates are **exempt**. A spec slug is the filename with the `YYYY-MM-DD-` date
prefix and `.md` extension stripped.

- A **spec-mode record** matches `docs/superpowers/objections/<slug>.md`
- A **code-mode record** matches `docs/superpowers/objections/<slug>-code.md`

**Error handling**: if any file at `docs/superpowers/objections/` fails YAML parse,
report it by name as "parse error" and exclude it from all metrics.

#### Overall totals (all records, both modes)

- **In-scope specs**: count of `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-19
- **Exempt specs (pre-feature)**: count of specs with filename date < 2026-04-19
- **Objection records present**: count of all `docs/superpowers/objections/*.md`,
  excluding `.gitkeep`
- **In-scope specs without any record**: in-scope spec slugs with no matching spec-mode
  or code-mode file
- **Objections total**: sum of `objections` list lengths across all records
- **Mean objections per record**: total objections / count of records (1 decimal)

#### Spec-mode breakdown

- **Spec-mode records present**: count of `docs/superpowers/objections/<slug>.md` files
  (no `-code` suffix), excluding `.gitkeep`
- **Fully-resolved rate (spec-mode)**: records where every `disposition` is non-`pending`
  / total spec-mode records (record-level ratio)
- **Disposition distribution (spec-mode)**: among non-`pending` dispositions —
  accepted% / deferred% / rejected%
- **Mean objections per spec-mode record**: (1 decimal)

#### Code-mode breakdown

- **Code-mode records present**: count of `docs/superpowers/objections/<slug>-code.md`
  files
- **In-scope specs with spec-mode record but no code-mode record**: slugs where
  `<slug>.md` exists but `<slug>-code.md` does not
- **Fully-resolved rate (code-mode)**: records where every `disposition` is non-`pending`
  / total code-mode records (record-level ratio)
- **Disposition distribution (code-mode)**: among non-`pending` dispositions —
  accepted% / deferred% / rejected%
- **Mean objections per code-mode record**: (1 decimal)

Summary line: `Diaboli [OK]` when at least one in-scope spec-mode record is present;
`Diaboli [MISSING]` when none exist. No `WARNING` state — no threshold is defined yet.

### Section 8: Cartographer activity

Check `docs/superpowers/specs/` and `docs/superpowers/stories/`.

A spec is **in-scope** if its filename date is on or after `2026-04-27`. Specs
with earlier dates are **exempt**. A spec slug is the filename with the
`YYYY-MM-DD-` date prefix and `.md` extension stripped.

A **choice-story record** matches `docs/superpowers/stories/<slug>.md`.

**Error handling**: if any file at `docs/superpowers/stories/` fails YAML parse,
report it by name as "parse error" and exclude it from all metrics.

#### Totals

- **In-scope specs**: count of `docs/superpowers/specs/*.md` with filename
  date ≥ 2026-04-27
- **Choice-story records present**: count of
  `docs/superpowers/stories/*.md`, excluding `.gitkeep`
- **In-scope specs without a choice-story record**: in-scope spec slugs with
  no matching `<slug>.md` file
- **Stories total**: sum of `stories` list lengths across all records
- **Mean stories per record**: total stories / count of records (1 decimal)

#### Disposition state

- **`cartograph_pending_count`**: total count of stories with
  `disposition: pending` across all in-scope records. This is the field
  surfaced at plan approval and tracked by harness-health snapshots.
- **Fully-resolved rate**: records where every `disposition` is
  non-`pending` / total records (record-level ratio)
- **Disposition distribution**: among non-`pending` dispositions —
  accepted% / revisit% / promoted%

#### Lens activity

- **Lens distribution**: count of stories per lens across all records,
  reported as the six-lens histogram (forces / alternatives / defaults /
  patterns / consequences / coherence). Each story may count toward
  multiple lenses if its `lens` field has multiple values.

Summary line: `Cartographer [OK]` when at least one in-scope choice-story
record is present and `cartograph_pending_count` is 0; `Cartographer
[WARNING]` when records exist but `cartograph_pending_count > 0`;
`Cartographer [MISSING]` when no in-scope record exists. The WARNING
state surfaces unadjudicated stories — the merge-time HARNESS constraint
will block the PR until they are resolved, so `WARNING` is an early-look
signal, not a steady state.

## Output format

Print the dashboard as a structured report:

```text
AI Literacy Habitat Status
==========================

Habitat files    [OK / WARNING / MISSING]
Harness          [OK / WARNING / MISSING]
Agent team       [OK / WARNING / MISSING]
Compound learning [OK / WARNING / MISSING]
Model routing    [OK / WARNING / MISSING]
CI               [OK / WARNING / MISSING]
Diaboli          [OK / MISSING]
Cartographer     [OK / WARNING / MISSING]

--- Details ---

[Section-by-section findings, flagging anything that is WARNING or MISSING;
 Diaboli and Cartographer sections always shown as descriptive stats —
 Cartographer's WARNING state means cartograph_pending_count > 0,
 surfaced as an early-look signal before the merge-time HARNESS gate
 fires]

--- Recommendations ---

[Prioritised list of actions to reach full green, if any]
```

If all sections are OK and Diaboli has at least one record, end with:
"Habitat is healthy. All checks passed."
