# Meta-Observability Checks Reference

Meta-observability is the self-referential layer: the harness checking
whether its own observability is working. These checks are run by the
harness-auditor agent as part of `/harness-health --deep` and during
`/harness-audit`.

"A harness that cannot verify its own operation is a harness you hope
works."

## The Five Checks

### 1. Snapshot Currency

**What it verifies:** The most recent snapshot in
`observability/snapshots/` is within the project's configured cadence
threshold.

**How to check:**

1. Read HARNESS.md Observability section for `Snapshot cadence` value
2. Map cadence to threshold: weekly=10 days, fortnightly=21 days,
   monthly=30 days. Default to monthly if not configured.
3. List files in `observability/snapshots/`
4. Parse the most recent filename date (YYYY-MM-DD)
5. Compare with today's date using the configured threshold

**Thresholds:**

| Age | Status | Signal |
| ----- | -------- | -------- |
| < threshold | On schedule | Outer loop is running |
| threshold to 2× threshold | Overdue | Outer loop slipping |
| > 2× threshold | Stale | Outer loop not running |

Where threshold is the configured cadence threshold (weekly=10,
fortnightly=21, monthly=30).

**What it means:** If snapshots aren't being taken, the harness has no
visibility into its own health. All other observability layers depend on
this one.

### 2. Cadence Compliance

**What it verifies:** Key harness operations ran within their declared
cadence.

**How to check:**

1. Read HARNESS.md Status section for last audit date
2. Read most recent assessment file date in `assessments/`
3. Read most recent reflection date in REFLECTION_LOG.md
4. Compare each with its declared cadence

**Declared cadences:**

| Operation | Cadence | Source |
| ----------- | --------- | -------- |
| /harness-audit | Quarterly (90 days) | CLAUDE.md quarterly cadence |
| /assess | Quarterly (90 days) | CLAUDE.md quarterly cadence |
| /reflect | Monthly (30 days) | Best practice for active projects |

**Thresholds:**

| Overdue by | Status |
| ------------ | -------- |
| 0 | On schedule |
| 1-30 days | Slightly overdue |
| > 30 days | Significantly overdue |

### 3. Learning Flow

**What it verifies:** New reflections are being reviewed for promotion
to AGENTS.md. The compound learning lifecycle (reflect → curate →
benefit) is active.

**How to check:**

1. Count REFLECTION_LOG.md entries added since last snapshot
2. Count AGENTS.md entries added since last snapshot
3. If reflections were added but no promotions occurred in 2+
   consecutive snapshots, the flow is stalled

**Thresholds:**

| Condition | Status |
| ----------- | -------- |
| Reflections added AND promotions occurring | Active |
| Reflections added but no promotions for 2+ snapshots | Stalled |
| No reflections added for 2+ snapshots | Inactive |
| No REFLECTION_LOG.md exists | Not configured |

**What it means:** Compound learning requires human curation. If
reflections pile up without promotion, the learning cycle is broken —
agents write but nobody reads.

### 4. GC Effectiveness

**What it verifies:** Garbage collection rules are actually catching
entropy. Silent GC rules may indicate misconfiguration or that the
rules are checking the wrong things.

**How to check:**

1. Read the current and previous snapshot's "GC findings" count
2. If findings have been 0 for 3+ consecutive snapshots, flag as
   silent

**Thresholds:**

| Condition | Status |
| ----------- | -------- |
| Findings > 0 in at least one of last 3 snapshots | Productive |
| Findings = 0 for 3+ consecutive snapshots | Silent |
| No GC rules configured | Not configured |

**What it means:** A productive codebase generates entropy. GC rules
that never find anything are either perfectly calibrated (unlikely) or
not checking the right things. Silent rules warrant investigation, not
panic.

### 5. Trend Direction

**What it verifies:** No metric has declined for 3 or more consecutive
snapshots without acknowledgement.

**How to check:**

1. Read the Trends sections from the last 3 snapshots
2. For each tracked metric, check if it has declined in all 3
3. If so, check whether the decline has been acknowledged (a comment
   in the snapshot's Meta section or a reflection entry)

**Tracked metrics:**

- Enforcement ratio
- Mutation kill rates (per language)
- Compound learning entries

**Thresholds:**

| Condition | Status |
| ----------- | -------- |
| No sustained declines | Stable |
| Decline for 3+ snapshots, acknowledged | Acknowledged |
| Decline for 3+ snapshots, unacknowledged | Alert |

**What it means:** Gradual decline is the hardest drift to notice.
Three consecutive drops in the same direction is a signal, not noise.
Acknowledgement means someone has seen it and either accepted it (e.g.
"mutation score dropped because we removed a module") or is acting on
it.

## Aggregate Health Status

The five checks combine into the snapshot's Meta section and the README
badge colour:

| Badge | Condition |
| ------- | ----------- |
| Healthy (green) | All five checks pass |
| Attention (amber) | One check is overdue/stalled/silent/alert |
| Degraded (red) | Two or more checks are overdue/stalled/silent/alert, OR snapshot is stale (>30 days), OR enforcement ratio < 70% |

The badge colour always reflects the worst status across all five
checks plus the enforcement ratio threshold.
