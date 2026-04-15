---
name: governance-observability
description: Use when defining governance metrics, reading governance health snapshots, generating the governance dashboard, or understanding the governance data model. Referenced by the governance-auditor agent and the /governance-health command.
---

# Governance Observability

Defines the metrics, snapshot formats, and dashboard specifications
for governance health. This skill is referenced by:

- The `governance-auditor` agent when producing audit reports
- The `/governance-health` command when displaying results
- The `/governance-audit` command when updating snapshots
- The portfolio dashboard when aggregating governance data

## Governance Metrics Catalogue

| Metric | Type | Description |
| --- | --- | --- |
| Total constraints | integer | Total governance constraints in HARNESS.md |
| Falsifiability ratio | percentage | Proportion of governance constraints scored as "falsifiable" |
| Falsifiable | integer | Number of constraints rated "Falsifiable" |
| Vague | integer | Number of constraints rated "Vague" |
| Semantic drift stage | integer (1-5) | Numeric semantic drift severity from the five-stage model |
| Drift velocity | enum (stable/increasing/decreasing) | Direction of drift trend between audits |
| Governance debt items | integer | Number of governance debt items identified |
| Aggregate debt score | integer | Sum of (severity x blast_radius) across all debt items |
| Frame alignment score | percentage | Proportion of governance constraints with confirmed three-frame alignment |

## Snapshot Format Extension

Governance metrics are expressed as a markdown section in audit
reports. The governance-auditor includes a Governance Summary section
that agents (including the snapshot generator) can parse directly:

```text
## Governance Summary

- Total constraints: 4
- Falsifiable: 3 (with verification criteria)
- Vague: 0 (lacking operational meaning)
- Falsifiability ratio: 75%
- Semantic drift stage: 1/5
- Drift velocity: stable
- Governance debt items: 2
- Aggregate debt score: 8 (sum of severity x blast radius)
- Frame alignment score: 50%
```

## Staleness Thresholds

| Metric | Fresh | Stale | Critical |
| --- | --- | --- | --- |
| `last_audit` | < 90 days | 90-180 days | > 180 days |
| `drift_velocity` | stable or decreasing | increasing for 1 quarter | increasing for 2+ quarters |
| `falsifiability_ratio` | > 0.75 | 0.50-0.75 | < 0.50 |
| `debt_inventory_size` | 0-2 items | 3-5 items | > 5 items |

## Audit Report Format

Governance audit reports are written to
`observability/governance/audit-YYYY-MM-DD.md` by the
governance-auditor agent. Each report contains:

1. **Summary** — overall governance health score, counts, ratios
2. **Constraint Assessment** — per-constraint table with
   falsifiability score, drift risk, frame alignment, drift stage
3. **Governance Debt Inventory** — per-item table with severity,
   blast radius, score, affected constraints, recommendation
4. **Debt Cycle Analysis** — any reinforcement patterns detected
5. **Prioritised Recommendations** — ordered by debt score

## Dashboard Specification

See `references/dashboard-spec.md` for the full HTML dashboard
specification — sections, data sources, visualisation types, and
colour schemes.

## Portfolio Integration

When governance data is aggregated across repos (via
`/portfolio-assess`), the portfolio dashboard gains:

- A governance column in the repo table showing each repo's
  falsifiability ratio and drift score
- A governance summary section with:
  - Distribution of falsifiability ratios across repos
  - Shared governance gaps (terms that are vague across multiple repos)
  - Drift trend comparison across repos
  - Aggregate debt inventory size
