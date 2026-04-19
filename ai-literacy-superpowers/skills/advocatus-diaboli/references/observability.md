---
name: diaboli-observability-reference
description: Metric computation definitions and interpretive notes for the Diaboli panel in /superpowers-status and the harness-health snapshot — what each field means, what it does NOT mean, and watch-for patterns
---

# Diaboli Observability Reference

The Diaboli panel surfaces advocatus-diaboli activity as descriptive stats in
`/superpowers-status` (Section 7) and the harness-health snapshot. This reference
documents how each metric is computed, how to interpret it, and what it does not tell you.

For the arch decision behind this approach (observability-before-enforcement, revisit
conditions), see `AGENTS.md` → ARCH_DECISIONS.

---

## Scope boundary

A spec is **in-scope** for diaboli coverage if its filename date is on or after
`2026-04-19` — the date the advocatus-diaboli feature shipped. Specs predating this
date are **exempt** and counted separately. All metrics that compare specs to objection
records use only in-scope specs.

A **spec slug** is the filename with the `YYYY-MM-DD-` date prefix and `.md` extension
stripped. A matching **objection record** is the file at
`docs/superpowers/objections/<slug>.md`.

---

## Field definitions

### In-scope specs

Count of `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-19.

**Does not mean:** that all in-scope specs have been reviewed. Use "In-scope specs
without a record" to see gaps.

### Exempt specs (pre-feature)

Count of specs with filename date < 2026-04-19. These predate the feature and were
never intended to have objection records.

**Does not mean:** these specs are low quality. They were written before the practice
existed.

### Objection records present

Count of `docs/superpowers/objections/*.md`, excluding `.gitkeep`.

**Does not mean:** all records are adjudicated. Use "Fully-resolved record rate" to
distinguish records with `pending` dispositions.

### In-scope specs without a record

In-scope spec slugs with no matching file in `docs/superpowers/objections/`. Should be 0
given the harness-enforcer PR constraint, but surfaced here for drift detection.

**Does not mean:** a gap of 0 guarantees review quality — only that a record exists.
Rubber-stamped records (all dispositions filled with minimal rationale) pass this check.

### Fully-resolved record rate

Records where every `disposition` field is non-`pending` / total records. This is a
**record-level** ratio: a record counts only when every objection within it is resolved.
A record with 9 of 10 dispositions filled counts as unresolved.

**Does not mean:** the resolved records were adjudicated carefully. A human can fill all
fields with minimal rationale and the count will increase. The metric measures completion,
not quality of engagement.

### Objections total

Sum of `objections` list lengths across all objection records.

**Does not mean:** more objections is better or worse. The agent is capped at 12 per spec
and instructed to prioritise quality over quantity. A record with 3 high-severity objections
may be more valuable than one with 10 low-severity ones.

### Severity breakdown

Count of `critical` / `high` / `medium` / `low` across all objection entries
(including `pending`).

**Does not mean:** a high count of `critical` objections indicates poor spec quality alone
— it may also indicate the agent's charter is tuned to fire at a high severity. Compare
severity distribution to disposition distribution when interpreting.

### Mean objections per spec

Total objections / count of objection records, rounded to 1 decimal.

**Does not mean:** a low mean indicates strong specs. The agent may be configured to raise
fewer, higher-quality objections (correct behaviour) or may be under-challenging specs
(failure mode). Read objection records alongside the metric to distinguish.

### Disposition distribution

Among non-`pending` dispositions only: percentage `accepted` / `deferred` / `rejected`.
Disposition values `fix` and `leave` are treated as `accepted` and `rejected` respectively
for this computation.

**Does not mean:** a high `rejected` rate indicates the agent is wrong — it may mean the
agent is raising legitimate concerns and the team is engaging carefully and deciding against
them (healthy pattern). A high `deferred` rate may mean the charter is firing on nits, or
may mean specs are genuinely mature — the metric alone cannot distinguish.

### Median days spec-to-disposition

For each fully-resolved record: days between the spec filename date and the date of the
most recent commit on the objection file (`git log --format=%as -1`). Median across all
fully-resolved records.

Reports "insufficient data" when fewer than 3 fully-resolved records exist.

**Does not mean:** a short median is necessarily healthy. Fast adjudication that involves
minimal engagement is worse than slow adjudication that involves careful reasoning. The
median measures throughput, not quality.

**Implementation note:** if a spec is revised and `/diaboli` is re-run, the objection file
is overwritten. The git date then reflects the post-revision fill date, not the original
one. This makes the metric an approximation of disposition speed rather than a precise
measurement. It is useful as an order-of-magnitude indicator of friction, not as a precise
SLA metric.

---

## Watch-for patterns

These patterns in the Diaboli panel are candidates for a reflection entry when observed
over multiple snapshots:

**Disposition distribution collapsing to a single bucket**
All dispositions are `accepted`, or all are `rejected`. A genuine spec process produces
a mix: some objections land, some are legitimately rejected. A distribution collapsed to
one bucket suggests the agent is not raising meaningful objections (if all `rejected`) or
the specs are consistently underprepared (if all `accepted`).

**Objection count trending toward zero**
Mean objections per spec falling toward 0 over consecutive snapshots. The agent should
consistently find something to challenge in a well-scoped spec. Trend toward 0 suggests
the charter is becoming toothless — either SKILL.md has been softened, or specs have
become genuinely trivial. Both warrant a look at recent records.

**Objection count trending toward 12 (the cap)**
Mean objections per spec approaching 12 consistently. The cap exists because above 12
the agent is pattern-matching rather than reasoning. A consistent mean of 11–12 suggests
the agent's charter may need tightening, or the specs arriving for review are genuinely
underprepared.

**Median days spec-to-disposition trending up**
Increasing time between spec creation and fully-resolved adjudication. May indicate the
human-cognition gate is creating friction beyond its intended effect, or that specs are
being revised frequently (resetting the clock). Investigate which before treating as
a problem.

---

## Error handling

If a file at `docs/superpowers/objections/` fails YAML parse during metric computation,
report it by name in the Details section as "parse error" and exclude it from all metrics.
Do not silently skip it — a parse error in an objection record should be visible.
