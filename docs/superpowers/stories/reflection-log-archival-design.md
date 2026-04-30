---
spec: docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md
date: 2026-04-30
mode: spec
cartographer_model: claude-opus-4-7[1m]
stories:
  - id: S1
    lens: [forces, alternatives]
    title: Bounded read uses union, not intersection
    disposition: pending
    disposition_rationale: null
  - id: S2
    lens: [defaults, coherence]
    title: Per-reader policy decided in one table
    disposition: pending
    disposition_rationale: null
  - id: S3
    lens: [coherence, forces]
    title: Curator is one person, not a team
    disposition: pending
    disposition_rationale: null
  - id: S4
    lens: [alternatives, consequences]
    title: Path 1 runs weekly, not monthly
    disposition: pending
    disposition_rationale: null
  - id: S5
    lens: [patterns]
    title: Evidence triple as the friction shape
    disposition: pending
    disposition_rationale: null
  - id: S6
    lens: [patterns, consequences]
    title: Migration proposals file as durable record
    disposition: pending
    disposition_rationale: null
  - id: S7
    lens: [coherence]
    title: Two clocks inside the archive
    disposition: pending
    disposition_rationale: null
  - id: S8
    lens: [defaults, patterns]
    title: HARNESS.md is the only config surface
    disposition: pending
    disposition_rationale: null
  - id: S9
    lens: [coherence, forces]
    title: Active log demoted to a working file
    disposition: pending
    disposition_rationale: null
---

## S1 — Bounded read uses union, not intersection

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Read-side filtering — Default bounded read)
**Lens:** forces, alternatives
**Refs:** O3

**Context.** When the diaboli's O3 was accepted, read-side filtering was introduced as a peer to archival. The chosen default is "the more inclusive of the last 50 entries OR entries dated within the last 90 days" — a union, not an intersection. Whichever of the two yields more entries wins.

**Forces.** Recall vs. precision in bounded reads. A high-cadence project (say, 100+ reflections per quarter) has 50 entries that span weeks — the day-window is the tighter bound. A low-cadence project has 90 days that may yield only 5 entries — the count bound is the tighter floor. The union shape says: when in doubt, prefer to surface more, on the assumption that under-recall (a stale entry quietly dropped from view) is a worse failure than over-cost (a few extra entries in context).

**Options not taken.**

- *Intersection*: "the last 50 entries AND within 90 days." This would give a tighter cost cap but creates the surprise where a low-cadence project sees an empty bounded read for weeks at a time.
- *Project-adaptive bounds*: read entry-count and recency from project history and pick the cap that matches typical reader needs. More work, more accurate; rejected silently.
- *Reader-specific bounds*: each reader picks its own union/intersection. The spec rejects this in S2 by hardcoding the same default everywhere.

**Choice as written.** The spec picks the union, with the rationale "for projects with the typical ~15-25 entries/year cadence, the bounded read covers everything; for higher-cadence projects, the bound clips to recent state where the active signal lives." That rationale leans on the typical case being low-cadence, which is true for the source repo today but not necessarily true for downstream adopters.

**Consequences.** A high-cadence adopter sees a smaller window than 50 entries (90 days clips); a low-cadence adopter pays cost proportional to their full active log up to 50 entries. The cap is asymmetric: cheap for slow projects, less cheap for fast ones. The bound is also static — there is no feedback loop adjusting it based on whether readers are actually finding signal in the unbounded portion.

**Pattern.** Resembles a *recall-favouring filter*. The closest named cousin is the "include-on-doubt" pattern in retrieval systems (e.g., Elasticsearch's `should` clauses scoring rather than gating). No formal citation — name your suspicion.

**Notes.** The "wanting more entries is a deliberate signal" framing is load-bearing for this choice — if opt-in is cheap and well-understood, the default can lean conservative; if opt-in is friction, the default has to be generous. The spec does not measure how often readers will opt-in.

## S2 — Per-reader policy decided in one table

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Read-side filtering — Per-reader policy)
**Lens:** defaults, coherence
**Refs:** S1

**Context.** A 14-row table assigns each reader (agents, hooks, commands) one of: bounded, full active, full active + archive, or n/a. The choices are made unilaterally in the spec, with one-sentence rationales per row.

**Forces.** Recent-state utility vs. cross-time pattern detection. A health snapshot (`/superpowers-status`, `/harness-health`) only needs recent state. A pattern-detective (governance auditor, assessor, regression detection) needs the long arc. The table sorts each reader into the bin that matches its dominant use, accepting that any single reader has multiple uses and the dominant-use heuristic will sometimes mislabel.

**Options not taken.**

- *Reader-asks-at-call-time*: every invocation declares its own bound; no default per reader. More flexible, more cognitive load, more drift between agents.
- *Two-tier policy*: bounded vs. unbounded only, with no "full active vs full active + archive" distinction. Simpler; loses the (genuine) cost difference between reading the active log only and reading active + archive.
- *Workload-shaped*: bounded by default *for everyone*, with each reader stating in its prompt what triggers an opt-in to unbounded. This shifts the policy into the agent prompts themselves rather than this central table. The spec implicitly chose central-table over distributed-prompt.

**Choice as written.** Central table; one row per reader; one bin per reader. Cartographer's own row is "bounded by default; full-with-archive when assessing decision continuity across long arcs" — note the spec is making a decision *about this very agent* without the agent's input, which is a defensible authorial move but worth surfacing.

**Consequences.** When a new reader is added (e.g., a future agent), someone has to remember to add it to this table or it gets the default-of-no-default. The table becomes a coordination point that can drift from reader behaviour silently. Future-proofing this would mean either policy-as-default-in-prompt (each agent's prompt states its bound) or runtime-discoverable (each agent declares its bound at call-site).

**Pattern.** Closest to *Configuration Catalog* — a single document mapping consumers to policy. Common in policy-as-data systems (e.g., Kubernetes RBAC role bindings); has the same drift hazard.

## S3 — Curator is one person, not a team

**Source:** Spec passim (Path 2 curator workflow; Migration steps; Curator burden in steady-state)
**Lens:** coherence, forces
**Refs:** —

**Context.** Throughout the spec, "the curator" is referenced as a singular role: "the curator adds it in the same commit", "the curator interprets the evidence", "the curator runs the migration script once, reviews proposals, applies confirmed tags." There is no model for multi-person curation, no concurrency story for two curators tagging in parallel, no role-handoff convention.

**Forces.** Plugin reach vs. role assumptions. The plugin is positioned for broad adopter use (per the dropped O11 framing), and downstream adopter projects could plausibly have multiple humans curating reflections. The spec resolves this tension by silently assuming away — curation is a single-actor activity, and concurrency is handled at the git layer ("rebase-and-retry on conflict").

**Options not taken.**

- *Curator-as-team*: a `curators:` field in HARNESS.md with multiple identities; assignment per entry; aged-out reports routed by area of expertise. Heavier; matches plugin's general "constraints declared in HARNESS.md" pattern.
- *Curator-as-rotation*: monthly rotation among committers; the aged-out report goes to whoever holds the role this month. Lighter weight than team; still surfaces multi-person reality.
- *No model at all (status quo)*: assume single curator; let teams that need multi-curator adapt locally. This is what the spec chose, by silence.

**Choice as written.** The spec chose by silence. There is no curator-multiplicity model; curator is a singleton in every reference.

**Consequences.** A team adopting the plugin where two people share curation duties has to invent the convention themselves (who tags which Promoted line; what happens when two curators independently tag the same entry; whose monthly review is authoritative). The plugin's silence forces local invention. If the plugin later wants to support team curation, the existing wording across HARNESS template, CLAUDE template, agent prompts, and skill docs all need editing — a coordinated change.

**Pattern.** *Single-Threaded Owner* (informal). Common in personal-tool design and risky in shared-tool design. Worth naming as a known shape.

## S4 — Path 1 runs weekly, not monthly

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Path 1 Specification; Remaining open questions §1)
**Lens:** alternatives, consequences
**Refs:** —

**Context.** Path 1's frequency is set to weekly. The Remaining open questions section flags "Should Path 1 run weekly or monthly?" and answers in the same breath: "Weekly is more responsive; monthly batches more. The design picks weekly."

**Forces.** Responsiveness vs. git history density. Weekly archival means a Promoted line added on Tuesday is acted on within seven days, keeping the active log close to its steady state. Monthly archival batches multiple promotions into one chore commit, reducing churn but lengthening the window during which the active log carries entries that are already conceptually retired. The spec also notes Risk 4: "~1 commit/week of archival churn. Acceptable" — weekly was chosen knowing it adds commits.

**Options not taken.**

- *Monthly Path 1*: aligns with the existing monthly Path 2 cadence; single review block per month covers both. Cheaper on git history; slower steady-state convergence.
- *Triggered Path 1*: archive runs whenever a Promoted line is committed (post-merge hook). Most responsive; adds tooling complexity and a new failure mode (hook didn't fire).
- *Weekly + monthly combined*: Path 1 weekly for archival; aligned with Path 2's monthly review for visibility. Close to chosen design but with explicit cadence coupling.

**Choice as written.** Weekly, deterministic, via existing `gc.yml`. The choice is made and the open question is left in the spec as a record of the decision-not-fully-justified.

**Consequences.** Weekly chore commits become part of the project's git history at ~52/year per active project. Adopters reviewing PRs see archival churn in their queue regularly. If batching becomes more important than responsiveness later (e.g., some adopter complains about commit noise), the cadence is HARNESS-tunable in principle but not currently surfaced as a configurable in the Configuration table — it's hardcoded in the GC rule definition.

**Pattern.** *Pull-based scheduled cleanup* (cf. cron-based GC in package managers). Trade-off is well-understood: tight loop vs. batched.

## S5 — Evidence triple as the friction shape

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Path 2 — Algorithm step 3; "Why evidence, not pre-classified labels")
**Lens:** patterns
**Refs:** O5

**Context.** O5's adjudication chose "evidence not labels" to defuse the training-into-acceptance dynamic. The implicit follow-on choice: *what does evidence look like?* The spec answers with three specific evidence types — recurrence counts (newer entries with overlapping Signal + keywords), AGENTS.md/HARNESS.md text-overlap matches with quoted excerpts, and the single-instance signal ("no newer entry shares this pattern").

**Forces.** Friction-by-design vs. usability. Evidence has to be informative enough that the curator can act on it, but not so structured that it becomes a label-in-disguise. Three signal types are enough to be actionable; not so many that the curator skims. The tension: if evidence is too thin, curator falls back to instinct (no friction added); if evidence is too rich and pre-shaped, curator pattern-matches it as a recommendation (friction defeated).

**Options not taken.**

- *Single-signal evidence* (e.g., recurrence count only). Lighter; risks under-informing the curator on entries with no recurrence.
- *Embedding-similarity evidence*: vector cosine to AGENTS.md sections. Richer signal; introduces ML opacity — curator can't sanity-check the underlying matches the way they can with quoted excerpts.
- *Curator-defined evidence patterns*: each project declares what evidence it wants. Most flexible; most cognitive cost; not all curators have a strong prior on what evidence helps them.

**Choice as written.** Recurrence count + text-overlap with quoted excerpts + single-instance signal. The "with quoted excerpts" piece is doing critical work — it makes the evidence sanity-checkable, which is what keeps it from becoming a label.

**Consequences.** Two assumptions are now load-bearing for Path 2's value: (a) text overlap is a meaningful proxy for "same learning" (acknowledged as brittle in Risk 3), and (b) the curator will read the quoted excerpts rather than pattern-matching the count. If either fails, Path 2 collapses back into the labelled-recommendations failure mode O5 was meant to prevent — but in a more disguised form.

**Pattern.** *Justification before classification* — a known shape in expert-system design (see Buchanan & Shortliffe, *Rule-Based Expert Systems*, 1984: explanation chains shown to the user, not just conclusions). Worth naming so that future iterations don't quietly swap in a "summary classification" field.

## S6 — Migration proposals file as durable record

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Migration helper script; Migration steps)
**Lens:** patterns, consequences
**Refs:** O6

**Context.** The migration helper script writes proposals to `reflections/migration-proposals.md`. The spec specifies: "The proposals file is committed alongside as a record of the migration decisions" and "the proposals file remains in `reflections/migration-proposals.md` as a permanent record of the migration's decisions, then is ignored by future runs (the script self-detects and skips if the file already exists)."

**Forces.** Auditability vs. directory cruft. Keeping the proposals file as a permanent artefact creates a durable record of what the curator was shown and what they decided — useful for future-Russ asking "why did entry X get tagged the way it did in 2026?". Removing it after use would keep the directory clean but lose the audit trail.

**Options not taken.**

- *Ephemeral working file*: deleted after migration; decisions live in git history of REFLECTION_LOG.md. Cleaner directory; relies on git archaeology to reconstruct migration intent.
- *Append to the archive entries themselves*: bake the proposal into each archived entry's `Archived` line ("from migration proposal: likely-promoted to AGENTS.md GOTCHA"). Co-locates audit with entry; complicates the archive format.
- *Stored in observability/*: a one-off observability artefact alongside other reports. Treats the migration as a monitoring event; shifts the file to a directory whose purpose is more transient.

**Choice as written.** Permanent file in `reflections/`. The script self-detects and skips on re-run. This makes the migration a one-shot event with a permanent receipt.

**Consequences.** The file persists for the life of the project, taking on the same long-lived character as REFLECTION_LOG.md and the archive. If the migration ever needs to be re-run (e.g., some entries weren't tagged on the first pass), the script's self-skip is a guard that needs deliberate override. The convention also suggests that future migrations of other artefacts (CHANGELOG archival, etc., per Success criteria) would establish their own permanent proposal files — directory accretion.

**Pattern.** *Decision audit trail* — the same shape as ADRs but for a one-off operation rather than a recurring decision. The proposals file is effectively an ADR for the migration, kept in-line with the artefact it migrated. Worth naming so future similar migrations follow the same shape rather than each inventing locally.

## S7 — Two clocks inside the archive

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Archive location and format — append order)
**Lens:** coherence
**Refs:** —

**Context.** The archive uses *original-year* to choose which file an entry goes into ("Determine the entry's original year from the Date field. Append the entry to `reflections/archive/<YYYY>.md`"), but uses *archive timestamp* to determine append order within the file ("entries are appended in the order they're archived, NOT re-sorted by original date"). Two different clocks govern two different aspects of the same write.

**Forces.** Query ergonomics vs. write atomicity. Splitting by original year keeps temporal queries clean — "show me all 2026 reflections" reads one file. Ordering by archive timestamp avoids re-write conflicts on every insertion (no need to re-sort on append). The spec resolves both concerns by accepting the inconsistency: file-selection clock and within-file-order clock are deliberately different.

**Options not taken.**

- *One clock, both decisions*: split AND order by archive timestamp. The 2026.md file would contain entries archived in 2026 regardless of original date. Simpler model; loses the "all 2026 reflections in one place" property when an entry from 2026 is archived in 2027.
- *One clock, both decisions, original-date version*: split AND order by original date. Re-sorts on every append (or accepts append-out-of-order). More expensive write; cleaner read.
- *Index file*: a sidecar `reflections/archive/INDEX.md` mapping original-date → archive file. Adds a coordination point; lets both files be append-only by archive timestamp.

**Choice as written.** Two clocks, with the asymmetry implicit. The spec mentions both decisions in adjacent paragraphs but does not surface the inconsistency as a tension that was resolved.

**Consequences.** A reader scanning `reflections/archive/2026.md` sees entries dated within 2026, but in non-chronological order with respect to the entries' own Date field. Date-based queries within a year are not "first match wins" — they may need to read the whole file. Cross-year archival (entry written in 2026, archived in 2027) is handled correctly (goes to 2026.md), so the file naming convention is robust; the cost is paid in within-file ordering only.

**Pattern.** Resembles *bi-temporal modelling* (Snodgrass, *Developing Time-Oriented Database Applications*, 1999) — two time axes, valid-time and transaction-time, treated separately. The archive uses original-Date as valid-time and archive-timestamp as transaction-time. Worth naming because most readers will expect a single chronological order and be briefly surprised.

## S8 — HARNESS.md is the only config surface

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Configuration section)
**Lens:** defaults, patterns
**Refs:** —

**Context.** Three tunables are exposed: Path 2 age threshold, read-side entry count, read-side day window. All three are declared in HARNESS.md (or "CLAUDE.md if more appropriate" for one). No environment variables, no CLI flags, no per-invocation overrides.

**Forces.** Config locality vs. config flexibility. HARNESS.md as the single config surface keeps configuration co-located with the harness constraints those tunables interact with — the curator who adjusts the Path 2 threshold is the same person who reads the GC rule that uses it. Multiple config surfaces would make tuning more flexible (a one-off audit could pass `--threshold 12mo` without committing) but would split the source of truth.

**Options not taken.**

- *CLI override on top of HARNESS default*: each script accepts flags that override HARNESS values. Enables one-off use without commits; doubles the contract surface.
- *Environment variables*: same as CLI but ambient. The plugin uses few env vars today; adding them for these tunables would set a precedent.
- *Per-reader config in agent prompt*: the bounded-read defaults live in each agent's prompt rather than a central HARNESS table. More distributed; harder to tune project-wide.

**Choice as written.** HARNESS.md only. The spec inherits the plugin's broader convention that durable project-shape decisions live in HARNESS.md and ephemeral overrides are not first-class.

**Consequences.** Tuning requires a commit to HARNESS.md, which is the right friction for a permanent change but the wrong friction for a one-off ("let me audit historical claims with a wider window for this PR"). The "explicit opt-in for full-history reads when historical patterns are needed" mechanism partially compensates, but it's a binary (bounded vs full) rather than a tunable. Future use cases that want a different bound for a single invocation will need to re-open this choice.

**Pattern.** *Single Source of Truth* applied to configuration; specifically the *Constraints-as-Configuration* shape the plugin uses elsewhere (HARNESS constraints govern agent behaviour, GC rules, audit scope). Inherited default; consistent with plugin philosophy.

## S9 — Active log demoted to a working file

**Source:** `docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md` (Steady-state expectation; What this design does NOT do)
**Lens:** coherence, forces
**Refs:** S6, S7

**Context.** The Steady-state expectation section states: "The active log becomes a **working file** rather than a permanent record. The permanent record lives in the archive." This is a substantial conceptual reframing of REFLECTION_LOG.md's role — it had previously been the permanent ledger of compound learning. After this spec lands, it becomes a holding pen for entries between authoring and disposition.

**Forces.** Stability of long-lived artefacts vs. signal-to-noise. The original REFLECTION_LOG.md was an append-only ledger — its value derived from its completeness. The new design splits that role: the active log holds in-flight entries (transient, working), the archive holds disposed entries (permanent, ledger). The reframing is necessary for the spec's other choices (read-side filtering, bounded steady state) to cohere — but the reframing itself is not held up as a load-bearing decision in its own right.

**Options not taken.**

- *Active log remains the ledger; archive is a cache*: the active log keeps every entry forever, the archive is an optimisation for readers. Inverts the polarity of "where does the canonical record live?"
- *No reframing; archive is a sibling*: both files are permanent records, just separated by lifecycle stage. Avoids the "working file" framing entirely.
- *Working-file-from-day-one*: declare from inception that REFLECTION_LOG.md is ephemeral and entries always migrate. This is what the spec is retrofitting onto existing semantics.

**Choice as written.** Working file vs. permanent record is the reframing the spec lands on. The "permanent record lives in the archive" language is one sentence; everything else in the spec (curation cadence, steady-state expectation, success criteria of "fewer than 25 entries") is downstream of this reframing.

**Consequences.** Anywhere the plugin's existing documentation refers to REFLECTION_LOG.md as the canonical reflection record, the wording is now wrong — those docs need to be reviewed and reworded as part of this spec's implementation, even if no behavioural change is needed. The mental model shift is the piece most likely to cause confusion for downstream adopters: an adopter who has internalised "the reflection log is the record of what we learned" now has to relocate that record to the archive directory. Onboarding documentation becomes more important, not less.

**Pattern.** *Hot/Cold split* — common in storage-tiering and log-archival systems (e.g., Elasticsearch's hot/warm/cold node tiers; Kafka's tiered storage). Naming the pattern compresses the cognitive cost of explaining the new model: "REFLECTION_LOG.md is the hot tier, archive/ is the cold tier."

## Material decisions intentionally not surfaced

The following decisions were considered as candidates but dropped, with rationale per the Routing Rule and selectivity protocol:

- **Annual vs. quarterly archive granularity.** The spec gives a coherent rationale (file count manageable, date-windowed grep still works); the diaboli's record explicitly notes this is a Cartographer-shaped decision, but the rationale is already articulated in-spec. Surfacing it would repeat the spec back to itself.

- **Markdown bullet vs. frontmatter/sidecar/git-trailer for the Promoted field.** Adjudicated under O10 (rejected); spec now contains an explicit "Why this shape, not frontmatter or sidecar" section. Re-surfacing would duplicate diaboli content.

- **6-month default for Path 2 threshold.** Adjudicated under O4 (accepted into Configuration). The default is now a tunable; surfacing it as a story would re-litigate the adjudication.

- **Whether the archive should be auto-archived after 12 months even without Promoted (Open question 3).** The spec answers this in the negative with rationale ("preserves human judgement; opt-in degradation property removes the unbounded-growth risk"). The decision is named and justified in-spec.

- **Pre-archive verification using grep rather than structural matching.** Considered as a "defaults" story (chose substring search over heading-anchor matching). Dropped because the choice's failure mode (false negatives on paraphrased AGENTS.md text) is already named in Risk 5 and handled with skip-and-warn. Mostly diaboli-shaped, and the diaboli already adjudicated O7 around exactly this verification step.

- **Plugin-version bump 0.31.1 → 0.32.0.** Mechanical follow-through from CLAUDE.md's semver discipline; no choice to surface.

- **Bounded readers don't signal that their read was bounded.** Considered as a "consequences" story but the consequence is failure-shaped (silent truncation could hide signal). Belongs in the diaboli record if anywhere; not raised in the existing record, but at this stage that gap is for the next adversarial pass to catch, not for the cartographer to backfill.
