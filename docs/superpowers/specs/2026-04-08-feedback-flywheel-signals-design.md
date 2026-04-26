---
diaboli: exempt-pre-existing
---

# Feedback Flywheel Signal Classification, Vocabulary Alignment, and Quality Metrics

**Date:** 2026-04-08
**Status:** Draft
**Source:** [The Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) by Birgitta Boeckeler

---

## Context

The Feedback Flywheel article introduces a four-signal taxonomy for
classifying learnings from AI-assisted development sessions. The plugin
already implements the core flywheel concept through its three-loop
system, reflection log, and curation promotion pipeline. This spec adds
three changes to align with and extend the article's framework.

---

## Change 1: Signal Classification on Reflections

### Problem

Reflections in REFLECTION_LOG.md are untyped. The Surprise, Proposal,
and Improvement fields capture useful information but do not classify
*why* something happened or *where* the fix should land. This makes
routing learnings to the right harness component a manual judgement call
during curation.

### Design

Add a `Signal` field to the reflection entry format. Values:

| Signal | Meaning | Routes to |
| -------- | --------- | ----------- |
| `context` | Gap in priming — missing convention, outdated stack info, incomplete domain knowledge | HARNESS.md Context section |
| `instruction` | Prompt or command that produced notably better or worse results | Skills or shared commands |
| `workflow` | Sequence or process pattern that reliably succeeded or failed | AGENTS.md (STYLE, ARCH_DECISIONS) |
| `failure` | Preventable error — missing check, wrong tool config, boundary condition | Constraints via `/harness-constrain` |
| `none` | No classifiable signal — routine work, nothing novel | No routing needed |

### Updated reflection template

```text
---

- **Date**: YYYY-MM-DD
- **Agent**: [who did the work]
- **Task**: [one-sentence summary]
- **Surprise**: [anything unexpected]
- **Proposal**: [what to add to AGENTS.md, or "none"]
- **Improvement**: [what would make the process better]
- **Signal**: [context | instruction | workflow | failure | none]
- **Constraint**: [proposed constraint, or "none"]
```

### `/reflect` command changes

After gathering Surprise and Improvement and before the auto-constraint
step, the command:

1. Reviews the Surprise and Improvement fields
2. Proposes a signal type with a one-sentence rationale
3. Presents it to the user for confirmation (with option to override)

Signal classification happens before the auto-constraint step because
`failure` signals feed directly into constraint proposals.

### Files changed

- `ai-literacy-superpowers/commands/reflect.md` — add signal
  classification step between gathering fields and auto-constraint
- `REFLECTION_LOG.md` — update header comment with new entry format
  including Signal field
- `docs/explanation/self-improving-harness.md` — update "What Gets
  Captured" section with Signal field and routing table

---

## Change 2: Vocabulary Alignment in Docs

### Problem

The article's terminology (feedback flywheel, four signals, priming
document) is gaining traction via martinfowler.com. The plugin
implements equivalent concepts under different names. Users who have
read the article series cannot easily recognise the mapping.

### Design

Add a "Relationship to the Feedback Flywheel" section to
`docs/explanation/compound-learning.md` after "Three Loops, One System"
and before the FAQ. The section:

- Maps article terms to plugin equivalents in a table
- Cites and links the article directly
- Notes the shared intellectual heritage (Birgitta Boeckeler, already
  credited in the docs footer)

Mapping table:

| Article term | Plugin equivalent |
| --- | --- |
| Feedback flywheel | Three-loop system (inner/middle/outer) |
| Priming document | HARNESS.md Context section + CLAUDE.md |
| Shared commands | Skills and slash commands |
| Team playbooks | AGENTS.md (STYLE, GOTCHAS, ARCH_DECISIONS) |
| Guardrails | Constraints + enforcement loops |
| Learning log | REFLECTION_LOG.md |
| Four signals (context, instruction, workflow, failure) | Signal field on reflections |
| Four cadences (session, daily, retro, quarterly) | Stop hooks (session), snapshots (monthly), audit/assess (quarterly) |

Add the article to "Further reading" in both `compound-learning.md` and
`self-improving-harness.md`.

### Files changed

- `docs/explanation/compound-learning.md` — add mapping section and
  further reading entry
- `docs/explanation/self-improving-harness.md` — add further reading
  entry

---

## Change 3: Quality Metrics in Snapshots

### Problem

The plugin tracks "learning velocity" (reflection and promotion counts)
but not learning *quality*. The article recommends tracking first-pass
acceptance rate and iteration cycles, but these require instrumentation
that does not exist. Signal classification (Change 1) provides a proxy:
reflections with classified signals are higher-value than routine ones.

### Design

Add a `Session Quality` section to the snapshot format after
`Compound Learning` and before `Operational Cadence`.

```text
## Session Quality

- Reflections with signal: N/M (P%)
- Signal distribution: context: X | instruction: Y | workflow: Z | failure: W
- Quality trend: improving/stable/declining (vs previous snapshot)
```

Computation:

| Field | How to compute |
| --- | --- |
| Reflections with signal | Count reflections where Signal field exists and is not "none", divided by total reflections |
| Signal distribution | Count of each signal type across all reflections (cumulative) |
| Quality trend | Compare "reflections with signal" percentage to previous snapshot. Stable = ±2%, improving = >+2%, declining = <-2% |

Add one row to the Trends table:

```text
| Reflections with signal | P% (N/M) | P% (N/M) | ±N% |
```

### Rationale

- Reflections with `none` signal are routine — fine but not driving
  improvement
- As the harness matures, a higher proportion of reflections should
  carry signal (the article's insight that "the nature of reflections
  changes")
- Signal distribution shows where learning is concentrated — heavy
  `failure` signals suggest the harness is catching up; heavy `context`
  or `workflow` signals suggest mature refinement

### Files changed

- `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
  — add Session Quality section definition
- `ai-literacy-superpowers/commands/harness-health.md` — add Session
  Quality to data gathering and generation steps

---

## Files changed (complete list)

1. `ai-literacy-superpowers/commands/reflect.md`
2. `REFLECTION_LOG.md`
3. `docs/explanation/self-improving-harness.md`
4. `docs/explanation/compound-learning.md`
5. `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
6. `ai-literacy-superpowers/commands/harness-health.md`
7. `CHANGELOG.md`

---

## Out of scope

- Per-session iteration cycle tracking (requires instrumentation)
- First-pass acceptance rate (requires instrumentation)
- Auto-routing of reflections to harness components (future work —
  signal field enables it but routing is manual for now)
- Daily/sprint cadence mechanisms (the article describes these but
  they are team process, not plugin infrastructure)
