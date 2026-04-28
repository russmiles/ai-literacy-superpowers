---
spec: docs/superpowers/specs/2026-04-28-agents-md-readback-hook-design.md
date: 2026-04-28
mode: spec
diaboli_model: claude-opus-4-7[1m]
adjudicated_by: russ
adjudicated_date: 2026-04-28
outcome: spec abandoned (premise refuted by O1)
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The spec asserts read-back is 'by convention only' but does not establish that AGENTS.md is failing to reach sessions today; the diagnosis is asserted rather than evidenced."
    evidence: "Spec, Problem section: 'But read-back at session start is by convention only. The patterns curated in AGENTS.md cannot shape future sessions if no reliable trigger surfaces them when an agent boots.' No telemetry, no reflection log entries showing missed-uptake events, and no comparison with the agreement-loading behaviour Claude Code already provides for AGENTS.md / CLAUDE.md."
    disposition: accepted-blocking
    disposition_rationale: "Accepted as blocking. Claude Code does load AGENTS.md as project memory at session start — it is a named project-memory file alongside CLAUDE.md. The spec's premise (that AGENTS.md fails to reach sessions absent the new hook) is refuted. The Q3 finding from the 2026-04-28 assessment was about the absence of an *uptake signal* (we cannot tell whether agents used the AGENTS.md content), not about absence of *exposure* (the content is in context). The hook would have been redundant for the exposure problem and would not have addressed the signal problem. Implementation abandoned. The remaining objections are made moot by this disposition but are recorded below for completeness."
  - id: O2
    category: premise
    severity: medium
    claim: "The 'half-closed loop' framing assumes the loop's third stage is enforcement; an equally plausible diagnosis from the same Q3 finding is that read-back is enforced fine but acknowledgement signal is missing — and the chosen design optimises the wrong half."
    evidence: "Spec, Problem section frames the gap as enforcement of read-back. The driving Q3 finding is summarised as 'read-back at session start is by convention only', which is compatible with both 'agents do not read it' and 'we have no signal that they did.' The spec picks the first interpretation without arguing against the second."
    disposition: accepted-as-correct-diagnosis
    disposition_rationale: "Confirmed by adjudication of O1. The signal/instrumentation framing was the right one all along. A separate spec for an instrumentation mechanism (e.g., logging when curated AGENTS.md content shows up in agent decisions) may be worth scoping as a future literacy improvement — but it is not this work."
  - id: O3
    category: implementation
    severity: high
    claim: "The 'hybrid' design does not close the read-back loop; it shifts dependence on agent compliance from CLAUDE.md (read AGENTS.md) to the systemMessage (act on the injected slice). The same failure mode — agent ignores the directive — applies to both."
    evidence: "Spec, Decisions table Q1: 'Pure injection wastes tokens every session; pure nudge recreates the original failure mode (relying on agent compliance with a nudge instead of a CLAUDE.md rule).' The hybrid still relies on the agent reading and applying the systemMessage content. The architectural claim that this 'closes the loop' is asserted but not defended against the compliance-equivalence objection."
    disposition: moot
    disposition_rationale: "Moot given O1's disposition (work abandoned). The objection itself was correct — the hybrid did not actually close the loop in the way the spec claimed — but the spec is no longer being implemented."
  - id: O4
    category: implementation
    severity: medium
    claim: "Auto-dismiss after first emission is incompatible with the goal of guaranteeing read-back per session. The spec's own multi-window note acknowledges that subsequent sessions in the same dismissal window receive nothing — which contradicts goal #1 ('reliably encounter the patterns ... at session start')."
    evidence: "Spec, Goals: 'Inject recently-curated AGENTS.md content into a session at start so that agents (human or LLM) reliably encounter the patterns'. Spec, Risks: 'If three sessions fire in the same minute, only the first sees the slice. Acceptable trade-off — the *purpose* is per-session awareness, not multi-session redundancy.' These two statements are in tension: 'per-session awareness' and 'only the first sees the slice' cannot both hold."
    disposition: moot
    disposition_rationale: "Moot given O1. The internal goal/trade-off contradiction was real but is no longer load-bearing."
  - id: O5
    category: risk
    severity: high
    claim: "Shipping the hook in plugin hooks.json with hardcoded section names creates a silent footgun for every downstream consumer whose AGENTS.md uses different section names — they pay token cost variance, get partial coverage, and have no signal that the hook is silently ignoring their content."
    evidence: "Spec, Risks: 'Section names are baked into the script. If a downstream consumer uses different AGENTS.md section names, the hook silently misses their content. ... unknown sections are not an error.' Spec, Decisions Q4a: 'Ship in plugin's hooks.json. Downstream consumers face the same half-closed-loop risk; silent-exit-on-no-AGENTS.md means consumers without it pay zero cost' — but this argument does not address consumers who have AGENTS.md with different section names, who pay the cost of a partially-functioning hook with no indication it is mis-configured for their schema."
    disposition: moot
    disposition_rationale: "Moot given O1. Downstream consumers do not need this hook either, for the same reason — Claude Code already loads AGENTS.md as project memory."
  - id: O6
    category: risk
    severity: medium
    claim: "Token cost framing assumes one emission per AGENTS.md change, but provides no analysis of teams running many short sessions a day after a curation event. A 2400–3000 token systemMessage is non-trivial, and there is no upper bound on consumer-side cost during high-edit periods (e.g., a curation sprint with multiple AGENTS.md commits in a day across many parallel sessions)."
    evidence: "Spec, Risks: 'Token cost surveyed but not measured. Estimate is ~2400 tokens per emission. If actual session telemetry shows higher (e.g., the hook emits on every session due to noisy AGENTS.md edits), revisit the recency model — possibly add a min-interval to the dismissal logic.' This explicitly defers the cost analysis to post-shipping telemetry without giving downstream consumers a way to bound exposure in v0.32.0."
    disposition: moot
    disposition_rationale: "Moot given O1. Cost concern was real but does not arise — the hook will not ship."
  - id: O7
    category: implementation
    severity: medium
    claim: "'Last 3 bullets per section' is presented as a recency proxy but rests on an undocumented convention that bullets are always appended. The spec acknowledges the gap but does not address what happens when a curator inserts a new bullet earlier in a section for thematic grouping — that bullet will be invisible to the hook indefinitely until three more bullets are appended after it."
    evidence: "Spec, Decisions Q3 rationale: 'empirically tracks \"recently curated\" because new entries are appended.' This is a project convention asserted in the rationale but is not a written rule in CLAUDE.md, AGENTS.md curation guidance, or the curation-nudge hook. There is no mechanism to enforce append-only curation, so the recency proxy can silently degrade."
    disposition: moot
    disposition_rationale: "Moot given O1. The append-only convention question becomes a question for any future signal/instrumentation spec, not this one."
  - id: O8
    category: specification quality
    severity: high
    claim: "The verification section says 'All 4 sections populated' but the slice-extraction logic and systemMessage payload list 5 sections (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS). A reasonable implementer would not know whether TEST_STRATEGY is in scope, out of scope, or a typo."
    evidence: "Spec, Verification §Test surface — 12 cases, row 1: 'All 4 sections populated, ≥3 bullets each | Last 3 bullets per section emitted'. Spec, Hook behaviour contract §Decision flow: 'Extract last 3 bullets per known section (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS).' Spec, Decisions Q3 also lists five sections."
    disposition: moot
    disposition_rationale: "Moot given O1. Specification-quality bug was real but the spec is no longer being implemented."
  - id: O9
    category: specification quality
    severity: high
    claim: "The slice extraction algorithm is under-specified at multiple boundaries: behaviour when a section has fewer than 3 bullets ('total − 3 + 1' becomes a non-positive line index), whether indented or nested bullets count as bullet starts, output ordering (file order vs canonical order), and how 'lines inside HTML comments' are detected (single-line `<!-- ... -->` vs multi-line)."
    evidence: "Spec, Slice extraction logic, step 3: 'Find the line number of the (total − 3 + 1)th bullet start.' This formula is undefined for total < 3. Step 2: 'identify every line beginning `- ` (bullet starts); ignore lines inside HTML comments' — does not define indented bullet handling, and 'inside HTML comments' is ambiguous between single-line and multi-line comment forms. The systemMessage payload format example shows a fixed section order but the spec does not state whether output order tracks file order or the canonical list."
    disposition: moot
    disposition_rationale: "Moot given O1. Algorithm under-specification was real but does not need fixing for an abandoned spec."
  - id: O10
    category: specification quality
    severity: medium
    claim: "The interaction between auto-dismiss and the 'zero bullets extracted' silent-exit path is not specified. If the file changes (hash differs) but extraction yields zero bullets — e.g., the user reorganised AGENTS.md into unknown sections — the spec does not say whether the marker is updated. Either choice has consequences and the implementer will guess."
    evidence: "Spec, Decision flow: '[Total bullets extracted equals 0?] yes → exit 0 silently (file exists but is unpopulated)'. The marker-write step is positioned after the JSON emission and is not explicitly tied to either the hash-mismatch branch or the bullets-extracted branch. A reader cannot determine whether the marker is updated when extraction is empty."
    disposition: moot
    disposition_rationale: "Moot given O1."
  - id: O11
    category: alternatives
    severity: medium
    claim: "A materially simpler alternative — emit a fixed, low-token nudge ('AGENTS.md changed since last session — re-read before proceeding') with no slice extraction — is not seriously considered. It would eliminate the awk algorithm, the test surface, the section-name coupling, the recency-proxy debate, and the downstream silent-skip footgun in one move; the only thing it would not do is render the slice into context the agent might already have."
    evidence: "Spec, Decisions Q1 lists only two alternatives — 'Pure injection' and 'pure nudge' — and rejects pure nudge with 'recreates the original failure mode'. But the spec's own architectural argument (O3 above) shows that the hybrid has the same compliance dependency. A pure-nudge with explicit framing as 'directive, not optional' is not evaluated."
    disposition: moot
    disposition_rationale: "Moot given O1. Both alternatives (pure nudge AND hybrid) target the wrong problem."
  - id: O12
    category: scope
    severity: medium
    claim: "The spec describes this work as 'introducing the first executable tests in the project' (per HARNESS.md TEST_STRATEGY) and bumps the harness CI accordingly, but treats this load-bearing change as a footnote. Introducing executable tests changes the project's TEST_STRATEGY contract; that change deserves its own decision rather than being ridden in on a hook PR."
    evidence: "Spec, Cross-references: 'HARNESS.md constraints touched: ... \"Tests must pass\" (currently unverified; this work introduces the first executable tests in the project).' AGENTS.md TEST_STRATEGY currently states: 'This project has no application code or test suite.' Bumping the harness from 'no tests' to 'tests must pass' is a project-wide convention change that the spec acknowledges only in a cross-reference line."
    disposition: moot
    disposition_rationale: "Moot given O1. The tests-as-load-bearing-change concern does not arise — no tests will be added."
---

## O1 — premise — high

### Claim

The spec asserts read-back is "by convention only" but does not establish that AGENTS.md is actually failing to reach sessions today. The diagnosis that motivates the entire feature is asserted rather than evidenced.

### Evidence

From the Problem section:

> But read-back at session start is by convention only. The patterns curated in AGENTS.md cannot shape future sessions if no reliable trigger surfaces them when an agent boots.

There is no telemetry, no REFLECTION_LOG entry showing missed-uptake events, and no comparison with the project-context loading behaviour Claude Code provides for `AGENTS.md` / `CLAUDE.md` files at the project root. Claude Code itself loads root-level memory files; the spec does not address whether that loading already covers the read-back step that this hook is meant to enforce.

### Why this matters

If AGENTS.md is already in agent context for most session starts (because Claude Code already surfaces it), the systemMessage injection is redundant for those agents, and the framing of "half-closed loop" is wrong. The fix would then be a signal-or-test problem (verify uptake), not an injection problem. A premise objection at this level invalidates Goal #1 and the architectural claim.

## O2 — premise — medium

### Claim

The "half-closed loop" framing presumes that read-back means *enforcement*. The same Q3 finding is equally compatible with the diagnosis that read-back happens but produces no observable signal. The spec optimises a single interpretation without showing it ruled out the other.

### Evidence

The Problem section presents the framing as established:

> The gap is in **enforcement of read-back** — closing the third stage of the compound-learning loop

But the surfacing reflection (paraphrased in the spec) says only that read-back is "by convention only." A convention-only mechanism may still work — it merely lacks confirmation. The spec does not consider an instrumentation-only intervention.

### Why this matters

Designs that target the wrong half of a problem look successful in isolation but do not move the metric the project cares about. If the real gap is "we cannot tell whether read-back happened," shipping an injection hook that auto-dismisses after one read makes the gap worse, not better.

## O3 — implementation — high

### Claim

The "hybrid" design does not close the read-back loop. It shifts dependence on agent compliance from one surface (CLAUDE.md saying "read AGENTS.md") to another (a systemMessage saying "here are recent patterns"). The spec rejects pure nudge precisely because nudges depend on compliance — and then proposes a design that has the same dependency.

### Evidence

From the Decisions table, Q1:

> Pure injection wastes tokens every session; pure nudge recreates the original failure mode (relying on agent compliance with a nudge instead of a CLAUDE.md rule)

A systemMessage is not enforcement. The agent reading the systemMessage may or may not act on its content; the project has no mechanism to verify uptake. The architectural claim that the hybrid "closes the loop" is therefore a statement about exposure (the slice is in context), not about enforcement (the agent uses it).

### Why this matters

If the hybrid does not actually close the loop, then the spec's central claim — Goal #4: "Ship the mechanism to downstream consumers so projects that adopt this plugin inherit a closed compound-learning loop" — is overstated. Downstream consumers will inherit the same half-closed loop with extra ceremony.

## O4 — implementation — medium

### Claim

Auto-dismiss after first emission is incompatible with Goal #1 ("reliably encounter the patterns ... at session start"). The spec's own multi-window note shows that simultaneous parallel sessions get only-first-sees-the-slice behaviour. "Per-session awareness" and "only the first sees the slice" are mutually exclusive descriptions of the same scenario.

### Evidence

Goal #1:

> Inject recently-curated AGENTS.md content into a session at start so that agents (human or LLM) reliably encounter the patterns

Risks section, on the same scenario:

> If three sessions fire in the same minute, only the first sees the slice. Acceptable trade-off — the *purpose* is per-session awareness, not multi-session redundancy.

The Risks rationalisation reframes the goal from "every session" to "any session in a window." This is a goal change disguised as a trade-off acceptance.

### Why this matters

This is the exact failure mode the spec was supposed to fix. If parallel sessions are common in this project's actual usage (and the existing reflections on parallel agents suggest they are), the hook will routinely fail to close the loop for the second and third agents in any parallel pipeline.

## O5 — risk — high

### Claim

Shipping the hook in plugin `hooks.json` with hardcoded section names creates a silent footgun for downstream consumers whose AGENTS.md uses different section names. They pay token cost variance, get partial coverage, and have no signal that the hook is silently mis-configured for their schema.

### Evidence

Risks section:

> Section names are baked into the script. If a downstream consumer uses different AGENTS.md section names, the hook silently misses their content. Mitigation: the hook only injects sections it recognises; unknown sections are not an error.

Decisions Q4a:

> Ship in plugin's hooks.json. Downstream consumers face the same half-closed-loop risk; silent-exit-on-no-AGENTS.md means consumers without it pay zero cost

The Q4a argument addresses consumers without AGENTS.md but not consumers with a *differently-shaped* AGENTS.md. Those consumers cannot tell from the outside whether the hook is doing its job.

### Why this matters

A hook that silently degrades for consumers who don't follow the plugin author's section schema is worse than no hook for those consumers — it consumes tokens, gives the appearance of compound learning being in place, and offers no diagnostic when it isn't. "Silent skip on unknown section" is reasonable for the plugin's own AGENTS.md (where the schema is controlled) and unreasonable for downstream consumer AGENTS.md (where it isn't).

## O6 — risk — medium

### Claim

Token cost framing assumes one emission per AGENTS.md change, but provides no analysis of teams that run many short sessions per day, particularly during a curation sprint that produces multiple AGENTS.md commits in a day. There is no upper bound on consumer-side cost in v0.32.0.

### Evidence

Risks section:

> Token cost surveyed but not measured. Estimate is ~2400 tokens per emission. If actual session telemetry shows higher (e.g., the hook emits on every session due to noisy AGENTS.md edits), revisit the recency model — possibly add a min-interval to the dismissal logic.

This explicitly defers cost analysis to post-shipping telemetry. There is no consumer-side configuration knob, no min-interval, no opt-out documentation in the v0.32.0 ship.

### Why this matters

Plugin updates affect every consumer who installs the plugin. A v0.32.0 minor bump that ships an unbounded token-cost mechanism with a "we'll measure it later" note transfers cost discovery to consumers. For a plugin promoted by a marketplace listing, this is a public commitment with no rollback short of a follow-up release.

## O7 — implementation — medium

### Claim

"Last 3 bullets per section" is presented as a recency proxy but rests on an undocumented convention that bullets are always appended at the end of a section. If a curator inserts a new bullet earlier (for thematic grouping or chronological re-ordering), the new bullet is invisible to the hook indefinitely.

### Evidence

Decisions Q3 rationale:

> empirically tracks "recently curated" because new entries are appended

This is asserted as observed behaviour but is not codified anywhere — not in CLAUDE.md, not in AGENTS.md curation guidance, not in the curation-nudge hook, not in any reference page. There is no mechanism that enforces append-only curation.

### Why this matters

The recency proxy degrades silently with curator behaviour. The spec's own non-goal — "This work does not redesign AGENTS.md format, sections, or curation flow" — means the hook depends on a convention it cannot enforce and that future curators may not know exists. This becomes a buried footgun in 6–12 months when a curator tries thematic ordering.

## O8 — specification quality — high

### Claim

The verification section's first test row says "All 4 sections populated" but the slice-extraction logic and systemMessage payload list 5 sections (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS). A reasonable implementer cannot tell whether TEST_STRATEGY is in scope, out of scope, or a typo.

### Evidence

Verification, Test surface — 12 cases, row 1:

> All 4 sections populated, ≥3 bullets each | Last 3 bullets per section emitted

Hook behaviour contract, Decision flow:

> Extract last 3 bullets per known section (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS).

Decisions Q3 also enumerates five sections. Token estimate uses "3 × 5 × 150" — explicitly five.

### Why this matters

This is the canonical specification-quality failure: a divergent count between the contract section and the test section. An engineer following the test table writes a 4-section hook; an engineer following the contract writes a 5-section hook. The objection record cannot be resolved without the spec author choosing.

## O9 — specification quality — high

### Claim

The slice-extraction algorithm is under-specified at multiple boundaries: behaviour when a section has fewer than 3 bullets (the formula `total − 3 + 1` is non-positive), whether indented or nested bullets count, output section ordering (file order vs canonical order), and how "lines inside HTML comments" is detected for multi-line comments.

### Evidence

Slice extraction logic, step 3:

> Find the line number of the (total − 3 + 1)th bullet start.

Step 2:

> identify every line beginning `- ` (bullet starts); ignore lines inside HTML comments

The Test surface row 4 ("DESIGN_DECISIONS has only 2 bullets | All 2 emitted") implies the formula must clamp to 1 — but that clamp is not stated in the algorithm. Indented bullets are not addressed; AGENTS.md does in fact contain bullets that are indented (see the existing AGENTS.md ARCH_DECISIONS continuation paragraphs). The systemMessage payload example shows sections in canonical order, but the spec does not say whether the implementation must always emit that order or follow the file's order.

### Why this matters

Each of these boundaries is a fork point where two reasonable engineers will produce different scripts. That is exactly what the specification-quality category exists to prevent. Catching it at spec time is cheaper than catching it in the code-mode diaboli pass.

## O10 — specification quality — medium

### Claim

The interaction between auto-dismiss (marker write) and the "zero bullets extracted" silent-exit branch is not specified. If the hash differs but extraction yields zero bullets, the spec does not say whether the marker is updated — and either choice has different consequences for the next session.

### Evidence

Decision flow:

> [Total bullets extracted equals 0?]
>     │ yes → exit 0 silently (file exists but is unpopulated)

The marker-write step is positioned at the bottom of the flow, after JSON emission. The spec does not state whether the zero-bullet branch passes through marker-write or short-circuits before it.

### Why this matters

If the marker is not updated, every subsequent session re-hashes, re-extracts, and re-skips — wasted work but not user-visible. If the marker is updated, the next session after the user actually populates the sections will silently miss the first emission. The implementer will guess; the test runner will codify whichever guess they made; the convention will be locked in by accident.

## O11 — alternatives — medium

### Claim

A materially simpler alternative — emit a small fixed nudge ("AGENTS.md changed since last session — re-read before proceeding") with no slice extraction — is not seriously evaluated. It eliminates the awk algorithm, the test surface, the section-name coupling, the recency-proxy debate, and the downstream silent-skip footgun in one move.

### Evidence

Decisions Q1 enumerates two alternatives — "Pure injection" and "pure nudge" — and rejects pure nudge with:

> recreates the original failure mode (relying on agent compliance with a nudge instead of a CLAUDE.md rule)

But the spec's own design (per O3) has the same compliance dependency. A "pure nudge with explicit re-read directive" is not the same as "a CLAUDE.md sentence" — it fires every change, it is hash-gated, and it is mechanically equivalent to the injection design in the dimension that matters (compliance). It was not given a fair hearing.

### Why this matters

The alternatives test is whether a meaningfully simpler approach exists that the spec does not acknowledge. A pure nudge is one-tenth the complexity (no awk, no fixtures, no 12-test runner, no 5-section coupling) and survives the same compliance critique the spec uses to reject it. If the simpler design is ruled out, the spec should explain why on the merits, not by mis-attributing the failure mode.

## O12 — scope — medium

### Claim

This work introduces the first executable tests in a project whose AGENTS.md TEST_STRATEGY says "no application code or test suite." Bumping the harness from "no tests" to "Tests must pass" is a project-wide convention change. The spec acknowledges this only as a parenthetical in Cross-references.

### Evidence

Cross-references section:

> HARNESS.md constraints touched: ... "Tests must pass" (currently unverified; this work introduces the first executable tests in the project)

The current AGENTS.md TEST_STRATEGY:

> This project has no application code or test suite. Content is validated by markdownlint (CI), ShellCheck, bash -n syntax checks, and gitleaks secret scanning. All validation is deterministic and runs in the harness CI workflow.

Adding `test-agents-md-readback.sh`, a `fixtures/` directory, and a CI test-runner job changes that strategy materially.

### Why this matters

A convention change of this scope deserves its own decision and its own AGENTS.md TEST_STRATEGY update. If it rides in on a hook PR, the next person looking at TEST_STRATEGY for guidance will find a stale statement and may not realise tests are now first-class. The compound-learning artefact (AGENTS.md TEST_STRATEGY) the spec is trying to enforce is itself made stale by the spec's own implementation.

## Explicitly not objecting to

- **The choice of SHA-256 for hashing.** The spec acknowledges the collision argument is not worth defending against and that is correct; a different hash would not change any structural property of the design.
- **The choice of `jq` for JSON encoding rather than manual `printf` escaping.** The spec's argument that arbitrary AGENTS.md content can contain JSON-active characters is sound, and the graceful degradation when `jq` is absent is reasonable for an advisory hook.
- **The version bump from 0.31.0 to 0.32.0.** Per the project's own semver rules a new hook is a behavioural change; minor-bump is the right call and does not need to be challenged.
- **The CHANGELOG and marketplace `plugin_version` sync items.** These are mechanical follow-ons from the version bump and are correctly enumerated; they do not warrant adversarial scrutiny.
- **The decision to put the test runner in `hooks/scripts/test/` rather than at the repo root.** Co-locating tests with the script under test is a reasonable convention and the placement does not affect the spec's correctness.
- **The CLAUDE.md placement of the new note ("after the existing 'Sync from Source' section").** Document layout is a linter-class concern outside this charter.
- **The non-goal of per-entry recency tracking.** The spec is explicit that hash-level granularity is deliberately chosen; that decision is well-argued and out of scope for an objection.
- **The 10-second hook timeout.** The script is O(file size) on a typically small file; the budget is generous and not worth challenging.
