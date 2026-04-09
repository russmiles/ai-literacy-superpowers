---
name: assess
description: Run an AI literacy assessment — scan the repo for evidence, ask clarifying questions, produce a timestamped assessment document, apply immediate habitat fixes, recommend workflow changes, capture a reflection, and add a literacy level badge to the README
---

# /assess

Run an AI literacy assessment for this project.

Read the `ai-literacy-assessment` skill before proceeding — it contains
the scoring heuristic, evidence signals, assessment template, and the
immediate adjustment and workflow recommendation phases.

## Process

### 1. Scan

Scan the repository for observable evidence of each framework level.
Check for CI workflows, test coverage, vulnerability scanning, mutation
testing, CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, custom
skills, agents, commands, hooks, specifications, implementation plans,
orchestrator safety gates, and platform-level tooling.

Record every signal found (with file path) and every signal not found.

### 2. Present and Question

Present what the scan found in a structured summary. Then ask 3-5
clarifying questions to fill gaps — focus on workflow habits, team
practices, cost awareness, and how consistently the observable tools
are actually used.

Ask ONE question at a time. Wait for each answer.

### 3. Assess

Apply the scoring heuristic: the assessed level is the highest level
where the team has substantial evidence across all three disciplines
(context engineering, architectural constraints, guardrail design).
The weakest discipline is the ceiling.

### 4. Document

Create `assessments/YYYY-MM-DD-assessment.md` using the template from
the skill's references. Fill every section with specific evidence.

### 5. Immediate Habitat Adjustments

Identify and apply fixes that require no team discussion — habitat
hygiene that should always be current:

- **Stale HARNESS.md Status**: If the constraint count, enforcement
  ratio, or GC count doesn't match the actual declarations, update it
- **Stale README badges**: If harness badge, mutation testing badge,
  or AI Literacy badge show outdated numbers, update them
- **Stale README mechanism map**: If new agents, commands, hooks,
  skills, or CI workflows exist but aren't in the map, add them
- **Stale README enforcement table**: If constraint type counts are
  wrong, fix them
- **Stale README framework document section**: If new appendices or
  themes exist but aren't listed, add them
- **Empty AGENTS.md sections**: If the assessment revealed gotchas
  or patterns that should be in AGENTS.md, propose additions

Present each adjustment. Apply immediately. Record what was changed
in the assessment document.

### 6. Workflow Operation Recommendations

Based on gaps identified, recommend changes to how existing artifacts
are *operated* (not built — they exist, they just need different usage
patterns). Present each recommendation ONE at a time. For each:

- Describe the recommendation
- Explain why it matters (which gap it closes)
- Ask: "Accept this change?" (yes/no)

If accepted, apply immediately:

- **Operating cadences** → add to CLAUDE.md as a workflow rule
- **Harness constraint promotions** → update HARNESS.md enforcement
  field from unverified to agent or deterministic
- **Artifact activation** → add operating notes to AGENTS.md or
  CLAUDE.md
- **Habit recommendations** → add to AGENTS.md GOTCHAS

Record accepted and rejected recommendations in the assessment
document.

### 6b. Improvement Plan

Invoke the `literacy-improvements` skill with the assessed level from
step 3 and the gaps from section 7 of the assessment document. The
skill asks the user to choose a target level, generates a prioritised
plan, and walks through each improvement interactively
(accept/skip/defer).

Phase 6 recommendations (operate better) and 6b improvements (build
toward next level) are complementary — run both.

### 7. Assessment Reflection

Append a structured reflection to REFLECTION_LOG.md:

- **Date**: today
- **Agent**: assessor (via /assess)
- **Task**: AI literacy assessment
- **Surprise**: what the scan revealed vs what was expected
- **Proposal**: any patterns to add to AGENTS.md
- **Improvement**: what would make the next assessment better

### 8. Check README for broader updates

Beyond the specific adjustments in step 5, do a final check:
has anything else in the README become stale? Update if needed.

### 9. Badge

Add or update an AI Literacy badge in the README:

```text
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_N-COLOUR?style=flat-square)](assessments/YYYY-MM-DD-assessment.md)
```

Colours: L0=808080, L1=87CEEB, L2=4682B4, L3=20B2AA, L4=2E8B57, L5=DAA520

### 9b. Tag Repository

If the assessed level is L3 or above and the project is hosted on
GitHub, add the `agent-harness-enabled` topic tag:

```bash
gh repo edit --add-topic agent-harness-enabled 2>/dev/null
```

Also add the harness-enabled badge to the README if not already present:

```text
[![Agent Harness Enabled](https://img.shields.io/badge/Agent_Harness-Enabled-000000?style=flat-square)](HARNESS.md)
```

If `gh` is not available, the repo is not on GitHub, or the level is
below L3, skip silently.

### 10. Commit

```bash
mkdir -p assessments
git add assessments/ README.md HARNESS.md AGENTS.md CLAUDE.md REFLECTION_LOG.md
git commit -m "AI Literacy Assessment: Level N — LEVEL_NAME (YYYY-MM-DD)

Assessment with immediate adjustments and accepted workflow changes."
```

### 11. Report

Present a summary to the user:

- Assessed level with one-line rationale
- Top 3 strengths
- Top 3 gaps
- Immediate adjustments applied (count and summary)
- Workflow changes accepted vs rejected
- Top 3 recommendations for longer-term work
- Link to the full assessment document
