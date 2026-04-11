# AI Literacy Assessment — ai-literacy-superpowers

**Date**: 2026-04-11
**Assessed by**: assessor (via /assess command)
**Assessed level**: Level 5 — Sovereign Engineering
**Previous assessment**: 2026-04-10 (Level 5)

---

## Observable Evidence

### Repository Signals

| Signal | Found | Level indicator |
| --- | --- | --- |
| CI workflows | Yes — lint-markdown, harness, gc, pages, version-check (5) | L2 |
| Test coverage enforcement | No — not applicable (markdown plugin, no test suite) | L2 |
| Vulnerability scanning | No — not applicable (no application dependencies) | L2 |
| Mutation testing | No — not applicable (no test suite) | L2 |
| Linting in CI | Yes — markdownlint + ShellCheck | L2 |
| CLAUDE.md | Yes — 58 lines, semver convention, PR workflow, CHANGELOG | L3 |
| HARNESS.md | Yes — 7 constraints, 7/7 enforced, 5 GC rules | L3 |
| AGENTS.md | Yes — 10 curated entries (up from 8) | L3 |
| MODEL_ROUTING.md | Yes — created from template during previous assessment | L3 |
| Custom skills | Yes — 24 (up from 23; added cost-tracking) | L3 |
| Custom agents | Yes — 10 | L3 |
| Custom commands | Yes — 15 (up from 14; added /cost-capture) | L3 |
| Hooks configured | Yes — 8 hooks in hooks.json, curation-nudge bug fixed | L3 |
| REFLECTION_LOG.md | Yes — 9 entries with Signal field (up from 7) | L3 |
| .markdownlint.json | Yes | L3 |
| Specifications directory | Yes — 17 spec files | L4 |
| Implementation plans | Yes — 3 plan files | L4 |
| Orchestrator with safety gates | Yes — GATE and GUARDRAIL in orchestrator.agent.md | L4 |
| Plugin/platform tooling | Yes — published plugin v0.9.4 (up from v0.8.2) | L5 |
| Cross-team templates | Yes — HARNESS.md, MODEL_ROUTING.md, CLAUDE.md, AGENTS.md, REFLECTION_LOG.md, 4 CI templates | L5 |
| Human Pace template entries | Yes — spec-scoped changes constraint + cadence drift GC in templates | L5 |
| OTel configuration | No — not applicable for markdown plugin | L5 |
| Docs site | Yes — GitHub Pages, complete Diataxis coverage, zero stubs | L5 |
| Articles | Yes — 8 (up from 7; added The Loops That Learn) | L5 |
| Portfolio assessment | Yes — with HTML dashboard | L5 |
| Portfolio discovery tag | Yes — agent-harness-enabled topic | L5 |
| Cost tracking skill | Yes — skill + /cost-capture command (new since last) | L5 |
| Actual cost data | No — tooling exists but no capture run yet | L5 |
| Small TDD-paced diffs | Yes — visible in commit history (Human Pace L2 signal) | L2 |

### Changes Since Previous Assessment (2026-04-10)

- MODEL_ROUTING.md gap closed (created during last assessment)
- Cost-tracking skill and /cost-capture command added (v0.9.0)
- Article 08: The Loops That Learn added (v0.9.1)
- Curation-nudge Stop hook bug fixed (v0.9.2)
- Human Pace template entries added (v0.9.3)
- All documentation reference stubs completed — zero "Coming Soon" pages (v0.9.4)
- 2 new reflections captured and curated into AGENTS.md GOTCHAS
- Plugin version advanced from v0.8.2 to v0.9.4 (+6 releases)

### Evidence Summary

This is a published Claude Code plugin consumed by multiple repos in the
Habitat-Thinking org. It originates the entire AI Literacy framework
infrastructure: 24 skills, 10 agents, 15 commands, 10 templates, 8 hooks,
and a complete documentation site with zero stub pages.

The plugin has 7/7 constraints enforced in CI (5 deterministic, 1 agent,
1 deterministic via CI workflow). The REFLECTION_LOG has 9 entries with
signal classification. The compound learning pipeline is active and
regular: reflections are curated into AGENTS.md across sessions, with
the latest session adding 2 new GOTCHAS entries.

The cost-tracking gap from the previous assessment has been partially
addressed: the skill and command exist, but no cost data has been
captured yet. The OTel gap has been reclassified as not applicable
for a markdown-only plugin.

New gap: the Human Pace template entries (spec-scoped changes constraint,
change cadence drift GC rule) are shipped for downstream consumers but
not applied to the project's own HARNESS.md.

## Clarifying Responses

- **Cost capture**: Tooling exists but no data captured yet
- **OTel**: Not applicable — markdown plugin has no runtime to instrument
- **Human Pace in own HARNESS.md**: Not yet applied — should be
- **Compound learning curation**: Happening regularly across sessions

## Level Assessment

### Primary Level: 5 — Sovereign Engineering

The plugin continues to meet Level 5 requirements across all three
disciplines. Since the last assessment, the primary improvements are:

- **Cost discipline infrastructure** now exists (was completely absent)
- **Documentation completeness** is now 100% (was ~70% with 3 stubs)
- **Compound learning velocity** increased (2 new reflections, 2 curated)
- **Human Pace signals** added to the assessment framework itself

### Discipline Maturity

| Discipline | Strength (1-5) | Change | Evidence |
| --- | --- | --- | --- |
| Context Engineering | 5/5 | Stable | CLAUDE.md, AGENTS.md (10 entries), 24 skills, 15 commands, 8 hooks, complete docs (zero stubs), 8 articles, MODEL_ROUTING.md |
| Architectural Constraints | 5/5 | Stable | 7/7 enforced (5 deterministic, 1 agent, 1 CI workflow), 5 CI workflows, 5 GC rules, version consistency check |
| Guardrail Design | 4.5/5 | Up from 4/5 | Orchestrator with safety gates, spec-first workflow, 9 reflections with signal classification, portfolio assessment, compound learning active and regular, cost-tracking tooling exists. Gap: no cost data yet |

### The Weakest Discipline

Guardrail Design at 4.5/5 remains the ceiling, improved from 4/5.
The cost-tracking infrastructure now exists (skill + command + template
entries in MODEL_ROUTING.md) but hasn't produced data. One cost capture
cycle would close this to 5/5.

## Strengths

- **Documentation completeness**: zero stubs remaining in the docs site —
  all reference pages (skills, commands, agents, hooks, templates,
  harness-md-format) are fully written
- **Active compound learning**: regular curation across sessions, not
  just batch catch-ups. 2 new GOTCHAS curated from reflections in the
  latest session
- **Self-referential improvement**: the plugin's own assessment framework
  now includes Human Pace signals, and the assessment skill was updated
  to detect them
- **Rapid iteration**: 6 releases (v0.8.2 → v0.9.4) in 2 days, each
  following the full PR workflow with CI checks

## Gaps

- **No cost data captured**: The /cost-capture command and cost-tracking
  skill exist but have never been run. Cost discipline is infrastructure
  without operation — exactly the pattern Article 08 warns about.
- **Human Pace not in own HARNESS.md**: The spec-scoped changes constraint
  and change cadence drift GC rule are in the template but not applied
  to this project. The cobbler's children pattern, again.
- **GC active ratio**: HARNESS.md Status shows 2/5 GC rules active.
  Three agent-scoped GC rules (documentation freshness, command-prompt
  sync, plugin manifest currency) run only via /harness-gc or
  /harness-health --deep, not on a schedule.

## Recommendations

1. **Run /cost-capture** — even a single data point closes the cost
   discipline gap. The tooling exists; it just needs one execution cycle.

2. **Apply Human Pace to own HARNESS.md** — add the spec-scoped changes
   constraint and change cadence drift GC rule from the template. This
   project should use what it ships.

3. **Schedule agent GC rules** — the 3 agent-scoped GC rules could run
   via a weekly CI job dispatching /harness-gc, raising the active ratio
   from 2/5 to 5/5.

## Immediate Adjustments Applied

1. **Add spec-scoped changes constraint to HARNESS.md** — from template,
   applying to this project
2. **Add change cadence drift GC rule to HARNESS.md** — from template,
   applying to this project
3. **Update HARNESS.md Status** — update counts and last audit date
4. **Update README** — stale counts if any (skills 24, commands 15,
   articles 8)

## Workflow Operation Recommendations

*Presented one at a time during assessment — see below for outcomes.*

| Recommendation | Status |
| --- | --- |
| Add Human Pace entries to own HARNESS.md | Pending |
| Run /cost-capture before next assessment | Pending |
| Update HARNESS.md GC active count after adding cadence drift | Pending |

## Improvement Plan

- Current level: L5
- Target level: L5 (refinement within level)
- Key improvement: cost discipline activation (run /cost-capture)
- Secondary: Human Pace self-application, GC active ratio

## Next Assessment

Suggested re-assessment date: 2026-07-11 (quarterly)

Previous assessment: 2026-04-10 (Level 5)
