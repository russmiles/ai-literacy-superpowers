---
name: governance-constraint-design
description: Use when writing governance constraints for HARNESS.md, translating governance language into operational meaning, reviewing existing governance constraints for falsifiability, or when "/governance-constrain" needs guidance on the authoring workflow.
---

# Governance Constraint Design

A governance constraint encodes operational meaning, not governance
language. The phrase "ensure human oversight" is governance language —
it sounds precise but means different things to different people. A
governance constraint translates that language into a verification
slot with defined pass/fail criteria, evidence requirements, and
failure actions.

This skill teaches how to make that translation. It is referenced by
the `/governance-constrain` command for guided authoring and by the
`harness-enforcer` agent when validating governance constraint quality.

## The Core Problem

Governance language carries meaning in one reference frame but is
implemented in another. The regulator writes "meaningful human
oversight." The engineer implements a boolean approval gate. The
compliance team audits the approval log. All three frames are
satisfied syntactically while governance fails semantically — the
approval happens, but the oversight is absent.

A governance constraint must make this translation explicit.

## The Falsifiability Test

Every governance constraint must answer three questions:

1. **What do you verify?** — the specific observable condition
2. **What counts as evidence?** — what artefacts demonstrate compliance
3. **What happens on failure?** — the response when verification fails

If the constraint cannot answer all three, it is governance language
pretending to be a constraint. It belongs in a policy document, not
in HARNESS.md.

## The Three-Frame Translation Step

Before writing a governance constraint, articulate what the
governance requirement means from three perspectives:

| Frame | Question | Example ("human review required") |
| --- | --- | --- |
| Engineering | What must the reviewer technically verify? | Reviewer must check that generated code has tests, follows naming conventions, and handles error paths |
| Compliance | What audit trail must exist? | PR approval record with reviewer name, timestamp, and at least one substantive comment |
| AI system | What does the automated gate check? | PR cannot merge without at least one approved review from a CODEOWNERS member |

**Flag divergence.** If the three frames describe different things,
the governance requirement is ambiguous. Resolve the ambiguity before
writing the constraint — do not push it into HARNESS.md and hope
enforcement resolves it.

## The Governance Constraint Template

Every governance constraint in HARNESS.md should use this extended
format (in addition to the standard Rule/Enforcement/Tool/Scope
fields from the `constraint-design` skill):

- **Governance requirement**: the institutional language being encoded
- **Operational meaning**: what it means in engineering terms
- **Verification method**: how to check (deterministic tool, agent
  review, or manual process)
- **Evidence**: what constitutes proof of compliance
- **Failure action**: what happens when verification fails
- **Frame check**: engineering / compliance / AI system interpretations
  confirmed aligned (yes/no, with notes on any divergence resolved)

See `references/governance-constraint-template.md` for the full
template with examples.

## Promotion Path

Governance constraints follow the same promotion ladder as all
constraints (see the `constraint-design` skill):

1. **Unverified** — declared in HARNESS.md, not yet automated
2. **Agent** — the `harness-enforcer` reviews against the constraint
   prose using LLM judgement
3. **Deterministic** — a tool checks the constraint automatically

Start at unverified. Promote when the constraint language is stable
and you have confidence in the verification method. Most governance
constraints will land at agent enforcement because governance meaning
requires judgement — few governance checks can be reduced to a shell
command.

## When Not to Use This Skill

- For standard (non-governance) constraints, use the `constraint-design`
  skill directly
- For auditing existing governance constraints, use the
  `governance-audit-practice` skill
- For metrics and snapshot formats, use the `governance-observability`
  skill

## Anti-Patterns

See `references/anti-patterns.md` for the full gallery of governance
constraint anti-patterns with falsifiable rewrites.
