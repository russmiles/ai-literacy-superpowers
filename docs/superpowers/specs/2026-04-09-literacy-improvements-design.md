---
diaboli: exempt-pre-existing
---

# Literacy Improvements Skill — Design

**Date:** 2026-04-09
**Status:** Approved

---

## Context

The `/assess` command identifies gaps and writes prose recommendations
in a markdown file. It applies immediate hygiene fixes and workflow
operation changes in-session. But for structural improvements — "you
need a harness," "you need secret detection," "you need CI enforcement"
— it does not generate a prioritised action plan that maps each gap to
the specific plugin command or skill that closes it.

This spec adds a `literacy-improvements` skill that bridges the gap
between assessment and action. The skill is independent (usable
standalone) and invoked by `/assess` after Phase 5.

---

## The Improvement Mapping

### L1 → L2 (Prompting → Verification)

| Gap | Command/Skill | What it does |
| --- | --- | --- |
| No CI test pipeline | (manual — outside plugin scope) | Set up CI with test suite |
| No linting in CI | `auto-enforcer-action` skill | Adds GitHub Action for PR checks |
| No vulnerability scanning | `dependency-vulnerability-audit` skill | Guides CVE scanning setup |
| No Docker image scanning | `docker-scout-audit` skill | Guides Docker Scout setup |
| No secret scanning | `secrets-detection` skill | Sets up gitleaks |

### L2 → L3 (Verification → Habitat Engineering)

| Gap | Command/Skill | What it does |
| --- | --- | --- |
| No CLAUDE.md or conventions | `/harness-init` (context feature) | Discovers stack, generates conventions |
| No HARNESS.md | `/harness-init` (constraints feature) | Generates constraints with enforcement |
| Constraints declared but not enforced | `/harness-constrain` | Promotes unverified → agent → deterministic |
| No CI constraint enforcement | `/harness-init` (CI feature) or `auto-enforcer-action` skill | Adds harness.yml workflow |
| No reflections | `/reflect` | Captures first reflection, establishes cadence |
| No AGENTS.md | (created by `/superpowers-init` or first curation) | Compound learning memory |
| Conventions not extracted | `/extract-conventions` | Guided session to surface tacit knowledge |
| No GC rules | `/harness-init` (GC feature) | Adds periodic entropy checks |
| No observability | `/harness-health` | Generates first health snapshot |

### L3 → L4 (Habitat → Specification Architecture)

| Gap | Command/Skill | What it does |
| --- | --- | --- |
| No spec-first workflow | `harness-engineering` skill (spec-first section) | Guidance on specification architecture |
| No agent pipeline | `/superpowers-init` (agent team feature) | Scaffolds orchestrator + agent team |
| No safety gates in orchestrator | `constraint-design` skill | Design guardrails for agent loops |
| Convention drift across tools | `/convention-sync` | Syncs to Cursor, Copilot, Windsurf |
| No fitness functions | `fitness-functions` skill + `/harness-gc` | Adds architectural health checks |

### L4 → L5 (Specification → Sovereign Engineering)

| Gap | Command/Skill | What it does |
| --- | --- | --- |
| No reusable plugin | `cross-repo-orchestration` skill | Patterns for cross-team sharing |
| No model routing | `model-sovereignty` skill | Decision framework for model selection |
| No cost tracking | `model-sovereignty` skill (cost section) | Break-even analysis |
| No observability export | `harness-observability` skill (telemetry layer) | OTel metric export guidance |

---

## Skill Structure

**Location:** `ai-literacy-superpowers/skills/literacy-improvements/SKILL.md`
**Reference:** `ai-literacy-superpowers/skills/literacy-improvements/references/improvement-mapping.md`

### Process

**Input:** An assessed level and a list of gaps. These come from either:

- The `/assess` command (which passes them after Phase 5)
- The user directly ("I'm at L2, what should I do next?")

**Step 1: Confirm current level.** If invoked standalone (not from
`/assess`), ask the user to confirm their level or run `/assess` first.

**Step 2: Ask target level.** Present the options:

```text
You're currently at Level N.

How far would you like to improve?

1. Level N+1 — [name] (recommended next step)
2. Level N+2 — [name]
3. Level 5 — Sovereign Engineering
```

The default recommendation is always "next level." Higher targets
include all intermediate levels — choosing L4 from L2 means doing
L2→L3 improvements first, then L3→L4.

**Step 3: Generate prioritised plan.** Read the mapping from
`references/improvement-mapping.md`. For each gap between current
level and target level:

- Check whether the gap is already closed (e.g., HARNESS.md already
  exists — verify by checking the file system)
- For open gaps, generate an improvement item with: what it closes,
  which command/skill to run, priority (high/medium/low based on
  impact)
- Group by level transition: "To reach Level 3" then "To reach Level 4"
- Within each group, order by priority: high-impact items first

**Step 4: Present plan item by item.** For each improvement:

```text
Improvement 1/6 (Level 3 — Habitat Engineering):
  Gap: No HARNESS.md with enforced constraints
  Action: Run /harness-init (context + constraints features)
  Priority: High — this is the foundation for everything else at L3

  Accept / Skip / Defer?
```

- **Accept** — execute the command or invoke the skill immediately
- **Skip** — remove from plan, don't ask again
- **Defer** — keep in plan but don't execute now (recorded for next
  assessment)

**Step 5: Record the plan.** Append to the assessment document (if
one exists for today) or write a standalone improvement plan to
`assessments/YYYY-MM-DD-improvements.md` with:

- Current level
- Target level
- Each improvement: accepted/skipped/deferred
- What was executed and what changed

---

## Integration with /assess

After the existing Phase 5 (Workflow Operation Recommendations), add:

### Phase 5b: Improvement Plan

Invoke the `literacy-improvements` skill with the assessed level from
Phase 3 and the gaps from section 7 of the assessment document. The
skill handles target level selection, plan generation, and interactive
execution.

The existing Phase 5 and Phase 5b are complementary:

- Phase 5 = **operate better** at your current level
- Phase 5b = **build toward** the next level

The assessment document gains a new section:

```text
## Improvement Plan

- Target level: LN
- Improvements accepted: N
- Improvements skipped: N
- Improvements deferred: N
- Commands executed: [list]
```

---

## Files Changed

1. `ai-literacy-superpowers/skills/literacy-improvements/SKILL.md` —
   new skill
2. `ai-literacy-superpowers/skills/literacy-improvements/references/improvement-mapping.md` —
   level-to-action mapping table
3. `ai-literacy-superpowers/skills/ai-literacy-assessment/SKILL.md` —
   add Phase 5b reference to literacy-improvements skill
4. `ai-literacy-superpowers/commands/assess.md` — add step 6b invoking
   the skill after workflow recommendations
5. `README.md` — update skills count 19 → 20, add literacy-improvements
   to skills table
6. `docs/index.md` — update skills count 19 → 20
7. `docs/reference/skills.md` — add literacy-improvements entry, update
   count 19 → 20
8. `docs/tutorials/getting-started.md` — update skills count in install
   output 19 → 20
9. `CHANGELOG.md` — entry for the new skill
10. `ai-literacy-superpowers/.claude-plugin/plugin.json` — version bump
    to 0.5.0 (new skill = minor)
11. `README.md` — version badge bump to 0.5.0
