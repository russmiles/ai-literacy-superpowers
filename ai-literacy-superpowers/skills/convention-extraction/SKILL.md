---
name: convention-extraction
description: Use when setting up a new project's conventions, onboarding AI to an existing codebase, after team composition changes, or when AI output quality varies depending on who prompts — guides structured discovery of tacit team knowledge into explicit, enforceable artefacts
---

# Convention Extraction

Most team conventions live in people's heads — pattern recognition
built from years of reviews, production incidents, and architectural
discussions. They transfer slowly through pairing and code review, and
walk out the door when someone leaves. AI amplifies this: without
explicit conventions, AI output quality varies by who prompts. Same
codebase, same AI, completely different quality gates.

This skill guides systematic extraction of tacit knowledge into
versioned, enforceable artefacts. The approach is informed by Rahul
Garg's "Encoding Team Standards" (2026), which frames inconsistent AI
output as a systems problem requiring a systems solution.

This skill does not cover convention enforcement (see constraint-design
and verification-slots), convention maintenance (see context-engineering
and garbage-collection), or CI pipeline configuration.

For the full interview protocol with worked examples, consult
`references/extraction-interview-guide.md`.

## When to Extract

| Situation | Signal |
| ----------- | -------- |
| New project setup | CLAUDE.md and HARNESS.md are empty or boilerplate |
| Onboarding AI to existing codebase | AI-generated code keeps violating unwritten rules |
| After team composition changes | New members or departures change the tacit knowledge base |
| Quality variance | AI output quality depends on who is prompting |
| Post-incident | A production incident reveals conventions that were implicit |

**Sizing heuristic:** Teams of five may not need formal extraction —
conversations happen naturally. Teams of fifteen almost certainly do —
tacit knowledge diverges without intervention.

## The Five Extraction Questions

These questions surface the tacit knowledge that matters most for AI
collaboration. Ask them in a team setting (mob session) or through
structured one-on-one interviews with senior engineers.

1. **What architectural decisions should never be left to individual
   judgment?** Surfaces non-negotiable patterns — dependency direction,
   module boundaries, API design rules.

2. **Which conventions are corrected most often in AI-generated code?**
   Surfaces the gap between what AI produces by default and what the
   team expects. These are your highest-value conventions.

3. **Which security checks are applied instinctively?** Surfaces
   embodied security knowledge — input validation, auth patterns,
   secrets handling — that seniors apply without thinking.

4. **What triggers an immediate rejection in review?** Surfaces hard
   boundaries — the things that are never acceptable regardless of
   context.

5. **What separates a clean refactoring from an over-engineered one?**
   Surfaces judgment about abstraction thresholds, YAGNI boundaries,
   and when to stop.

## Mapping Answers to Artefacts

Each answer maps to a specific artefact type and location:

| Answer category | Priority tier | Artefact type | Where it lives |
| ---------------- | --------------- | --------------- | ---------------- |
| Non-negotiable patterns | Must-follow | Constraint | HARNESS.md |
| Frequent corrections | Should-follow | Convention | CLAUDE.md |
| Security instincts | Must-follow | Threat-model item | HARNESS.md or security skill |
| Review rejections | Must-follow | Critical check | Code reviewer agent instructions |
| Refactoring philosophy | Nice-to-have | Style preference | CLAUDE.md or skill reference |
| "It depends" answers | Not encodable yet | Aspiration | Backlog for decomposition |

**"It depends" is a signal, not a failure.** If the answer is always
"it depends on context," the convention needs decomposition into
specific, observable cases before it can be encoded.

## The Four-Element Anatomy

Every encoded instruction benefits from four elements:

### 1. Role Definition

What expertise is assumed? Not persona play — it establishes the lens.
"A senior engineer implementing a new service following the team's
architectural patterns" is different from "a security reviewer
assessing input handling."

### 2. Context Requirements

What does the instruction need to operate? Relevant code, architectural
context, applicable constraints. Makes dependencies explicit.

### 3. Categorised Standards

Organised by priority tier:

| Tier | Meaning | Enforcement |
| ------ | --------- | ------------- |
| Must-follow | Non-negotiable. Violations are blockers. | HARNESS.md constraint |
| Should-follow | Strong expectation. Exceptions need justification. | CLAUDE.md convention |
| Nice-to-have | Preferred but not enforced. | CLAUDE.md or skill reference |

### 4. Output Format

What should the result look like? A structured response with summary,
categorised findings, and clear next steps. Ensures consistency across
developers and sessions.

## Anti-Patterns

| Anti-pattern | Problem | Fix |
| ------------- | --------- | ----- |
| Over-prescriptive instructions | Brittle, false positives on edge cases | Test the instruction against real code before committing |
| Encoding aspirations | "Write clean code" is not enforceable | Decompose into observable properties |
| Documentation graveyards | Created with enthusiasm, abandoned in months | Place artefacts close to the workflow; use GC rules for freshness |
| Premature scaling | Ten instructions before one is adopted | Start with one instruction (generation or review) and expand after adoption |
| Skipping disagreement | Assuming seniors agree when they don't | The extraction conversation is the point — disagreements are features |

## When to Re-Extract

- After significant team composition changes (someone joins or leaves)
- After a production incident reveals tacit knowledge that wasn't
  encoded
- When AI output quality degrades without obvious cause
- Quarterly, as part of the operating cadence — review whether encoded
  conventions still match practice

## The Command

Run `/extract-conventions` for a guided, conversational extraction
session that walks through the five questions and maps answers to
artefacts.
