# AI Literacy Assessment — ai-literacy-superpowers

**Date**: 2026-04-28
**Assessed by**: assessor (via /assess command)
**Assessed level**: Level 5 — Sovereign Engineering
**Previous assessment**: 2026-04-11 (Level 5)

---

## Observable Evidence

### Repository Signals

| Signal | Found | Level indicator |
| --- | --- | --- |
| CI workflows | Yes — 7 (lint-markdown, harness, gc, pages, version-check, spec-first-check, auto-tag) | L2 |
| Test coverage enforcement | N/A — content-only plugin | L2 |
| Vulnerability scanning | N/A — content-only plugin | L2 |
| Mutation testing | N/A — content-only plugin | L2 |
| Linting in CI | Yes — markdownlint, ShellCheck, bash -n, gitleaks | L2 |
| CLAUDE.md | Yes — branch discipline, PR workflow, semver, output-validation checkpoints, docs review, marketplace cache auto-sync | L3 |
| HARNESS.md | Yes — 19 constraints (18 enforced, 1 unverified by design), 15 GC rules | L3 |
| AGENTS.md | Yes — STYLE/GOTCHAS/ARCH_DECISIONS/TEST_STRATEGY/DESIGN_DECISIONS, 2 patterns promoted 2026-04-28 | L3 |
| MODEL_ROUTING.md | Yes — agent tier table, token budgets, sovereignty/data-classification, fallback strategy | L3 |
| Custom skills | Yes — 30 in `ai-literacy-superpowers/skills/` | L3 |
| Custom agents | Yes — 13 (assessor, advocatus-diaboli, choice-cartographer, code-reviewer, governance-auditor, harness-auditor, harness-discoverer, harness-enforcer, harness-gc, integration-agent, orchestrator, spec-writer, tdd-agent) | L3 |
| Custom commands | Yes — 24 | L3 |
| Hooks configured | Yes — 10 scripts (curation, drift, framework-change, gc-rotate, governance-drift, markdownlint, reflection, secrets, snapshot-staleness, template-currency) | L3 |
| REFLECTION_LOG.md | Yes — 25 entries, 21/25 (84%) with Signal field; signal distribution: workflow 14, failure 3, context 3, instruction 1 | L3 |
| .markdownlint.json | Yes | L3 |
| Specifications directory | Yes — 33 spec files in `docs/superpowers/specs/` | L4 |
| Implementation plans | Yes — `docs/superpowers/plans/` | L4 |
| Orchestrator with safety gates | Yes — plan-approval gate AND integration-approval gate (mirrored for diaboli code-mode) | L4 |
| Adversarial review at gates | Yes — advocatus-diaboli hard-wired as PR constraint, both spec-time and code-time dispatches | L4+ |
| Decision archaeology | Yes — choice-cartographer agent + `/choice-cartograph` command + adjudicated-stories constraint (new since last assessment) | L5 |
| Plugin/platform tooling | Yes — published plugin v0.31.0 (was v0.9.4) | L5 |
| Cross-team templates | Yes — HARNESS.md, MODEL_ROUTING.md, CLAUDE.md, AGENTS.md, REFLECTION_LOG.md, 7 CI templates | L5 |
| Governance subsystem | Yes — governance-auditor agent, `/governance-audit`, `/governance-constrain`, `/governance-health`, `observability/governance/` (entirely new since last assessment) | L5+ |
| OTel configuration | N/A — content-only plugin | L5 |
| Docs site | Yes — `docs/` Diataxis structure, GitHub Pages, complete | L5 |
| Articles | Yes — 8 (stable since last assessment) | L5 |
| Portfolio assessment | Yes — tooling + HTML dashboard | L5 |
| Portfolio discovery tag | Yes — `agent-harness-enabled` topic | L5 |
| Cost-tracking infrastructure | Yes — `/cost-capture` + cost-tracking skill + MODEL_ROUTING.md | L5 |
| Actual cost data | **No — never captured** (same gap as 2026-04-11) | L5 gap |
| Small TDD-paced diffs | Yes — visible in commit history (Human Pace L2 signal) | L2 |

### Changes Since Previous Assessment (2026-04-11)

- Plugin v0.9.4 → v0.31.0 (22 minor releases over 17 days, 194 commits)
- Skills: 24 → 30 (+6)
- Agents: 10 → 13 (+3: advocatus-diaboli, choice-cartographer, governance-auditor)
- Commands: 15 → 24 (+9: governance-audit, governance-constrain, governance-health, choice-cartograph, harness-affordance, observatory-verify, harness-onboarding, harness-upgrade, diaboli)
- Hooks: 8 → 10 scripts (+governance-drift, +template-currency)
- Constraints in HARNESS.md: 7 → 19 (+12)
- GC rules in HARNESS.md: 5 → 15 (+10)
- Specs: 17 → 33 (+16)
- Reflections: 12 → 25 (+13); signal coverage 67% → 84%
- New subsystems: **governance** (auditor + audit/constrain/health commands + observability dir), **decision archaeology** (choice-cartographer + adjudicated-stories constraint), **adversarial review** (advocatus-diaboli + spec-time + code-time + adjudicated-objections constraint), **harness affordances** (discover command)
- 2 patterns promoted from REFLECTION_LOG to AGENTS.md on 2026-04-28 (chore-PR pattern, references-file idiom)

### Evidence Summary

This published Claude Code plugin continues to originate the entire AI
Literacy framework infrastructure. Since the last assessment, three
substantive new subsystems have shipped — governance, decision archaeology,
and dual-mode adversarial review — each integrated into the harness as PR
constraints. The plugin meets every L5 criterion.

The persistent cost-data gap from 2026-04-11 has not closed: tooling
exists, but `/cost-capture` has never been run. Per Q1 in this assessment,
the cause is forgotten cadence, not tool friction — a calendar anchor is
the right intervention.

Two new gaps emerged from this assessment's clarifying questions:

1. **AGENTS.md read-back is by convention only** (Q3) — the
   compound-learning loop is half-closed. Capture and curation are strong;
   the read-back trigger that would surface curated patterns at session
   start does not exist. The plugin's own SessionStart hook for
   harness-upgrade is the architectural template for closing this loop.
2. **Depletion management is implicit-consistent rather than engineered**
   (Q4) — pace is sustainable, but session boundaries are not designed.

These do not lower the L5 ceiling — they refine what *operational* L5
maturity looks like.

## Clarifying Responses

- **Q1 / cost capture**: Forgotten — no calendar/cadence reminder, just
  slipped. (Cadence gap, not tooling gap.)
- **Q2 / governance operation**: Quarterly only, but acknowledged it could
  be more often. The framework already provides `/governance-health` as
  the lightweight monthly pulse; pairing monthly health with quarterly
  audit is the natural rhythm.
- **Q3 / AGENTS.md read-back**: By convention only — written into CLAUDE.md
  but not enforced; depends on the agent dispatcher.
- **Q4 / depletion management**: Implicit but consistent — no formal
  cadence, but degradation is noticed and acted on.

## Level Assessment

### Primary Level: 5 — Sovereign Engineering

The project continues to meet Level 5 across all three disciplines.
Since the last assessment, the L5 surface has expanded substantially:

- **Governance subsystem** added — auditor agent, audit/constrain/health
  commands, governance/observability snapshots, governance-aware
  constraints
- **Decision archaeology** added — choice-cartographer agent surfaces the
  implicit decision terrain a spec commits to, with the
  adjudicated-stories constraint enforcing read-before-merge
- **Dual-mode adversarial review** wired in — advocatus-diaboli runs at
  both spec-time and code-time, hard-wired as PR constraints rather than
  optional discipline
- **Harness affordances** introduced — `/harness-affordance` makes
  HARNESS.md content discoverable as a direct affordance rather than a
  document to be read

The L5 ceiling is held; gaps are operational and guardrail-tightening,
not capability-missing.

### Discipline Maturity

| Discipline | Strength (1-5) | Change | Evidence |
| --- | --- | --- | --- |
| Context Engineering | 5/5 | Stable | CLAUDE.md, AGENTS.md (with 2 fresh promotions today), 30 skills, 24 commands, 13 agents, 10 hooks, complete docs (zero stubs), 8 articles, MODEL_ROUTING.md, decision archaeology |
| Architectural Constraints | 5/5 | Strengthened | 18/19 enforced (was 12/13), 15 GC rules (was 13), governance subsystem, choice-cartographer + adjudicated-stories, advocatus-diaboli + adjudicated-objections, references-file idiom |
| Guardrail Design | 4.5/5 | Stable (shifted gap profile) | Orchestrator with plan-approval AND integration-approval gates, dual-mode adversarial review wired as PR constraint, choice-cartographer exposing implicit decision terrain. Gaps: cost data still uncaptured (Q1), AGENTS.md read-back not enforced (Q3), session-boundary design implicit not engineered (Q4) |

### The Weakest Discipline

Guardrail Design at 4.5/5 remains the ceiling. The 2026-04-11 gap (no
cost data) persists; the addition of advocatus-diaboli, choice-cartographer,
and the integration-approval gate strengthens guardrails substantially —
but two newly-surfaced gaps replace what they would have closed:

- AGENTS.md read-back is by convention, not enforced
- Depletion is recognised but not designed-for

A SessionStart hook for AGENTS.md (mirroring the harness-upgrade hook
pattern), a calendar anchor for `/cost-capture`, and a monthly
`/governance-health` pulse would close all three Phase-7 gaps.

## Strengths

- **Rapid, disciplined iteration**: 22 minor plugin releases in 17 days,
  each going through the full PR workflow with CI checks. The 2026-04-28
  promotion of two reflection-log patterns into AGENTS.md is a textbook
  compound-learning closure.
- **Three substantive new subsystems**: governance, decision archaeology,
  dual-mode adversarial review — all wired into the harness as PR
  constraints rather than optional discipline.
- **Self-referential maturity**: the project's own assessment scored
  itself with the framework it ships, and the framework's
  Choice-Cartographer agent (added 2026-04-27) was used in the same
  session that captured its own building-the-thing reflection.
- **Reflection signal coverage at 84%** (up from 67%): of 25 entries, 21
  carry signal classification, and the workflow-heavy distribution (14/21)
  indicates a team iterating on how it works rather than fighting fires.
- **References-file idiom captured** in AGENTS.md ARCH_DECISIONS — a
  concrete piece of cross-cutting methodology now lives in one place
  instead of duplicating across consumers.

## Gaps

- **Cost data still never captured** — the `/cost-capture` command has
  existed for 17 days; no execution. Per Q1 this is forgotten cadence,
  not tool friction. Cost discipline remains *infrastructure without
  operation* — exactly the pattern Article 08 warns about.
- **AGENTS.md read-back not enforced** — capture and curation are strong,
  but the read-back trigger that would surface curated patterns at
  session start does not exist. The compound-learning loop is half-closed.
- **Governance cadence at minimum** — operating at quarterly audits only
  (Q2). The lighter `/governance-health` pulse exists but isn't on a
  monthly rhythm.
- **Session-boundary design is implicit** — pace is sustainable but
  depletion is recognised reactively rather than engineered into the
  workflow as time-based session structure (Q4).
- **`docs/superpowers/stories/` empty** — choice-cartographer is wired,
  but no spec authored after 2026-04-27 has produced a stories record
  yet. The first one tells us whether the constraint is truly operational
  or only declared.

## Recommendations

1. **Add a calendar anchor for `/cost-capture`** — quarterly, aligned to
   `/governance-audit` so cost capture and governance audit ride the same
   cadence. The cost-data gap closes the day this is run once.
2. **Build a SessionStart hook that injects recently-curated AGENTS.md
   entries** — mirror the harness-upgrade hook pattern. Closes the
   compound-learning read-back loop. The plugin already demonstrates the
   architectural template for this.
3. **Adopt a monthly `/governance-health` pulse** — distinct from the
   quarterly `/governance-audit`. Tighter loop without the full audit
   overhead.
4. **Run `/choice-cartograph` on the next post-cutoff spec** — produces
   the first stories record and confirms the adjudicated-stories
   constraint is operational, not just declared.
5. **Make session boundaries explicit** — add a Depletion Check pattern
   (e.g. 90-min self-assessment) to AGENTS.md or CLAUDE.md so
   session-boundary design becomes engineered rather than emergent.

## Immediate Adjustments Applied

*Applied during this assessment (Phase 6 of /assess) — see commit for the full set:*

| Adjustment | Where | Status |
| --- | --- | --- |
| Update HARNESS.md Status block (counts 13/15 → 18/19, drift yes → no) | HARNESS.md | applied |
| Update README "Harness" badge to 18/19 enforced | README.md | applied |
| Update README "AI Literacy" badge link to today's assessment | README.md | applied |
| Update Mechanism Map "Skills (29)" → "Skills (30)" | README.md | applied |
| Add missing SessionStart template currency hook to Mechanism Map | README.md | applied |

## Workflow Operation Recommendations

*Presented one at a time during Phase 7 of /assess. All three accepted
and applied in this assessment session.*

| Recommendation | Status | Where applied |
| --- | --- | --- |
| Add quarterly /cost-capture cadence anchor to CLAUDE.md | accepted | CLAUDE.md "Quarterly Operations" section |
| Add monthly /governance-health pulse to CLAUDE.md | accepted | CLAUDE.md "Monthly Operations" section |
| Add Depletion Check pattern to AGENTS.md GOTCHAS | accepted | AGENTS.md GOTCHAS entry (90-min time-based break) |

## Improvement Plan

- Current level: L5
- Target level: L5 (refinement within level — sovereign at the edges)

The `literacy-improvements` skill maps gaps to commands for sub-L5
teams (L1→L2, L2→L3, L3→L4, L4→L5). It explicitly excludes L5 because
"Level 5 teams do not need this skill — they are already at the top."
For L5 teams, the Phase 7 workflow recommendations *are* the
improvement plan — they tighten operating discipline within the level.

### Phase 7 closures (this session)

| Gap | Closure | Status |
| --- | --- | --- |
| Cost capture cadence (Q1) | CLAUDE.md "Quarterly Operations" section | accepted, applied |
| Governance pulse cadence (Q2) | CLAUDE.md "Monthly Operations" section | accepted, applied |
| Depletion management (Q4) | AGENTS.md GOTCHAS — 90-min time-based break entry | accepted, applied |

### Open gap surviving Phase 7

| Gap | Why it survives | Suggested follow-up |
| --- | --- | --- |
| AGENTS.md read-back not enforced (Q3) | This is a *build* task (a new SessionStart hook), not an operating cadence — outside the scope of /assess | File an issue: "SessionStart hook injects recently-promoted AGENTS.md entries". Mirror the existing harness-upgrade hook pattern. |

The read-back gap is the highest-leverage remaining L5 improvement. It
warrants a separate spec → diaboli → implement cycle rather than a
quick fix in this session.

## Reflection

What the scan revealed vs what was expected:

- **Expected**: persistent cost-data gap, possible drift in counts.
  Confirmed both.
- **Surprise**: the compound-learning loop is half-closed. Capture and
  curation are textbook (84% signal coverage, 2 promotions today), but
  read-back is purely conventional. The plugin ships the architectural
  template (SessionStart hook for harness-upgrade) but doesn't apply it
  to its own AGENTS.md. The cobbler's children, refracted through a new
  surface.
- **Surprise**: Q4 produced a clean L4-vs-L5 distinction the framework
  encodes but the project hadn't articulated for itself. "Implicit but
  consistent" is sustainable but not engineered — the difference matters
  at L5, where guardrails are designed rather than emergent.
- **Surprise**: governance, decision archaeology, and adversarial review
  all shipped *as PR constraints* rather than optional discipline. That's
  the L5 maturity signal — capability isn't built and then ignored, it's
  built and gated.

What future assessments should pay attention to:

- Whether the new gaps surfaced here close (read-back hook, cost cadence,
  governance pulse, depletion check) or persist.
- Disposition distribution across diaboli records and stories — whether
  rubber-stamping starts to creep in once the constraint is routine.
- Whether the article corpus expands (still at 8) or remains stable as
  the framework continues to grow — the asymmetry between framework
  growth and articulation growth is itself a signal.

## Next Assessment

Suggested re-assessment date: 2026-07-28 (quarterly).

Previous assessment: 2026-04-11 (Level 5).

---

## Postscript — 2026-04-28 (later same day)

After this assessment was filed, the highest-leverage gap (Q3, AGENTS.md
read-back) was scoped for implementation as a SessionStart hook. The
spec-mode `/diaboli` adjudication of that spec refuted the foundational
premise: Claude Code already loads AGENTS.md as project memory at session
start. The Q3 answer ("by convention only") was correct in the literal
sense — there is no enforcement rule — but the implication ("agents do not
see AGENTS.md") was wrong. AGENTS.md content does reach agents; we just
have no signal of *uptake*.

The corrected diagnosis: Q3 surfaces a **signal/instrumentation** gap, not
an exposure gap. Future literacy improvements addressing this should aim
at instrumentation (logging when curated patterns shape agent decisions,
or telemetry on AGENTS.md reference frequency), not at exposure
(injecting content the agent already has).

This correction does not change the assessed level (L5 still holds — the
gap is real, just differently shaped), but it does retire the "build a
SessionStart hook for AGENTS.md read-back" recommendation. The remaining
three Phase-7 changes (cost-capture cadence, governance pulse, depletion
check) stand.

See `docs/superpowers/objections/agents-md-readback-hook-design.md` for
the full diaboli adjudication and `REFLECTION_LOG.md` 2026-04-28 entry
for the methodological lesson.
