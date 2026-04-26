---
diaboli: exempt-pre-existing
---

# Harness Onboarding Documentation Generator

## Problem

Teams use HARNESS.md for agents but need plain-language onboarding
docs for humans. There's no way to generate a "here's how we work"
document from the harness state.

## Approach

A new `/harness-onboarding` command that reads HARNESS.md, AGENTS.md,
and REFLECTION_LOG.md and generates a human-readable `ONBOARDING.md`.
Follows the convention-sync pattern: sources are the single source of
truth, sync is one-way only, regeneration replaces the output.

Three user requirements beyond the original proposal:

1. **README link** — the generated ONBOARDING.md is linked from the
   project README
2. **Monthly GC rule** — a garbage collection rule checks whether
   ONBOARDING.md is stale (sources changed since last generation)
3. **Validation checkpoint** — the command includes a validate-and-
   fix-in-place step that verifies the generated document matches the
   template structure, following the pattern established for 8 other
   commands in v0.19.4

## Components

### 1. Skill: `skills/harness-onboarding/SKILL.md`

Defines:

- The tone: friendly, practical, written for a human who just joined
  the team and needs to ship their first PR
- Section guidelines: what content goes in each section, how to
  transform terse HARNESS.md bullets into readable prose
- Source mapping: which file feeds which section

### 2. Command: `commands/harness-onboarding.md`

Steps:

1. Check HARNESS.md exists
2. Read sources (HARNESS.md, AGENTS.md, REFLECTION_LOG.md)
3. Generate ONBOARDING.md from template
4. **Validate generated document** — verify structure against
   `templates/ONBOARDING.md` (same checkpoint pattern as other
   commands)
5. Add README link if not present
6. Commit

### 3. Template: `templates/ONBOARDING.md`

Skeleton with 10 section headings and placeholder markers. The
validation checkpoint verifies all sections are present.

Sections:

1. Welcome
2. Tech Stack
3. How We Write Code
4. What's Enforced
5. Common Pitfalls
6. Architecture Decisions
7. How We Test
8. How the Harness Works
9. Your First PR Checklist
10. Where to Learn More

### 4. GC rule addition to `templates/HARNESS.md`

```markdown
### Onboarding document staleness

- **What it checks**: Whether ONBOARDING.md is older than the most
  recent change to HARNESS.md, AGENTS.md, or REFLECTION_LOG.md
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: file date comparison
- **Auto-fix**: false
```

### 5. Project HARNESS.md update

Add the same GC rule to the project's own HARNESS.md.

## Version

0.20.0 — new command added.

## Out of Scope

- CONTRIBUTING.md generation (different concern: process, licensing,
  code of conduct)
- Docs site page for the generated content (ONBOARDING.md is a
  repo-level file, not a docs site page)
