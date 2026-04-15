# Telemetry Export Reference

This reference documents how to export harness health snapshot data as
OpenTelemetry metrics for teams that want external dashboards. This is
Layer 3 of harness observability — optional for teams using the
file-based approach (Layers 1-2), valuable for teams operating at scale.

## Metric Definitions

All metrics use the `harness.` namespace following OpenTelemetry
semantic conventions.

### Enforcement Metrics

| Metric | Type | Unit | Description |
| -------- | ------ | ------ | ------------- |
| `harness.enforcement.ratio` | Gauge | ratio (0-1) | Enforced constraints / total constraints |
| `harness.enforcement.deterministic` | Gauge | count | Constraints backed by deterministic tools |
| `harness.enforcement.agent` | Gauge | count | Constraints backed by agent review |
| `harness.enforcement.unverified` | Gauge | count | Declared but unautomated constraints |

### Mutation Testing Metrics

| Metric | Type | Unit | Description |
| -------- | ------ | ------ | ------------- |
| `harness.mutation.kill_rate` | Gauge | ratio (0-1) | Mutation kill rate per language |

Attribute: `language` = `go` | `kotlin` | `python` | `csharp` | `js`

### Garbage Collection Metrics

| Metric | Type | Unit | Description |
| -------- | ------ | ------ | ------------- |
| `harness.gc.rules_active` | Gauge | count | GC rules with enforcement configured |
| `harness.gc.findings` | Counter | count | Cumulative GC findings |

### Compound Learning Metrics

| Metric | Type | Unit | Description |
| -------- | ------ | ------ | ------------- |
| `harness.learning.reflections` | Counter | count | Total REFLECTION_LOG entries |
| `harness.learning.promotions` | Counter | count | Entries promoted to AGENTS.md |

### Operational Metrics

| Metric | Type | Unit | Description |
| -------- | ------ | ------ | ------------- |
| `harness.cadence.days_since_audit` | Gauge | days | Days since last /harness-audit |
| `harness.cadence.days_since_assess` | Gauge | days | Days since last /assess |
| `harness.cadence.days_since_reflect` | Gauge | days | Days since last /reflect |
| `harness.health.status` | Gauge | enum (0/1/2) | 0 = Healthy, 1 = Attention, 2 = Degraded |

## Export Targets

### OTLP Collector

For Grafana, Datadog, or any OTel-compatible backend. Configure an OTLP
exporter pointing at your collector endpoint:

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
export OTEL_SERVICE_NAME="harness-health"
```

### Langfuse

For teams already using Langfuse for LLM observability. Langfuse
accepts OTLP traces and metrics, so harness health data appears
alongside LLM interaction traces.

### stdout/JSON

For piping into CI artifacts or custom tooling:

```bash
./export-snapshot.sh --format json observability/snapshots/latest.md
```

## Reference Export Script

A reference bash script that reads a snapshot and emits metrics to
stdout in JSON format. Teams adapt this for their export target.

```bash
#!/usr/bin/env bash
# export-snapshot.sh — Export harness health snapshot as JSON metrics
#
# Reads a snapshot markdown file and emits structured JSON suitable
# for piping to an OTLP collector or logging to CI artifacts.
#
# Usage: export-snapshot.sh [--format json|text] <snapshot-file>

set -euo pipefail

FORMAT="${1:---format}"
if [ "$FORMAT" = "--format" ]; then
  FORMAT="${2:-json}"
  SNAPSHOT_FILE="${3}"
else
  SNAPSHOT_FILE="${1}"
fi

if [ ! -f "$SNAPSHOT_FILE" ]; then
  echo "Error: Snapshot file not found: $SNAPSHOT_FILE" >&2
  exit 1
fi

# Parse enforcement ratio
enforced_line=$(grep -E '^- Constraints:' "$SNAPSHOT_FILE" || echo "")
if [ -n "$enforced_line" ]; then
  ratio=$(echo "$enforced_line" | grep -oE '[0-9]+/[0-9]+')
  numerator=$(echo "$ratio" | cut -d'/' -f1)
  denominator=$(echo "$ratio" | cut -d'/' -f2)
  if [ "$denominator" -gt 0 ]; then
    enforcement_ratio=$(echo "scale=2; $numerator / $denominator" | bc)
  else
    enforcement_ratio="0"
  fi
fi

# Parse mutation rates
go_rate=$(grep -E '^- Go kill rate:' "$SNAPSHOT_FILE" | grep -oE '[0-9]+' || echo "0")
kotlin_rate=$(grep -E '^- Kotlin kill rate:' "$SNAPSHOT_FILE" | grep -oE '[0-9]+' || echo "0")
python_rate=$(grep -E '^- Python kill rate:' "$SNAPSHOT_FILE" | grep -oE '[0-9]+' || echo "0")

# Parse learning counts
reflections=$(grep -E '^- REFLECTION_LOG entries:' "$SNAPSHOT_FILE" | grep -oE '[0-9]+' | head -1 || echo "0")

# Parse health status
health_status="0"
if grep -q 'Snapshot cadence: overdue' "$SNAPSHOT_FILE"; then
  health_status="1"
fi
if grep -q 'Trend alerts:' "$SNAPSHOT_FILE" | grep -v 'none'; then
  health_status="2"
fi

if [ "$FORMAT" = "json" ]; then
  cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "metrics": {
    "harness.enforcement.ratio": ${enforcement_ratio:-0},
    "harness.mutation.kill_rate.go": ${go_rate:-0},
    "harness.mutation.kill_rate.kotlin": ${kotlin_rate:-0},
    "harness.mutation.kill_rate.python": ${python_rate:-0},
    "harness.learning.reflections": ${reflections:-0},
    "harness.health.status": ${health_status}
  }
}
EOF
else
  echo "harness.enforcement.ratio: ${enforcement_ratio:-0}"
  echo "harness.mutation.kill_rate.go: ${go_rate:-0}"
  echo "harness.mutation.kill_rate.kotlin: ${kotlin_rate:-0}"
  echo "harness.mutation.kill_rate.python: ${python_rate:-0}"
  echo "harness.learning.reflections: ${reflections:-0}"
  echo "harness.health.status: ${health_status}"
fi
```

This script is a starting point. Production deployments should use a
proper OTel SDK (Python, Go, or Node) for reliable metric emission with
batching and retry.

## Dashboard Patterns

For teams building dashboards, recommended panels:

| Panel | Metric | Visualisation |
| ------- | -------- | -------------- |
| Enforcement health | `harness.enforcement.ratio` | Gauge (0-100%) |
| Constraint breakdown | `deterministic` + `agent` + `unverified` | Stacked bar |
| Mutation trend | `harness.mutation.kill_rate` by language | Time series |
| Learning velocity | `harness.learning.reflections` | Counter over time |
| Cadence compliance | `days_since_audit` / `assess` / `reflect` | Traffic light |
| Overall health | `harness.health.status` | Status indicator |
