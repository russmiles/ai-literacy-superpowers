---
spec: docs/superpowers/specs/2026-04-19-diaboli-observability.md
date: 2026-04-19
diaboli_model: claude-sonnet-4-6
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "The median-days-spec-to-disposition metric uses git log on the objection file to find the resolution date, but objection files are overwritten on regeneration, making git log an unreliable proxy for disposition date."
    evidence: "Spec Metrics table: 'Median days spec-to-disposition — Spec date from filename; resolution date from git log on objection file; median across fully-resolved records.' diaboli.md step 4: 'If a file already exists at that path, overwrite it. Warn the user that any prior dispositions are replaced and they will need to re-adjudicate.'"
    disposition: leave
    disposition_rationale: we are not trying to police dispositions.
  - id: O2
    category: implementation
    severity: high
    claim: "The 'Specs without a record' metric will immediately surface 27+ missing records because pre-diaboli specs are included in the count with no filtering mechanism defined, making the metric misleading from day one."
    evidence: "Spec Metrics table: 'Specs without a record — Spec slugs with no matching objection file — slug comparison.' There are 28 files in docs/superpowers/specs/ and only 1 objection record, but at least 27 of those specs predate the advocatus-diaboli feature and were never intended to have objection records. The spec defines no start-date or exclusion mechanism."
    disposition: fix
    disposition_rationale: we must include an exclusion mechanism for existing specs.
  - id: O3
    category: specification quality
    severity: high
    claim: "harness-health.md step 7 hardcodes 'All 12 section headings' in its validation check, but inserting Diaboli as a new section would make 13 sections; the spec does not call out updating this count."
    evidence: "harness-health.md step 7: 'All 12 section headings present in order: Enforcement, Enforcement Loop History, Garbage Collection, Mutation Testing, Compound Learning, Session Quality, Operational Cadence, Cost Indicators, Regression Indicators, Meta, Changes Since Last Snapshot, Trends.' Spec artefact #4 modifies harness-health.md to 'add Diaboli to required section list and section order' but does not mention updating the hardcoded '12' count or the enumerated list in the validation step."
    disposition: fix
    disposition_rationale: adjust this count.
  - id: O4
    category: risk
    severity: medium
    claim: "The Diaboli summary line in /superpowers-status uses a non-standard status format ([ACTIVE — N records] / [NO DATA]) that breaks the OK/WARNING/MISSING uniformity relied on by any consumer or CI check that parses the status dashboard."
    evidence: "Spec: 'The summary line shows Diaboli [ACTIVE — N records] or [NO DATA] — explicitly not OK/WARNING/MISSING, since we have no threshold yet.' superpowers-status.md output format: all six existing sections emit exactly one of OK/WARNING/MISSING in square brackets."
    disposition: fix
    disposition_rationale: this needs to work well with CI
  - id: O5
    category: specification quality
    severity: medium
    claim: "The 'Disposition rate' metric definition is ambiguous: 'Records where all disposition fields are non-pending / total records' could mean fully-resolved records or records with at least one resolved disposition, and the field name does not disambiguate."
    evidence: "Spec Metrics table: 'Disposition rate — Records where all disposition fields are non-pending / total records — YAML frontmatter.' The numerator clause describes records where every objection is resolved; the denominator 'total records' is record-level. But 'Disposition rate' more naturally reads as 'what fraction of dispositions are resolved' — a materially different number computed at the objection level."
    disposition: fix
    disposition_rationale: this should be made more clear.
  - id: O6
    category: premise
    severity: medium
    claim: "The observability layer is being built over a dataset with one objection record; most metrics will report 'insufficient data' or single-data-point values on launch day, making the dashboard uninformative at the moment it is most likely to be inspected."
    evidence: "Spec Problem section describes wanting to see patterns (clustering, trends). Spec: 'Insufficient data is reported for median when fewer than 3 fully-resolved records exist.' At time of writing docs/superpowers/objections/ contains one file. Distribution and trend metrics require a meaningful sample the data does not yet contain."
    disposition: accept
    disposition_rationale: this is ok and expected. As more dispositions appear this problem will disappear.
  - id: O7
    category: scope
    severity: medium
    claim: "The 'Specs reviewed' denominator conflates 28 total specs (27 pre-dating the feature) with specs expected to have diaboli coverage, structurally inflating the 'Specs without a record' gap metric from the first snapshot with no resolution mechanism."
    evidence: "Spec metrics table: 'Specs reviewed — Count of docs/superpowers/specs/*.md — filesystem.' The advocatus-diaboli feature was introduced on 2026-04-19; specs from 2026-04-06 onward predate it. No start-date filter, exclusion list, or legacy marker is defined."
    disposition: fix
    disposition_rationale: add a start date filter and/or a mechanism for specs prior to diaboli being introduced to exclude themselves.
  - id: O8
    category: alternatives
    severity: low
    claim: "The new observability.md reference file duplicates content that the ARCH_DECISION added to AGENTS.md in the same spec, creating two canonical locations for the observability-before-enforcement principle with no clear authority."
    evidence: "Spec artefact #5 creates observability.md to document 'what each metric means, what it does NOT mean, and the watch-for patterns.' Spec artefact #7 adds an ARCH_DECISION to AGENTS.md capturing 'the observability-before-enforcement principle and the revisit conditions.' AGENTS.md is already the declared location for such decisions in this project."
    disposition: fix
    disposition_rationale: move arch enforcement to AGENTS.md
  - id: O9
    category: implementation
    severity: low
    claim: "The spec does not define error-handling behavior when a malformed or unparseable objection file YAML frontmatter is encountered during metric computation in /superpowers-status or /harness-health."
    evidence: "Spec metrics table specifies 'YAML frontmatter' as the source for four metrics. The write-time validation checkpoint in diaboli.md step 5 validates at creation; the spec contains no instruction for what the status/health commands should do if a file is subsequently edited to an invalid YAML state."
    disposition: fix
    disposition_rationale: specify if the YAML is unparseable declare the spec as not being subject to diaboli
  - id: O10
    category: scope
    severity: low
    claim: "The taxonomy fix in diaboli.md validation checkpoint is a pre-existing bug independent of the observability work; bundling it risks the fix being dropped if the PR scope is narrowed."
    evidence: "Spec: 'SKILL.md was updated to the new taxonomy in a prior PR. The command's checkpoint must be corrected.' This is described as a 'Side fix' within the Approach section. It does not depend on any new metric or section and could have been (and arguably should have been) a standalone patch PR."
    disposition: accepted
    disposition_rationale: acknowledged.
---

## O1 — implementation — high

### Claim

The median-days-spec-to-disposition metric uses `git log` on the objection file to determine the resolution date, but objection files are overwritten on every regeneration. This makes the git timestamp an unreliable proxy for when dispositions were actually filled.

### Evidence

The spec's metrics table specifies: "Median days spec-to-disposition — Spec date from filename; resolution date from git log on objection file; median across fully-resolved records."

The `/diaboli` command (diaboli.md step 4) states: "If a file already exists at that path, overwrite it. Warn the user that any prior dispositions are replaced and they will need to re-adjudicate."

### Why this matters

If a spec is revised and `/diaboli` is re-run, the objection file is overwritten. The human then re-fills dispositions. The git log on that file now shows the regeneration date — possibly weeks later than the original resolution — or earlier if re-dispositioned quickly. The metric designed to signal whether "time-to-disposition is growing" would be computed on a timestamp that does not reflect the actual disposition timeline. A metric that is formally defined but epistemically ungrounded is worse than no metric: it creates false confidence in what is being measured.

---

## O2 — implementation — high

### Claim

The "Specs without a record" metric will immediately surface 27 or more missing records on launch day because the metric counts all files in `docs/superpowers/specs/` with no mechanism to distinguish pre-feature specs from specs that are expected to have objection coverage.

### Evidence

The spec's metrics table states: "Specs without a record — Spec slugs with no matching objection file — slug comparison — filesystem."

As of 2026-04-19, `docs/superpowers/specs/` contains 28 files. The advocatus-diaboli feature was introduced on 2026-04-19. There is currently one objection record. The spec defines no start-date filter, no exclusion list, and no way to mark a spec as legacy or pre-feature.

### Why this matters

"Specs without a record: 27" is not a useful reading on the dashboard's first day. A developer seeing this number must manually verify whether the gap is a current problem or a historical artefact. The observability surface designed to surface patterns would itself require a post-hoc audit to interpret. A start-date or scope boundary is not an enhancement — it is required for the metric to be informative at all.

---

## O3 — specification quality — high

### Claim

`harness-health.md` step 7 hardcodes the string "All 12 section headings" and enumerates all 12 by name. Inserting the Diaboli section as a new mandatory section creates 13 sections, but the spec's artefact description for harness-health.md does not call out updating this count or the enumerated list.

### Evidence

`harness-health.md` step 7, structural check 1: "All 12 section headings present in order: Enforcement, Enforcement Loop History, Garbage Collection, Mutation Testing, Compound Learning, Session Quality, Operational Cadence, Cost Indicators, Regression Indicators, Meta, Changes Since Last Snapshot, Trends."

Spec artefact #4: "`ai-literacy-superpowers/commands/harness-health.md` — add Diaboli to required section list and section order." The description mentions adding Diaboli to the list but does not mention updating the count "12" or the enumerated heading names in the same structural check.

### Why this matters

An implementer reading artefact #4 will add Diaboli to the section order. If they update the required section list but do not update the hardcoded "12" count or the enumerated heading names, the validation checkpoint will be internally inconsistent or will silently pass when a snapshot lacks a Diaboli section. The step 7 validation is described as "mandatory" — if its internal count is wrong, it cannot serve as the correctness gate the spec intends.

---

## O4 — risk — medium

### Claim

The Diaboli summary line in `/superpowers-status` uses `[ACTIVE — N records]` or `[NO DATA]`, which is structurally different from the `OK/WARNING/MISSING` format used by all other sections. Any parser or future consumer that reads the status dashboard for structured tokens will encounter an anomalous format in Section 7.

### Evidence

The spec states: "The summary line shows `Diaboli [ACTIVE — N records]` or `[NO DATA]` — explicitly not OK/WARNING/MISSING, since we have no threshold yet."

The current `superpowers-status.md` output format template shows six sections each emitting exactly one of `[OK / WARNING / MISSING]`. The format is uniform and parseable by pattern.

### Why this matters

Explicitly choosing a non-standard format without auditing downstream consumers transfers the consistency debt to the future. The spec does not note whether such consumers exist. If a script or hook parses `/superpowers-status` output by looking for `[OK]`, `[WARNING]`, or `[MISSING]` tokens, Section 7 will be invisible to that consumer.

---

## O5 — specification quality — medium

### Claim

The "Disposition rate" metric definition is ambiguous. "Records where all `disposition` fields are non-`pending` / total records" could mean a record-level completion ratio or an objection-level completion ratio, and the field name "Disposition rate" does not resolve this.

### Evidence

Spec metrics table: "Disposition rate — Records where all `disposition` fields are non-`pending` / total records — YAML frontmatter."

The numerator clause "Records where all disposition fields are non-`pending`" describes fully-resolved records. But "Disposition rate" more naturally reads as "what fraction of dispositions are resolved" — total non-pending dispositions / total dispositions — a materially different number when partial resolution exists.

### Why this matters

Two implementers reading this definition could produce different computations. Because the metric is the primary signal for whether objection review is completing, a computation ambiguity here produces a misleading headline number that cannot be detected without examining the implementation.

---

## O6 — premise — medium

### Claim

The observability layer is being built over a dataset with one objection record. The metrics designed to reveal patterns — mean objections per spec, disposition distribution, severity breakdown trends, median days to disposition — will report "insufficient data" or single-data-point values on launch day.

### Evidence

The spec's Problem section describes wanting to see patterns (clustering, trends). The spec notes: "'Insufficient data' is reported for median when fewer than 3 fully-resolved records exist." At time of writing, `docs/superpowers/objections/` contains one file.

### Why this matters

This is not fatal — the spec correctly frames the approach as "observability before enforcement" and the data will grow. But the Problem section implies the dashboard makes invisible patterns visible on day one. A dashboard that opens in `[NO DATA]` or single-point mode for most metrics defers the value. The spec would be strengthened by explicitly acknowledging the launch-day state and setting reader expectations.

---

## O7 — scope — medium

### Claim

The "Specs reviewed" denominator includes all 28 files in `docs/superpowers/specs/`, providing no mechanism to distinguish the 27 pre-feature specs (not intended to have diaboli coverage) from post-feature specs (which should). This structurally inflates the "Specs without a record" gap from the first snapshot.

### Evidence

Spec metrics table: "Specs reviewed — Count of `docs/superpowers/specs/*.md` — filesystem." The advocatus-diaboli feature was introduced on 2026-04-19; approximately 27 of the 28 specs predate it. No `since:` parameter, exclusion list, or legacy annotation is defined.

### Why this matters

"Specs without a record: 27" is indistinguishable from "27 current gaps" vs "27 historical specs" without contextual knowledge. A feature-activation date filter would make the metric immediately useful rather than requiring a separate audit to interpret.

---

## O8 — alternatives — low

### Claim

The new `observability.md` reference file duplicates content that the ARCH_DECISION added to AGENTS.md in the same spec, creating two canonical locations for the observability-before-enforcement design rationale with no clear authority.

### Evidence

Spec artefact #5 creates `observability.md` to document "what each metric means, what it does NOT mean, and the watch-for patterns worth a reflection entry." Spec artefact #7 adds an ARCH_DECISION to AGENTS.md capturing "the observability-before-enforcement principle and the revisit conditions." AGENTS.md is already the declared project location for architectural decisions with their rationale and revisit conditions.

### Why this matters

When the observability design is revisited at the 10-record trigger, a reader may find one document in AGENTS.md and a different or evolved version in `observability.md`, with no clear indication of which is authoritative.

---

## O9 — implementation — low

### Claim

The spec does not define error-handling behavior when `/superpowers-status` or `/harness-health` encounter a malformed or unparseable YAML frontmatter block in an objection file during metric computation.

### Evidence

The spec's metrics table specifies "YAML frontmatter" as the source for four metrics. The write-time validation checkpoint in diaboli.md step 5 validates at creation. The spec contains no instruction for what the status/health commands should do if a file is subsequently edited to an invalid YAML state.

### Why this matters

Without defined error handling, both commands would silently produce incorrect counts or surface a parsing error mid-health-check. A single sentence — "if a file fails YAML parse, report it as a named parse error in the Details section and exclude it from all metrics" — would close this gap.

---

## O10 — scope — low

### Claim

The taxonomy fix in `diaboli.md` validation checkpoint is a pre-existing bug independent of the observability work; bundling it risks the fix being dropped if the PR scope is narrowed.

### Evidence

The spec describes the diaboli.md taxonomy fix as a "Side fix" within the Approach section. It does not depend on any new metric or section. It would have been cleaner as a standalone patch PR.

### Why this matters

The taxonomy mismatch means the validation checkpoint currently accepts objection records with the old (wrong) category and severity values. If this PR is deferred for any reason, the taxonomy bug continues to silently accept malformed records. The fix is urgent relative to the observability additions.

---

## Explicitly not objecting to

- **The observability-before-enforcement principle**: Choosing descriptive stats with no pass/fail thresholds before enforcement is correct sequencing. Enforcement without observable baselines produces arbitrary thresholds. The spec's reasoning is sound and aligns with the ARCH_DECISION pattern already in the project.

- **The choice to surface metrics in existing surfaces rather than a new command**: Reusing `/superpowers-status` and `/harness-health` avoids command proliferation and keeps diaboli activity visible within the normal health cadence rather than requiring a separate invocation.

- **The revisit trigger definition (10 fully-resolved records or 2026-07-19)**: A concrete, dual-condition revisit trigger is better than an open-ended deferral. The date-based backstop prevents indefinite delay; the data-based condition creates the right incentive to resolve dispositions promptly.

- **Placement of the Diaboli section after Session Quality, before Operational Cadence**: This ordering places diaboli data in the quality/discipline cluster of the snapshot, contextually appropriate alongside measures of reflection and session quality.

- **Not adding a GC rule or new constraint in this PR**: Adding enforcement before establishing a baseline would produce a threshold without evidence. The spec correctly defers this to the revisit evaluation.
