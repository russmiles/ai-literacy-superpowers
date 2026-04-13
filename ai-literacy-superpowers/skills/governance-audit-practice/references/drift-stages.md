# The Five Stages of Semantic Drift

From the AI Literacy framework (Theme 19: Governance as
Meaning-Alignment). Semantic drift is the process by which governance
language diverges from operational reality.

## Stage 1: Coinage

A term is introduced with specific meaning in a specific context.

**Example:** "Meaningful human oversight" is coined in a regulatory
discussion to mean: a human who understands the system's behaviour
actively evaluates whether an AI decision is appropriate before it
takes effect.

**Detection:** N/A — this is the baseline. The term means what it
was intended to mean.

## Stage 2: Adoption Without Frame

The term enters governance documents without the context that gave
it meaning.

**Example:** An internal policy says "all AI features require
meaningful human oversight" without defining what "meaningful" means
in this organisation's context.

**Detection:** Governance constraints that use terms without
operational definitions. Look for constraints where the Rule field
contains governance language but no Operational meaning field.

## Stage 3: Implementation from a Different Frame

Engineers implement the requirement from their own reference frame.

**Example:** The engineering team implements a boolean approval gate
on AI-generated PRs. The gate satisfies "human oversight" in the
engineering frame (a human clicks approve) but not in the regulatory
frame (the human must understand and evaluate the decision).

**Detection:** Verification methods that check for the presence of
an action (approval exists) rather than the quality of the action
(approval was substantive). Look for deterministic checks on
governance constraints that verify form but not substance.

## Stage 4: Audit from Yet Another Frame

Compliance teams verify from the institutional frame.

**Example:** The compliance team audits the approval log and confirms
that every AI PR has an approval record. The audit passes. The
governance requirement is "met." But no one checked whether the
approver actually understood the code.

**Detection:** Evidence fields that describe audit trails without
substantive quality criteria. If the evidence is "log exists" rather
than "log demonstrates engagement," drift has reached Stage 4.

## Stage 5: Crisis

The gap between governance language and reality becomes visible
through real-world harm.

**Example:** An AI-generated code change introduces a security
vulnerability. The PR was approved (gate passed), the audit trail
exists (compliance happy), but the reviewer did not understand the
code (governance failed). The organisation discovers that "meaningful
human oversight" meant nothing meaningful.

**Detection:** Post-incident analysis reveals that governance
constraints were satisfied but the risk they were meant to mitigate
occurred anyway. This is the most expensive form of detection.

## Using the Stages in an Audit

For each governance constraint:

1. Identify which stage it is in (most will be Stage 2 or 3)
2. Record the stage in the drift assessment
3. Prioritise constraints at Stage 3+ for immediate attention
4. Recommend frame translation exercises for Stage 2 constraints
   before they progress
