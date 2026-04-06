---
name: cupid-code-review
description: Use when reviewing or refactoring code and wanting a structured lens beyond SOLID — applies Daniel Terhorst-North's CUPID properties to surface improvement opportunities in any codebase or language.
---

# CUPID as a Code Review and Refactoring Lens

## Overview

CUPID is a set of five properties — **C**omposable, **U**nix philosophy, **P**redictable, **I**diomatic, **D**omain-based — described by Daniel Terhorst-North as things good code *tends toward*, not rules it must comply with. That makes them ideal review lenses: you are asking "how strongly does this code exhibit this property?" and "what would moving it further in this direction look like?"

Use them as questions, not verdicts.

---

## The Five Lenses

### C — Composable: plays well with others

Code is composable when it can be combined with other code in many contexts without modification.

**Review questions:**
- Can I use this function/module independently, without pulling in unrelated state?
- Is the API surface the minimum needed — no accidental exposure?
- Are dependencies explicit (passed in) rather than implicit (global/ambient)?
- Does it work at multiple call sites, or does it secretly assume one?

**Refactoring signals:**
- Many parameters that describe context rather than the operation itself
- Functions that only make sense when called in a specific order
- Hidden global state or singleton dependencies
- "God object" arguments that carry everything

**Move toward:** Smaller surface area. Dependencies injected. Works in isolation.

---

### U — Unix philosophy: does one thing well

Not just single responsibility — the function does its one thing *completely* and *well*, with a clear, nameable purpose.

**Review questions:**
- Can I describe what this does in one short sentence without using "and"?
- Does the name match what it actually does?
- Are there multiple abstraction levels mixed together (orchestration alongside detail)?
- Would splitting it make each part simpler or just create indirection?

**Refactoring signals:**
- "and" or "or" in function/method names
- Functions that both compute *and* persist *and* notify
- Comments that describe sections within a function (each section wants to be a function)
- Length as a proxy: long functions often do several things

**Move toward:** One clear responsibility. Name that earns no qualification. Flat abstraction level.

---

### P — Predictable: does what you expect

Given its name and context, the code behaves consistently, without surprises. Deterministic where possible. Fails loudly rather than silently.

**Review questions:**
- Given only the name, would a reader expect the observed behaviour?
- Are there hidden side effects beyond what the signature suggests?
- Does it behave the same way every time with the same inputs?
- Does it fail loudly (exception/error) or silently (returns null/zero/empty)?

**Refactoring signals:**
- Boolean parameters that change behaviour significantly (boolean trap)
- Functions that mutate their arguments
- Swallowed exceptions or silent fallbacks
- Different return types depending on a flag
- Names that understate what the function does ("get" that also writes)

**Move toward:** Behaviour matches name. Side effects visible in signature. Loud failure.

---

### I — Idiomatic: feels natural

Code that fits its language, ecosystem, and team conventions. A reader familiar with the context should not be surprised by the patterns used.

**Review questions:**
- Would a developer new to this codebase (but experienced in this language) find this familiar?
- Are language features used as intended, not fought against?
- Does it follow the team/project conventions established elsewhere?
- Is anything reimplementing something the standard library provides?

**Refactoring signals:**
- Manual iteration where a higher-order function is conventional
- Reimplementing collection operations, parsing, or formatting from scratch
- Patterns that need a comment to explain why they exist
- Inconsistent style compared to surrounding code

**Move toward:** Follows the grain of the language. Uses established patterns. No surprises for the familiar reader.

---

### D — Domain-based: the solution domain models the problem domain

The code uses the language of the business or problem domain. Names come from the domain, not from technical implementation details.

**Review questions:**
- Do the names in this code appear in conversations with domain experts?
- Could a domain expert (non-programmer) read the high-level logic and recognise what it describes?
- Are there technical names where domain names exist (e.g. `dataList` vs `invoices`)?
- Does the structure of the code mirror the structure of the domain?

**Refactoring signals:**
- Generic names: `data`, `item`, `manager`, `handler`, `util`, `helper`
- Technical names for business concepts: `UserRecord` instead of `Customer`
- Domain logic buried inside infrastructure or UI code
- No shared vocabulary between code and domain conversations (missing ubiquitous language)

**Move toward:** Names from the domain. Structure that reflects domain relationships. Code a domain expert could navigate.

---

## Quick Reference

| Property | Core question | Primary smell |
| --------- | ------------- | ------------- |
| Composable | Can I use this anywhere without baggage? | Hidden dependencies, large surface area |
| Unix | Does it do one thing, completely? | "and" in name, mixed abstraction levels |
| Predictable | Does it behave as its name suggests? | Hidden side effects, silent failure |
| Idiomatic | Does it feel natural here? | Reinventing the wheel, inconsistent patterns |
| Domain-based | Does it speak the domain's language? | Generic or technical names for business concepts |

---

## Using CUPID as a Review Lens

Work through each property in turn for the code under review. For each one:

1. Ask the review questions above
2. Note which properties are weakly exhibited
3. Describe a concrete change that would move toward the property

Avoid framing as pass/fail. The goal is: "this code is more Predictable than Composable — what would make it more Composable?"

## Using CUPID as a Refactoring Guide

When deciding where to start refactoring:

1. Score each property loosely (strong / weak / absent) for the target code
2. Prioritise the weakest property that, if improved, would make the others easier
3. Domain-based often unlocks everything else: when names are right, the right structure becomes obvious
4. Composable refactoring tends to have the highest leverage — isolated code is testable, movable, reusable

---

## Common Mistakes

- **Treating CUPID as a checklist** — these are properties to aspire toward, not boxes to tick. A function can be partially Predictable.
- **Conflating Unix with small** — a function can be small and still do two things. The question is clarity of purpose, not line count.
- **Skipping Domain-based** — it feels soft but it is often the most impactful lens. Code that speaks the domain language is self-documenting and easier to reason about.
- **Applying all five at once** — pick the one or two properties that are most weakly exhibited and focus there. Trying to improve all five simultaneously leads to over-engineering.

---

## Optional: README Status Addendum

After completing a CUPID assessment, offer to add or update a **CUPID Status** section in the project's README. Do not add it automatically — offer it and let the user decide.

### When to offer

- After completing a full five-property assessment
- After a significant refactoring pass guided by CUPID lenses
- When the user asks to document the code quality state

### Badge

Add a shields.io static badge to the project's badge row (alongside CI and language badges) that links to the `#cupid-status` section. Update the date whenever the assessment is refreshed:

```markdown
[![CUPID Status](https://img.shields.io/badge/CUPID-assessed_YYYY--MM--DD-DAA520?style=flat-square)](README.md#cupid-status)
```

The goldenrod colour (`DAA520`) is intentional — it matches the CUPID five-star rating aesthetic and is visually distinct from the green CI badges. The badge links directly to the status table in the same README.

### GitHub label

If the project has a GitHub repository, ensure a `CUPID assessed` label exists for tagging PRs that include a CUPID review. Create it once with:

```bash
gh label create "CUPID assessed" --color "DAA520" --description "PR includes a CUPID code quality assessment" --repo <owner>/<repo>
```

Apply the label when opening a PR that includes a full CUPID review or a targeted CUPID-guided refactoring.

### Standard format

Add a `## CUPID Status` section (or update it if already present) using this template:

```markdown
## CUPID Status

Last assessed: YYYY-MM-DD

| Property | Strength | Top opportunity |
| --------- | -------- | --------------- |
| Composable | ★★★★☆ | Brief description |
| Unix philosophy | ★★★☆☆ | Brief description |
| Predictable | ★★★★★ | — |
| Idiomatic | ★★★☆☆ | Brief description |
| Domain-based | ★★★★☆ | Brief description |
```

**Strength ratings:** use ★ symbols on a 1–5 scale. A `—` in the opportunity column means no meaningful opportunity was identified.

**Top opportunity:** one sentence describing the single most impactful change for that property. Keep it specific enough to be actionable, not a restatement of the property definition.

### Placement in the README

Insert the section after any existing badges, overview, or quick-start content, and before detailed technical documentation. It should be easy to find at a glance — near the top, not buried at the bottom.

The badge belongs in the badge row at the very top of the README, after language/CI badges.

### Workflow

If the project uses a branch/PR workflow (e.g. a CLAUDE.md that requires working on branches), follow that workflow to add the addendum: create a branch, make the change, open a PR. Do not commit directly to main if the project convention says otherwise.
