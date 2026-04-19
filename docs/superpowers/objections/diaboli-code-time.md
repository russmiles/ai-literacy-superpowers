---
spec: docs/superpowers/specs/2026-04-19-diaboli-code-time.md
date: 2026-04-19
mode: spec
diaboli_model: claude-sonnet-4-6
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "Code-time diaboli has no defined behaviour when the review loop exits via escalation (MAX_REVIEW_CYCLES=3) rather than PASS, leaving PRs that exhaust review cycles without a code-time objection record while the renamed constraint requires one."
    evidence: "Approach section: 'Dispatch timing: once, after the final code-reviewer PASS, before integration-agent.' Orchestrator artefact (#5): 'add code-time dispatch after final code-reviewer PASS.' The escalation path (MAX_REVIEW_CYCLES exceeded → human intervenes → human may approve proceeding) is not mentioned. The renamed HARNESS constraint requires a code-mode record for all feature PRs with no escalation exemption."
    disposition: fix
    disposition_rationale: Define as existing thr process.
  - id: O2
    category: implementation
    severity: high
    claim: "The `pr_ref:` field in code-mode frontmatter cannot be filled by the agent at write time — the PR does not exist until integration-agent runs, which is after the integration-approval gate the record must pass."
    evidence: "Approach section: 'Frontmatter additions: mode: code and pr_ref: fields in code-mode records.' Artefact #2: 'include pr_ref: pointing to the PR under review.' The agent's trust boundary is read-only (Read, Glob, Grep only — it cannot write files). The PR number is unknown at code-time diaboli dispatch because integration-agent creates the PR after the gate. A human would need to fill pr_ref: manually, or the field should be filled later, or the field should be removed."
    disposition: fix
    disposition_rationale: remove.
  - id: O3
    category: specification quality
    severity: high
    claim: "The spec does not specify what the harness-health.md step 7 section count becomes after the Diaboli panel is extended, leaving the validation checkpoint underspecified and likely to produce a broken check."
    evidence: "Artefact #7: 'extend Diaboli panel to split stats by mode; apply validation-checkpoint discipline.' The current harness-health.md step 7 validates 'All 13 section headings.' The diaboli-observability spec required updating this from 12 to 13 (PR #186). If the Diaboli section is extended in place (not split into new sections), the count stays at 13. If new sections are added, the count increases. The spec does not specify which."
    disposition: fix
    disposition_rationale: increase count.
  - id: O4
    category: specification quality
    severity: medium
    claim: "The observability artefact says 'retain overall totals for backward comparison' but does not define which fields are 'overall' versus 'per-mode', leaving implementers to choose incompatible field sets."
    evidence: "Step 9 of the task scope: 'Keep the overall totals for backward comparison with prior snapshots.' Artefact #6 and #7: extend panels to split stats by mode with 'objection records present, disposition distribution, mean objections per PR.' The existing fields (In-scope specs, Objections total, Severity breakdown, Mean objections per spec, Disposition distribution, Median days spec-to-disposition) are not labelled 'overall' or 'per-mode' in the spec. An implementer must guess the partition."
    disposition: fix
    disposition_rationale: label appropriately
  - id: O5
    category: risk
    severity: medium
    claim: "The integration-approval gate is enforced only when the orchestrator is in use; manual pipelines have no gate and could arrive at integration-agent without running code-time diaboli, failing the renamed HARNESS constraint silently."
    evidence: "Approach section: 'New gate: Integration Approval — mirrors the plan-approval gate. Refuses to proceed while any code-mode disposition is pending.' Artefact #5: 'add Integration Approval gate' in orchestrator.agent.md. The harness-enforcer constraint check happens at PR time (scope: pr) and is agent-based, not a hard block. A developer running integration-agent directly bypasses the gate and the constraint check runs only when harness-enforcer is dispatched. The existing plan-approval gate has the same structural gap — this objection applies to both gates equally, which may be a reason to accept it as a known limitation."
    disposition: accept
    disposition_rationale: this is accepted behaviour at this point.
  - id: O6
    category: implementation
    severity: low
    claim: "The validation checkpoint extension for --mode is described as 'extend the validation checkpoint to verify mode-appropriate frontmatter fields' without specifying which fields are required for each mode, making the checkpoint implementation underspecified."
    evidence: "Artefact #3: 'add optional --mode flag (default: spec); extend validation checkpoint to verify mode-appropriate frontmatter fields.' The spec defines the frontmatter schema (mode: field; pr_ref: in code mode) but the validation checkpoint step in commands/diaboli.md is not updated in the artefact description to name the new required fields explicitly."
    disposition: fix
    disposition_rationale: specify fields explicitly.
---

## O1 — implementation — high

### Claim

Code-time diaboli has no defined behaviour when the review loop exits via
escalation rather than PASS. When MAX_REVIEW_CYCLES is exhausted and the
orchestrator escalates to the human, the loop does not exit via PASS. The
spec says code-time diaboli runs "after the final code-reviewer PASS" — which
does not happen in the escalation path. Feature PRs that exhaust review cycles
would arrive at integration without a code-mode record while the renamed
HARNESS constraint requires one.

### Evidence

> "Dispatch timing: once, after the final code-reviewer PASS, before
> integration-agent. Not per review cycle — only after the loop exits."

> "GUARDRAIL: MAX_REVIEW_CYCLES = 3. If the reviewer has not returned PASS
> after 3 reviewer→implementer cycles, STOP the loop and escalate."
> (orchestrator.agent.md)

The renamed constraint (artefact #10) requires a code-mode record for all
feature PRs with no escalation exemption stated.

### Why this matters

A PR that exhausts review cycles is already in a degraded state. Arriving at
integration without a code-mode objection record means it also fails the HARNESS
constraint — compounding the problem. The human making the escalation decision
needs clear instructions: does code-time diaboli still run, and if so, when?

---

## O2 — implementation — high

### Claim

The `pr_ref:` field in code-mode frontmatter cannot be filled by the agent at
write time. The PR does not exist when code-time diaboli runs — integration-agent
creates the PR after the integration-approval gate the record must pass.

### Evidence

> "Frontmatter additions: `mode: code` and `pr_ref:` fields in code-mode records"

> "In code mode, include an additional frontmatter field `pr_ref:` pointing to
> the PR under review." (step 4 of task scope)

The agent's trust boundary: `tools: [Read, Glob, Grep]` — write capability is
structurally absent. The PR number is not known until integration-agent creates
it. The field as specified cannot be populated by any agent without breaking
either the read-only boundary or the sequencing.

### Why this matters

If `pr_ref:` is listed as a required frontmatter field and the validation
checkpoint enforces it, every code-mode record will fail validation. If it is
optional or filled later (by integration-agent after PR creation), that must
be stated explicitly in the spec and reflected in the validation checkpoint.

---

## O3 — specification quality — high

### Claim

The spec does not state what the harness-health.md step 7 section count becomes
after the Diaboli panel is extended, leaving the validation checkpoint broken or
underspecified.

### Evidence

> "Artefact #7: extend Diaboli panel to split stats by mode; apply
> validation-checkpoint discipline."

The current harness-health.md step 7 explicitly validates: "All 13 section
headings present in order." The diaboli-observability spec required a specific
update from 12 to 13. If this change extends the Diaboli section in place
(no new top-level sections), the count stays 13. If new sections are added,
it increases. The spec does not say.

### Why this matters

The validation checkpoint is what makes the structured output trustworthy. An
underspecified checkpoint will either miss the new fields (too loose) or fail
on the new structure (too strict). The diaboli-observability PR had to make
this explicit — the same clarity is needed here.

---

## O4 — specification quality — medium

### Claim

"Retain overall totals for backward comparison" is not actionable without a
definition of which existing fields are "overall" and which new fields are
"per-mode." Implementers will produce incompatible field sets.

### Evidence

> "Keep the overall totals for backward comparison with prior snapshots."
> (step 9 of task scope)

The existing Diaboli panel fields include: In-scope specs, Exempt specs,
Objection records present, In-scope specs without a record, Fully-resolved
record rate, Objections total, Severity breakdown, Mean objections per spec,
Disposition distribution, Median days spec-to-disposition. None are labelled
"overall" in the spec. The new per-mode fields (objection records present,
disposition distribution, mean objections per PR) overlap in name with
existing fields, creating further ambiguity.

### Why this matters

The observability reference (artefact #8) and both commands must agree on field
names and partitioning. Without explicit definitions, the snapshot-format
reference and the commands will diverge, and the validation checkpoint cannot
enforce structure.

---

## O5 — risk — medium

### Claim

The integration-approval gate is only enforced when the orchestrator is in use.
Manual pipelines can bypass it silently, arriving at integration without a
code-mode record while the HARNESS constraint requires one.

### Evidence

> "New gate: Integration Approval — mirrors the plan-approval gate. Refuses to
> proceed while any code-mode disposition is `pending`."

The gate lives in orchestrator.agent.md. A developer running integration-agent
directly bypasses the orchestrator entirely. The harness-enforcer constraint
check is agent-based (scope: pr) — it fires at PR review time, not at
integration-agent dispatch time.

### Why this matters

The plan-approval gate has the identical structural gap. If that gap is
accepted as a known limitation of the orchestrator-optional architecture, this
objection has the same answer and can be noted as such. The objection is raised
to surface the decision explicitly rather than assume the answer.

---

## O6 — implementation — low

### Claim

The validation checkpoint extension for `--mode` is described without specifying
which fields are required per mode, leaving the checkpoint implementation
underspecified.

### Evidence

> "Artefact #3: add optional --mode flag (default: spec); extend validation
> checkpoint to verify mode-appropriate frontmatter fields."

The frontmatter schema is shown in the approved plan but not reproduced in the
spec. The validation checkpoint step in commands/diaboli.md currently checks for
`spec`, `date`, `diaboli_model`, `objections`. The new fields (`mode`,
`pr_ref`) need explicit inclusion in the checkpoint field list.

### Why this matters

Low — the schema is clear from the plan. This is a spec-completeness note rather
than a blocking concern.

---

## Explicitly not objecting to

- **Read-only trust boundary for code-time dispatch**: The same boundary that
  enforces the human-cognition gate at spec time is equally correct at code time.
  The disposition fields require human engagement; the read-only boundary is the
  mechanism. No objection.

- **Running code-time diaboli once after the final review cycle rather than per
  cycle**: The spec gives the correct rationale (burns tokens on drafts; conflates
  roles). Running it per cycle would produce objections on intermediate states that
  implementers are actively fixing. Once after PASS is the right timing. No
  objection.

- **Reusing the same agent rather than creating a new code-diaboli agent**: The
  charter, categories, evidence requirements, and output format are identical
  across modes. A separate agent would duplicate the charter and fragment
  maintenance. Mode-based weighting within one agent is the correct design. No
  objection.

- **Not including hook changes**: Code-time diaboli is an orchestrator-wired
  dispatch, not a stop-hook concern. Hooks are for advisory nudges at session end;
  gates are for blocking progression. The division is correct. No objection.

- **The six-category output taxonomy staying identical across modes**: The
  weighting changes; the categories do not. This is the right level of
  abstraction — the output format stays machine-readable and comparable across
  modes without introducing a new schema. No objection.
