---
name: governance-health
description: Show governance health snapshot — constraint count, falsifiability ratio, drift score, debt inventory, last audit date. Pass --dashboard to generate the HTML governance dashboard.
---

# /governance-health

Quick governance health pulse check. Lighter than a full
`/governance-audit` — reads existing data rather than running a
full investigation.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists, tell the user to run `/harness-init` first.

### 2. Find Most Recent Audit

Look for the most recent audit report in
`observability/governance/audit-*.md`. If none exists, warn:

> No governance audit found. Run `/governance-audit` first to
> establish a baseline.

Then fall back to a lightweight assessment: count governance
constraints in HARNESS.md and report the count with a note that
falsifiability, drift, and alignment data require a full audit.

### 3. Read Current State

From HARNESS.md:

- Count governance constraints (those with governance language or
  a `Governance requirement` field)

From the most recent audit report:

- Read the governance metrics block
- Read the constraint assessment table
- Read the debt inventory

### 4. Compute Current Metrics

| Metric | Source |
| --- | --- |
| Constraint count | HARNESS.md (live count) |
| Falsifiability ratio | Most recent audit |
| Drift score | Most recent audit |
| Debt inventory size | Most recent audit |
| Frame alignment score | Most recent audit |
| Last audit | Audit report date |
| Days since audit | Today minus last audit date |
| Drift velocity | Compare current and previous audit drift scores |

### 5. Display Summary

Present a summary table:

```text
Governance Health
─────────────────────────────────────────
Constraints:          4
Falsifiability:       0.75 (3/4 falsifiable)
Drift score:          low
Debt items:           2
Frame alignment:      0.50 (2/4 aligned)
Last audit:           2026-04-13 (0 days ago)
Drift velocity:       stable
─────────────────────────────────────────
```

Apply colour coding:

- Green: falsifiability > 0.75, drift low, debt < 3, audit < 90d
- Amber: falsifiability 0.50-0.75, drift medium, debt 3-5,
  audit 90-180d
- Red: falsifiability < 0.50, drift high, debt > 5, audit > 180d

### 6. Generate Dashboard (if --dashboard flag)

If the user passes `--dashboard` (or explicitly asks for a
dashboard):

1. Read the `governance-observability` skill's
   `references/dashboard-spec.md` for the specification
2. Read all audit reports in `observability/governance/` for
   historical data
3. Generate a self-contained HTML file at
   `observability/governance/governance-dashboard.html`
4. The HTML file embeds all data in a `<script>` tag — no external
   dependencies
5. Open the file in the default browser if possible

### 7. Recommend Next Steps

Based on the health check:

- If audit is stale (> 90 days): recommend `/governance-audit`
- If falsifiability is low: recommend `/governance-constrain` to
  rewrite vague constraints
- If drift is high: recommend `/governance-audit` for full
  investigation
- If debt is growing: highlight highest-scoring debt items
