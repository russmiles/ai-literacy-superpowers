---
name: literacy-improvements
description: Use when generating a prioritised improvement plan after an AI literacy assessment, or when a user knows their current level and wants to know what to do next — maps gaps to specific plugin commands and skills, grouped by target level, with accept/skip/defer for each item
---

# Literacy Improvements

Generate a prioritised improvement plan that maps assessment gaps to
specific plugin commands and skills. Each improvement is presented
interactively — the user chooses to accept, skip, or defer.

This skill is invoked by `/assess` after Phase 5 (workflow
recommendations), but can also be used standalone when the user
knows their current level.

## Input

The skill needs two things:

- **Current level** (L0–L5) — from an assessment or stated by the user
- **Gaps** (optional) — from the assessment document's Gaps section.
  If not provided, the skill infers gaps by checking which items in
  the improvement mapping are not yet present in the repository.

## Process

### Step 1: Confirm Current Level

If invoked from `/assess`, the level is already known — skip this step.

If invoked standalone, ask the user:

```text
What is your current AI literacy level?

If you don't know, run /assess first — it takes fifteen minutes
and gives you an evidence-based answer.

1. Level 0 — Awareness
2. Level 1 — Prompting
3. Level 2 — Verification
4. Level 3 — Habitat Engineering
5. Level 4 — Specification Architecture
```

Level 5 teams do not need this skill — they are already at the top.

### Step 2: Ask Target Level

Present the levels above the current one:

```text
You're currently at Level N (Level Name).

How far would you like to improve?

1. Level N+1 — [name] (recommended next step)
2. Level N+2 — [name]
...up to Level 5
```

The default recommendation is always the next level. Higher targets
include all intermediate levels — choosing L4 from L2 means doing
L2→L3 improvements first, then L3→L4.

### Step 3: Generate Prioritised Plan

Read the mapping from `references/improvement-mapping.md`. For each
level transition between current and target:

1. **Check existing state** — for each gap in the mapping, verify
   whether it is already closed. Check the file system:
   - Does HARNESS.md exist? Does it have enforced constraints?
   - Does CLAUDE.md exist?
   - Are there CI workflows?
   - Does REFLECTION_LOG.md have recent entries?
   - Do specs/ directories exist?
   Use the observable evidence checks from the `ai-literacy-assessment`
   skill as guidance.

2. **Filter to open gaps** — remove items where the file or
   configuration already exists and is active.

3. **Assign priority** using this heuristic:
   - **High** — foundational. Nothing else at this level works without
     it. Examples: HARNESS.md for L3, CI pipeline for L2.
   - **Medium** — valuable and closes a real gap, but other items don't
     depend on it. Examples: secret scanning, GC rules.
   - **Low** — nice-to-have at this level, or the gap is partially
     closed. Examples: Docker scanning when no Docker is used,
     convention sync when only one AI tool is in use.

4. **Group by level transition** — "To reach Level 3" then "To reach
   Level 4".

5. **Order within each group** — high priority first, then medium,
   then low.

### Step 4: Present Plan Item by Item

For each improvement, present one at a time:

```text
Improvement 1/N (Level M — Level Name):
  Gap: [what is missing]
  Action: Run [command] or use [skill]
  Priority: High — [one-sentence rationale]

  Accept / Skip / Defer?
```

Handle each response:

- **Accept** — execute the command or invoke the skill immediately.
  Wait for it to complete before presenting the next item.
- **Skip** — remove from plan. Do not ask again this session.
- **Defer** — keep in plan but do not execute. Record as deferred
  for the next assessment to pick up.

If executing a command produces further interactive prompts (e.g.,
`/harness-init` asks about features), let them run naturally. Resume
the improvement plan after the command completes.

### Step 5: Record the Plan

If an assessment document exists for today
(`assessments/YYYY-MM-DD-assessment.md`), append an Improvement Plan
section:

```markdown
## Improvement Plan

- Current level: LN
- Target level: LM
- Improvements accepted: N
- Improvements skipped: N
- Improvements deferred: N
- Commands executed: [list of commands/skills that ran]

### Accepted

| Gap | Action | Result |
| --- | --- | --- |
| No HARNESS.md | /harness-init | HARNESS.md created with 4 constraints |

### Skipped

| Gap | Reason |
| --- | --- |
| No Docker scanning | No Docker in this project |

### Deferred

| Gap | Action | Reason |
| --- | --- | --- |
| No fitness functions | fitness-functions skill | Team wants to stabilise L3 first |
```

If no assessment document exists for today, write the plan to
`assessments/YYYY-MM-DD-improvements.md` as a standalone document.

### Step 6: Summary

Print a summary:

```text
Improvement plan complete.

  Current level: L2 (Verification)
  Target level: L3 (Habitat Engineering)
  Accepted: 4 improvements
  Skipped: 1
  Deferred: 1
  Commands executed: /harness-init, /harness-constrain, /reflect, /harness-health

  Run /assess again in 3 months to measure progress.
```

## Standalone Usage

When used outside `/assess`, the skill follows the same process but
starts from Step 1 (confirm level). The user can say:

- "I'm at L2, what should I do next?" → confirms L2, asks target, runs plan
- "Show me what L4 requires from L2" → confirms L2, sets target L4, runs plan
- "What's left to reach L3?" → infers current level by scanning, sets target L3

## Priority Heuristic

| Priority | Criteria | Examples |
| --- | --- | --- |
| High | Foundational — other items at this level depend on it | HARNESS.md for L3, CI pipeline for L2, specs dir for L4 |
| Medium | Valuable — closes a real gap independently | Secret scanning, GC rules, convention extraction |
| Low | Conditional — depends on project context or gap is partial | Docker scanning (no Docker), convention sync (one AI tool) |

Items marked as "(manual — outside plugin scope)" in the mapping are
presented as guidance rather than executable actions.
