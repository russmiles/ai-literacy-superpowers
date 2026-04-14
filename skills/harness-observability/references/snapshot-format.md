# Snapshot Format Reference

Health snapshots are the core artefact of harness observability. Each
snapshot captures the harness's state at a point in time. Trends are
derived by comparing snapshots — no separate database or trend storage.

## Storage

Path: `observability/snapshots/YYYY-MM-DD-snapshot.md`

One file per snapshot. Markdown format — readable by developers and
agents, diffable in git.

## Sections

Every snapshot contains these sections in order. Each section has a
fixed format so agents can parse them reliably.

### Enforcement

```text
## Enforcement
- Constraints: N/M enforced (P%)
- Deterministic: X | Agent: Y | Unverified: Z
- Drift detected: yes/no
```

**Source:** HARNESS.md Status section and constraint definitions.

| Field | How to compute |
|-------|---------------|
| N (enforced) | Count constraints with enforcement = deterministic or agent |
| M (total) | Count all constraints |
| P% | (N / M) * 100, rounded to nearest integer |
| Deterministic | Count constraints with enforcement = deterministic |
| Agent | Count constraints with enforcement = agent |
| Unverified | Count constraints with enforcement = unverified |
| Drift | Read HARNESS.md Status section drift field |

### Garbage Collection

```text
## Garbage Collection
- Rules active: N/M
- Last run: YYYY-MM-DD
- Findings since last snapshot: N
```

**Source:** HARNESS.md GC section and audit history.

| Field | How to compute |
|-------|---------------|
| N (active) | Count GC rules with enforcement != none |
| M (total) | Count all GC rules |
| Last run | Date of most recent /harness-gc or /harness-audit |
| Findings | Count of GC findings since previous snapshot date (from audit reports or commit messages) |

### Mutation Testing

```text
## Mutation Testing
- Go kill rate: N%
- Kotlin kill rate: N%
- Python kill rate: N%
- Trend: stable/improving/declining (±N% from last snapshot)
```

**Source:** Latest mutation testing CI artifacts.

| Field | How to compute |
|-------|---------------|
| Kill rate per language | Parse from CI artifact HTML reports or workflow logs |
| Trend | Compare with previous snapshot's kill rates. stable = ±2%, improving = >+2%, declining = <-2% |

If CI artifacts are unavailable, report "not available" rather than
guessing.

### Compound Learning

```text
## Compound Learning
- REFLECTION_LOG entries: N (M new since last snapshot)
- AGENTS.md entries: N (X gotchas, Y arch decisions)
- Promotions since last snapshot: N
```

**Source:** REFLECTION_LOG.md and AGENTS.md.

| Field | How to compute |
|-------|---------------|
| REFLECTION_LOG entries | Count entries (each starts with `## ` heading with a date) |
| New since last snapshot | Count entries with dates after previous snapshot date |
| AGENTS.md entries | Count `GOTCHA:` and `ARCH_DECISION:` lines |
| Promotions | New AGENTS.md entries since previous snapshot date |

### Operational Cadence

```text
## Operational Cadence
- Last /harness-audit: YYYY-MM-DD
- Last /assess: YYYY-MM-DD
- Last /reflect: YYYY-MM-DD
- Outer loop overdue: yes/no
```

**Source:** Git log, assessment files, HARNESS.md Status section.

| Field | How to compute |
|-------|---------------|
| Last /harness-audit | HARNESS.md Status section "Last audit" date |
| Last /assess | Most recent file in assessments/ directory |
| Last /reflect | Most recent date in REFLECTION_LOG.md |
| Outer loop overdue | yes if any of the above is older than its declared cadence (audit: 90 days, assess: 90 days, reflect: 30 days) |

### Cost Indicators

```text
## Cost Indicators
- Model routing configured: yes/no
- Tier distribution: (from MODEL_ROUTING.md)
```

**Source:** MODEL_ROUTING.md existence and content.

### Meta

```text
## Meta
- Snapshot cadence: on schedule / overdue
- Learning flow: active / stalled
- GC effectiveness: productive / silent
- Trend alerts: none / [list declining metrics]
```

**Source:** Computed from other sections and previous snapshot.

See `references/meta-observability-checks.md` for check definitions
and thresholds.

### Trends

```text
## Trends (vs YYYY-MM-DD)

| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
| Enforcement ratio | P% (N/M) | P% (N/M) | ±N% |
| Mutation (Go) | N% | N% | ±N% |
| Mutation (Kotlin) | N% | N% | ±N% |
| Mutation (Python) | N% | N% | ±N% |
| Reflections | N | N | ±N |
| Promotions | N | N | ±N |
| GC findings | N | N | ±N |
| Cadence status | status | status | changed/unchanged |
```

**Source:** Previous snapshot file. If no previous snapshot exists, omit
this section entirely.

## Parsing Notes for Agents

Agents reading snapshots should:

1. Find the latest file in `observability/snapshots/` by filename date
2. Parse each section by its `## ` heading
3. Extract values from the `- Field: Value` format
4. For the Trends table, parse the markdown table rows

The format is deliberately simple and consistent so regex-based parsing
works reliably.

## Observatory Metrics Block

**This block is mandatory in every snapshot.** Unlike the Trends section
(which is omitted when no previous snapshot exists), the YAML metrics
block is always present — even in the very first snapshot.

After all markdown sections (including the optional Trends section),
every snapshot ends with a YAML metrics block fenced by `---` delimiters.
This block contains all quantitative metrics in a structured, typed
format intended for machine consumption by the Observatory.

The existing markdown sections remain the primary human-readable output.
The YAML block is complementary — it does not replace or duplicate the
markdown, but provides the same data in a format that avoids brittle
regex parsing.

For the schema versioning policy and changelog, see
`observatory-metrics-schema.md`.

### Schema

```yaml
---
observatory_metrics:
  schema_version: "1.2.0"
  plugin_version: "<read from plugin.json>"
  timestamp: "<ISO 8601 UTC timestamp of snapshot generation>"

  habitat_configuration:
    context_depth:
      score: <float 0-1>
      layers_present: <int 0-5>
      layers:
        stack: { present: <bool>, last_modified: "<YYYY-MM-DD or null>" }
        conventions: { present: <bool>, last_modified: "<YYYY-MM-DD or null>" }
        arch_decisions: { present: <bool>, last_modified: "<YYYY-MM-DD or null>" }
        rationale: { present: <bool>, last_modified: "<YYYY-MM-DD or null>" }
        threat_model: { present: <bool>, last_modified: "<YYYY-MM-DD or null>" }

    constraint_maturity:
      enforcement_ratio: <float 0-1>
      total_constraints: <int>
      enforced: <int>
      deterministic: <int>
      agent_backed: <int>
      unverified: <int>
      drift_detected: <bool>
      constraints:
        - name: "<constraint name>"
          tier: "<deterministic | agent_backed | unverified>"
          enforced: <bool>

    entropy_management:
      gc_rules_active: <int>
      gc_rules_total: <int>
      gc_active_ratio: <float 0-1>
      findings_since_last_snapshot: <int>
      cadence_compliant: <bool>
      last_run: "<YYYY-MM-DD or null>"

    compound_learning:
      reflection_log_entries: <int>
      reflections_this_period: <int>
      agents_md_entries: <int>
      gotchas: <int>
      arch_decisions: <int>
      promotions_this_period: <int>
      velocity: <float or null>
      signal_distribution:
        context: <int>
        instruction: <int>
        workflow: <int>
        failure: <int>

    feedback_loops:
      advisory:
        active: <bool>
        first_activated: "<YYYY-MM-DD or null>"
      strict:
        active: <bool>
        first_activated: "<YYYY-MM-DD or null>"
      investigative:
        active: <bool>
        first_activated: "<YYYY-MM-DD or null>"
      coverage: <int 0-3, count of active loops>
      latency:
        advisory_violations_this_period: <int>
        strict_violations_this_period: <int>
        investigative_findings_this_period: <int>
      violations_total: <int, total lines in violations.jsonl>

    agent_delegation:
      agents_configured: <int>

    observability:
      configured_cadence: "<weekly | fortnightly | monthly>"
      cadence_threshold_days: <int, 10 | 21 | 30>
      health: "<Healthy | Attention | Degraded>"
      snapshot_age_days: <int>
      meta_checks:
        snapshot_currency: "<on_schedule | overdue | stale>"
        cadence_compliance: "<all_on_schedule | [list of overdue items]>"
        learning_flow: "<active | stalled | inactive>"
        gc_effectiveness: "<productive | silent>"
        trend_direction: "<stable | [list of declining metrics]>"

  outcomes:
    mutation_kill_rate:
      aggregate: <float 0-1 or null>
      by_language: {}
    cost:
      model_routing_configured: <bool>
      tier_distribution: {}
      trend: "<rising | stable | declining | unknown>"

  operational_cadence:
    days_since_audit: <int or null>
    days_since_assess: <int or null>
    days_since_reflect: <int or null>
    audit_overdue: <bool>
    assess_overdue: <bool>
    reflect_overdue: <bool>

  regression_indicators:
    snapshot_stale: <bool, true if snapshot_age_days > configured cadence threshold>
    snapshot_age_days: <int, days since previous snapshot, 0 if first>
    cadence_non_compliant_count: <int, number of scheduled activities overdue>
    consecutive_zero_reflection_weeks: <int, consecutive weeks with no REFLECTION_LOG entries>
    regression_flag: <bool, true if ANY of: snapshot_stale, cadence_non_compliant_count >= 2, consecutive_zero_reflection_weeks >= 4>
---
```

### Generation Rules

All values come from the same data sources already read for the
markdown sections — no new data collection is required.

| Field | How to compute |
|-------|---------------|
| `schema_version` | Always `"1.1.0"` (bump per `observatory-metrics-schema.md` policy) |
| `plugin_version` | Read `version` from `plugin.json` |
| `timestamp` | ISO 8601 UTC timestamp at the moment the snapshot is generated |
| `context_depth.score` | Count layers where `present == true` AND `last_modified` is within the last 30 days, divided by 5 |
| `context_depth.layers_present` | Count layers where `present == true` |
| `context_depth.layers.stack` | Check CLAUDE.md existence and git modification date |
| `context_depth.layers.conventions` | Check CLAUDE.md existence and git modification date |
| `context_depth.layers.arch_decisions` | Check HARNESS.md existence and git modification date |
| `context_depth.layers.rationale` | Check `specs/` directory existence and most recent file modification date |
| `context_depth.layers.threat_model` | Check for threat model documentation; if absent, `present: false`, `last_modified: null` |
| `constraint_maturity.*` | Same counts as the Enforcement markdown section |
| `constraint_maturity.constraints[]` | Each constraint from HARNESS.md Constraints section with name, tier, and enforced status |
| `entropy_management.*` | Same data as the Garbage Collection markdown section |
| `compound_learning.velocity` | `promotions_this_period` divided by weeks between this snapshot and the previous one; `null` if no previous snapshot |
| `compound_learning.signal_distribution` | Count REFLECTION_LOG.md entries by `signal:` field value |
| `feedback_loops.advisory.active` | `true` if `hooks/` directory exists and hooks configuration defines PreToolUse or Stop hooks |
| `feedback_loops.advisory.first_activated` | Git history: first commit that added hooks configuration (e.g. `git log --diff-filter=A --format=%ai -- .claude/hooks.json`). `null` if hooks don't exist |
| `feedback_loops.strict.active` | `true` if a CI workflow enforcing harness constraints exists (`.github/workflows/harness.yml` or similar referencing HARNESS.md) |
| `feedback_loops.strict.first_activated` | Git history: first commit that added the CI enforcement workflow. `null` if no CI enforcement exists |
| `feedback_loops.investigative.active` | `true` if HARNESS.md Garbage Collection section has at least one rule with enforcement = "agent" or "deterministic" |
| `feedback_loops.investigative.first_activated` | Git history: first commit that added a GC rule to HARNESS.md. `null` if no GC rules exist |
| `feedback_loops.coverage` | Count of active loops (0-3) |
| `feedback_loops.latency.advisory_violations_this_period` | Count entries in `observability/violations.jsonl` where `loop == "advisory"` and `timestamp` is after the previous snapshot date. `0` if no violations file or no entries |
| `feedback_loops.latency.strict_violations_this_period` | Count entries where `loop == "strict"` since previous snapshot |
| `feedback_loops.latency.investigative_findings_this_period` | Count entries where `loop == "investigative"` since previous snapshot |
| `feedback_loops.violations_total` | Total line count of `observability/violations.jsonl`. `0` if file does not exist |
| `agent_delegation.agents_configured` | Count `.agent.md` files in `agents/` directory |
| `observability.*` | Same data as the Meta markdown section |
| `outcomes.mutation_kill_rate.*` | Same data as the Mutation Testing markdown section |
| `outcomes.cost.*` | Same data as the Cost Indicators markdown section |
| `operational_cadence.*` | Same data as the Operational Cadence markdown section |
| `observability.configured_cadence` | Read HARNESS.md Observability section `Snapshot cadence` value. Default `monthly` if not configured |
| `observability.cadence_threshold_days` | Map cadence to threshold: weekly=10, fortnightly=21, monthly=30 |
| `regression_indicators.snapshot_stale` | `true` if `snapshot_age_days` exceeds the configured cadence threshold. `false` if this is the first snapshot |
| `regression_indicators.snapshot_age_days` | Days between previous snapshot date and today. `0` if no previous snapshot |
| `regression_indicators.cadence_non_compliant_count` | Count of the four scheduled activities (audit/90d, assess/90d, reflect/30d, GC/declared cadence) that are overdue. Reuse data from Meta section |
| `regression_indicators.consecutive_zero_reflection_weeks` | Count consecutive calendar weeks (working backwards from today) with zero REFLECTION_LOG.md entries. `0` if the most recent entry is this week |
| `regression_indicators.regression_flag` | Logical OR of: `snapshot_stale == true`, `cadence_non_compliant_count >= 2`, `consecutive_zero_reflection_weeks >= 4` |

**Activation date caching:** The git history lookups for
`first_activated` dates only need to run once. After the first
snapshot records the dates, subsequent snapshots can read them from
the previous snapshot and only re-check if a loop's `active` status
has changed from `false` to `true`.

**Null handling:** Use `null` (not empty string, not `0`) for values
that cannot be determined. For example, if no previous snapshot exists,
`velocity` is `null`. If mutation testing is not configured,
`aggregate` is `null`.
