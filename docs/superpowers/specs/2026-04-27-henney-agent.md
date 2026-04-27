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
- **Not a disposition-writer.** The agent emits stories with `disposition: pending`
  in the frontmatter. Humans set the disposition by editing the frontmatter
  directly; no agent is permitted to.
- **Not a hard plan-approval gate.** The diaboli already imposes a hard gate
  at the same point. Adding a second hard gate compounds friction punitively.
  The Henney is a soft gate at plan approval; the merge-time HARNESS
  constraint supplies the forcing function — see "Soft gate semantics" and
  "Constraints" below.

## Routing rule (Henney vs. diaboli)

A finding belongs in the Henney's story record iff: removing it would leave
a decision unrecorded but no failure undetected. A finding belongs in the
diaboli's objection record iff: removing it would leave a class of failures
undetected. This is the deterministic test both agents reference; their
skills must apply it before emitting any candidate. When a finding satisfies
both tests, it is a diaboli risk (failures dominate decisions for routing
purposes); when it satisfies neither, it is dropped.

## Scope

### In scope (this release)

- `henney` agent with spec mode only. No `--mode` flag — single invocation
  shape until code-mode work in #209 introduces it.
- `/henney <spec-path>` command. Single positional argument.
- `henney` skill describing the six lenses, the routing rule, output format,
  selectivity rule, and cross-reference protocol.
- Per-spec story records at `docs/superpowers/stories/<spec-slug>.md`.
- Orchestrator step 1b: after spec-mode diaboli dispositions are resolved,
  before plan approval.
- Soft gate at plan approval, with structured `henney_pending_count: N`
  surfaced in the plan-approval summary and exposed in observability — see
  semantics below.
- HARNESS constraint **"PRs have adjudicated stories"** — agent-enforced
  via harness-enforcer. PR merge is blocked until every story in
  `docs/superpowers/stories/<slug>.md` has `disposition != pending`. This
  is the merge-time forcing function; the plan-approval gate stays soft.
- Validation checkpoint in `/henney` mirroring `/diaboli`, including
  cross-reference resolution.
- Docs: how-to guide, explanation page.
- Follow-up issue raised at PR open time tracking code-mode implementation
  (#209) and story-promotion mechanism (#211).

### Out of scope (deferred)

- **Code mode behaviour.** Tracked under issue #209. `/henney` is spec-only
  in this release; the `--mode` flag is introduced alongside the actual
  code-mode implementation, not reserved in advance.
- **Promotion of stories to AGENTS.md ARCH_DECISION or HARNESS.md
  constraints.** Tracked under issue #211. The `promoted` disposition value
  is captured from day one; a future command (`/henney-promote` or similar)
  reads stories with `disposition: promoted` and proposes routing targets.
- **Aggregate `STORIES.md` index.** Future enhancement once enough per-spec
  records exist to justify cross-spec navigation.

## Soft gate semantics

At plan approval, the orchestrator presents the plan summary, the adjudicated
diaboli record (already gated as hard), **and** the Henney story record. The
Henney record is surfaced for the human to read; progression is allowed even
if every story is still `pending`. The merge-time HARNESS constraint (see
"In scope" above) supplies the forcing function — the soft gate at plan
approval can stay genuinely soft because the PR cannot land while any
disposition remains `pending`.

The orchestrator's plan-approval surface is precise:

- Emit a structured field `henney_pending_count: N` in the plan-approval
  summary, where N is the number of stories with `disposition: pending`.
- Print the count in the user-facing summary alongside the diaboli outcome,
  e.g. `Henney: N pending dispositions in docs/superpowers/stories/<slug>.md`.
- Expose the same field in `/superpowers-status` and harness-health snapshot
  output so the team has a metric for whether dispositions are being
  resolved at plan-approval time or deferred to merge time.
- Continue execution after surfacing — no acknowledgement keypress is
  required at plan approval.

This is deliberate. The diaboli gate exists because a `pending` objection is
a risk that has not been triaged. A Henney story without a disposition is
*not* a risk — it is a captured decision waiting for human curation. The
decision is not load-bearing for plan approval; it is load-bearing for
compound learning, and the merge-time constraint ensures it is resolved
before the work ships.

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

Two parallel-dispatch alternatives were considered and rejected:

1. **Parallel adjudication of diaboli + Henney.** Rejected because stories
   that cite or counter objections should be authored *after* the team has
   resolved the objection record, not in parallel with it. Cross-references
   from stories to objection IDs are explicitly supported in the Refs field
   and depend on the diaboli record being settled at the moment the Henney
   reads.

2. **Parallel agent dispatch with serial adjudication** (dispatch both agents
   simultaneously after spec-writer; human adjudicates diaboli first, then
   Henney). This would halve wall-clock latency without losing the
   cross-reference benefit at adjudication time. Rejected because
   parallel agent dispatch is currently unreliable in this codebase:
   REFLECTION_LOG 2026-04-07 documents that worktree-isolated subagents lose
   Bash permissions and that non-worktree parallel agents cross-contaminate
   branches. Until that platform-level issue is resolved, the latency saving
   does not justify the orchestration risk. If the underlying reliability
   issue is fixed, this configuration is the right next step.

## Output format

Each story (prose body):

```markdown
### Story #N — <short evocative title>

**Mode:** spec
**Source:** `<path/to/spec.md>` (section if useful)
**Lens:** <one or more of: forces / alternatives / defaults / patterns / consequences / coherence>
**Refs:** <story IDs / objection IDs, else —>

**Context.** 2–4 sentences.
**Forces.** Tensions resolved. Specific.
**Options not taken.** 2–3 realistic alternatives.
**Choice as written.** What the spec chose. Note silences explicitly.
**Consequences.** What this forecloses or accepts.
**Pattern.** Named pattern with citation, or `—`.

**Notes.** Optional flag for the curator.
```

The disposition lives in the frontmatter only — there are no prose
checkboxes. This mirrors the diaboli pattern and keeps the canonical
source of truth in a single machine-readable field.

YAML frontmatter for the file:

```yaml
---
spec: <path/to/spec.md>
date: <YYYY-MM-DD>
mode: spec
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

`disposition` legal values are `pending | accepted | revisit | promoted`.
Compound values are not permitted — the human picks one. The frontmatter
is canonical: downstream consumers (the merge-time HARNESS constraint,
observability) read frontmatter only.

`disposition: pending` until the human edits the frontmatter to a non-pending
value and writes a `disposition_rationale`. `disposition_rationale` may be
`null` until the human writes it.

## Selectivity guardrail

Selectivity is enforced inside the agent's reasoning protocol, not at the
validator. The skill instructs the agent to bias toward 5–8 stories per spec
and to enforce a self-imposed cap of 15 — if it has more than 15 candidate
stories, it selects the 15 with the highest signal/leverage and drops the
rest, mirroring the diaboli's 12-objection cap pattern. This keeps the
validation-checkpoint contract clean: the validator verifies count is in
range and surfaces a warning at ≥13, but never refuses to write or discards
the agent's work. Fix-in-place remains the codified pattern.

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
2. `mode` is `spec`.
3. Each story has `id`, `lens`, `title`, `disposition`,
   `disposition_rationale`.
4. `disposition: pending` for all entries (not pre-filled by the agent).
5. `disposition_rationale: null` for all entries (not pre-filled by the
   agent).
6. Lens values drawn from the six-lens set (forces, alternatives, defaults,
   patterns, consequences, coherence).
7. Story count between 1 and 15 inclusive (warning at ≥ 13).
8. Prose body has one `### Story #N` section per frontmatter entry,
   numbered consecutively from 1.
9. **Cross-reference resolution — objection IDs.** Any `O\d+` in any
   story's `Refs` field must correspond to an entry in
   `docs/superpowers/objections/<spec-slug>.md` if that file exists. If
   the objection record does not exist yet, `O\d+` references in `Refs`
   are a validation error.
10. **Cross-reference resolution — story IDs.** Any `#N` in any story's
    `Refs` field must satisfy `N < current_story_id` (no forward
    references, no self-references).

Deviations are fixed in place — no agent re-dispatch. The selectivity cap
is enforced inside the agent (see "Selectivity guardrail"), so the
validator never refuses to write.

## Acceptance scenarios

1. **Manual spec-mode invocation.** `/henney docs/superpowers/specs/foo.md`
   produces `docs/superpowers/stories/foo.md` with 5–8 stories, all
   `disposition: pending` in the frontmatter. Validation checkpoint passes.
   User edits the frontmatter to set each story's `disposition` to one of
   `accepted | revisit | promoted` and writes a `disposition_rationale`.

2. **Orchestrator integration.** Orchestrator dispatches henney after
   spec-mode diaboli dispositions are resolved. Surfaces the record at plan
   approval with structured field `henney_pending_count: N` and a
   user-facing prose line. Allows progression with `pending` dispositions.
   The same count appears in `/superpowers-status` and harness-health
   snapshot output.

3. **Cross-reference resolution.** A story cites objection O3 and earlier
   story #2. The validation checkpoint resolves both — O3 must exist in
   the matching objections record, and #2 must satisfy `N < current_id`.
   A story citing O17 in a 5-objection record is a validation error.

4. **Selectivity guardrail.** Spec with 30 implicit decisions produces at
   most 15 stories — the agent's reasoning protocol selects the 15
   highest-signal candidates and drops the rest. The validator never
   refuses to write.

5. **Merge-time HARNESS gate.** PR with one or more stories whose
   `disposition: pending` cannot merge. The harness-enforcer agent reports
   the constraint failure with the unresolved story IDs. After the human
   resolves all dispositions, a fresh enforcer run passes and the merge
   gate clears.

## Plugin impact

- **Adds:** `agents/henney.agent.md`, `skills/henney/SKILL.md`,
  `commands/henney.md`, `.github/prompts/henney.prompt.md`,
  `docs/how-to/run-henney.md`, `docs/explanation/decision-archaeology.md`.
- **Modifies:** `agents/orchestrator.agent.md` (step 1b),
  `agents/harness-enforcer.agent.md` (read the new constraint),
  `commands/superpowers-status.md` and harness-health output (surface
  `henney_pending_count`), `templates/HARNESS.md` (add the new constraint
  to the upstream template), `HARNESS.md` (this project adopts the
  constraint), `README.md` (Commands count badge, agents list),
  `plugin.json` (version bump, keywords), `marketplace.json`
  (`plugin_version`).
- **Version bump:** minor (e.g. 0.28.0 → 0.29.0).
- **CHANGELOG entry** under the new version heading.
- **HARNESS.md:** new constraint **"PRs have adjudicated stories"** —
  agent-enforced via harness-enforcer, scope `pr`. Symmetric with the
  existing "PRs have adjudicated objections" constraint, with the same
  exemption rules (bug/fix/chore/maintenance).
- **Follow-up issues:** code-mode at #209, story-promotion mechanism at
  #211, both referenced from the PR description at open time.

## Open questions

None at spec time. The four design dispositions (per-spec records, soft
gate at plan approval + hard gate at merge, single agent without `--mode`
flag yet, strict serial sequencing) were resolved during diaboli
adjudication and are recorded above. Adjudicated objection record at
`docs/superpowers/objections/henney-agent.md` (12 objections; 9 accepted,
3 rejected, 0 pending).
