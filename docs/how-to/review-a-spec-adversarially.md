---
title: Review a Spec Adversarially
layout: default
parent: How-to Guides
nav_order: 38
---

# Review a Spec Adversarially

Run `/diaboli` to get an adversarial review of a spec file before approving the implementation plan.

## When to use this

- After `/spec-writer` completes and before you approve the plan
- When a spec is substantially edited after an objection record already exists
  (the command regenerates the record; prior dispositions are lost — this is intentional)
- When working outside the full orchestrator pipeline and you want adversarial review on demand

Do not use this as a quality check on your own reasoning. The point of the agent is that it
disagrees with you from a clean context. Running it after you have already decided to proceed
removes the gate it is meant to enforce.

---

## 1. Run `/diaboli <spec-path>`

Pass the path to a spec file under `docs/superpowers/specs/`:

```text
/diaboli docs/superpowers/specs/2026-04-19-my-feature.md
```

The command dispatches the advocatus-diaboli agent, which reads the spec and produces a
structured objection record at `docs/superpowers/objections/<spec-slug>.md`.

The slug is derived from the spec filename by stripping the date prefix and `.md` extension.
For example, `2026-04-19-my-feature.md` → `my-feature`.

---

## 2. Read the objection record

The record has two parts:

**YAML frontmatter** — a machine-readable list of objections, each with:

- `id` — O1, O2, … in order of severity
- `category` — one of: `premise`, `scope`, `implementation`, `risk`, `alternatives`,
  `specification quality`
- `severity` — one of: `critical`, `high`, `medium`, `low`
- `claim` — one sentence stating the objection
- `evidence` — a quote or citation from the spec that grounds the objection
- `disposition` — starts as `pending`; you fill this in
- `disposition_rationale` — starts as `null`; you write this

**Prose body** — one `## O<N>` section per objection with the claim restated, the
evidence expanded, and an explanation of why the objection matters if unaddressed.

Read the prose sections, not just the frontmatter. The prose is where the reasoning lives.

---

## 3. Write dispositions inline

Open the objection record and fill in `disposition` and `disposition_rationale` for each
objection in the YAML frontmatter.

Valid disposition values:

- `accepted` — the objection is valid; the spec or approach will change
- `rejected` — the objection is not valid; the rationale must explain why
- `deferred` — acknowledged; the concern is real but will be addressed separately
- `fix` — shorthand for accepted with a planned correction (same weight as `accepted`)
- `leave` — shorthand for rejected with a deliberate choice to keep the current approach

**This step cannot be delegated back to an agent.** The agent's trust boundary is
read-only — it cannot write dispositions. This is structural: a human must engage
with the objections and write a rationale before the pipeline proceeds. That engagement
is the mechanism. If you find yourself wanting to have an agent fill in the dispositions,
the gate is not working.

For `critical` and `high` severity objections, the rationale must be substantive. "Looks
fine" is not a rationale. "This will be addressed by X change to the spec" is.

---

## 4. Update the spec if needed

If objections are `accepted` or `fix`, update the spec to reflect what changes. The
objection record stays as written — it is a permanent record of the adversarial review
at a point in time.

If the spec changes substantially (new approach, different scope, different artefact
list), re-run `/diaboli` on the updated spec. The old record will be overwritten; old
dispositions are not preserved. This is intentional: a substantially revised spec is a
new thing and deserves a fresh adversarial review.

---

## 5. What you have now

An adjudicated objection record with all dispositions filled and all rationales written.
The plan-approval gate will not advance while any disposition is `pending`.

The record lives at `docs/superpowers/objections/<slug>.md` and accumulates alongside
other objection records over time. A GC rule checks weekly whether any spec has been
modified more recently than its objection record — if so, it flags the record as stale.

As records accumulate, disposition patterns (distribution, mean objections per spec,
median days to adjudication) become visible in `/superpowers-status` Section 7 and the
harness-health snapshot Diaboli panel. These surfaces update on the normal health cadence
without requiring a separate command.

---

## Next steps

- Present the plan for approval — once all dispositions are filled, return to the
  orchestrator pipeline and approve the spec
- Proceed to tdd-agent only after plan approval
- See [Adversarial Review]({% link explanation/adversarial-review.md %}) for the
  conceptual background on why this gate exists and what the agent is not allowed to do
