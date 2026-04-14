---
name: harness-observability
description: Use when checking harness health, setting up observability cadences, understanding snapshot formats, configuring telemetry export, or verifying that the harness's own observability is working — covers all four layers of harness observability
---

# Harness Observability

Harness observability is the measurement layer that makes context
engineering, architectural constraints, and garbage collection
evidence-based rather than intuition-based. Without it, a harness is
infrastructure you hope works. With it, you know.

This skill covers four layers of observability, each answering a
different question at a different timescale.

This skill does not cover CI workflow configuration (middle loop),
individual constraint design, or garbage collection rule authoring —
those belong to their respective skills. It covers how to observe
whether those mechanisms are operating effectively.

For the snapshot schema and field definitions, consult
`references/snapshot-format.md`.

## The Four Layers

| Layer | Question | Timescale | Consumer |
|-------|----------|-----------|----------|
| Operational Cadence | "Is the harness running?" | Session / weekly / quarterly | Developer in session |
| Trend Visibility | "How has the harness changed?" | Weekly / quarterly | Team over time |
| Telemetry Export | "Can I visualise this externally?" | Continuous | External dashboards |
| Meta-Observability | "Is the observability itself working?" | Quarterly | Agents + team |

## Layer 1: Operational Cadence

The harness has mechanisms — audit, GC, reflection, mutation testing —
but mechanisms only work if they run. Operational cadence ensures they
actually fire on schedule.

**The primary tool is `/harness-health`.** Running it:

1. Produces a structured snapshot of the harness's current state
2. Surfaces deltas from the previous snapshot
3. Flags overdue cadences (e.g. "last audit was 45 days ago")
4. Updates the README health badge

**Recommended cadences:**

| Mechanism | Cadence | Command |
|-----------|---------|---------|
| Health snapshot | Monthly | `/harness-health` |
| Full audit | Quarterly | `/harness-audit` |
| Assessment | Quarterly | `/assess` |
| Reflection review | Quarterly | Review REFLECTION_LOG.md |
| Mutation trend check | Monthly | Download CI artifacts |

A Stop hook nudges the developer when the last snapshot is older than
30 days. This turns a declared cadence into an actual practice.

## Layer 2: Trend Visibility

Snapshots are point-in-time. Trends are the delta between snapshots.
No external tooling required — trends are computed by diffing markdown
files.

When `/harness-health` runs and a previous snapshot exists, it:

1. Computes deltas for every tracked metric
2. Appends a Trends section to the new snapshot
3. Prints a delta summary to the session

For quarterly reviews, `/harness-health --trends` reads all snapshots
and produces a multi-period trend view.

**What agents do with trends:** The orchestrator reads the latest
snapshot's Trends section before planning work. Declining mutation
scores might trigger test quality prioritisation. A stalled learning
flow might prompt a `/reflect` nudge.

## Layer 3: Telemetry Export

For teams that want Grafana, Langfuse, or other external dashboards,
the snapshot data can be exported as OpenTelemetry metrics.

This is optional. The file-based approach (Layers 1-2) works without
any external tooling. Telemetry export adds continuous visibility for
teams operating at scale.

For OTel metric names, semantic conventions, and a reference export
script, consult `references/telemetry-export.md`.

## Layer 4: Meta-Observability

The self-referential layer: the harness checking whether its own
observability is working.

"A harness that cannot verify its own operation is a harness you hope
works."

The harness-auditor agent runs five meta-checks:

| Check | Signal |
|-------|--------|
| Snapshot currency | Stale = outer loop not running |
| Cadence compliance | Overdue = practice not followed |
| Learning flow | Stalled = compound learning broken |
| GC effectiveness | Silent = rules may be misconfigured |
| Trend direction | Unacknowledged decline = drift unnoticed |

For thresholds and detailed check definitions, consult
`references/meta-observability-checks.md`.

## Observatory Metrics Block

Every snapshot must include a YAML metrics block appended after all
markdown sections (including Trends, if present). This block provides
all quantitative metrics in a structured, typed format for machine
consumption by the Observatory.

**Generation steps:**

1. After writing all markdown sections to the snapshot file, append
   the YAML metrics block as described in
   `references/snapshot-format.md` § Observatory Metrics Block. The
   block is fenced by `---` delimiters and contains the
   `observatory_metrics` root key.

2. **Read the configured cadence.** Check the HARNESS.md Observability
   section for `Snapshot cadence`. Map to a threshold: weekly=10 days,
   fortnightly=21 days, monthly=30 days. Default to monthly if not
   configured. Include `configured_cadence` and
   `cadence_threshold_days` in the `observability` section.

3. **Compute feedback loop activation.** For each loop (advisory,
   strict, investigative), determine whether it is active and when it
   was first activated using git history. Cache `first_activated` dates
   from the previous snapshot — only re-check git history when a
   loop's status transitions from inactive to active.

4. **Compute regression indicators.** After computing the meta-
   observability checks, populate the `regression_indicators` section:
   - `snapshot_stale`: previous snapshot age exceeds cadence threshold
   - `cadence_non_compliant_count`: count of overdue activities
     (already computed for Meta section)
   - `consecutive_zero_reflection_weeks`: count consecutive weeks
     without REFLECTION_LOG entries, working backwards from today
   - `regression_flag`: logical OR of the three trigger conditions

All values in the YAML block come from the same data sources already
read for the markdown sections — no additional data collection is
required beyond the git history lookups for loop activation dates.
Follow the generation rules and null-handling policy in the format spec.

The schema version is tracked in
`references/observatory-metrics-schema.md`. The `schema_version` field
in the YAML block must match the current documented version (1.1.0).

## When to Use This Skill

| Situation | Action |
|-----------|--------|
| Starting a new quarter | Run `/harness-health` to baseline |
| After a major feature lands | Run `/harness-health` to check impact |
| Harness feels stale | Run `/harness-health --deep` for authoritative check |
| Quarterly review | Run `/harness-health --trends` for multi-period view |
| Setting up a new project | Configure cadences in CLAUDE.md |
| Want external dashboards | Follow `references/telemetry-export.md` |

## README Health Indicator

`/harness-health` maintains two README elements:

**Health badge** — shields.io, colour-coded:

| Status | Condition | Colour |
|--------|-----------|--------|
| Healthy | All layers operating, no overdue cadences | Green |
| Attention | One layer degraded or outer loop overdue | Amber |
| Degraded | Multiple layers degraded or no snapshot in 30+ days | Red |

**Health icon** — a custom SVG linked to the latest snapshot.

The badge colour factors in meta-health. Stale snapshots or overdue
cadence trigger amber even if enforcement ratios look fine.
