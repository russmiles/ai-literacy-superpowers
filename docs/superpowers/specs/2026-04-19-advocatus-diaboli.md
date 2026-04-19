---
name: advocatus-diaboli
description: Spec for the adversarial spec-review agent hard-wired into the spec-first pipeline
date: 2026-04-19
status: approved
---

# Advocatus Diaboli — Adversarial Spec Review

## Problem

### 1. Sycophantic acceptance in agentic workflows

The spec-writer agent produces a plan. The orchestrator presents that plan. The
tdd-agent translates it into tests. At no point does any agent in the pipeline
have a charter to disagree. Disagreement is structurally absent — not because
agents are incapable of it, but because no component has been given the role of
adversary. The result is a pipeline that surfaces assumptions only when they
collide with reality during implementation, which is the most expensive moment
to discover them.

### 2. Confirmation bias in same-agent review

Asking spec-writer to review its own spec, or asking orchestrator to critique
the plan it just presented, does not produce adversarial review. It produces
refinement. The agent's prior output becomes the anchor; subsequent reasoning
adjusts around it. This is not a flaw in any particular agent — it is a
structural property of single-agent self-review. The only remedy is a separate
agent with a different charter.

### 3. Premise-level objections suppressed by sunk cost

Once tdd-agent has written tests, once implementers have written code, the cost
of a premise-level objection rises sharply. "The spec solves the wrong problem"
becomes "we'd have to throw away the tests and the implementation." Human
reviewers and agents alike are subject to sunk-cost pressure. The premise-level
objection must be raised before any implementation artefacts exist — specifically,
before plan approval.

## Approach

A chartered adversarial agent — the advocatus diaboli — is dispatched immediately
after spec-writer and before plan approval. Its charter is to raise steel-manned
objections, not nits. It operates with a read-only trust boundary: it cannot write
code, cannot modify the spec, and cannot write its own objection dispositions. This
last constraint is structural: it forces a human to open the objection record and
write dispositions before the pipeline can proceed.

The plan-approval gate is extended to surface the objection record alongside the
plan summary. While any disposition is `pending`, the gate refuses progression.
The human writes dispositions inline — `accepted`, `deferred`, or `rejected` —
with a rationale. This is the cognitive-engagement mechanism; it cannot be
delegated.

The agent takes a single input (a spec file path) and produces a structured
objection record at `docs/superpowers/objections/<spec-slug>.md`. The record
uses YAML frontmatter for machine-readable dispositions and prose sections for
human-readable elaboration.

## Intellectual Foundations

The name and role derive from the historical Promoter of the Faith
(*Promotor Fidei*), the Vatican official appointed to argue against a candidate's
beatification — to find reasons to doubt, to challenge miracles, to expose
hagiographic bias. The role was abolished in 1983 under John Paul II, after which
the rate of beatifications increased sharply. This history is instructive: removing
the adversarial gate did not improve the quality of decisions; it accelerated them.
We are reinstating the gate in a different domain.

The epistemic basis is Popperian: a claim is only meaningful if it can be falsified.
A spec that has not been challenged is not a strong spec — it is an unchallenged
assertion. The adversarial agent's job is to attempt falsification before
commitment.

Schopenhauer's *Art of Being Right* (*Eristische Dialektik*) names what this is
explicitly **not**. Schopenhauer catalogued 38 rhetorical stratagems for winning
arguments regardless of truth. The advocatus diaboli must not use them. No
strawmanning, no shifting the burden of proof, no exploiting ambiguity. Every
objection requires evidence grounded in the spec itself. Winning for its own sake
is a failure mode, not a success criterion.

## Expected Outcome

Every feature PR arrives at the plan-approval gate with a structured objection
record that the human has adjudicated. The quality gate is not whether the
adversarial agent found objections — it is whether the human engaged with them.
Disposition distribution becomes observable over time: a cluster of
`deferred — not material` responses signals that the SKILL.md charter needs
tuning, not that the constraint needs weakening.

## Artefacts

1. `skills/advocatus-diaboli/SKILL.md` — charter, six categories, severity
   definitions, max-objection cap, "Explicitly not objecting to" requirement,
   intellectual foundations, non-goals
2. `agents/advocatus-diaboli.agent.md` — read-only agent, objection record
   output schema, disposition gate
3. `commands/diaboli.md` — `/diaboli <spec-path>` for manual invocation and
   regeneration when a spec is substantively edited
4. `.github/prompts/diaboli.prompt.md` — Copilot CLI equivalent
5. `agents/orchestrator.agent.md` — pipeline updated: spec-writer → diaboli →
   GATE (objections adjudicated) → plan approval → tdd-agent
6. `HARNESS.md` — constraint (agent, scope pr) + GC rule (deterministic, weekly)
7. `MODEL_ROUTING.md` — advocatus-diaboli routed to most-capable tier
8. `templates/HARNESS.md` — constraint + GC rule for new projects
9. `AGENTS.md` — ARCH_DECISION: hard-wired from the outset (Option B)
10. `README.md`, `plugin.json`, `marketplace.json`, `CHANGELOG.md` — version 0.23.0

## Exemptions

Specs created before 2026-04-19 are exempt from the objection-record constraint.
Mark with `diaboli: exempt-pre-existing` in frontmatter, or rely on the dated
cutoff in the constraint text. Bug fixes, dependency updates, and maintenance PRs
are exempt on the same terms as spec-first-commit-ordering.
