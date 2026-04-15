# Output Validation Checkpoints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add validate-and-fix-in-place checkpoint steps to 7 commands that produce structured output parsed by downstream consumers.

**Architecture:** Each command gets a new numbered step inserted between output generation and the next action (commit, badge update, etc.). The step reads the output file, checks structural requirements against the referenced format spec, and fixes deviations in place. No agent re-dispatch. No new files created.

**Tech Stack:** Markdown command specs (no application code). Markdownlint for validation.

---

## File Map

All changes are to existing command files in `ai-literacy-superpowers/commands/`:

| File | Change | Reference spec |
| --- | --- | --- |
| `harness-health.md` | Insert step 7, renumber 7-9 to 8-10 | `references/snapshot-format.md` |
| `assess.md` | Insert step 5, renumber 5-11 to 6-12 | `ai-literacy-assessment/references/assessment-template.md` |
| `reflect.md` | Insert step 6, renumber 6-7 to 7-8 | Entry template in `commands/reflect.md` itself |
| `cost-capture.md` | Insert step 10, renumber 10-11 to 11-12 | `cost-tracking/SKILL.md` |
| `harness-constrain.md` | Insert step 9, renumber 9-10 to 10-11 | Constraint template in `templates/HARNESS.md` |
| `harness-init.md` | Insert step 8, renumber 8-12 to 9-13 | `templates/HARNESS.md` |
| `superpowers-init.md` | Insert step 8, renumber 8 to 9 | `templates/CLAUDE.md`, `templates/AGENTS.md`, `templates/MODEL_ROUTING.md` |

Also modified:

| File | Change |
| --- | --- |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version 0.19.3 to 0.19.4 |
| `.claude-plugin/marketplace.json` | plugin_version 0.19.3 to 0.19.4 |
| `README.md` | Badge version 0.19.3 to 0.19.4 |
| `CHANGELOG.md` | New 0.19.4 entry |

---

### Task 1: `/harness-health` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-health.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/harness-health.md` to confirm
current step numbering. Steps 1-6 are before the insertion point,
step 7 (Update README) is the first step to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 7. Validate Snapshot Structure` after step 6
(Generate Markdown Sections) and before the current step 7 (Update
README). Content:

```markdown
### 7. Validate Snapshot Structure

**This step is mandatory.** After writing the snapshot file, read
`observability/snapshots/YYYY-MM-DD-snapshot.md` and verify its
structure against `references/snapshot-format.md`.

**Structural checks:**

1. All 12 section headings present in order: Enforcement,
   Enforcement Loop History, Garbage Collection, Mutation Testing,
   Compound Learning, Session Quality, Operational Cadence,
   Cost Indicators, Regression Indicators, Meta,
   Changes Since Last Snapshot, Trends
2. Trends section is conditional — required only when a previous
   snapshot exists (step 3 found one)
3. No YAML `observatory_metrics` block anywhere in the file
   (deprecated in v0.16.0)
4. Each section contains the fields defined in
   `references/snapshot-format.md` for that section

If any check fails, fix the snapshot in place:

- Add missing sections using the field templates from
  `references/snapshot-format.md` with placeholder values
- Reorder sections if present but misordered
- Remove any YAML `observatory_metrics` block if found

Do not regenerate the snapshot. Fix the output directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing steps:

- `### 7. Update README` becomes `### 8. Update README`
- `### 8. Print Summary` becomes `### 9. Print Summary`
- `### 9. Nudge Overdue Actions` becomes `### 10. Nudge Overdue Actions`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/harness-health.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-health.md
git commit -m "Add snapshot validation checkpoint to /harness-health"
```

---

### Task 2: `/assess` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/assess.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/assess.md` to confirm current
step numbering. Steps 1-4 are before the insertion point, step 5
(Immediate Habitat Adjustments) is the first step to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 5. Validate Assessment Document` after step 4
(Document) and before the current step 5 (Immediate Habitat
Adjustments). Content:

```markdown
### 5. Validate Assessment Document

**This step is mandatory.** After writing the assessment document,
read `assessments/YYYY-MM-DD-assessment.md` and verify its structure
against `ai-literacy-assessment/references/assessment-template.md`.

**Structural checks:**

1. Required sections present: Observable Evidence, Level Assessment,
   Discipline Maturity, Strengths, Gaps, Recommendations
2. Level Assessment contains a level number (1-5) and a level name
   (e.g. "Level 3 — Adaptive Collaboration")
3. Discipline Maturity contains a markdown table with rows for each
   scored discipline
4. Gaps section contains at least one item (every project has gaps)

If any check fails, fix the document in place:

- Add missing sections using the structure from the assessment
  template reference
- Ensure the level number is a single digit 1-5 that downstream
  portfolio aggregation can parse

Do not re-dispatch the assessor agent. Fix the output directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing steps:

- `### 5. Immediate Habitat Adjustments` becomes `### 6. Immediate Habitat Adjustments`
- `### 6. Workflow Operation Recommendations` becomes `### 7. Workflow Operation Recommendations`
- `### 6b. Improvement Plan` becomes `### 7b. Improvement Plan`
- `### 7. Assessment Reflection` becomes `### 8. Assessment Reflection`
- `### 8. Check README for broader updates` becomes `### 9. Check README for broader updates`
- `### 9. Badge` becomes `### 10. Badge`
- `### 9b. Tag Repository` becomes `### 10b. Tag Repository`
- `### 10. Commit` becomes `### 11. Commit`
- `### 11. Report` becomes `### 12. Report`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/assess.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/assess.md
git commit -m "Add assessment document validation checkpoint to /assess"
```

---

### Task 3: `/reflect` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/reflect.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/reflect.md`. The file uses
numbered list items (1. 1. 1. ...) not headings for steps. The
insertion point is after step 5 (append entry) and before step 6
(do not modify AGENTS.md).

- [ ] **Step 2: Insert the checkpoint step**

Insert a new numbered step after the "Append the entry to
`REFLECTION_LOG.md`" step and before the "Do NOT modify `AGENTS.md`"
step. Content:

```markdown
1. **Validate the reflection entry.** Read the last entry in
   `REFLECTION_LOG.md` and verify its structure against the entry
   template above.

   **Structural checks:**

   1. Entry starts with `---` separator
   2. All 8 mandatory fields present: Date, Agent, Task, Surprise,
      Proposal, Improvement, Signal, Constraint
   3. Session metadata block present with all 4 subfields: Duration,
      Model tiers used, Pipeline stages completed, Agent delegation
   4. Signal field value is one of: `context`, `instruction`,
      `workflow`, `failure`, `none`

   If any check fails, fix the entry in place:

   - Add missing fields with `"unknown"` values
   - Add missing session metadata subfields with `"unknown"`
   - If Signal value is not in the enum, set it to `none`

   Do not ask the user to re-enter the reflection. Fix the output
   directly.
```

- [ ] **Step 3: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/reflect.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/reflect.md
git commit -m "Add reflection entry validation checkpoint to /reflect"
```

---

### Task 4: `/cost-capture` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/cost-capture.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/cost-capture.md`. Steps 1-9
are before the insertion point, step 10 (Commit) is the first step
to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 10. Validate Cost Snapshot` after step 9 (Write
the Snapshot) and before the current step 10 (Commit). Content:

```markdown
### 10. Validate Cost Snapshot

**This step is mandatory.** After writing the cost snapshot, read
`observability/costs/YYYY-MM-DD-costs.md` and verify it contains the
fields that `/harness-health` needs to parse for the Cost Indicators
section.

**Structural checks:**

1. File exists at the expected path
2. Period field present (date range for the snapshot)
3. Total spend field present (even if estimated)
4. Model routing reference present (whether MODEL_ROUTING.md was
   updated)

Reference the `cost-tracking` skill for the full field definitions.

If any check fails, fix the snapshot in place:

- Add missing fields with `"not tracked"` as the value

Do not re-run the capture conversation. Fix the output directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing steps:

- `### 10. Commit` becomes `### 11. Commit`
- `### 11. Summary` becomes `### 12. Summary`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/cost-capture.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/cost-capture.md
git commit -m "Add cost snapshot validation checkpoint to /cost-capture"
```

---

### Task 5: `/harness-constrain` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-constrain.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/harness-constrain.md`. Steps
1-8 are before the insertion point, step 9 (Update CI) is the first
step to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 9. Validate Constraint Block` after step 8 (Update
HARNESS.md) and before the current step 9 (Update CI). Content:

```markdown
### 9. Validate Constraint Block

**This step is mandatory.** After adding or updating the constraint
in HARNESS.md, read the constraint block you just wrote and verify
its structure against the constraint template in
`templates/HARNESS.md`.

**Structural checks:**

1. All required fields present: Rule, Enforcement, Tool, Scope
2. Enforcement value is one of: `deterministic`, `agent`,
   `unverified`
3. Scope value is one of: `commit`, `pr`, `weekly`, `manual`
4. If a `Governance requirement` field is present, all governance
   fields must also be present: Operational meaning, Verification
   method, Evidence, Failure action, Frame check

If any check fails, fix the constraint block in place:

- Add missing fields with placeholder values
- Normalise Enforcement and Scope to valid enum values if they are
  close matches (e.g. "det" to "deterministic")

Do not restart the constraint conversation. Fix the output directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing steps:

- `### 9. Update CI (if deterministic + PR scope)` becomes `### 10. Update CI (if deterministic + PR scope)`
- `### 10. Commit` becomes `### 11. Commit`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/harness-constrain.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-constrain.md
git commit -m "Add constraint block validation checkpoint to /harness-constrain"
```

---

### Task 6: `/harness-init` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/harness-init.md`. Steps 1-7
are before the insertion point, step 8 (Generate CI Configuration)
is the first step to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 8. Validate Generated HARNESS.md` after step 7
(Generate HARNESS.md) and before the current step 8 (Generate CI
Configuration). Content:

```markdown
### 8. Validate Generated HARNESS.md

**This step is mandatory.** After writing HARNESS.md, read it and
verify its structure against `templates/HARNESS.md`.

**Structural checks:**

1. All 4 top-level sections present: `## Context`,
   `## Constraints`, `## Garbage Collection`, `## Observability`
2. Context section has `### Stack` and `### Conventions`
   subsections (either with content or the placeholder marker)
3. Observability section has `### Operating cadence`,
   `### Health thresholds`, and `### Regression detection`
   subsections
4. `## Status` section present with all 4 fields: Last audit,
   Constraints enforced, Garbage collection active, Drift detected
5. Template version marker comment present:
   `<!-- template-version: X.Y.Z -->` where X.Y.Z matches the
   current plugin version

If any check fails, fix HARNESS.md in place:

- Add missing sections from the template with placeholder markers
- Insert the template version marker if absent
- Add missing Status fields with default values

Do not re-run the init conversation. Fix the output directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing steps:

- `### 8. Generate CI Configuration` becomes `### 9. Generate CI Configuration`
- `### 9. Add README Badge` becomes `### 10. Add README Badge`
- `### 10. Commit` becomes `### 11. Commit`
- `### 11. Tag Repository` becomes `### 12. Tag Repository`
- `### 12. Summary` becomes `### 13. Summary`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/harness-init.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Add HARNESS.md validation checkpoint to /harness-init"
```

---

### Task 7: `/superpowers-init` checkpoint

**Files:**

- Modify: `ai-literacy-superpowers/commands/superpowers-init.md`

- [ ] **Step 1: Read the current file**

Read `ai-literacy-superpowers/commands/superpowers-init.md`. Steps
1-7 are before the insertion point, step 8 (Commit and summary) is
the step to renumber.

- [ ] **Step 2: Insert the checkpoint step**

Insert a new `### 8. Validate Habitat Files` after step 7 (Scaffold)
and before the current step 8 (Commit and summary). Content:

```markdown
### 8. Validate Habitat Files

**This step is mandatory.** After all habitat files are generated,
read each one and verify its structure against the corresponding
template in `${CLAUDE_PLUGIN_ROOT}/templates/`.

**Structural checks per file:**

1. **CLAUDE.md**: has required sections `## Workflow`,
   `## Build and Test`, `## Learnings`
   (reference: `templates/CLAUDE.md`)
2. **AGENTS.md**: has required sections `## STYLE`, `## GOTCHAS`,
   `## ARCH_DECISIONS`, `## TEST_STRATEGY`, `## DESIGN_DECISIONS`
   (reference: `templates/AGENTS.md`)
3. **MODEL_ROUTING.md**: has required sections
   `## Agent Routing Table` (with markdown table),
   `## Token Budget Guidance` (with markdown table)
   (reference: `templates/MODEL_ROUTING.md`)
4. **REFLECTION_LOG.md**: exists and has the header comment
   containing the entry format template

If any check fails, fix the file in place:

- Add missing sections from the corresponding template
- Do not overwrite existing content in sections that are already
  populated

Do not re-run the init conversation. Fix each file directly.
```

- [ ] **Step 3: Renumber subsequent steps**

Renumber the existing step:

- `### 8. Commit and summary` becomes `### 9. Commit and summary`

- [ ] **Step 4: Lint**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/commands/superpowers-init.md"`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/superpowers-init.md
git commit -m "Add habitat file validation checkpoint to /superpowers-init"
```

---

### Task 8: Version bump and changelog

**Files:**

- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump plugin.json version**

In `ai-literacy-superpowers/.claude-plugin/plugin.json`, change:
`"version": "0.19.3"` to `"version": "0.19.4"`

- [ ] **Step 2: Bump marketplace.json plugin_version**

In `.claude-plugin/marketplace.json`, change:
`"plugin_version": "0.19.3"` to `"plugin_version": "0.19.4"`

- [ ] **Step 3: Update README badge**

In `README.md`, change: `Plugin-v0.19.3` to `Plugin-v0.19.4`

- [ ] **Step 4: Add CHANGELOG entry**

Add a new section at the top of `CHANGELOG.md`:

```markdown
## 0.19.4 — 2026-04-15

### Output validation checkpoints

- Add validate-and-fix-in-place checkpoint to /harness-health —
  verifies all 12 snapshot sections present, no deprecated YAML block
- Add validation checkpoint to /assess — verifies assessment document
  has required sections and parseable level number for portfolio
  aggregation
- Add validation checkpoint to /reflect — verifies all 8 mandatory
  fields plus 4 session metadata subfields and Signal enum value
- Add validation checkpoint to /cost-capture — verifies cost snapshot
  has fields that /harness-health needs for Cost Indicators section
- Add validation checkpoint to /harness-constrain — verifies
  constraint block has required fields with valid enum values
- Add validation checkpoint to /harness-init — verifies generated
  HARNESS.md has all top-level sections, subsections, and template
  version marker
- Add validation checkpoint to /superpowers-init — verifies all 4
  habitat files (CLAUDE.md, AGENTS.md, MODEL_ROUTING.md,
  REFLECTION_LOG.md) have required sections
```

- [ ] **Step 5: Lint all changed files**

Run: `npx markdownlint-cli2 "CHANGELOG.md" "README.md"`
Expected: 0 errors

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json \
       .claude-plugin/marketplace.json \
       README.md CHANGELOG.md
git commit -m "Bump to 0.19.4 — output validation checkpoints"
```

---

### Task 9: Push and PR

- [ ] **Step 1: Push the branch**

```bash
git push -u origin fix/governance-summary-checkpoint
```

Note: use the existing branch if still on it, or create a new branch
`add-output-validation-checkpoints` if starting fresh from main.

- [ ] **Step 2: Create PR**

```bash
gh pr create --title "Add output validation checkpoints to 7 commands (0.19.4)" \
  --body "## Summary
- Add validate-and-fix-in-place checkpoints to 7 commands that produce structured output
- Each checkpoint reads the output, verifies structure against the format spec, fixes deviations in place
- Follows the pattern established in /governance-audit step 5

## Commands updated
1. /harness-health — 12 snapshot sections
2. /assess — assessment template sections
3. /reflect — 8 fields + session metadata + Signal enum
4. /cost-capture — cost snapshot fields
5. /harness-constrain — constraint block fields + enums
6. /harness-init — HARNESS.md sections + template marker
7. /superpowers-init — 4 habitat files

## Test plan
- [ ] CI passes (markdownlint, version-check)
- [ ] Each command file has a validation step
- [ ] No step numbers are duplicated or skipped"
```

- [ ] **Step 3: Watch CI**

```bash
gh pr checks <number> --watch
```

Expected: all checks pass.
