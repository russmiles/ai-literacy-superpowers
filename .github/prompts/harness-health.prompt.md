---
name: harness-health
description: Generate a harness health snapshot with enforcement status, trends, and meta-observability checks
---

Generate a health snapshot. Read
#file:skills/harness-observability/SKILL.md first.

**Quick mode** (default): read existing data sources — HARNESS.md
Status, REFLECTION_LOG.md count, AGENTS.md count, assessment dates,
MODEL_ROUTING.md presence.

**Deep mode** (with --deep): dispatch harness-auditor for authoritative
verification and run meta-observability checks from
#file:skills/harness-observability/references/meta-observability-checks.md

**Trends mode** (with --trends): read all snapshots in
observability/snapshots/ for multi-period view.

1. Gather data from sources above
2. Find previous snapshot for trend comparison
3. Compute meta-observability status
4. Write snapshot to `observability/snapshots/YYYY-MM-DD-snapshot.md`
   using format from
   #file:skills/harness-observability/references/snapshot-format.md
5. Update README health badge via `scripts/update-health-badge.sh`
6. Print snapshot and delta summary
7. Nudge any overdue cadences
