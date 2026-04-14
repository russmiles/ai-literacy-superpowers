# Observatory Event Log

The event log records Observatory-relevant state transitions in a
persistent, append-only file. It enables the Observatory to track
precise timing of key events without parsing multiple files across
multiple dates.

## File

**Path:** `observability/events.jsonl`

**Format:** JSON Lines — one JSON object per line, append-only,
committed to git.

**Rules:**

- Create the file if it does not exist (first event creates it)
- Append a single line per event (no pretty-printing)
- Never modify or delete existing lines
- If writing fails, the originating command should complete normally —
  event logging is best-effort, never blocking

## Event Types

### snapshot.created

Emitted by `/harness-health` after a snapshot file is written.

```json
{"type": "snapshot.created", "timestamp": "<ISO 8601 UTC>", "path": "observability/snapshots/YYYY-MM-DD-snapshot.md", "schema_version": "1.2.0", "health": "<Healthy | Attention | Degraded>"}
```

### assessment.completed

Emitted by `/assess` after an assessment file is written.

```json
{"type": "assessment.completed", "timestamp": "<ISO 8601 UTC>", "path": "assessments/YYYY-MM-DD-assessment.md", "level": 3, "previous_level": 2}
```

If no previous assessment exists, `previous_level` is `null`.

### governance.audited

Emitted by the `governance-auditor` agent after an audit file is
written.

```json
{"type": "governance.audited", "timestamp": "<ISO 8601 UTC>", "path": "observability/governance/audit-YYYY-MM-DD.md", "drift_stage": 2, "debt_total_score": 12}
```

### constraint.added

Emitted by `/harness-constrain` when a new constraint is added to
HARNESS.md, or by `/harness-health` when a constraint appears in
the current HARNESS.md but was absent from the previous snapshot's
`constraint_maturity.constraints` array.

```json
{"type": "constraint.added", "timestamp": "<ISO 8601 UTC>", "constraint": "<name>", "tier": "<deterministic | agent_backed | unverified>"}
```

### constraint.promoted

Emitted by `/harness-constrain` when a constraint's tier changes
upward, or by `/harness-health` when a constraint's tier has changed
since the previous snapshot.

```json
{"type": "constraint.promoted", "timestamp": "<ISO 8601 UTC>", "constraint": "<name>", "old_tier": "<previous tier>", "new_tier": "<new tier>"}
```

### constraint.removed

Emitted by `/harness-constrain` when a constraint is removed, or by
`/harness-health` when a constraint was in the previous snapshot but
is absent from the current HARNESS.md.

```json
{"type": "constraint.removed", "timestamp": "<ISO 8601 UTC>", "constraint": "<name>", "reason": "<reason or null>"}
```

### regression.detected

Emitted by `/harness-health` when `regression_flag` transitions from
`false` to `true` (comparing the current computation with the previous
snapshot's `regression_indicators.regression_flag`).

```json
{"type": "regression.detected", "timestamp": "<ISO 8601 UTC>", "trigger": "<snapshot_stale | cadence_non_compliant | zero_reflections>", "snapshot_age_days": 35}
```

The `trigger` field names the specific condition(s) that caused the
flag. If multiple triggers fired, emit one event with the primary
trigger.

### regression.cleared

Emitted by `/harness-health` when `regression_flag` transitions from
`true` to `false`.

```json
{"type": "regression.cleared", "timestamp": "<ISO 8601 UTC>", "duration_days": 17}
```

`duration_days` is the number of days between the `regression.detected`
event and this clearing event.

### reflection.captured

Emitted by `/reflect` after a reflection entry is appended to
REFLECTION_LOG.md.

```json
{"type": "reflection.captured", "timestamp": "<ISO 8601 UTC>", "signal": "<context | instruction | workflow | failure | none>", "has_proposal": true, "has_constraint": false}
```

### cadence.configured

Emitted when the Observability section of HARNESS.md is modified to
change the snapshot cadence.

```json
{"type": "cadence.configured", "timestamp": "<ISO 8601 UTC>", "cadence": "weekly", "previous": "monthly"}
```

## Event Emission Matrix

| Command / Agent | Event type(s) | When |
| --- | --- | --- |
| `/harness-health` | `snapshot.created` | After snapshot file is written |
| `/harness-health` | `regression.detected` | When `regression_flag` transitions false → true |
| `/harness-health` | `regression.cleared` | When `regression_flag` transitions true → false |
| `/harness-health` | `constraint.added`, `constraint.promoted`, `constraint.removed` | When constraint diff detects changes vs previous snapshot |
| `/assess` | `assessment.completed` | After assessment file is written |
| `/governance-audit` | `governance.audited` | After audit file is written |
| `/reflect` | `reflection.captured` | After reflection appended to REFLECTION_LOG.md |
| `/harness-constrain` | `constraint.added`, `constraint.promoted`, `constraint.removed` | When a constraint is added, promoted, or removed |

## Constraint Lifecycle Detection

When `/harness-health` runs, it reads the current HARNESS.md
constraints and compares with the previous snapshot's
`constraint_maturity.constraints` array:

- A constraint in current HARNESS.md but not in the previous
  snapshot: emit `constraint.added`
- A constraint whose tier has changed since the previous snapshot:
  emit `constraint.promoted`
- A constraint in the previous snapshot but absent from the current
  HARNESS.md: emit `constraint.removed`
