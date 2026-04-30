---
spec: docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md
date: 2026-04-30
mode: spec
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The spec proposes archival machinery for a 457-line / 29-entry log that has not yet demonstrated the failure modes it describes; the premise rests on projected, not observed, harm."
    evidence: "\"At the time of writing the log is 457 lines / ~29 entries. Annualised growth at current cadence is roughly 100–200 entries / year.\" and \"Driving signal: User concern that REFLECTION_LOG.md will grow over time...\""
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: premise
    severity: high
    claim: "The 'signal-to-noise degradation' framing is asserted as the primary failure mode without evidence that current readers actually struggle to find signal — the alternative diagnosis (readers should read less, or filter at read time) is not considered."
    evidence: "\"Signal-to-noise degradation (primary). When an agent or command reads the log to look for recent learnings or recurring patterns, stale entries ... drown out fresh signal. The reader's attention is the bottleneck, not the tokens themselves.\" — no cited instance of a reader missing signal because of staleness is given."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: alternatives
    severity: high
    claim: "A materially simpler alternative — readers consume only the last N entries or the last M months by date filter — is not acknowledged, and would solve the signal-to-noise and per-read-cost goals without any new file, schema, GC rule, or migration."
    evidence: "The 'Reader updates' table modifies six agents and several commands to read both active and archive, but never considers teaching those readers to bound their own intake. The Approach overview goes directly to a two-path archival model with no comparison to read-side filtering."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: specification quality
    severity: high
    claim: "The 6-month Path 2 threshold is admitted to be a midpoint with no analysis, yet it is specified as a concrete value in the algorithm and the curation-debt metric — implementers will encode 6 months without knowing whether it is load-bearing or arbitrary."
    evidence: "Open question 1: \"Is 6 months the right Path 2 threshold, or should it be 3 / 12 months? (The design picks 6 as the middle.)\" combined with the Path 2 algorithm step 2: \"Filter to entries older than 6 months\"."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "The Path 2 recommendation logic is built on cross-reference techniques the spec itself flags as brittle (text overlap, semantic match against AGENTS.md), yet the design relies on those recommendations to drive curator attention monthly — a brittle signal driving a recurring action is a known training-into-acceptance failure mode."
    evidence: "Risk 4: \"Cross-reference logic in Path 2 is approximate. Pattern recurrence detection by text overlap is brittle; semantic match against AGENTS.md is even more so. Recommendations may be wrong.\" combined with Risk 2 acknowledging the same training-into-acceptance shape."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: risk
    severity: high
    claim: "The migration is described as 'an hour or two' but requires the curator to reconstruct, by inspection, which of 29 entries were promoted in the past — a task whose actual duration is unknown and whose deferral leaves the system stuck in a half-state where Path 2 keeps surfacing the same large report every month."
    evidence: "Migration step 2: \"Tags promoted entries with Promoted: <today's date> → AGENTS.md ... based on actual prior promotions (cross-referenced against current AGENTS.md).\" and Risk 1: \"Risk that curators defer it indefinitely.\""
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: risk
    severity: medium
    claim: "The design's safety asymmetry between Path 1 (auto) and Path 2 (human-gated) is presented as load-bearing, but Path 1's safety rests entirely on the curator never adding a Promoted line erroneously — and the spec gives no guard against an accidental or premature Promoted line being auto-archived on the next weekly run."
    evidence: "\"Path 1 — explicit promotion signal → auto-archive ... Auto-fix is safe because the signal is explicit.\" and Path 1 failure-mode list covers concurrent edits and malformed lines but does not cover a syntactically-valid Promoted line added in error."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: scope
    severity: medium
    claim: "The implementation scope touches at least eleven plugin files plus templates and a new script, for a feature whose driving artefact is 457 lines today — the scope/cost ratio is high enough that the change itself becomes a long-lived liability if adoption is silent."
    evidence: "The 'Implementation scope' section enumerates 14 distinct file changes including six agent definitions, three commands, two templates, a skill, a script, and a workflow — for a system whose current state is described as \"457 lines / ~29 entries\"."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: specification quality
    severity: medium
    claim: "The Promoted field's semantics are over-loaded: the same field encodes promotion (→ AGENTS.md), non-promotion (→ no promotion), aged-out closure, and supersedence — readers and the GC script must distinguish these by string parsing, but the spec does not give a grammar or a parser contract."
    evidence: "Schema change section lists five distinct right-hand sides for the Promoted field with no formal grammar; Path 1 Algorithm step 3 simply says \"For each entry that contains a Promoted field\" without specifying which right-hand sides trigger archival vs. which (if any) might not."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: alternatives
    severity: medium
    claim: "Encoding promotion state as 'one line of metadata appended at curation time' inside a markdown bullet is a fragile shape; YAML frontmatter per entry, a sidecar file, or a git-trailer convention would all be more parseable and less ambiguous, and none of these alternatives is acknowledged."
    evidence: "Schema change section: \"Each reflection entry gains an optional Promoted field, added by the curator at promotion time\" — example shown is a markdown list item. No comparison to frontmatter, sidecar, or trailer-based alternatives."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: specification quality
    severity: medium
    claim: "The spec says the active log 'is not loaded at session start' yet justifies the design partly on per-read cost compounding across thousands of installs — these two claims sit in tension because on-demand reads scale with adopter activity, not adopter count, and the spec does not quantify either."
    evidence: "Problem section: \"The log itself is not loaded at session start (no SessionStart hook reads it...)\" alongside failure mode 2: \"Per-read cost compounds across many adopters (secondary). The plugin is recommended to many users. Each adopter's project pays the same growing per-read cost. Aggregate token spend across thousands of installs is meaningful even when any single read is cheap.\""
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: risk
    severity: medium
    claim: "If adopters do not follow the curation discipline (don't add Promoted lines), Path 1 archives nothing, Path 2 surfaces an ever-growing report, and the system degrades to worse-than-status-quo (same long log plus monthly noise from the report) — graceful degradation is not specified."
    evidence: "The design assumes curator engagement: Path 1 fires only on Promoted entries; Path 2 produces reports the curator must act on. Failure mode \"Curator does not act on the report: entries remain in the active log. The same entries will be re-surfaced next month\" treats this as a feature, but at scale it is a worse signal-to-noise problem than the one being solved."
    disposition: pending
    disposition_rationale: null
---

## O1 — premise — high

### Claim

The spec proposes substantial machinery — two GC rules, a schema change, six agent updates, a new script, a new directory, a one-off migration, and a minor version bump — to address a problem whose current concrete state is 457 lines and 29 entries. The harms cited are projected from annualised growth (100–200/year) and from aggregate adopter-base costs that are not measured. The spec is solving a future problem at present-day cost.

### Evidence

> At the time of writing the log is **457 lines / ~29 entries**. Annualised growth at current cadence is roughly 100–200 entries / year.

And the driving signal:

> User concern that `REFLECTION_LOG.md` will grow over time, costing tokens at every read by the seven plugin agents and several commands that consume it

No cited episode of a reader having missed signal, of a token cost having been measurably painful, or of a curator having been overwhelmed.

### Why this matters

If the premise is "this will be a problem eventually", the right responses are (a) instrument the actual cost now, (b) define a numeric trigger ("when the log exceeds N lines or M entries, build archival"), and (c) implement archival when the trigger fires. Building it now risks the worst of both worlds: present-day cost paid, future fit unknown. The spec does not justify why now is the right time rather than later.

## O2 — premise — high

### Claim

"Signal-to-noise degradation" is asserted as the primary failure mode, but the spec gives no concrete instance of a reader (agent or command) failing to extract signal because of staleness. The alternative diagnosis — readers should bound their own intake (read the last N entries, or the last M months) — would address the same harm without any persistent state change.

### Evidence

> Signal-to-noise degradation (primary). When an agent or command reads the log to look for recent learnings or recurring patterns, stale entries — particularly entries whose learning has already been promoted to `AGENTS.md` and is reaching agents that way already — drown out fresh signal. The reader's attention is the bottleneck, not the tokens themselves.

This is the strongest failure mode by user emphasis, but it is asserted, not demonstrated. The spec does not cite a reflection-driven agent run that produced a worse output because of a stale entry.

### Why this matters

A premise objection invalidates everything downstream. If readers can be taught to filter at read time (a one-line change: "read the last 20 entries" or "read entries from the last 90 days"), the entire archival apparatus is unnecessary. The spec should either show a concrete failure of read-side filtering, or own the premise as speculative.

## O3 — alternatives — high

### Claim

A materially simpler approach — bound what each reader consumes, rather than persistently moving entries — is not considered. Readers could read the tail of the log (last N entries), or filter by `Date` field at read time, achieving the same goals (reduce signal-to-noise; bound per-read cost) without a new directory, a schema change, two GC rules, a script, a migration, or six agent updates.

### Evidence

The Reader updates table modifies six agents and several commands to read both active and archive:

> When auditing reflection-related claims in HARNESS.md Status, also consults the archive.

But never considers teaching those readers to bound their own intake. The Approach overview leaps directly to a two-path archival model:

> A two-path archival model that matches the safety profile of the signal driving the archival

with no acknowledgement of read-side filtering as a competing design.

### Why this matters

At spec time this is the right moment to ask whether a simpler approach exists. Read-side filtering is strictly cheaper to implement (no migration, no schema change, no new file, reversible at any time) and addresses the named goals directly. If the spec author rejected this alternative, the rejection should be in the spec; if they didn't consider it, that is a gap in design exploration.

## O4 — specification quality — high

### Claim

The 6-month threshold for Path 2 is acknowledged in the open questions as picked-because-it's-the-middle, yet it is specified as a concrete value in the algorithm and used as a curation-debt metric. An implementer reading this spec without reading the open-questions section would encode 6 months as a load-bearing value. The spec is internally inconsistent about whether 6 months is settled or open.

### Evidence

Path 2 Algorithm step 2:

> Filter to entries older than **6 months** (calculated from the `Date` field) that lack a `Promoted` field.

Implementation scope:

> `/superpowers-status`, `/harness-health`, `/harness-audit` — Report active-log count and archive-entry count separately, plus the count of unpromoted entries older than 6 months as a curation-debt metric.

Open questions:

> Is 6 months the right Path 2 threshold, or should it be 3 / 12 months? (The design picks 6 as the middle.)

### Why this matters

If 6 months is a placeholder, it should be flagged in the algorithm itself ("threshold = 6 months, currently a placeholder; see open question 1") and made configurable, not hardcoded into reports and metrics. As written, the threshold will end up in code, in the HARNESS template, in agent definitions, and in observability output before it is justified.

## O5 — implementation — high

### Claim

Path 2's recommendation logic is built on cross-reference techniques the spec itself flags as brittle. A monthly recurring report driven by brittle recommendations is a recipe for training the curator into reflexive acceptance — the very failure mode listed in Risk 2. The combination of Risk 2 and Risk 4 describes a structural flaw, not two separate concerns to mitigate.

### Evidence

Risk 4:

> Cross-reference logic in Path 2 is approximate. Pattern recurrence detection by text overlap is brittle; semantic match against AGENTS.md is even more so. Recommendations may be wrong.

Risk 2:

> If the agent's PROMOTE / SUPERSEDE / AGED-OUT calls are accepted reflexively rather than scrutinised, the agent becomes a single point of failure for what enters AGENTS.md.

The mitigation given for Risk 2 — "the curator must take an explicit action (edit AGENTS.md, then add Promoted line)" — does not address reflexive acceptance, because reflexive acceptance is precisely the case where the curator does take the explicit action without scrutiny.

### Why this matters

The whole point of Path 2 being human-gated is that brittle signals shouldn't drive automatic actions. But if the design produces a monthly report of pre-classified recommendations, the path of least curator resistance is to accept them. The spec needs either (a) a confidence threshold below which recommendations are not surfaced, (b) a deliberate friction step (e.g., the agent gives evidence, not a label), or (c) acknowledgement that the agent's labels will, in practice, become decisions.

## O6 — risk — high

### Claim

The migration is sized at "an hour or two" but the actual task — reconstructing which of 29 historical entries were promoted in the past, by cross-referencing each against current AGENTS.md and HARNESS.md — is uncertain in duration and high in cognitive load. The spec admits the risk of indefinite deferral but its mitigation (Path 2 keeps surfacing the same report) is the same dynamic that creates "the unstarted spring cleaning" pattern.

### Evidence

Migration step 2:

> Tags promoted entries with `Promoted: <today's date> → AGENTS.md ...` based on actual prior promotions (cross-referenced against current `AGENTS.md`).

> The migration naturally fits as part of the next monthly review and should take an hour or two of curator time.

Risk 1:

> The one-off tagging of 29 entries is an hour or two of work that has to happen before the system steady-states. Risk that curators defer it indefinitely. Mitigation: the Path 2 monthly run will keep producing the same report until tagged, providing a recurring forcing function.

### Why this matters

A recurring report of the same 29 unactioned items every month is not a forcing function — it is the standard shape of a project debt that ages without action. Until the migration is done, Path 2's signal value is zero (every entry is a candidate). The spec should either (a) ship a migration tool to reduce the cognitive load (open question 5 raises this and rejects it), (b) define a hard deadline beyond which Path 1 widens its scope, or (c) accept that adoption may stall at the migration step and design for that case.

## O7 — risk — medium

### Claim

Path 1's safety claim — "auto-fix is safe because the signal is explicit" — assumes the curator never adds a syntactically-valid Promoted line in error. The failure-mode list covers concurrent edits and malformed lines but not the case of a Promoted line added prematurely or to the wrong entry, which the next weekly run will silently archive.

### Evidence

> Path 1 — explicit promotion signal → auto-archive ... Auto-fix is safe because the signal is explicit.

Failure modes for Path 1:

> Concurrent edit during the GC run ... Malformed Promoted line ... Archive file write failure

No mention of "valid Promoted line, but wrongly applied".

### Why this matters

A weekly auto-archive that runs unattended on any entry tagged with a parseable Promoted line means a curator typo (wrong entry tagged, tag added before the AGENTS.md edit was actually committed) is irreversible without a git revert. The spec relies on the atomic-commit discipline ("The curator adds it in the same commit as the AGENTS.md / HARNESS.md edit") but does not enforce or verify it. A pre-archive check that the referenced AGENTS.md/HARNESS.md content actually exists in the current tree would be a cheap guard.

## O8 — scope — medium

### Claim

The implementation scope touches fourteen distinct file types — six agent definitions, three commands, two templates, a skill, a script, a workflow, plus the live HARNESS.md and REFLECTION_LOG.md — for a feature whose driving artefact is 457 lines today. The scope/value ratio is questionable, and the cost of carrying the new conventions forward (in adopter projects, in onboarding documentation, in agent prompts) is unbounded.

### Evidence

Implementation scope section enumerates: harness-gc, harness-auditor, assessor, governance-auditor, choice-cartographer, integration-agent agents; HARNESS.md template, REFLECTION_LOG.md template (or CLAUDE.md), CLAUDE.md template; reflect, superpowers-status, harness-health, harness-audit commands; garbage-collection skill; new shell script; gc.yml workflow; this repo's REFLECTION_LOG.md (migration); this repo's HARNESS.md; new reflections/archive/2026.md.

### Why this matters

Every adopter who pulls a new plugin version inherits the new conventions. If archival proves not to be needed (per O1), or if the schema choice proves wrong (per O10), the plugin will need to remove or migrate the convention from every file it touched. Spec scope at this size deserves a stronger premise than "the log will grow".

## O9 — specification quality — medium

### Claim

The Promoted field is overloaded with five distinct semantic right-hand sides (AGENTS.md promotion, HARNESS.md promotion, no-promotion-but-closed, aged-out, superseded). Path 1's algorithm simply checks "contains a Promoted field" without specifying which right-hand sides should trigger archival, and there is no grammar an implementer can use to distinguish them at parse time.

### Evidence

Schema change section lists:

> - `→ HARNESS.md: <constraint name>`
> - `→ no promotion (single-instance learning)`
> - `→ aged-out, no promotion warranted`
> - `→ superseded by <reflection-date>`

Path 1 Algorithm step 3:

> For each entry that contains a `Promoted` field

No grammar; no statement of whether all five forms trigger archival or only some.

### Why this matters

Two implementers will produce two different parsers. One will key on the literal string "Promoted"; another will key on " → " separator; another will try to distinguish "→ no promotion" from "→ AGENTS.md ...". The spec needs either (a) a regex/grammar for the field, (b) an explicit statement that all parseable Promoted lines trigger archival regardless of right-hand side, or (c) a structured (e.g., enum-typed) form rather than free text.

## O10 — alternatives — medium

### Claim

The Promoted field's chosen shape — a markdown bullet line appended inside the entry — is fragile to parse, fragile to edit, and easy to typo. Alternatives exist (per-entry YAML frontmatter, a sidecar `reflections/promotions.yaml` file, git-trailer-style annotation in commit messages) and none is acknowledged.

### Evidence

Schema change:

> Each reflection entry gains an **optional** `Promoted` field, added by the curator at promotion time:
>
> ```markdown
> - **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
> ```

No comparison to frontmatter, sidecar, or trailer alternatives.

### Why this matters

Spec time is the right moment to interrogate format choices. A sidecar file would (a) keep REFLECTION_LOG.md untouched, eliminating the migration burden of editing each entry, (b) be trivially parseable without splitting on `---`, (c) make promotion state queryable independent of the log format. Frontmatter would similarly avoid free-text right-hand sides. The spec author may have chosen markdown bullets deliberately for grep-ability, but that rationale is not given.

## O11 — specification quality — medium

### Claim

The spec asserts both that the log is "not loaded at session start" and that "per-read cost compounds across many adopters (secondary)" with "thousands of installs". These claims are not contradictory but they are unquantified, and the spec uses the latter to justify cost while admitting the former dampens it sharply.

### Evidence

Problem section:

> The log itself is **not** loaded at session start (no `SessionStart` hook reads it; no priming convention requires it), but it **is** read on-demand by [seven agents and several commands].

> Per-read cost compounds across many adopters (secondary). The plugin is recommended to many users. Each adopter's project pays the same growing per-read cost. Aggregate token spend across thousands of installs is meaningful even when any single read is cheap.

### Why this matters

If reads are on-demand, the relevant cost driver is reader-activity-per-adopter, not adopter count. An adopter who never invokes the seven agents or several commands pays zero extra cost. The spec needs at minimum an order-of-magnitude estimate of how often readers actually touch the log per adopter per month, otherwise the "thousands of installs" framing is rhetorical rather than load-bearing. As written, an implementer cannot tell whether the cost concern is real or notional.

## O12 — risk — medium

### Claim

The design assumes adopters follow the curation discipline (Promoted lines added at promotion time; monthly aged-out report acted on). If they do not, Path 1 archives nothing, Path 2 surfaces a permanently growing report, and the adopter ends up with the original long log plus a monthly observability artefact that itself becomes noise. The spec does not specify graceful degradation for the disengaged-curator case.

### Evidence

Path 2 failure modes:

> Curator does not act on the report: entries remain in the active log. The same entries will be re-surfaced next month, giving the system a recurring forcing function rather than a one-shot.

The "Steady-state expectation" section:

> After one full quarterly cycle following migration: Active log: 10–20 entries

assumes a fully-engaged curator following the discipline. No alternate steady state is described.

### Why this matters

An adopter who installs the plugin but doesn't have an active curator gets a worse outcome than today: same long log, plus monthly machinery generating reports nobody reads. The plugin's broad reach (cited as motivation) means most adopters will be in this state. Graceful degradation should be a first-class design property: at minimum, define what the system looks like for an adopter who never adds a Promoted line, and ensure that state is no worse than today.

## Explicitly not objecting to

- **The annual-vs-quarterly archive granularity choice**: the spec gives a coherent rationale (file count manageable, date-windowed grep still works) and the choice does not create a failure mode worth surfacing here — it is a Cartographer-shaped decision, not a diaboli-shaped one.
- **The decision to preserve full-fidelity entries in the archive rather than summarise**: this aligns with the "don't lose history" non-goal and is a defensible default; objecting to it would be bikeshedding.
- **The append-via-PR constraint being preserved**: the dispatcher explicitly excluded this from scope, and the spec correctly leaves the existing constraint untouched.
- **The chronological-by-archive-timestamp ordering inside archive files**: the spec gives a sound rationale (avoids re-write conflicts) and the consequence (out-of-original-date order inside the archive) is named and accepted.
- **The plugin-version-bump from 0.31.1 to 0.32.0**: this follows the project's documented semver convention for behavioural changes and adding GC rules; nothing to challenge.
- **The two-path naming and conceptual split**: separating explicit-signal auto-archive from absence-of-signal human review is a defensible structure regardless of the brittleness of the Path 2 implementation (which is captured in O5); the conceptual split itself is reasonable.
- **The choice not to introduce a UI/dashboard**: file-based and command-driven matches plugin convention; objecting would be inventing scope.
