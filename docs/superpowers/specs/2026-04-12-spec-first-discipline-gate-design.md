# Spec-First Discipline Gate

**Date**: 2026-04-12
**Status**: Approved

## Problem

The harness requires feature PRs to trace to a spec ("Spec-scoped
changes" constraint), but nothing enforces that the spec is committed
and pushed *before* implementation begins. A spec could exist only in
conversation context and never make it to the repository. Without a
durable intent record in git history, traceability between design
decisions and code is implicit rather than verifiable.

## Decision

Specs must be committed as the **first commit on the implementation
branch**, before any production code. This creates an immutable
ordering guarantee: intent is recorded in git before code appears.

### Scope

- Applies to feature and behaviour-change PRs
- Bug fixes, dependency updates, and maintenance PRs are exempt (same
  carve-out as the existing "Spec-scoped changes" constraint)
- Exemption signalled by PR label (`bug`, `fix`, `chore`,
  `maintenance`) or branch prefix (`fix/`, `chore/`)

### Enforcement model

Two new constraints, layered by enforcement type:

**1. Spec-first commit ordering (deterministic)**

A CI workflow inspects the PR's commit history against the base branch:

- The first commit must include exactly one new or modified file
  matching `docs/superpowers/specs/*.md`
- That first commit must not include files outside
  `docs/superpowers/specs/`
- Exempt PRs (by label or branch prefix) skip the check entirely

**2. Spec captures intent (agent)**

The harness-enforcer agent reviews the spec for quality:

- Does the spec describe the problem being solved?
- Does it describe the chosen approach and expected outcome?
- Does the implementation in the PR trace back to what the spec
  describes?

### Relationship to existing constraints

| Constraint | What it checks | Type |
| --- | --- | --- |
| Spec-first commit ordering (new) | Spec exists and is committed first | Deterministic |
| Spec captures intent (new) | Spec quality and intent coverage | Agent |
| Spec-scoped changes (existing) | PR is coherently scoped to one spec | Agent |

These form a progression: spec exists (deterministic) then spec is
good (agent) then PR matches spec (existing agent).

## Changes required

| File | Change |
| --- | --- |
| `HARNESS.md` | Add two new constraints to the Constraints section |
| `.github/workflows/spec-first-check.yml` | New workflow implementing the deterministic gate |
| Harness-enforcer agent | Extend prompt to include intent-quality review |

## What stays the same

- The brainstorming skill already writes and commits specs to
  `docs/superpowers/specs/` — no change needed
- The "Spec-scoped changes" constraint remains as-is
- Bug-fix and maintenance PR workflow is unaffected
