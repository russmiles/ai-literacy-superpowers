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

### Enforcement Loop History

```text
## Enforcement Loop History

- Advisory (edit-time): active since YYYY-MM-DD
- Strict (merge-time): active since YYYY-MM-DD (or "not active")
- Investigative (scheduled): active since YYYY-MM-DD (or "not active")
```

**Source:** Git history and file existence checks.

| Field | How to compute |
|-------|---------------|
| Advisory | Active if hooks exist. First activated = earliest git commit that added hooks configuration (`git log --diff-filter=A --format=%as` on the hooks file). "not active" if no hooks |
| Strict | Active if CI enforcement workflow exists (`.github/workflows/harness.yml` or similar). First activated = earliest commit adding the harness CI workflow. "not active" if no CI enforcement |
| Investigative | Active if GC rules exist in HARNESS.md with enforcement. First activated = earliest commit adding a GC rule. "not active" if no GC rules |

After first computation, subsequent snapshots can read the dates from
the previous snapshot and only re-check if a loop's status changes.

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

### Session Quality

```text
## Session Quality

- Reflections with signal: N/M (P%)
- Signal distribution: context: X | instruction: Y | workflow: Z | failure: W
- Quality trend: improving/stable/declining (vs previous snapshot)
```

**Source:** REFLECTION_LOG.md Signal fields.

| Field | How to compute |
|-------|---------------|
| Reflections with signal | Count reflections where Signal field exists and is not "none", divided by total reflections. Entries predating the Signal field (before 2026-04-08) count as "none". |
| Signal distribution | Count of each signal type across all reflections (cumulative, not just since last snapshot) |
| Quality trend | Compare "reflections with signal" percentage to previous snapshot. stable = ±2%, improving = >+2%, declining = <-2% |

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
- Last cost capture: YYYY-MM-DD (or "never")
- Monthly average: $X,XXX (or "not tracked")
- Budget status: within/over/not set
- Cost trend: increasing/stable/decreasing (vs previous capture)
```

**Source:** MODEL_ROUTING.md existence and content, plus the most
recent file in `observability/costs/` matching `*-costs.md`.

| Field | How to compute |
|-------|---------------|
| Model routing configured | Check MODEL_ROUTING.md exists and has routing table |
| Tier distribution | Read Agent Routing table from MODEL_ROUTING.md |
| Last cost capture | Most recent filename date in observability/costs/ |
| Monthly average | Read from the most recent cost snapshot |
| Budget status | Read from the most recent cost snapshot |
| Cost trend | Compare current and previous cost snapshots |

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

### Regression Indicators

```text
## Regression Indicators

- Snapshot stale: yes/no (> configured cadence threshold)
- Snapshot age: N days
- Cadence non-compliance: N of 4 activities overdue (audit, assess, reflect, GC)
- Consecutive weeks without reflections: N
- Regression flag: yes/no
```

**Source:** Computed from Operational Cadence and REFLECTION_LOG.md.

| Field | How to compute |
|-------|---------------|
| Snapshot stale | Compare previous snapshot date to today. Stale if age exceeds the cadence threshold (10 days for weekly, 21 for fortnightly, 30 for monthly). Read cadence from HARNESS.md Observability section, default monthly |
| Snapshot age | Days between previous snapshot date and today. 0 if this is the first snapshot |
| Cadence non-compliance | Count how many of audit (90-day cadence), assess (90-day), reflect (30-day), and GC (declared cadence) are overdue. Reuse data from Operational Cadence section |
| Consecutive weeks without reflections | Count calendar weeks backwards from today with zero REFLECTION_LOG.md entries. 0 if the most recent entry is this week |
| Regression flag | "yes" if any of: stale = yes, non-compliance >= 2, or consecutive weeks >= 4 |

### Changes Since Last Snapshot

```text
## Changes Since Last Snapshot

- Constraints added: [list or "none"]
- Constraints promoted: [list with old → new tier, or "none"]
- Constraints removed: [list or "none"]
- Assessments completed: [dates and levels, or "none"]
- Governance audits completed: [dates, or "none"]
```

**Source:** Comparison of current HARNESS.md with previous snapshot's
Enforcement section, plus file listings in `assessments/` and
`observability/governance/`.

| Field | How to compute |
|-------|---------------|
| Constraints added | Names of constraints in current HARNESS.md not present in the previous snapshot's Enforcement section |
| Constraints promoted | Constraints whose tier changed between snapshots, shown as `name: old tier → new tier` |
| Constraints removed | Constraints present in the previous snapshot but absent from current HARNESS.md |
| Assessments completed | Dates and levels from assessment files in `assessments/` created since the previous snapshot date |
| Governance audits completed | Dates from audit files in `observability/governance/` created since the previous snapshot date |

If no previous snapshot exists, report "first snapshot" for all fields.

This section replaces the separate event log — constraint lifecycle
and assessment events are captured directly in the snapshot.

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
| Reflections with signal | P% (N/M) | P% (N/M) | ±N% |
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
