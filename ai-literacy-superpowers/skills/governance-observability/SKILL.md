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
| `constraint_count` | integer | Total governance constraints in HARNESS.md |
| `falsifiability_ratio` | float (0-1) | Proportion of governance constraints scored as "falsifiable" |
| `drift_score` | enum (low/medium/high) | Overall semantic drift risk across all governance constraints |
| `debt_inventory_size` | integer | Number of governance debt items identified |
| `frame_alignment_score` | float (0-1) | Proportion of governance constraints with confirmed three-frame alignment |
| `last_audit` | date (YYYY-MM-DD) | Date of most recent governance audit |
| `drift_velocity` | enum (stable/increasing/decreasing) | Direction of drift trend between audits |

## Snapshot Format Extension

The governance block is added to existing harness health snapshots
in `observability/snapshots/`. It sits alongside the existing
harness metrics:

```yaml
governance:
  constraint_count: 4
  falsifiability_ratio: 0.75
  drift_score: low
  debt_inventory_size: 2
  frame_alignment_score: 0.50
  last_audit: 2026-04-13
  drift_velocity: stable
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
5. **Governance Metrics Block** — the YAML block for snapshot
   inclusion
6. **Prioritised Recommendations** — ordered by debt score

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
