# The Assessment Practice — Article Design

**Date:** 2026-04-09
**Status:** Approved
**Type:** Single long-form article (~2300 words)
**Series label:** *The Assessment Practice — Companion to The Environment Hypothesis series*

---

## Context

The existing 6-article series ("The Environment Hypothesis") introduces
the AI Literacy framework: environment as product, context engineering,
constraints, entropy, agent orchestration, and the learning loop. It
does not cover assessment — how teams determine their current level and
use that knowledge to improve.

This companion article fills that gap. It is aimed at the same audience
(developers already using AI tools but not yet thinking systematically
about literacy levels) and can be read independently of the first series.

The core thesis: **assessment is a recurring practice, not a one-off
audit.** It is the meta-skill of knowing where you are — the quarterly
rhythm that closes the outermost feedback loop.

---

## Structure

### Section 1: Opening and Problem Statement (~400 words)

Scene: a team that's been using AI tools for six months. They have a
CLAUDE.md and some constraints. They think they're doing well. Then
someone asks: "Are we actually good at this, or are we just busy?"

The problem: you can't improve what you can't locate. Most teams
confuse activity (using AI tools) with literacy (using them well).
The Dunning-Kruger of AI literacy — teams at L1 think they're at L3.

Thesis: assessment is not an audit. It's a practice. A recurring
discipline that tells you where you are, what's working, and what to
do next.

### Section 2: The Six Levels — "Which of These Sounds Like You?" (~500 words)

Conversational tour of L0–L5. Each level is a short vignette the
reader recognises or doesn't:

- **L0 — Awareness:** know AI exists, haven't used it on real work
- **L1 — Prompting:** daily use, copy-paste output, no verification
- **L2 — Verification:** tests in CI, linters, don't trust by default,
  but AI still doesn't know your conventions
- **L3 — Habitat Engineering:** CLAUDE.md, HARNESS.md, reflections,
  sessions improve over time because environment accumulates knowledge
- **L4 — Specification Architecture:** specs before code, agent pipeline
  with safety gates, AI is a colleague not a typewriter
- **L5 — Sovereign Engineering:** reusable plugins, cross-team templates,
  cost tracking, model routing, organisational governance

Key insight after the tour: these are diagnostic positions, not
aspirational destinations. You're already at one. The question is which.

Brain check: "Which level did you recognise yourself in? Did you
hesitate between two? That hesitation is the whole point."

### Section 3: Observable Evidence — "Files, Not Feelings" (~400 words)

Turn from self-perception to evidence. Sceptic/Pragmatist dialogue
opens: the sceptic claims L3, the pragmatist asks when they last ran
an audit and how many constraints are enforced in CI.

An assessment scans for concrete signals — files that exist or don't,
configurations active or stale, workflows that run or are disabled.
Grouped by level:

- L2: CI workflows, test coverage, vulnerability scanning
- L3: CLAUDE.md, HARNESS.md enforced, AGENTS.md with entries,
  REFLECTION_LOG.md with recent dates
- L4: spec files, plans, orchestrator with safety gates
- L5: plugin structure, cross-team templates, observability config

The uncomfortable truth: most teams are one level lower than they think.
A CLAUDE.md that hasn't been updated in two months is L1 wearing L3
costume.

Brain check: "Open your repo. Is there a file that declares a practice
you've stopped doing?"

### Section 4: The Practice — Assessment as Recurring Discipline (~500 words)

The core section. Bank balance analogy — you wouldn't check once and
never look again.

The quarterly cadence:

1. Scan — read repo for evidence
2. Question — 3-5 clarifying questions
3. Assess — evidence maps to level, weakest discipline is ceiling
4. Document — timestamped assessment file
5. Adjust — immediate habitat hygiene fixes
6. Recommend — workflow changes, accepted/rejected, applied immediately
7. Reflect — assessment becomes a reflection feeding the learning loop

Key mechanism: assessment closes the outer loop. The first series
described three loops. Assessment is the periodic loop's deepest cycle.

Veteran quote: team thought L3, was L2. Second assessment three months
later: L3 — not from building anything new but from operating what they
already had.

Compound effect: each assessment raises the floor for the next one.
Recommendations from Q1 become evidence in Q2.

### Section 5: What Happens After (~400 words)

Three things happen after assessment:

**Immediate adjustments** — habitat hygiene fixed on the spot. Stale
counts, missing entries, drift between declared and actual.

**Workflow recommendations** — not "build something new" but "use what
you have differently." Unverified constraints promoted. AGENTS.md
activated. Reflection cadence practised.

**The reflection** — assessment captures a reflection on itself. Feeds
REFLECTION_LOG.md, feeds curation, feeds the harness. The assessment
is part of the learning loop, not outside it.

Brain check: "Retrospective action items that never get done. Assessment
is different because it applies changes in the same session."

The badge — README badge showing level, linking to full assessment.
Accountability, not vanity.

Closing: the first series said "the environment is the product." This
article adds: you have to know the state of the product.

Call to action: "Run `/assess`. Fifteen minutes. You'll learn more
from one assessment than from six months of vague intention."

### Section 6: Bullet Points (~100 words)

Summary bullets matching existing series format:

- The Dunning-Kruger of AI literacy
- Files, not feelings
- Six levels (L0–L5)
- Assessment is a practice, not an audit
- Weakest discipline is the ceiling
- Immediate adjustments in the same session
- Assessment feeds the learning loop

---

## Style

Match the existing series: conversational, second-person, Head
First-style Brain checks, Sceptic/Pragmatist dialogues, Veteran
quotes. British English spelling (colour, organisation, behaviour).

## File

`articles/07-the-assessment-practice.md`

## Files Changed

1. `articles/07-the-assessment-practice.md` — the article (new)
2. `CHANGELOG.md` — entry for the new article
