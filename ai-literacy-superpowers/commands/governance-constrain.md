---
name: governance-constrain
description: Guided authoring of governance constraints — translates governance language into operational meaning with three-frame alignment check, then writes the constraint to HARNESS.md
---

# /governance-constrain

Guided workflow for translating governance language into a falsifiable
HARNESS.md constraint. Walks through the governance requirement,
operational meaning, verification method, evidence, failure action,
and three-frame alignment check.

Read the `governance-constraint-design` skill before starting.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists, tell the user to run `/harness-init` first.

### 2. Gather the Governance Requirement

Ask the user: **What governance requirement are you encoding?**

Accept free text. This is the institutional language — the regulation,
policy, or standard the constraint is meant to satisfy. Examples:

- "Human review of all AI-generated code"
- "GDPR Article 5(1)(c) data minimisation for AI features"
- "Internal AI governance policy Section 3 — traceability"

### 3. Translate to Operational Meaning

Ask the user: **What does this mean operationally? What must
actually happen?**

Guide them from governance language to engineering terms. If the
user gives vague answers ("ensure quality", "maintain oversight"),
push for specifics: what must the reviewer verify? What must the
system check? What observable condition proves this requirement is
met?

### 4. Define Verification

Ask the user: **How do you verify compliance?**

Present the three options:

- **Deterministic** — a tool checks automatically (linter, test
  suite, regex check, network inspector)
- **Agent** — the harness-enforcer reviews using LLM judgement
  against the constraint prose
- **Manual** — a human checks during review (start here if unsure,
  promote later)

### 5. Define Evidence and Failure

Ask the user:

- **What counts as evidence of compliance?** (test reports, audit
  logs, review records, CI output)
- **What happens when verification fails?** (block merge, file
  incident, alert team, escalate)

### 6. Three-Frame Alignment Check

Present the constraint from three perspectives and ask the user to
confirm alignment:

> **Engineering frame:** [restate what the constraint means to the
> engineering team]
>
> **Compliance frame:** [restate what the constraint means for audit
> and regulatory purposes]
>
> **AI system frame:** [restate what the automated gate or check
> actually verifies]
>
> **Do these three interpretations align?** If not, where do they
> diverge?

If divergence is identified, work with the user to resolve it before
writing the constraint. The resolution should be documented in the
Frame check field.

### 7. Write the Constraint

Add the constraint to HARNESS.md using the governance constraint
template (from `governance-constraint-design` skill's
`references/governance-constraint-template.md`):

- **Rule**: [falsifiable statement from Steps 2-3]
- **Enforcement**: [from Step 4 — map manual to unverified]
- **Tool**: [specific tool or "none yet" for unverified]
- **Scope**: [recommend `pr` for most governance constraints]
- **Governance requirement**: [from Step 2]
- **Operational meaning**: [from Step 3]
- **Verification method**: [from Step 4]
- **Evidence**: [from Step 5]
- **Failure action**: [from Step 5]
- **Frame check**: [from Step 6 — "confirmed aligned" or
  "divergence resolved: [notes]"]

### 8. Suggest Promotion Path

After writing the constraint, suggest the promotion path:

> This constraint starts as **[current enforcement level]**. To
> promote it:
>
> - **To agent:** ensure the Rule is precise enough for consistent
>   LLM review by the harness-enforcer
> - **To deterministic:** identify or build a tool that can verify
>   the Rule automatically

### 9. Commit

```bash
git add HARNESS.md
git commit -m "Add governance constraint: [constraint name]"
```
