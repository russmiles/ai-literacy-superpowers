---
name: governance-audit-practice
description: Use when conducting a governance audit — detecting semantic drift in governance constraints, inventorying governance debt, checking three-frame alignment, or when the governance-auditor agent needs methodology for deep investigation.
---

# Governance Audit Practice

The methodology for conducting governance audits. This skill guides
the governance-auditor agent through semantic drift detection, debt
inventory, and frame alignment review. It is also used by the
`/governance-audit` command.

A governance audit answers one question: **does the meaning encoded
in your governance constraints still correspond to the reality they
are meant to govern?**

## When to Audit

- **Quarterly**: as part of the operating cadence (alongside `/assess`
  and `/harness-audit`)
- **After significant change**: when the technology, process, or
  regulatory environment that governance constraints reference has
  changed substantially
- **On suspicion**: when a team member notices that governance
  language no longer matches what the team actually does

## Audit Process

### 1. Identify Governance Constraints

Scan HARNESS.md for constraints that encode governance requirements.
A constraint is governance-related if it:

- References a regulation, policy, standard, or compliance requirement
- Uses governance language (fairness, transparency, oversight,
  accountability, compliance, safety, responsible, ethical)
- Has a `Governance requirement` field in the extended template

### 2. Score Falsifiability

For each governance constraint, assess falsifiability on a three-point
scale:

| Score | Meaning | Signal |
| --- | --- | --- |
| Falsifiable | Has specific verification criteria, defined evidence, clear failure action | Healthy |
| Partially operationalised | Has some operational detail but gaps in verification or evidence | Needs attention |
| Vague | Uses governance language without operational meaning | Governance debt |

Apply the falsifiability test from the `governance-constraint-design`
skill: can you answer what you verify, what counts as evidence, and
what happens on failure?

### 3. Detect Semantic Drift

For each governance constraint, check whether the meaning has drifted
since the constraint was written. Use the five-stage drift model
(see `references/drift-stages.md`):

**Detection heuristics:**

- **Implementation files changed**: if the code files that a
  governance constraint references have changed substantially since
  the constraint was last reviewed, drift is likely
- **Process changed**: if the team's workflow has changed (new CI
  pipeline, new review process, new tools) but governance constraints
  still reference the old process
- **Regulatory environment changed**: if the regulation or standard
  cited by the constraint has been updated
- **Term meaning shifted**: if the team now uses a governance term
  differently than when the constraint was written

Score drift risk as `low`, `medium`, or `high`.

### 4. Inventory Governance Debt

Governance debt is a governance mechanism whose language no longer
corresponds to the risk it addresses. Build an inventory:

For each debt item, record:

- **Description**: what the debt is (which constraint, what divergence)
- **Severity**: how far meaning has drifted (minor wording gap vs
  fundamental misalignment)
- **Blast radius**: how many other constraints or processes depend on
  the drifted term
- **Score**: severity x blast radius (see `references/debt-scoring.md`)
- **Affected constraints**: which constraints reference this term
- **Recommended action**: rewrite constraint, update verification,
  or retire

### 5. Check Three-Frame Alignment

For each governance constraint, assess whether the engineering,
compliance, and AI system interpretations align:

- **Aligned**: all three frames describe the same operational meaning
- **Partial divergence**: frames overlap but emphasise different
  aspects (e.g., engineering checks code quality, compliance checks
  audit trail — both valid, but neither checks the other)
- **Significant divergence**: frames describe materially different
  things (e.g., engineering implements a boolean gate, compliance
  expects substantive review)

### 6. Check for Debt Cycle Reinforcement

The four-debt vicious cycle:

- Governance debt → intent debt (governance language obscures purpose)
- Intent debt → cognitive debt (teams cannot form accurate mental
  models)
- Cognitive debt → technical debt (developers implement controls they
  do not understand)
- Technical debt → governance debt (gap between language and reality
  widens)

Look for governance constraints that reference other constraints which
have their own unresolved debt. This is the cycle in action.

### 7. Produce Report

Write the audit report to `observability/governance/audit-YYYY-MM-DD.md`
with sections:

1. **Summary**: overall governance health score, constraint count,
   falsifiability ratio
2. **Constraint Assessment**: each constraint with falsifiability
   score, drift risk, frame alignment status
3. **Governance Debt Inventory**: each debt item with score and
   recommendation
4. **Debt Cycle Analysis**: any reinforcement patterns detected
5. **Governance Metrics**: the snapshot-format block for inclusion
   in harness health snapshots
6. **Prioritised Recommendations**: what to fix first, ordered by
   debt score

## What You Do NOT Do

- Do not modify HARNESS.md constraints directly — report findings,
  humans decide
- Do not guess at regulatory requirements — if a governance
  requirement field cites a regulation you are unsure about, flag
  it for human review
- Do not score constraints you cannot read — if a verification tool
  is not available, note it as "unable to verify" rather than
  guessing
