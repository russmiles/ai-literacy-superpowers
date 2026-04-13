# Governance Constraint Template

Use this template when adding a governance constraint to HARNESS.md.
It extends the standard constraint format (Rule/Enforcement/Tool/Scope)
with governance-specific fields that force operational meaning.

## Template

### [Constraint name]

- **Rule**: [what must be true — specific, observable, falsifiable]
- **Enforcement**: [unverified | agent | deterministic]
- **Tool**: [which tool or agent checks this]
- **Scope**: [commit | pr | weekly | manual]
- **Governance requirement**: [the institutional language being encoded
  — cite the regulation, policy, or standard]
- **Operational meaning**: [what this means in engineering terms —
  what the team must actually do]
- **Verification method**: [how compliance is checked — what runs,
  what it inspects, what it compares]
- **Evidence**: [what artefacts demonstrate compliance — test reports,
  audit logs, review records]
- **Failure action**: [what happens when verification fails — block
  merge, file incident, alert team, escalate]
- **Frame check**: [confirmed aligned | divergence resolved — with
  notes on how engineering, compliance, and AI system interpretations
  were reconciled]

## Example: Meaningful Code Review

### AI-generated code review quality

- **Rule**: Every PR containing AI-generated code must have at least
  one review with a substantive comment on design intent and
  confirmation that tests cover changed behaviour
- **Enforcement**: agent
- **Tool**: harness-enforcer (reviews PR comment quality)
- **Scope**: pr
- **Governance requirement**: Internal AI governance policy Section
  4.2 — meaningful human review of AI-assisted work
- **Operational meaning**: reviewers must demonstrate cognitive
  engagement, not just approval-click
- **Verification method**: agent reviews PR comments for evidence of
  design reasoning and test coverage confirmation
- **Evidence**: PR review record with at least one comment referencing
  design intent and one referencing test coverage
- **Failure action**: PR flagged for additional review, team lead
  notified
- **Frame check**: confirmed aligned — engineering (substantive
  review), compliance (documented review trail), AI system (PR gate
  requires approved review with comments)
