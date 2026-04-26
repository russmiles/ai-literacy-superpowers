---
diaboli: exempt-pre-existing
---

# Auto-Constraint Generation from Reflections — Design Spec

## Problem

REFLECTION_LOG.md is write-only. Reflections capture surprises and
failures but nothing reads them back to improve enforcement. The
learning loop is open: agents fail, humans reflect, reflections sit
in a file, agents fail the same way again.

The auto-harness project (neosigmaai/auto-harness) demonstrates a
closed loop: failures → evals → gating. The equivalent for this plugin
is: failures → reflections → constraints → enforcement.

## Decision

Update the `/reflect` command to offer constraint generation when a
reflection describes a preventable failure. Add an optional `Constraint`
field to the reflection format to make proposals machine-readable.

## Artifacts

### 1. Update to `/reflect` command — `commands/reflect.md`

After capturing the reflection entry, add a step:

1. Read the `Surprise` and `Improvement` fields
2. If either describes a failure that could be prevented by a rule
   (e.g. "ShellCheck found issues", "agent missed a lint error",
   "wrong branch was used"), offer to draft a constraint
3. Propose the constraint: rule text, enforcement type, tool, scope
4. If the user accepts, invoke `/harness-constrain` with the proposal
5. If declined, record `Constraint: none` in the entry

### 2. Update to REFLECTION_LOG.md format

Add an optional field to the entry template:

```text
- **Constraint**: [proposed constraint text, or "none"]
```

This field is read by the regression suite GC rule (issue #40) to
detect recurring patterns that became constraints vs those that didn't.

### 3. Update to HARNESS.md template — `templates/REFLECTION_LOG.md`

Update the template's entry format comment to include the new field.

### 4. Update CHANGELOG

## Example Flow

```text
User runs /reflect after a session:

  Surprise: "ShellCheck found 4 issues in scripts that passed
  both implementer and spec reviewer subagents"

Plugin detects preventable failure pattern and offers:

  "This looks like a preventable failure. Want to add a constraint?
   Proposed:
     Rule: All .sh files must pass ShellCheck with no errors
     Enforcement: deterministic
     Tool: find . -name '*.sh' -exec shellcheck {} +
     Scope: commit + pr

   Add this constraint? (yes/no)"

User: yes
→ /harness-constrain runs, HARNESS.md updated
→ Reflection entry records: Constraint: "ShellCheck compliance (deterministic)"
```

## What Is NOT In Scope

- Fully automated constraint generation without human approval — the
  human always decides whether a reflection warrants a constraint
- Modifying existing constraints based on reflections — only new
  constraints are proposed
- Reading reflections from other projects — this is project-scoped
