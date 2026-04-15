---
name: harness-onboarding
description: Use when generating a human-readable onboarding document from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md — produces a friendly guide for new team members joining a harnessed project
---

# Harness Onboarding Documentation

## Overview

HARNESS.md is written for agents and experienced team members.
New contributors need something different — a friendly, practical
guide that explains "here's how we work" without requiring them to
parse constraint definitions and GC rule syntax.

This skill generates `ONBOARDING.md` from three sources the project
already maintains. No new data entry is needed — the onboarding
document is a human-readable projection of existing harness state.

---

## Sources

| Source | What it contributes |
| --- | --- |
| HARNESS.md | Stack, conventions, constraints, GC rules, observability cadence |
| AGENTS.md | Gotchas, architecture decisions, test strategy, design decisions |
| REFLECTION_LOG.md | Recent surprises with `context` or `workflow` signal |

HARNESS.md, AGENTS.md, and REFLECTION_LOG.md are the single source
of truth. Sync is one-way only — these files drive ONBOARDING.md.
The generated document is never edited directly.

---

## Tone

Write for a human who just joined the team and needs to ship their
first PR. The reader is a skilled developer who knows nothing about
this specific project.

- **Friendly, not formal.** "We use markdownlint to keep files
  consistent" not "All markdown files must pass markdownlint."
- **Practical, not theoretical.** Focus on what the contributor
  needs to do, not why the framework exists.
- **Grouped by action.** Constraints grouped by when they fire
  (commit-time, PR-time), not by enforcement type.
- **Warnings are stories.** Gotchas should explain what happened
  and how to avoid it, not just state the rule.

---

## Section Guidelines

### Welcome

One paragraph. What this project is, why it matters, what a new
contributor should expect. Pull from the README if it has a good
description; otherwise synthesise from the stack and conventions.

### Tech Stack

From HARNESS.md Context > Stack. List each technology with a
brief note on how it's used. Don't just repeat the HARNESS.md
bullets — add context about what each tool does in this project.

### How We Write Code

From HARNESS.md Context > Conventions. Transform the terse bullet
format into readable prose. Explain not just the rule but why the
team follows it. Use examples where helpful.

### What's Enforced

From HARNESS.md Constraints. Group by when they fire:

- **At commit time** — warnings during editing
- **At PR time** — CI gates that block merges
- **On schedule** — periodic checks

For each constraint, explain in plain English what it checks and
what happens if it fails. Skip the Tool and Enforcement fields —
those are implementation details for the harness, not for the
contributor.

### Common Pitfalls

From AGENTS.md GOTCHAS + recent REFLECTION_LOG entries where
Signal is `context` or `workflow`. Present as practical warnings:
"what happened" and "how to avoid it". Limit to the 5-7 most
relevant entries — the onboarding doc should not be exhaustive.

### Architecture Decisions

From AGENTS.md ARCH_DECISIONS. Each entry: what was decided, why,
and what the alternatives were. Frame as "the team already decided
this — here's why."

### How We Test

From AGENTS.md TEST_STRATEGY. Explain how quality is assured.
What tools run, what they check, how to run them locally.

### How the Harness Works

Brief explanation of the three enforcement loops. One sentence
each for advisory (hooks), strict (CI), and investigative (GC).
Mention the observability cadence from HARNESS.md Observability.
Don't explain the framework — just explain what the contributor
will encounter.

### Your First PR Checklist

Synthesise from Constraints and Conventions. Include only items
the contributor needs to check before pushing. Format as a
numbered list they can work through. Example items:

1. Run the linter
2. Check for secrets
3. Update CHANGELOG.md
4. Ensure commit message format

### Where to Learn More

Links to HARNESS.md, AGENTS.md, REFLECTION_LOG.md, and the docs
site if one exists.

---

## Validation

The generated document must match the section structure of
`templates/ONBOARDING.md`. The `/harness-onboarding` command
includes a validation checkpoint that verifies all 10 sections
are present and fixes missing sections in place.

---

## Regeneration

A GC rule checks monthly whether ONBOARDING.md is stale — whether
any of its three sources (HARNESS.md, AGENTS.md, REFLECTION_LOG.md)
have been modified more recently than ONBOARDING.md. When stale,
the GC rule flags it and suggests re-running `/harness-onboarding`.
