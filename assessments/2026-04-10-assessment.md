# AI Literacy Assessment — ai-literacy-superpowers

**Date**: 2026-04-10
**Assessed by**: assessor (via /assess command)
**Assessed level**: Level 5 — Sovereign Engineering

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
| HARNESS.md | Yes — 182 lines, 7 constraints, 7/7 enforced | L3 |
| AGENTS.md | Yes — 88 lines, 8 curated entries | L3 |
| MODEL_ROUTING.md | No | L3 |
| Custom skills | Yes — 23 | L3 |
| Custom agents | Yes — 10 | L3 |
| Custom commands | Yes — 14 | L3 |
| Hooks configured | Yes — 8 hooks in hooks.json | L3 |
| REFLECTION_LOG.md | Yes — 7 entries with Signal field | L3 |
| Specifications directory | Yes — 17 spec files | L4 |
| Implementation plans | Yes — 3 plan files | L4 |
| Orchestrator with safety gates | Yes — GATE and GUARDRAIL in orchestrator.agent.md | L4 |
| Plugin/platform tooling | Yes — published marketplace plugin | L5 |
| Cross-team templates | Yes — HARNESS.md + MODEL_ROUTING.md templates | L5 |
| OTel configuration | No — documented in skills but not configured | L5 |
| Docs site | Yes — GitHub Pages with full Diataxis coverage | L5 |
| Articles | Yes — 7 articles | L5 |
| Portfolio assessment | Yes — with HTML dashboard | L5 |
| Portfolio discovery tag | Yes — agent-harness-enabled topic | L5 |
| Cost tracking | No — no MODEL_ROUTING.md, no cost data | L5 |

### Evidence Summary

This is a published Claude Code plugin consumed by multiple repos in the
Habitat-Thinking org. It originates the entire AI Literacy framework
infrastructure: 23 skills, 10 agents, 14 commands, templates, hooks, and
a complete documentation site.

The plugin has 7/7 constraints enforced in CI (6 deterministic, 1 agent),
including a version consistency check added in v0.8.3. The REFLECTION_LOG
has 7 entries with signal classification. The compound learning pipeline
is active: reflections are curated into AGENTS.md, and the latest
reflection's improvement suggestions have been implemented (how-to
template, CI version check).

The spec-first workflow has been used extensively: 17 specs and 3 plans
across the project's history. The orchestrator agent has safety gates.
The portfolio assessment system (assess → improvements → portfolio →
dashboard → team-api) spans five layers.

Missing: MODEL_ROUTING.md, OTel configuration, cost data.

## Clarifying Responses

- **Spec workflow**: Specs first — consistently, before implementation
- **Agent pipeline**: Used on most features; smaller changes use a subset
- **Cross-team adoption**: Actively consumed by other repos in the org
- **Cost tracking**: No visibility on AI tool costs, no model routing
- **Quarterly cadence**: At least one complete cycle

## Level Assessment

### Primary Level: 5 — Sovereign Engineering

The plugin meets Level 5 requirements across all three disciplines:

- **Platform-level tooling**: The plugin IS the platform. It is published,
  installed by other repos, and provides the complete framework
  infrastructure.
- **Cross-team governance**: Portfolio assessment aggregates across repos.
  The team-api skill bridges to Team Topologies. The agent-harness-enabled
  topic tag enables org-wide discovery.
- **Spec-first workflow**: 17 specs demonstrate consistent use.
- **Compound learning**: 7 reflections, signal classification, curation
  into AGENTS.md, reflection-driven improvements implemented.

### Discipline Maturity

| Discipline | Strength (1-5) | Evidence |
| --- | --- | --- |
| Context Engineering | 5/5 | CLAUDE.md with semver + PR workflow, AGENTS.md with 8 curated entries, 23 skills, 14 commands, 8 hooks, complete docs site (6 tutorials, 23 how-tos, reference pages, 14 explanations), 7 articles |
| Architectural Constraints | 5/5 | 7/7 enforced (6 deterministic, 1 agent), 5 CI workflows, GC rules active via weekly CI + rotating Stop hook, version consistency check |
| Guardrail Design | 4/5 | Orchestrator with safety gates, spec-first on most features, 7 reflections with signal classification, portfolio assessment with dashboard, compound learning active. Missing: cost data, OTel, MODEL_ROUTING.md |

### The Weakest Discipline

Guardrail Design at 4/5 is the ceiling. The gaps are L5 refinements
(cost discipline, automated observability) rather than missing
fundamentals. The project meets all L5 structural requirements; the
remaining work is operational maturity within L5.

## Strengths

- **The plugin IS the platform** — it originates the entire framework
  infrastructure (skills, agents, templates, hooks) consumed by the org
- **Complete documentation** — full Diataxis coverage: 6 tutorials,
  23 how-tos, reference pages, 14 explanation pages, 7 articles
- **Reflection-driven improvement** — the latest session implemented
  both improvements from the reflection log (how-to template, CI
  version check), demonstrating the compound learning loop in action
- **Five-layer assessment stack** — assess → improvements → portfolio
  → dashboard → team-api, each layer reading the output of the one
  below
- **7/7 constraints enforced** — zero unverified constraints, including
  the version consistency check added from a reflection

## Gaps

- **No MODEL_ROUTING.md** — the template exists but hasn't been applied
  to this project. No model routing rules, no cost data.
- **No OTel configuration** — the harness-observability skill documents
  telemetry export, but no actual OTel is configured for this project
- **No cost visibility** — AI tool costs are not tracked or reviewed.
  Cost discipline is theoretical.

## Recommendations

1. **Create MODEL_ROUTING.md** — use the template at
   `templates/MODEL_ROUTING.md` to declare routing rules for this
   project. Even without cost data, documenting which models are used
   for which tasks improves reproducibility.

2. **Collect cost data** — check the AI provider's usage dashboard.
   Record monthly spend in the next health snapshot. Compare with
   model routing guidance.

3. **Evaluate OTel** — decide whether automated observability is worth
   the setup cost for a markdown-only plugin. If yes, follow the
   harness-observability skill's telemetry export reference.

## Immediate Adjustments Applied

1. Updated HARNESS.md Status "Last audit" from 2026-04-08 to 2026-04-10

## Workflow Operation Recommendations

| Recommendation | Status |
| --- | --- |
| Create MODEL_ROUTING.md from template | Accepted — created from templates/MODEL_ROUTING.md |
| Collect cost data in next quarterly review | Deferred — recommendation for Q3 |
| Evaluate OTel for this project | Deferred — markdown plugin may not need OTel |

## Improvement Plan

- Current level: L5
- Target level: L5 (refinement within level)
- Improvements accepted: 1 (MODEL_ROUTING.md)
- Improvements deferred: 2 (cost data, OTel)
- Commands executed: none (MODEL_ROUTING.md was a file copy)

## Next Assessment

Suggested re-assessment date: 2026-07-10 (quarterly)

Previous assessment: first assessment
