---
name: henney-agent
description: Spec for the decision-archaeologist agent — surfaces implicit decisions in specs and (later) implementations as Henney-style pattern stories for human disposition
date: 2026-04-27
status: draft
---

# The Henney — Decision Archaeology for Specs and Code

## Problem

### 1. Intent debt accumulates in silences

The spec-first pipeline (spec-writer → diaboli → plan approval → tdd →
implementers → code-reviewer → diaboli code-mode → integration) is good at
capturing *what was said*. It is poor at capturing *what was assumed*. Defaults
inherited from frameworks, AI training priors, or team habit slip in unannounced.
The spec records the resolution but not the forces that produced it. Six months
later the team re-litigates the choice because nobody wrote down why it was made
— there was no seam in the workflow at which to write that down.

### 2. Cognitive debt accumulates in unnamed patterns

The diaboli surfaces *risks* (premise, design, threat, failure, operational,
specification quality). It does not surface *patterns*. When a spec implements
Mediator, Saga, Outbox, or Repository without naming it, the team carries the
pattern-recognition cost on every future change to that surface. The named-pattern
discount is the cheapest cognitive-debt payment available, but no agent in the
current pipeline is chartered to make it.

### 3. Adversarial review is not the same as decision archaeology

Asking the diaboli to also surface decisions confuses two roles. Risk surfacing
filters for what could be wrong. Decision archaeology filters for what was chosen
without saying so. They use different lenses, weight different evidence, and
produce different artefacts. Bundling them produces longer objection records that
mix "this might fail" with "this chose X over Y," and humans triage them
identically — usually by skimming.

## Approach

A second chartered read-only agent — the **Henney** — is dispatched after the
diaboli's spec-mode dispositions are resolved and before plan approval. Its
charter is to reconstruct the decisions a spec has made, including the ones
surfaced only in silence, and to emit them as **pattern stories**: structured
narratives with forces, options, choice, consequences, and (where applicable)
named patterns.

Trust boundary: Read, Glob, Grep only. The agent never writes the stories file
— the orchestrator (or `/henney` command) writes it. The agent never writes
dispositions — humans do, by opening the file and editing. This mirrors the
diaboli mechanism: the tool boundary *is* the cognitive-engagement gate.

The agent has two modes (mirroring diaboli):

- **Spec mode** (default): reads the spec, surfaces decisions implicit in the
  spec text. Dispatched by the orchestrator after spec-mode diaboli dispositions
  are resolved.
- **Code mode**: reads the spec to understand intent, then reads the
  implementation diff. Dispatched after code-mode diaboli dispositions are
  resolved, before integration-agent. Out of scope for the initial release —
  see "Scope" below. Tracked under follow-up issue #209.

Output goes to `docs/superpowers/stories/<spec-slug>.md` (spec mode) or
`docs/superpowers/stories/<spec-slug>-code.md` (code mode), symmetric with
`docs/superpowers/objections/`.

## Intellectual Foundations

The named lineage is Kevlin Henney's *pattern stories* (POSA Vol. 5: *On Patterns
and Pattern Languages*, Buschmann/Henney/Schmidt 2007), in which a pattern is
animated as a worked narrative with forces, options, choice, and consequences
laid out as a story rather than a template. Henney's broader claim — that names
compress cognition and that decisions without stories get re-litigated —
provides the framework's epistemic basis.

The "decision archaeology" framing draws on Michael Nygard's *Architecture
Decision Records* (2011) but inverts the convention: ADRs are written by the
decision-maker to explain a known choice; pattern stories are written by an
external observer to surface a choice the decision-maker may not have realised
they made. Both are rationale capture; only the latter pays down intent debt.

Christopher Alexander's "quality without a name" (*The Timeless Way of
Building*, 1979) underwrites the sixth lens — story coherence. A spec whose
decisions form a coherent narrative is one where future changes have a frame
to be evaluated against. A spec whose decisions are a bag of independent
choices is tomorrow's refactor.

The role frame is brakes-as-acceleration. The team can move faster *because*
the Henney slows it down at the points where slowing down compounds. Friction
by design; needless friction discredits the role.

## What this is explicitly not

- **Not adversarial review.** The Henney does not raise objections. If a
  finding is shaped "this could fail because…", that belongs in the diaboli
  record. The Henney reframes as "this chose X over Y" or names it as a story
  not worth telling and drops it.
- **Not exhaustive decision-archaeology.** Pedantic enumeration of every
  micro-choice produces noise that masks signal. Selectivity is the value.
- **Not a disposition-writer.** The agent emits stories with empty disposition
  checkboxes. Humans tick the boxes; no agent is permitted to.
- **Not a hard plan-approval gate.** The diaboli already imposes a hard gate
  at the same point. Adding a second hard gate compounds friction punitively.
  The Henney is a soft gate — see "Soft gate semantics" below.

## Scope

### In scope (this release)

- `henney` agent with spec mode only.
- `/henney <spec-path>` command accepting `--mode spec|code` (code-mode
  contract stable; behaviour deferred).
- `henney` skill describing the six lenses, output format, selectivity rule,
  and cross-reference protocol.
- Per-spec story records at `docs/superpowers/stories/<spec-slug>.md`.
- Orchestrator step 1b: after spec-mode diaboli dispositions are resolved,
  before plan approval.
- Soft gate at plan approval (see semantics below).
- Validation checkpoint in `/henney` mirroring `/diaboli`.
- Docs: how-to guide, explanation page.
- Follow-up issue raised at PR open time tracking code-mode implementation
  (issue #209).

### Out of scope (deferred)

- **Code mode behaviour.** The agent definition will accept `--mode spec|code`
  so the contract is stable, but the orchestrator will not dispatch code-mode
  in this release. `/henney --mode code` returns "out of scope in this release"
  and exits non-error. Tracked under issue #209.
- **HARNESS.md constraint "PRs have adjudicated stories".** Premature; revisit
  after spec-mode has produced records on at least three real specs.
- **Promotion of stories to AGENTS.md ARCH_DECISION or HARNESS.md constraints.**
  The `promote` checkbox is scaffolding for a future workflow; the actual
  promotion mechanism is a follow-up.
- **Aggregate `STORIES.md` index.** Future enhancement once enough per-spec
  records exist to justify cross-spec navigation.

## Soft gate semantics

At plan approval, the orchestrator presents the plan summary, the adjudicated
diaboli record (already gated as hard), **and** the Henney story record. The
Henney record is surfaced for the human to read, but progression is allowed
even if no story disposition is ticked.

This is deliberate. The diaboli gate exists because a `pending` objection is
a risk that has not been triaged. A Henney story without a tick is *not* a
risk — it is a captured decision waiting for the human to decide whether to
accept, revisit, or promote. The decision is not load-bearing for plan
approval; it is load-bearing for compound learning. We trade some discipline
for less ceremony.

A subsequent constraint can re-introduce a hard gate at PR merge if the team
finds dispositions are routinely skipped. This is reversible if we observe
the soft gate failing.

## Sequencing

Strict serial, mirroring the diaboli ordering:

1. spec-writer
2. advocatus-diaboli (spec mode) → user adjudicates dispositions (hard gate)
3. **henney (spec mode) → user adjudicates dispositions (soft gate)**
4. plan approval
5. tdd-agent
6. implementers
7. code-reviewer (loop until PASS)
8. advocatus-diaboli (code mode) → user adjudicates dispositions (hard gate)
9. integration-agent

Parallel adjudication of diaboli + Henney was considered and rejected:
stories that cite or counter objections should be authored *after* the team
has resolved the objection record, not in parallel with it. Cross-references
from stories to objection IDs are explicitly supported in the Refs field.

## Output format

Each story:

```markdown
### Story #N — <short evocative title>

**Mode:** spec | code
**Source:** `<path/to/spec.md>` (section if useful)
**Lens:** <one or more of: forces / alternatives / defaults / patterns / consequences / coherence>
**Refs:** <story IDs / objection IDs, else —>

**Context.** 2–4 sentences.
**Forces.** Tensions resolved. Specific.
**Options not taken.** 2–3 realistic alternatives.
**Choice as written.** What the spec chose. Note silences explicitly.
**Consequences.** What this forecloses or accepts.
**Pattern.** Named pattern with citation, or `—`.

**Disposition.**
- [ ] accept
- [ ] revisit
- [ ] promote

**Notes.** Optional flag for the curator.
```

YAML frontmatter for the file:

```yaml
---
spec: <path/to/spec.md>
date: <YYYY-MM-DD>
mode: spec | code
henney_model: <model identifier>
stories:
  - id: 1
    lens: [forces, patterns]
    title: <evocative title>
    disposition: pending
    disposition_rationale: null
  # ...
---
```

`disposition: pending` until the human ticks at least one box and writes a
rationale. `disposition_rationale` may be `null` until the human writes it.

## Selectivity guardrail

The agent biases toward 5–8 stories per spec. If it emits more than 12, the
command flags this in its output as a possible signal that the spec needs
rewriting before annotation is useful. The validation checkpoint enforces a
hard cap of 15 stories per record — beyond that, the command refuses to
write and surfaces the count to the user.

## Six lenses (full definitions in the skill)

1. **Forces.** Tensions resolved by this part of the spec.
2. **Alternatives unspoken.** Realistic options not acknowledged.
3. **Defaults inherited.** Where "the obvious choice" came from.
4. **Patterns unnamed.** Named pattern recognition (GoF, POSA, EIP, CUPID, etc).
5. **Consequences accepted.** What this forecloses, what bugs are now possible.
6. **Story coherence.** Whether decisions form a coherent narrative.

## Validation checkpoint

`/henney` performs the same read-back-and-verify pattern as `/diaboli`:

1. YAML frontmatter parseable; required fields present (`spec`, `date`,
   `mode`, `henney_model`, `stories`).
2. `mode` matches the flag passed.
3. Each story has `id`, `lens`, `title`, `disposition`,
   `disposition_rationale`.
4. `disposition: pending` for all entries (not pre-filled).
5. `disposition_rationale: null` for all entries (not pre-filled).
6. Lens values drawn from the six-category set.
7. Story count between 1 and 15 inclusive (warning ≥ 13).
8. Prose body has one `### Story #N` section per frontmatter entry.

Deviations are fixed in place — no agent re-dispatch.

## Acceptance scenarios

1. **Manual spec-mode invocation.** `/henney docs/superpowers/specs/foo.md`
   produces `docs/superpowers/stories/foo.md` with 5–8 stories, all
   `disposition: pending`. Validation checkpoint passes. User can tick boxes
   and write rationales.

2. **Orchestrator integration.** Orchestrator dispatches henney after
   spec-mode diaboli dispositions are resolved. Surfaces the record at plan
   approval. Allows progression with `pending` dispositions but flags them
   in the summary.

3. **Cross-reference.** A story cites objection O3 and earlier story #2.
   Validation accepts both forms in the Refs field.

4. **Selectivity guardrail.** Spec with 30 implicit decisions produces no
   more than 15 stories; command output warns user and recommends rewriting
   the spec before annotation.

5. **Mode contract stability.** `--mode code` is accepted by `/henney` and
   the agent but produces an "out of scope in this release — tracked under
   issue #209" message and exits non-error. (Reserves the slot without
   implementing.)

## Plugin impact

- **Adds:** `agents/henney.agent.md`, `skills/henney/SKILL.md`,
  `commands/henney.md`, `.github/prompts/henney.prompt.md`,
  `docs/how-to/run-henney.md`, `docs/explanation/decision-archaeology.md`.
- **Modifies:** `agents/orchestrator.agent.md` (step 1b), `README.md`
  (Commands count badge, agents list), `plugin.json` (version bump,
  keywords), `marketplace.json` (`plugin_version`).
- **Version bump:** minor (e.g. 0.28.0 → 0.29.0).
- **CHANGELOG entry** under the new version heading.
- **HARNESS.md:** no new constraint in this release (deferred per scope).
- **Follow-up issue:** code-mode tracked at #209 from PR open time.

## Open questions

None at spec time. The four design dispositions (per-spec records, soft
gate, single agent with `--mode`, strict serial) were resolved before this
spec was written and are recorded above. Code mode and HARNESS constraint
are explicitly deferred and tracked under "Out of scope."
