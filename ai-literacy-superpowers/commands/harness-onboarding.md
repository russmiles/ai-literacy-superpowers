---
name: harness-onboarding
description: Generate a human-readable onboarding document from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md — a friendly guide for new team members
---

# /harness-onboarding

Generate `ONBOARDING.md` — a human-readable onboarding guide for new
team members, synthesised from the project's harness state.

Read the `harness-onboarding` skill from this plugin before proceeding.
It provides the tone guidelines and section-by-section content mapping.

## Process

### 1. Check Prerequisites

Verify `HARNESS.md` exists. If not, tell the user to run
`/harness-init` first.

Check whether `AGENTS.md` and `REFLECTION_LOG.md` exist. If either
is missing, proceed with reduced sources — note which sections will
be skipped.

### 2. Read Sources

Read three files:

- **HARNESS.md** — extract Context (Stack, Conventions), Constraints
  (all entries with Rule, Scope), Garbage Collection rules,
  Observability cadence
- **AGENTS.md** — extract GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY,
  DESIGN_DECISIONS sections
- **REFLECTION_LOG.md** — extract recent entries (last 10) where
  Signal is `context` or `workflow`

### 3. Generate ONBOARDING.md

Read the template from `${CLAUDE_PLUGIN_ROOT}/templates/ONBOARDING.md`.

For each section, replace the placeholder content with generated
prose following the tone and section guidelines from the
`harness-onboarding` skill:

1. **Welcome** — synthesise from README and stack info
2. **Tech Stack** — from Context > Stack
3. **How We Write Code** — from Context > Conventions
4. **What's Enforced** — from Constraints, grouped by Scope
5. **Common Pitfalls** — from GOTCHAS + filtered REFLECTION_LOG
6. **Architecture Decisions** — from ARCH_DECISIONS
7. **How We Test** — from TEST_STRATEGY
8. **How the Harness Works** — from GC rules + Observability
9. **Your First PR Checklist** — synthesised from Constraints +
   Conventions
10. **Where to Learn More** — links to source files

Write the result to `ONBOARDING.md` at the project root.

### 4. Validate Generated Document

**This step is mandatory.** After writing ONBOARDING.md, read it and
verify its structure against `templates/ONBOARDING.md`.

**Structural checks:**

1. All 10 section headings present: Welcome (as H1), Tech Stack,
   How We Write Code, What's Enforced, Common Pitfalls, Architecture
   Decisions, How We Test, How the Harness Works, Your First PR
   Checklist, Where to Learn More
2. What's Enforced section has subsections for at least one of:
   At commit time, At PR time, On schedule
3. Generated header comment present (the "Do not edit directly"
   notice)
4. No placeholder markers remain (`{{` or `}}`)

If any check fails, fix the document in place:

- Add missing sections with content from the corresponding source
- Remove any remaining placeholder markers

Do not regenerate the document. Fix the output directly.

### 5. Update README

Check whether README.md contains a link to ONBOARDING.md. If not,
add one. Look for an existing "Onboarding" or "Getting Started" or
"Contributing" section. If found, add the link there. If not, add
a line after the project description:

```text
New to the project? Start with [ONBOARDING.md](ONBOARDING.md).
```

### 6. Commit

```bash
git add ONBOARDING.md README.md
git commit -m "Generate onboarding guide from harness state"
```
