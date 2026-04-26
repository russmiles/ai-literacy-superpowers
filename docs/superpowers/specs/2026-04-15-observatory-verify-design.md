---
diaboli: exempt-pre-existing
---

# Observatory Signal Verification Command

## Problem

The Observatory plugin reads structured markdown from projects running
ai-literacy-superpowers. When signal formats drift — wrong headings,
missing fields, deprecated blocks — the Observatory silently gets
incomplete data. The only way to detect these gaps today is a manual
72-signal audit (done once in this session, found 13 gaps). A reusable
command would let any session start with "what signals are we missing?"

## Approach

A new `/observatory-verify` command that runs the signal contract
checklist on demand. Two verification layers:

1. **Contract completeness** — are format specs and command checkpoints
   covering all expected signals?
2. **Output compliance** — do the latest generated files match their
   contracts?

## Signal Sources (5 categories)

### Snapshot signals (12 sections)

Reference: `references/snapshot-format.md`

Sections: Enforcement, Enforcement Loop History, Garbage Collection,
Mutation Testing, Compound Learning, Session Quality, Operational
Cadence, Cost Indicators, Regression Indicators, Meta, Changes Since
Last Snapshot, Trends.

### Governance summary signals (9 fields)

Reference: `governance-auditor.agent.md` Governance Summary section.

Fields: Total constraints, Falsifiable, Vague, Falsifiability ratio,
Semantic drift stage, Drift velocity, Governance debt items,
Aggregate debt score, Frame alignment score.

### Reflection entry signals (12 fields)

Reference: `commands/reflect.md` entry template.

8 mandatory fields + 4 session metadata subfields.

### HARNESS.md signals (sections + subsections)

Reference: `templates/HARNESS.md`

4 top-level sections (Context, Constraints, GC, Observability) +
Status section + template version marker.

### Assessment signals (6 sections)

Reference: `ai-literacy-assessment/references/assessment-template.md`

Sections: Observable Evidence, Level Assessment, Discipline Maturity,
Strengths, Gaps, Recommendations.

## Components

### 1. Signal checklist reference

`skills/harness-observability/references/observatory-signals.md`

The authoritative checklist of all signals the Observatory expects.
Structured as a parseable table per source. This is the document the
command reads — updating the checklist updates what gets verified.

### 2. Command

`commands/observatory-verify.md`

Steps:

1. Read the signal checklist reference
2. For each signal source, find the latest output file
3. Check each signal: PRESENT / PARTIAL / MISSING
4. Produce a structured report table
5. Print summary counts per source

### 3. Validation checkpoint

The command itself produces a report (to stdout, not a file), so no
file-level validation checkpoint is needed. The report format is
defined in the command spec.

## Output format

```text
## Observatory Signal Verification

| Signal | Source | Expected Location | Status | Notes |
| --- | --- | --- | --- | --- |
| Enforcement count | Snapshot | ## Enforcement | PRESENT | |
| ... | ... | ... | ... | ... |

Summary: N PRESENT, N PARTIAL, N MISSING out of N total signals
```

Status values:

- **PRESENT** — signal documented in format spec and present in latest output
- **PARTIAL** — signal exists but incomplete (e.g. section present, field missing)
- **MISSING** — signal not found in latest output
- **NO_OUTPUT** — no output file exists yet (e.g. no snapshot generated)

## Version

0.20.0 — this is a new command but the version was already bumped for
/harness-onboarding. If shipped in the same release, no additional
bump needed. If shipped separately, bump to 0.21.0.
