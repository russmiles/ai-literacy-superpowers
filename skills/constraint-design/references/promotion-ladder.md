# The Constraint Promotion Ladder

## Overview

Every constraint in HARNESS.md sits at one of three enforcement levels.
The ladder describes how constraints move from declared intent to
automated enforcement over time.

```text
┌─────────────┐     ┌─────────┐     ┌───────────────┐
│  Unverified  │ ──► │  Agent  │ ──► │ Deterministic │
│  (declared)  │     │ (LLM)   │     │   (tooling)   │
└─────────────┘     └─────────┘     └───────────────┘
```

## Level 1: Unverified

The constraint is declared in HARNESS.md but has no automated
enforcement. It exists as documentation and intent.

**When to use:**

- The team has identified a convention but has not automated it yet
- No deterministic tool exists for this constraint
- The team is still refining the rule's wording

**What it provides:**

- Visibility — the constraint is documented and version-controlled
- Intent — the team has committed to this rule in writing
- A target — `/harness-status` shows unverified constraints as
  opportunities to improve

## Level 2: Agent

The constraint is checked by the `harness-enforcer` agent, which reads
the constraint's prose rule from HARNESS.md and reviews code against it.

**When to promote from unverified:**

- The rule is well-worded and specific enough for consistent LLM review
- The team wants automated feedback before investing in tooling
- No deterministic tool exists but agent review would catch most
  violations

**Strengths:**

- Works for nuanced rules that resist deterministic checking
- No tooling setup required — the rule's prose is the check
- Can evaluate intent and context, not just syntax

**Limitations:**

- Non-deterministic — may give different results on the same input
- Token-intensive — each check costs LLM inference
- Slower than deterministic tools

## Level 3: Deterministic

The constraint is checked by a specific tool — a linter rule, a
formatter, a structural test, or a custom script. The tool produces
the same result every time for the same input.

**When to promote from agent:**

- A deterministic tool can check the rule (even partially)
- The team wants faster, cheaper, more consistent enforcement
- The constraint has been stable (no rule wording changes) for several
  audit cycles

**Strengths:**

- Deterministic — same input, same result, every time
- Fast — milliseconds, not seconds
- Cheap — no LLM inference cost
- Trustworthy — no interpretation ambiguity

**Limitations:**

- Cannot evaluate nuance or intent
- Requires tool setup and maintenance
- Some constraints cannot be fully expressed as tool rules

## Partial Promotion

Some constraints benefit from both levels simultaneously. For example:

- **Deterministic**: Linter checks that doc comments exist on exported
  functions (presence check)
- **Agent**: Reviews that the doc comments explain reasoning, not just
  restate the signature (quality check)

## Deciding When to Promote

| Signal | Action |
| --- | --- |
| Unverified constraint violated in a PR | Consider promoting to agent |
| Agent constraint catches real issues consistently | Keep at agent level |
| Agent constraint gives inconsistent results | Rewrite the rule or find a tool |
| A linter rule exists that covers the constraint | Promote to deterministic |
| Constraint has not changed wording in 3+ audits | Good candidate for tool investment |

## Demotion

Constraints can also move backward:

- **Deterministic to agent**: The tool is removed or no longer
  maintained — fall back to agent review while finding a replacement
- **Agent to unverified**: The rule is too vague for consistent agent
  review — rewrite and re-promote when ready
- **Any to removed**: The constraint is no longer relevant — delete it
  from HARNESS.md

The `harness-auditor` detects when a tool listed in a deterministic
constraint no longer exists and flags it as drift.
