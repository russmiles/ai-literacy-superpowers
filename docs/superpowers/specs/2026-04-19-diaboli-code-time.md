---
name: diaboli-code-time
description: Extend advocatus-diaboli to a second dispatch point — post-code-review,
             before integration-agent — reusing the same agent with mode-based
             category weighting
date: 2026-04-19
status: draft
---

# Diaboli Code-Time Dispatch

## Problem

### 1. Spec-time diaboli cannot see the implementation

Spec-time diaboli catches premise and design flaws before code is written.
But threat-model, failure-mode, and operational objections require concrete
implementation evidence to ground them. At spec time, those categories are
speculative unless the spec itself describes threat surface or failure
semantics. The speculative objection wastes adjudication time and will be
re-raised — with better evidence — once code exists. There is currently
nowhere for that re-raising to happen.

### 2. Code-reviewer is constructive by charter

The code-reviewer evaluates code through CUPID and literate programming
lenses. Its charter is to find what to improve and return findings for the
implementer. Constructive review and adversarial review are different
epistemic stances — the same agent cannot hold both simultaneously without
compromising both roles. The code-reviewer should not be asked to raise
steel-manned objections to the approach; that is a different kind of work.

### 3. No adversarial gate before integration

Between the final code-reviewer PASS and integration-agent, there is
currently no gate that asks: "Is there a structural risk in this
implementation that a constructive reviewer would not raise?" API surface
exposures, error path gaps, resource-management failures, and operational
blind spots are all visible in finished code and invisible in spec text.
They currently have no structured mechanism to surface before merge.

## Approach

Second dispatch of the same advocatus-diaboli agent, with the same read-only
trust boundary and the same output format, using a mode parameter to apply
category weighting appropriate to code time.

- **Mode input**: `spec` (existing default) | `code` (new)
- **Dispatch timing**: once, after the final code-reviewer PASS, before
  integration-agent. Not per review cycle — only after the loop exits.
  Running adversarial review on draft code conflates the code-reviewer's
  constructive role with diaboli's adversarial one and burns tokens on
  intermediate states.
- **Output path**: `docs/superpowers/objections/<spec-slug>-code.md`
  (spec-mode path unchanged: `docs/superpowers/objections/<spec-slug>.md`)
- **Frontmatter additions**: `mode: code` and `pr_ref:` fields in code-mode
  records
- **New gate**: Integration Approval — mirrors the plan-approval gate.
  Refuses to proceed while any code-mode disposition is `pending`. Human
  writes dispositions inline before integration-agent is dispatched.
- **Category weighting**: documented in SKILL.md Dispatch Modes section.
  Spec-time emphasises premise, design (implementation), and cost
  (alternatives). Code-time emphasises threat model, failure mode, and
  operational (all mapping to `risk`) and implementation-level structural
  flaws.

## Expected Outcome

Every feature PR arrives at integration-agent with two adjudicated objection
records: a spec-mode record (premise/design focus, adjudicated before plan
approval) and a code-mode record (risk/implementation focus, adjudicated
after final code review). The pipeline has two diaboli-backed gates — one
before code is written, one before it is merged.

The HARNESS.md constraint "Spec has adjudicated objections" is renamed to
"PRs have adjudicated objections" and extended to require both records.
Observability panels split descriptive stats by mode while retaining overall
totals for backward comparison.

## Artefacts

### Plugin files

1. `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` — add
   Dispatch Modes section documenting spec-time and code-time weighting
2. `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md` — accept
   mode input (`spec|code`, default `spec`); apply mode-appropriate
   weighting; output to mode-appropriate path; include `mode:` in
   frontmatter; include `pr_ref:` in code-mode frontmatter
3. `ai-literacy-superpowers/commands/diaboli.md` — add optional `--mode`
   flag (default: `spec`); extend validation checkpoint to verify
   mode-appropriate frontmatter fields
4. `.github/prompts/diaboli.prompt.md` — match commands/diaboli.md
5. `ai-literacy-superpowers/agents/orchestrator.agent.md` — add code-time
   dispatch after final code-reviewer PASS; add Integration Approval gate
   that refuses while any code-mode disposition is `pending`
6. `ai-literacy-superpowers/commands/superpowers-status.md` — extend
   Diaboli panel to split stats by mode (objection records present,
   disposition distribution, mean objections per PR per mode; retain overall
   totals)
7. `ai-literacy-superpowers/commands/harness-health.md` — extend Diaboli
   panel to split stats by mode; apply validation-checkpoint discipline
8. `ai-literacy-superpowers/skills/advocatus-diaboli/references/observability.md`
   — add mode-split field definitions and interpretation notes; document
   cross-mode patterns (code-time counts up = spec-time charter too loose;
   code-time counts down = spec-time working OR code-time charter too narrow)
9. `ai-literacy-superpowers/templates/MODEL_ROUTING.md` — note code-time
   routes to most-capable tier same as spec-time

### Project files

10. `HARNESS.md` — rename "Spec has adjudicated objections" to "PRs have
    adjudicated objections"; extend rule to require both spec-mode and
    code-mode records; extend "Objection record freshness" GC rule to cover
    both record types
11. `MODEL_ROUTING.md` — note code-time routes to most-capable tier
12. `AGENTS.md` — add ARCH_DECISION: one agent, two dispatches, mode-based
    weighting; alternatives considered and rejected; conditions for revisit
13. `ai-literacy-superpowers/templates/HARNESS.md` — update constraint and
    GC rule to match project HARNESS.md

### Docs

14. `README.md` — update pipeline diagram to show both dispatch points and
    both gates; update Agents table row for advocatus-diaboli to mention both
    modes; agent count unchanged at 12

### Version

15. `ai-literacy-superpowers/.claude-plugin/plugin.json` — 0.25.0 → 0.26.0
16. `README.md` — badge bump (combined with item 14)
17. `.claude-plugin/marketplace.json` — plugin_version bump
18. `CHANGELOG.md` — new version entry

## Exemptions

This change adds new required records for future PRs only. Existing
spec-mode objection records without a `mode:` field are valid — the field
is new and backward-compatible. The pre-existing exempt clause (specs before
2026-04-19) carries forward unchanged. Bug fixes, dependency updates, and
maintenance PRs remain exempt from both records on the same terms as
spec-first-commit-ordering.
