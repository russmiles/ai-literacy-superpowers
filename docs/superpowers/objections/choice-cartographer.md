---
spec: docs/superpowers/specs/2026-04-27-choice-cartographer.md
date: 2026-04-27
mode: spec
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The two-pattern problem (intent debt and cognitive debt) is asserted from authority, not from observed evidence in this codebase, despite a fresh diaboli pipeline that could supply such evidence."
    evidence: "Section 'Problem' subsections 1 and 2 assert that 'intent debt accumulates in silences' and 'cognitive debt accumulates in unnamed patterns' without citing any spec, objection record, REFLECTION_LOG entry, or PR in which a decision was actually re-litigated or a pattern actually went unnamed. The diaboli has been live since 2026-04-19 (PR #177) and produced records on real specs; the spec writes 'Six months later the team re-litigates the choice' as a hypothetical."
    disposition: rejected
    disposition_rationale: "The framing is sound on first principles. Real evidence will accumulate from running the agent — see https://arxiv.org/abs/2603.22106. The codebase-grounded evidence base the objection asks for is what the agent itself will produce; demanding it before the agent runs inverts the order."
  - id: O2
    category: alternatives
    severity: high
    claim: "Extending the existing diaboli skill with a seventh category (e.g. 'decisions') is not considered, even though the spec rejects it implicitly by asserting the two roles 'use different lenses'."
    evidence: "Section 'Problem' subsection 3 says 'Asking the diaboli to also surface decisions confuses two roles' and that 'bundling them produces longer objection records that mix this might fail with this chose X over Y.' But the spec does not show a worked example of this failure, does not consider a third option (a single agent with a 'mode' that emits both objection and story records on disjoint output paths), and does not consider extending the diaboli's six-category set with a non-adversarial seventh category. The current proposal doubles plugin surface area (new agent, new skill, new command, new prompt, new docs, new orchestrator step, new directory) — the bar for a new top-level component should be that the merged alternative was tried or shown infeasible."
    disposition: rejected
    disposition_rationale: "The concern is distinct enough."
  - id: O3
    category: scope
    severity: high
    claim: "Reserving a code-mode contract that immediately returns 'out of scope' on invocation ships dead surface area in the public command, agent, and skill — the contract is invented before any user has expressed need for it."
    evidence: "Section 'Out of scope (deferred)' first bullet: 'The agent definition will accept --mode spec|code so the contract is stable, but the orchestrator will not dispatch code-mode in this release. /henney --mode code returns out of scope in this release and exits non-error.' Acceptance scenario 5 enshrines this as a deliverable: 'Reserves the slot without implementing.' This is YAGNI in the API surface: a flag is documented, accepted, validated, tested in an acceptance scenario, and explicitly does nothing. By the time code-mode is implemented (issue #209), the inputs, outputs, and dispatch context for code-time decision archaeology may differ — the diaboli code-mode dispatch already discovered context differences from spec-time (REFLECTION_LOG 2026-04-19: 'pr_ref: in code-mode frontmatter was impossible'). The 'stable contract' that is stable today may not be stable when implemented."
    disposition: accepted
    disposition_rationale: "Flag not justified just yet."
  - id: O4
    category: scope
    severity: high
    claim: "The spec adds a new pipeline stage that will execute on every feature PR but explicitly defers the constraint that would make its output load-bearing — producing optional artefacts on the critical path."
    evidence: "Section 'Out of scope (deferred)' second bullet defers 'HARNESS.md constraint PRs have adjudicated stories'. Section 'Soft gate semantics' confirms 'progression is allowed even if no story disposition is ticked.' Combined with sequencing step 3 (henney runs after every spec-mode diaboli adjudication), the pipeline now has a mandatory-to-run stage with optional-to-read output. Without a constraint, dispositions will accumulate as 'pending' indefinitely; without a forcing function, the soft gate degrades to no gate. The diaboli's own ARCH_DECISION (AGENTS.md) explicitly rejected this pattern: 'manual invocation only — discovers utility in early PRs but never creates discipline; users skip it under pressure; advisory gate without constraint — same failure mode.' The Henney spec re-introduces exactly that pattern and calls it 'reversible if we observe the soft gate failing'."
    disposition: accepted
    disposition_rationale: "Let's make this more than theatre with a real constraint."
  - id: O5
    category: implementation
    severity: high
    claim: "The lens set overlaps materially with the diaboli's six categories, producing predictable conflicts about where a finding belongs without a tie-breaking rule."
    evidence: "The Henney's six lenses include 'Alternatives unspoken' and 'Consequences accepted'. The diaboli's six categories include 'alternatives' ('a materially better approach exists and the spec does not acknowledge it') and 'risk' ('the spec's design creates or ignores a trust, safety, operational, or failure risk' — i.e. consequences). The spec's only differentiating rule is rhetorical: 'If a finding is shaped this could fail because…, that belongs in the diaboli record. The Henney reframes as this chose X over Y or names it as a story not worth telling and drops it.' That is a re-shaping rule, not a routing rule — the same evidence can be expressed either way. Without a deterministic where-does-this-belong test, both agents will surface the same evidence in different framings, defeating the spec's stated motivation that 'humans triage them identically — usually by skimming.' Two records, same content, same skim."
    disposition: accepted
    disposition_rationale: "Adopt the following routing test: if removing the finding would leave a class of failures undetected, it's a diaboli risk; if removing it would leave a decision unrecorded but no failure undetected, it's a Henney story. Embed this in both the Henney skill and the spec's routing-rule section so both agents reference the same test."
  - id: O6
    category: implementation
    severity: high
    claim: "The selectivity guardrail is enforced as a hard cap (15 stories) by the validation checkpoint, but the diagnostic action when the cap is exceeded is to refuse to write — discarding the agent's work."
    evidence: "Section 'Selectivity guardrail': 'The validation checkpoint enforces a hard cap of 15 stories per record — beyond that, the command refuses to write and surfaces the count to the user.' This conflicts with the validation-checkpoint pattern codified across the rest of the plugin, in which the checkpoint 'fixes deviations in place — no agent re-dispatch' (Section 'Validation checkpoint', last line of this same spec; also AGENTS.md ARCH_DECISION on validation checkpoints). Refusing to write is not fixing in place. It is also a worst-of-both-worlds outcome for the user: the agent ran, produced 16+ stories, the user has no record of any of them, and the orchestrator then has nothing to surface at the soft gate. The 'fix' is presumably to re-dispatch with a tighter guardrail prompt — i.e. exactly the re-dispatch the codified pattern forbids."
    disposition: accepted
    disposition_rationale: "Accepted to keep consistent with diaboli."
  - id: O7
    category: specification quality
    severity: high
    claim: "The 'soft gate' is described in three different operational shapes that cannot all be true at once."
    evidence: "Section 'Soft gate semantics' says 'progression is allowed even if no story disposition is ticked.' Acceptance scenario 2 says the orchestrator 'allows progression with pending dispositions but flags them in the summary.' Section 'Open questions' lists 'soft gate' as one of the four design dispositions resolved before the spec was written. None of these three statements specify the operational mechanism: does the orchestrator print a warning and continue silently? Does it require an explicit user keypress to proceed? Is 'flags them in the summary' a structured record (counted in observability) or a prose line in the plan-approval prompt? The diaboli's hard gate has a precise contract ('refuses progression while any disposition is pending'). The Henney's soft gate has only a stance, not a contract — implementers will diverge."
    disposition: accepted
    disposition_rationale: "Accepted with operational shape C: orchestrator emits a structured `henney_pending_count: N` field in the plan-approval prompt summary, and the count is exposed in observability (/superpowers-status, harness-health snapshots) so the team has a metric to watch. User can ignore at plan-approval time; the merge-time HARNESS constraint (per O4) supplies the actual forcing function."
  - id: O8
    category: specification quality
    severity: high
    claim: "The 'Refs' field accepts cross-references to objection IDs and earlier story IDs but the validation checkpoint does not verify those references resolve."
    evidence: "Section 'Output format' says 'Refs: <story IDs / objection IDs, else —>' and acceptance scenario 3 says 'A story cites objection O3 and earlier story #2. Validation accepts both forms in the Refs field.' Section 'Validation checkpoint' lists eight checks; none of them verify (a) that an O3 reference points to an existing entry in the corresponding objections record, or (b) that a story #2 reference points to an earlier entry in the same record. 'Validation accepts both forms' means the validator parses the syntax. With no resolution check, a story can cite O17 in a record that has only 5 objections, and the checkpoint will pass. Cross-references that silently dangle are worse than no cross-references — they imply a connection that doesn't exist."
    disposition: accepted
    disposition_rationale: "Accepted to keep things tight."
  - id: O9
    category: specification quality
    severity: medium
    claim: "The output format mixes a per-story disposition list (three checkboxes) with a frontmatter disposition field (single string) that has no defined mapping between the two."
    evidence: "Per-story prose body shows 'Disposition. - [ ] accept - [ ] revisit - [ ] promote'. Frontmatter shows 'disposition: pending' / 'disposition_rationale: null' for each story. The validation checkpoint requires 'disposition: pending for all entries (not pre-filled).' The spec does not say how the frontmatter disposition value moves off 'pending' as the human ticks checkboxes — does ticking 'accept' require the human to also edit the frontmatter to 'accepted'? What if the human ticks both 'accept' and 'promote'? Is the frontmatter value the union, the most recent, or undefined? The diaboli has a single disposition field with three legal values; the Henney has two surfaces (boxes and frontmatter) with no synchronisation rule. Downstream consumers (observability, the deferred 'PRs have adjudicated stories' constraint) will need to read one or the other and the spec doesn't say which is canonical."
    disposition: accepted
    disposition_rationale: "Accepted with operational shape C: frontmatter is canonical; drop the prose checkboxes. Legal values are pending | accepted | revisit | promoted (no compounds — choose one). Mirrors the diaboli pattern and simplifies the HARNESS constraint check to `disposition != pending` for all stories."
  - id: O10
    category: alternatives
    severity: medium
    claim: "An ADR-style template captured by the spec-writer at decision time is the orthodox alternative to a separate decision-archaeology agent and is not seriously considered."
    evidence: "Section 'Intellectual Foundations' explicitly invokes Nygard's ADRs and then dismisses them: 'ADRs are written by the decision-maker to explain a known choice; pattern stories are written by an external observer to surface a choice the decision-maker may not have realised they made.' This dismissal is too quick. The spec-writer agent is already in the pipeline at the moment of authorship; adding an 'Implicit decisions' section to the spec template (or a checklist of the six lenses) would surface forces, alternatives, and named patterns at the cheapest possible cost — when the author still remembers the decision. The Henney is then needed only to catch what the author missed, dramatically reducing 5–8 stories per spec to a much smaller residual set. The spec does not consider the spec-writer-template alternative as a complement to (or substitute for) a new agent."
    disposition: rejected
    disposition_rationale: "The external-observer charter is essential; the author's blind spots are precisely what's worth surfacing, and a checklist in the spec template can't surface what the author doesn't know they're missing."
  - id: O11
    category: scope
    severity: medium
    claim: "The 'promote' checkbox is shipped as scaffolding for a workflow that does not exist and is described as 'a follow-up' with no follow-up issue cited."
    evidence: "Section 'Out of scope (deferred)' third bullet: 'Promotion of stories to AGENTS.md ARCH_DECISION or HARNESS.md constraints. The promote checkbox is scaffolding for a future workflow; the actual promotion mechanism is a follow-up.' Unlike code-mode (tracked at issue #209), no issue number is given for the promotion mechanism. The checkbox will appear in every story record from day one, users will tick it (or not), and there is no mechanism for what happens when they do. Reflection 2026-04-18 explicitly identifies this failure mode: 'REFLECTION_LOG.md Improvements are not load-bearing — they are captured but not routed anywhere.' Adding another check-but-do-nothing surface repeats that pattern."
    disposition: accepted
    disposition_rationale: "Mirror the code-mode pattern: open a follow-up issue now tracking the promotion mechanism (story → AGENTS.md ARCH_DECISION or HARNESS.md constraint), and reference that issue from the spec's Out-of-scope section the same way #209 is referenced."
  - id: O12
    category: specification quality
    severity: medium
    claim: "Sequencing rationale claims 'parallel adjudication of diaboli + Henney was considered and rejected' but does not address the alternative of running both agents in parallel before adjudication."
    evidence: "Section 'Sequencing': 'Parallel adjudication of diaboli + Henney was considered and rejected: stories that cite or counter objections should be authored after the team has resolved the objection record, not in parallel with it.' This rejects parallel adjudication, but the actual cost the spec is paying (extra wall-clock latency between spec-writer and plan approval) comes from serial dispatch of the agents themselves, not serial adjudication. The spec could dispatch both agents in parallel after spec-writer, then have the human adjudicate diaboli first and Henney second — capturing the cross-reference benefit while halving the agent-dispatch latency. The spec does not consider this configuration."
    disposition: accepted
    disposition_rationale: "Accepted with option B: stay strict serial, but the spec's Sequencing section must explicitly address parallel dispatch as an option and cite REFLECTION_LOG 2026-04-07 (parallel agent dispatch reliability problems in this codebase) as the defensible reason serial is preferred."
---

# Objections — choice-cartographer (spec mode)

> **Renamed-after-adjudication note.** The agent was renamed from "Henney"
> to "Choice Cartographer" after this objection record was adjudicated.
> References in the body and dispositions to "Henney" / `the Henney` /
> `/henney` / `henney_pending_count` / `henney_model` /
> `agents/henney.agent.md` / "Henney stories" refer to what is now the
> Choice Cartographer / `/choice-cartograph` / `cartograph_pending_count`
> / `cartographer_model` / `agents/choice-cartographer.agent.md` /
> "choice stories" respectively. The format ("choice stories") and the
> Henney pattern-stories lineage (POSA Vol. 5) are preserved by design;
> the rename affects the agent role, not the format. The dispositions
> below stand as written — rewriting them post-rename would falsify the
> adjudication record.

## O1 — premise — high

### Claim

The two-pattern problem (intent debt and cognitive debt) is asserted from authority, not from observed evidence in this codebase, despite a fresh diaboli pipeline that could supply such evidence.

### Evidence

From the Problem section:

> Six months later the team re-litigates the choice because nobody wrote down why it was made — there was no seam in the workflow at which to write that down.

> When a spec implements Mediator, Saga, Outbox, or Repository without naming it, the team carries the pattern-recognition cost on every future change to that surface.

Both claims are framed as general truths. Neither cites a specific instance in `docs/superpowers/specs/`, `docs/superpowers/objections/`, `REFLECTION_LOG.md`, or any merged PR in which a re-litigation actually occurred or an unnamed pattern actually imposed cost. The diaboli has been live since 2026-04-19 (PR #177) — at minimum the pipeline has been generating objection records that could be inspected for "this chose X over Y" content already accidentally surfacing there. The spec does not reference any.

### Why this matters

A premise objection at spec time is the highest-leverage challenge available — it invalidates all downstream artefacts. The diaboli's own ARCH_DECISION cites a falsifiable revisit condition: "if disposition distribution clusters on `deferred — not material` over a meaningful sample (20+ PRs), tune the SKILL.md charter." The Henney spec proposes a parallel mechanism (six lenses, soft gate, per-spec records) without producing the equivalent evidence base. If two or three of the existing diaboli records already contain "this chose X over Y" content under categories like `alternatives` or `implementation`, the case for a separate agent collapses; if none do, that is itself a signal worth examining before adding a second pipeline stage. Either way, the spec is asking the team to commit to a pipeline change on the strength of an argument from authority (Henney, Nygard, Alexander) rather than evidence from the artefacts the pipeline has already produced.

## O2 — alternatives — high

### Claim

Extending the existing diaboli skill with a seventh category (e.g. `decisions`) is not considered, even though the spec rejects it implicitly by asserting the two roles "use different lenses."

### Evidence

> Asking the diaboli to also surface decisions confuses two roles. Risk surfacing filters for what could be wrong. Decision archaeology filters for what was chosen without saying so. They use different lenses, weight different evidence, and produce different artefacts.

The spec asserts this without showing a worked example of a finding that genuinely cannot be expressed in either of the diaboli's existing categories. The diaboli already has an `alternatives` category whose definition is: "A materially better approach exists and the spec does not acknowledge it... an alternative that is meaningfully simpler, cheaper, or more aligned with existing project conventions" (skill, lines 81–89). That definition is one re-framing away from "Alternatives unspoken" — the Henney's second lens. The spec does not explain what would be lost by extending the diaboli's category list to seven, with weighting tuned to surface decisions at spec time alongside risks.

### Why this matters

The plugin's surface area is the dominant cognitive cost imposed on contributors and on Claude Code itself. Each new chartered agent adds a skill file, an agent file, a command file, a prompt file, two docs pages, an orchestrator step, a directory, and a validation checkpoint. The Henney also adds a soft gate and a deferred constraint, with the deferred constraint already implicit in the design. The bar for a new top-level component should be that the merged alternative was tried (or shown infeasible by argument from a worked example, not by a categorical claim about lenses). The spec's argument here is that bundling produces "longer objection records that mix this might fail with this chose X over Y, and humans triage them identically — usually by skimming." But the proposed remedy is *two* records to triage instead of one. If the failure mode is human skimming, doubling the triage surface area is the wrong direction.

## O3 — scope — high

### Claim

Reserving a code-mode contract that immediately returns "out of scope" on invocation ships dead surface area in the public command, agent, and skill — the contract is invented before any user has expressed need for it.

### Evidence

> The agent definition will accept `--mode spec|code` so the contract is stable, but the orchestrator will not dispatch code-mode in this release. `/henney --mode code` returns "out of scope in this release" and exits non-error.

And acceptance scenario 5:

> `--mode code` is accepted by `/henney` and the agent but produces an "out of scope in this release — tracked under issue #209" message and exits non-error. (Reserves the slot without implementing.)

### Why this matters

This is YAGNI in the API surface. A flag is documented, accepted, validated, included as an acceptance scenario, and does nothing. The diaboli's code-mode extension (PR #188) discovered that code-time dispatch context differs from spec-time in non-trivial ways (REFLECTION_LOG 2026-04-19: "`pr_ref:` in code-mode frontmatter was impossible — the PR does not exist when code-time runs"). A "stable contract" reserved today, without the dispatch context to design against, is likely to need breaking changes when implemented — the worst of both worlds: a public contract that consumers (docs, examples, tests) treat as load-bearing, and a real implementation that has to break it. The simpler scope is: ship spec mode only, no `--mode` flag, add the flag in the same PR as the code-mode implementation. The contract is exactly as stable when introduced alongside its implementation as when reserved before it, and one fewer surface needs to be maintained in the meantime.

## O4 — scope — high

### Claim

The spec adds a new pipeline stage that will execute on every feature PR but explicitly defers the constraint that would make its output load-bearing — producing optional artefacts on the critical path.

### Evidence

From "Out of scope (deferred)":

> **HARNESS.md constraint "PRs have adjudicated stories".** Premature; revisit after spec-mode has produced records on at least three real specs.

From "Soft gate semantics":

> The Henney record is surfaced for the human to read, but progression is allowed even if no story disposition is ticked.

> A subsequent constraint can re-introduce a hard gate at PR merge if the team finds dispositions are routinely skipped. This is reversible if we observe the soft gate failing.

This is contradicted by the diaboli's own ARCH_DECISION (AGENTS.md, lines 99–115):

> Decision: advocatus-diaboli is hard-wired into the spec-first pipeline as an agent-enforced PR constraint from the outset (Option B — not optional, not advisory)... Alternatives considered and rejected: (1) manual invocation only — discovers utility in early PRs but never creates discipline; users skip it under pressure; (2) advisory gate without constraint — same failure mode.

### Why this matters

The Henney spec re-introduces the exact configuration the diaboli's ARCH_DECISION rejected, with no argument for why this case is different. The "revisit after three real specs" deferral assumes the soft gate will produce three real story records to evaluate; but with no forcing function, the most likely outcome is three records with empty dispositions and no signal about whether the mechanism works. The spec's "reversible if we observe the soft gate failing" is the same posture as "advisory gate without constraint" — and the prior decision found that posture self-undermining: there is no observation of failure if the artefact is optional, because no one is required to look. The premise of compound learning (REFLECTION_LOG 2026-04-18) is that captured-but-unread signal does not change behaviour. The Henney is being shipped as a captured-but-optionally-read signal.

## O5 — implementation — high

### Claim

The lens set overlaps materially with the diaboli's six categories, producing predictable conflicts about where a finding belongs without a tie-breaking rule.

### Evidence

The diaboli's six categories include `alternatives` ("a materially better approach exists and the spec does not acknowledge it") and `risk` ("the spec's design creates or ignores a trust, safety, operational, or failure risk... structural gaps in how the design handles adversarial conditions, misuse, unexpected inputs, or foreseeable failure modes"). The Henney's six lenses include "Alternatives unspoken. Realistic options not acknowledged" and "Consequences accepted. What this forecloses, what bugs are now possible." The differentiation rule offered by the spec is:

> If a finding is shaped "this could fail because…", that belongs in the diaboli record. The Henney reframes as "this chose X over Y" or names it as a story not worth telling and drops it.

### Why this matters

This is a re-shaping rule, not a routing rule. Any "this could fail" finding has an underlying choice (X over Y) and any "this chose X over Y" has an associated consequence ("...and the consequence of choosing X is that scenario Z fails"). The same evidence will reach both agents and be expressed in their respective grammars, producing two records that read differently but cover the same ground. The spec's stated motivation — "humans triage them identically — usually by skimming" — is *worsened* by a second record. The code-time mechanism makes this worse still: the diaboli runs at both spec-time and code-time, and the Henney spec leaves room for code-mode dispatch later. The plan-approval gate could then end up surfacing four artefacts (spec-mode objections, spec-mode stories, plan summary) and the integration gate three (code-mode objections, code-mode stories, integration summary). Without a deterministic routing test ("a finding belongs in record X iff …") the redundancy will compound.

## O6 — implementation — high

### Claim

The selectivity guardrail is enforced as a hard cap (15 stories) by the validation checkpoint, but the diagnostic action when the cap is exceeded is to refuse to write — discarding the agent's work.

### Evidence

From "Selectivity guardrail":

> The validation checkpoint enforces a hard cap of 15 stories per record — beyond that, the command refuses to write and surfaces the count to the user.

From "Validation checkpoint", final line:

> Deviations are fixed in place — no agent re-dispatch.

From AGENTS.md ARCH_DECISION on validation checkpoints:

> The pattern is: generate, read back, check against format spec, fix in place... Reference templates set intent but do not guarantee compliance. The checkpoint is the verification layer.

### Why this matters

"Refusing to write" is not "fixing in place" — it is throwing the agent's work away and forcing the user (or the command) to either lower the cap and re-run, or commit only a manually pruned subset. The spec gives no fix-in-place instruction for the cap-exceeded case (e.g. "drop the lowest-severity stories until the count is 15"), so the only recovery path is a re-dispatch — exactly what the codified pattern forbids. The user-visible failure mode is also poor: the agent ran, produced a record, the user has nothing to read, and the orchestrator has nothing to surface at the soft gate. The diaboli's analogous cap (12 objections) is enforced inside the agent's reasoning protocol ("if you have more than 12 candidate objections, select the 12 with the highest severity") rather than at the checkpoint, which is the correct place.

## O7 — specification quality — high

### Claim

The "soft gate" is described in three different operational shapes that cannot all be true at once.

### Evidence

From "Soft gate semantics":

> The Henney record is surfaced for the human to read, but progression is allowed even if no story disposition is ticked.

From acceptance scenario 2:

> Surfaces the record at plan approval. Allows progression with `pending` dispositions but flags them in the summary.

From "Open questions":

> The four design dispositions (per-spec records, soft gate, single agent with --mode, strict serial) were resolved before this spec was written and are recorded above.

### Why this matters

None of these statements specifies the operational mechanism. Open questions:

1. Is "flags them in the summary" a structured field in the plan-approval prompt (e.g. `henney_pending_count: N`) or a prose line?
2. Does the user see the count and is required to acknowledge it (e.g. press Enter), or is it printed and the orchestrator continues silently?
3. Is the `pending` count exposed in observability (`/superpowers-status`, harness-health) the way diaboli activity is (per AGENTS.md ARCH_DECISION on diaboli observability)? If yes, where? If no, how does the team know the soft gate isn't being skipped?
4. Does the plan-approval prompt change when `pending` dispositions exist, or does it look identical to the no-Henney case?

The diaboli's hard gate has a precise contract ("refuses progression while any disposition is `pending`"). The Henney's soft gate has only a stance. Implementers will diverge — one will print a one-line warning, another will require a keypress, a third will treat the record as informational and not surface it at all. The spec needs to pick one operational shape and write it down.

## O8 — specification quality — high

### Claim

The "Refs" field accepts cross-references to objection IDs and earlier story IDs but the validation checkpoint does not verify those references resolve.

### Evidence

From "Output format":

> **Refs:** <story IDs / objection IDs, else —>

Acceptance scenario 3:

> A story cites objection O3 and earlier story #2. Validation accepts both forms in the Refs field.

The validation checkpoint lists eight checks; none of them verifies cross-reference resolution. The closest is "Lens values drawn from the six-category set" — a syntactic check, not a referential one.

### Why this matters

Cross-references that silently dangle are worse than no cross-references — they imply a connection the reader will trust. A story citing O17 in a record where the corresponding objections file has only 5 objections will pass validation. A story citing "earlier story #2" when the story being authored is itself story #2 (a self-reference, or out-of-order numbering) will pass validation. The compound-learning hypothesis behind cross-references is that the team can navigate from a story back to the objection that informed it (or the prior story it builds on); a broken reference defeats that hypothesis at the exact moment someone tries to use it. The validation checkpoint should at minimum check (a) that any `O\d+` in Refs corresponds to an entry in the matching objections record at `docs/superpowers/objections/<slug>.md`, and (b) that any story `#N` reference satisfies `N < current_id`.

## O9 — specification quality — medium

### Claim

The output format mixes a per-story disposition list (three checkboxes) with a frontmatter disposition field (single string) that has no defined mapping between the two.

### Evidence

From the per-story prose body:

> **Disposition.**
> - [ ] accept
> - [ ] revisit
> - [ ] promote

From the frontmatter:

> stories:
>   - id: 1
>     ...
>     disposition: pending
>     disposition_rationale: null

From the validation checkpoint:

> 4. `disposition: pending` for all entries (not pre-filled).
> 5. `disposition_rationale: null` for all entries (not pre-filled).

### Why this matters

There is no rule for how the frontmatter `disposition` value moves off `pending` as the human ticks checkboxes. Specifically:

- If the human ticks "accept", does the human also have to edit the frontmatter to a non-pending value? What is that value — `accepted`? `accept`?
- If the human ticks both `accept` and `promote` (the spec does not say the boxes are mutually exclusive), what does the frontmatter say?
- Is the frontmatter or the prose the canonical source of truth for downstream consumers (the deferred "PRs have adjudicated stories" constraint, observability)?

The diaboli has a single disposition surface: a frontmatter string with three legal values. The Henney has two surfaces with no synchronisation rule. The deferred HARNESS constraint will eventually need to read one or the other — and "resolved" will mean different things depending on which. This is exactly the kind of ambiguity the spec-mode `specification quality` category exists to catch: a reasonable implementer reading this spec could plausibly build either (a) checkboxes are the source of truth and the frontmatter `disposition` is a derived field, or (b) the frontmatter is canonical and the checkboxes are a UX hint, with the human required to keep them in sync manually.

## O10 — alternatives — medium

### Claim

An ADR-style template captured by the spec-writer at decision time is the orthodox alternative to a separate decision-archaeology agent and is not seriously considered.

### Evidence

From "Intellectual Foundations":

> The "decision archaeology" framing draws on Michael Nygard's *Architecture Decision Records* (2011) but inverts the convention: ADRs are written by the decision-maker to explain a known choice; pattern stories are written by an external observer to surface a choice the decision-maker may not have realised they made. Both are rationale capture; only the latter pays down intent debt.

### Why this matters

The dismissal of ADRs is too quick to be load-bearing. The spec-writer agent is already in the pipeline at the moment of authorship; adding an "Implicit decisions" section to the spec template — a checklist prompting the author to enumerate forces, alternatives considered, named patterns, and consequences — would surface the same content at the cheapest possible cost (when the author still remembers the decision). The Henney is then needed only to catch what the author missed, dramatically reducing the 5–8 stories per spec target down to a much smaller residual set, and weakening the case for a chartered agent at all. The spec also does not consider a hybrid: spec-writer captures forces/alternatives/consequences in the spec template; Henney runs only as a residual pass that catches *unnamed patterns* (its strongest unique lens — pattern recognition is harder to elicit from the author who didn't realise they were using a pattern). A narrower Henney with one lens and a smaller scope would be a smaller surface change.

## O11 — scope — medium

### Claim

The "promote" checkbox is shipped as scaffolding for a workflow that does not exist and is described as "a follow-up" with no follow-up issue cited.

### Evidence

From "Out of scope (deferred)":

> **Promotion of stories to AGENTS.md ARCH_DECISION or HARNESS.md constraints.** The `promote` checkbox is scaffolding for a future workflow; the actual promotion mechanism is a follow-up.

Unlike code mode (tracked at issue #209), no follow-up issue number is cited for the promotion mechanism.

### Why this matters

The checkbox will appear in every story record from day one. Users will tick it (or not). There is no mechanism for what happens when they do — no agent reads `[x] promote` and proposes an ARCH_DECISION; no command exists to scan stories with `promote` ticked. REFLECTION_LOG 2026-04-18 explicitly identifies this failure mode: "REFLECTION_LOG.md Improvements are not load-bearing — they are captured but not routed anywhere that influences future sessions." The author of that reflection is the same project. Adding another check-but-do-nothing surface repeats the pattern the project has already learned costs trust. At minimum, ship the checkbox with a follow-up issue number alongside it (the same way code mode is tracked at #209), so the scaffolding is on a path to being load-bearing rather than indefinite scaffolding.

## O12 — specification quality — medium

### Claim

Sequencing rationale claims "parallel adjudication of diaboli + Henney was considered and rejected" but does not address the alternative of running both agents in parallel before adjudication.

### Evidence

From "Sequencing":

> Parallel adjudication of diaboli + Henney was considered and rejected: stories that cite or counter objections should be authored *after* the team has resolved the objection record, not in parallel with it. Cross-references from stories to objection IDs are explicitly supported in the Refs field.

### Why this matters

The argument addresses parallel *adjudication*, not parallel *agent dispatch*. The cost the spec is paying is wall-clock latency between spec-writer and plan approval: under strict serial sequencing, the user must wait for diaboli to complete, adjudicate it, then dispatch Henney, then adjudicate it, then approve the plan. A different configuration — dispatch both agents in parallel after spec-writer; have the human adjudicate diaboli first, then Henney — captures the spec's stated cross-reference benefit (Henney is adjudicated after objections are resolved) while halving the agent-dispatch latency. The spec does not consider this configuration, so a reader cannot tell whether it was rejected for a reason or simply not considered. Given that REFLECTION_LOG 2026-04-07 documents reliability problems with parallel agent dispatch in this codebase, "considered and rejected because parallel agent dispatch is unreliable here" would be a defensible argument; the spec needs to make it.

## Explicitly not objecting to

- **The intellectual foundations (Henney, Nygard, Alexander, brakes-as-acceleration).** The cited lineage is well-chosen and the framing is coherent — the question raised under O1 is whether this codebase has the evidence to justify acting on the framing now, not whether the framing is sound.
- **The read-only trust boundary (Read, Glob, Grep only).** This mirrors the diaboli mechanism exactly, the rationale is the same (cognitive-engagement gate), and REFLECTION_LOG 2026-04-19 explicitly affirms that this design intent is well-understood. Re-litigating it would be noise.
- **The choice of per-spec records at `docs/superpowers/stories/<spec-slug>.md` over an aggregate `STORIES.md`.** This is symmetric with `docs/superpowers/objections/<spec-slug>.md`, navigable from the spec, and the aggregate index is correctly deferred until the per-spec corpus is large enough to justify it. Symmetry with the diaboli output path also reduces the cognitive cost of reasoning about the pipeline.
- **The model-bump path (single agent with `--mode`, not two agents).** The fourth design disposition was resolved correctly — two agents would duplicate charter, fragment maintenance, and create divergent evolution risk, exactly as the diaboli's ARCH_DECISION found for its own spec/code split.
- **Selectivity-as-value (5–8 stories target).** The principle is right and aligned with the diaboli's 12-objection cap rationale ("Quality over quantity... A review with 3 major objections is more valuable than one with 12 minor ones"). My objection (O6) is to how the cap is enforced, not to the existence of selectivity discipline.
- **CHANGELOG, version bump, and plugin-manifest changes.** These are mechanical and follow the project's existing semver discipline correctly. Nothing to challenge here.
- **The validation checkpoint pattern as a category.** The spec correctly applies the codified plugin-wide pattern (AGENTS.md ARCH_DECISION on validation checkpoints). My objection (O6) is to one specific check; the pattern itself is right.
