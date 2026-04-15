# Output Validation Checkpoints

## Problem

Agents producing structured output drift from their format specs under
cognitive load. The governance-auditor proved this: detailed instructions
(lines 92-144 of the agent file) were consistently ignored, producing a
loose `## Summary` section instead of the machine-readable
`## Governance Summary` contract. The fix — a validation checkpoint in
the dispatching command — works because it verifies the output after the
agent finishes, then fixes deviations in place.

Six other HIGH+ risk commands produce structured output that downstream
agents, commands, or external consumers parse. None of them have
validation checkpoints.

## Approach

Add a validate-and-fix-in-place checkpoint step to each of the 7
commands that produce structured, parseable output. Each checkpoint:

1. Reads the output file after it is written
2. Checks structural requirements against the referenced format spec
3. Fixes deviations in place (does not re-dispatch the agent)

Checkpoints reference existing format specs rather than inlining field
definitions, to avoid duplication.

This is a patch-level change (output compliance fix, not new features).

## Checkpoint Specifications

### 1. `/harness-health` — snapshot validation

**Insert after**: Step 6 (Generate Markdown Sections)
**Insert before**: Step 7 (Update README)

**Output file**: `observability/snapshots/YYYY-MM-DD-snapshot.md`
**Format reference**: `references/snapshot-format.md`

**Structural checks**:

- File exists at the expected path
- All 12 section headings present in order:
  1. `## Enforcement`
  2. `## Enforcement Loop History`
  3. `## Garbage Collection`
  4. `## Mutation Testing`
  5. `## Compound Learning`
  6. `## Session Quality`
  7. `## Operational Cadence`
  8. `## Cost Indicators`
  9. `## Regression Indicators`
  10. `## Meta`
  11. `## Changes Since Last Snapshot`
  12. `## Trends` (conditional — only required when previous snapshot
      exists)
- No YAML `observatory_metrics` block (deprecated in v0.16.0)
- Each section contains the fields defined in `references/snapshot-format.md`

**Fix strategy**: Add missing sections with placeholder values sourced
from the format spec. Reorder if present but misordered. Remove
deprecated YAML block if found.

### 2. `/assess` — assessment document validation

**Insert after**: assessor agent writes the document
**Insert before**: README badge update

**Output file**: `assessments/YYYY-MM-DD-assessment.md`
**Format reference**: `ai-literacy-assessment/references/assessment-template.md`

**Structural checks**:

- File exists at the expected path
- Required sections present: Observable Evidence, Level Assessment,
  Discipline Maturity, Strengths, Gaps, Recommendations
- Level Assessment contains a level number (1-5) and level name
- Discipline Maturity contains a markdown table with scored disciplines

**Fix strategy**: Add missing sections from template. Ensure level
number is parseable by downstream portfolio aggregation.

### 3. `/reflect` — reflection entry validation

**Insert after**: entry is appended to REFLECTION_LOG.md
**Insert before**: commit

**Output file**: `REFLECTION_LOG.md` (last entry only)
**Format reference**: the entry template in `commands/reflect.md`

**Structural checks**:

- Last entry starts with `---` separator
- All 8 mandatory fields present: Date, Agent, Task, Surprise,
  Proposal, Improvement, Signal, Constraint
- Session metadata block present with all 4 subfields: Duration,
  Model tiers used, Pipeline stages completed, Agent delegation
- Signal field value is one of: `context`, `instruction`, `workflow`,
  `failure`, `none`

**Fix strategy**: Add missing fields with `"unknown"` values. Fix
Signal value to `none` if not in the enum. Add missing session metadata
subfields with `"unknown"`.

### 4. `/cost-capture` — cost snapshot validation

**Insert after**: snapshot is written
**Insert before**: commit

**Output file**: `observability/costs/YYYY-MM-DD-costs.md`
**Format reference**: `cost-tracking/SKILL.md`

**Structural checks**:

- File exists at the expected path
- Required fields present for `/harness-health` to parse: period,
  total spend, model routing reference

**Fix strategy**: Add missing fields with `"not tracked"` placeholders.

### 5. `/harness-constrain` — constraint block validation

**Insert after**: constraint is added to HARNESS.md
**Insert before**: test run dispatch

**Output file**: `HARNESS.md` (newly added constraint block only)
**Format reference**: constraint template block in `templates/HARNESS.md`

**Structural checks**:

- Newly added constraint block has all required fields: Rule,
  Enforcement, Tool, Scope
- Enforcement value is one of: `deterministic`, `agent`, `unverified`
- Scope value is one of: `commit`, `pr`, `weekly`, `manual`
- If a `Governance requirement` field is present, all governance fields
  must also be present: Operational meaning, Verification method,
  Evidence, Failure action, Frame check

**Fix strategy**: Add missing fields with placeholder values. Normalise
Enforcement and Scope to valid enum values if they are close matches.

### 6. `/harness-init` — generated HARNESS.md validation

**Insert after**: HARNESS.md is generated
**Insert before**: CI workflow generation

**Output file**: `HARNESS.md`
**Format reference**: `templates/HARNESS.md`

**Structural checks**:

- All 4 top-level sections present: `## Context`, `## Constraints`,
  `## Garbage Collection`, `## Observability`
- Context section has `### Stack` and `### Conventions` subsections
- Observability section has `### Operating cadence`,
  `### Health thresholds`, and `### Regression detection` subsections
- `## Status` section present with all 4 fields: Last audit,
  Constraints enforced, Garbage collection active, Drift detected
- Template version marker comment present:
  `<!-- template-version: X.Y.Z -->`

**Fix strategy**: Add missing sections from template. Insert template
version marker if absent.

### 7. `/superpowers-init` — habitat file validation

**Insert after**: all habitat files are generated
**Insert before**: commit

**Output files**: `CLAUDE.md`, `AGENTS.md`, `MODEL_ROUTING.md`,
`REFLECTION_LOG.md`
**Format references**: corresponding files in `templates/`

**Structural checks per file**:

- **CLAUDE.md**: has required sections: Workflow, Build and Test,
  Learnings
- **AGENTS.md**: has required sections: STYLE, GOTCHAS,
  ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS
- **MODEL_ROUTING.md**: has required sections: Agent Routing (with
  table), Token Budget Guidance (with table)
- **REFLECTION_LOG.md**: has the header comment with entry format
  template

**Fix strategy**: Add missing sections from templates. Do not overwrite
existing content in sections that are already populated.

## Checkpoint Pattern

Every checkpoint follows the same structure in the command spec:

```text
### N. Validate [output name]

**This step is mandatory.** After [producer] writes [output file],
read it and verify the structure matches the [format reference].

**Structural checks:**

1. [check 1]
2. [check 2]
...

If any check fails, fix the output in place using data from the
[producer]'s output. Do not re-dispatch the [agent/command].
```

## Scope

- 7 command files modified (new step added to each)
- 0 agent files modified (agents keep existing instructions;
  checkpoints are in the dispatching commands)
- 0 format spec files modified (checkpoints reference, not duplicate)
- Version bump: 0.19.3 to 0.19.4 (patch — compliance fix)

## Out of Scope

- MEDIUM risk producers (convention-sync, harness-gc, code-reviewer)
  are not included in this change. They can be added later if format
  drift is observed.
- Agent-level self-check instructions are not added. The
  governance-auditor already has one; the others can get them later.
  The command-level checkpoint is the reliable layer.
- No new format specs are created. Existing references are sufficient.
