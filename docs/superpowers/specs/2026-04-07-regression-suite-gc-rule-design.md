---
diaboli: exempt-pre-existing
---

# Regression Suite GC Rule from Reflection Patterns — Design Spec

## Problem

Individual reflections capture one-off surprises. But when the same type
of failure appears across multiple reflections, it signals a systemic
gap in the harness — a failure pattern that should be a constraint but
isn't.

Auto-harness (neosigmaai/auto-harness) maintains a self-growing
regression suite: tasks that failed once are automatically added to
the gate. The equivalent for this plugin is a GC rule that mines
REFLECTION_LOG.md for recurring patterns and proposes constraints.

## Decision

Add a GC rule that reads REFLECTION_LOG.md, groups surprises by theme,
and proposes new constraints for patterns that appear 2+ times without
an existing HARNESS.md constraint covering them.

## Artifacts

### 1. GC rule for HARNESS.md template

```markdown
### Reflection-driven regression detection

- **What it checks**: Whether REFLECTION_LOG.md contains recurring
  failure patterns (same type of surprise across 2+ entries) that
  are not yet covered by a HARNESS.md constraint
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
```

### 2. Update to harness-gc agent guidance

When running this rule, the agent should:

1. Read all REFLECTION_LOG.md entries
2. Group `Surprise` fields by theme using semantic similarity (e.g.
   "lint failures", "branch discipline", "permission issues",
   "review gaps")
3. For any theme appearing in 2+ entries:
   - Check if a HARNESS.md constraint already covers it
   - Check if a previous reflection already proposed a constraint
     (the `Constraint` field from issue #39)
4. For uncovered recurring patterns: create a GitHub issue proposing
   a new constraint with:
   - The pattern description
   - Evidence (reflection dates and quotes)
   - Suggested enforcement type and tool
   - Suggested scope

### 3. Update to GC skill and catalogue

Add "Reflection-driven regression" as a pattern in the GC catalogue
under a new "Learning-driven GC" category. This category covers GC
rules that use compound learning artifacts (reflections, assessments)
as input rather than scanning code or configuration.

### 4. Update CHANGELOG

## Example

```text
REFLECTION_LOG.md contains:
  2026-04-06: Surprise: "ShellCheck found issues that spec review missed"
  2026-04-07: Surprise: "markdownlint caught formatting not flagged by
              agent review"
  2026-04-07: Surprise: "worktree agents failed on Bash permissions"

GC agent groups by theme:
  - "Deterministic tools catch issues agent review misses" (2 entries)
  - "Permission/environment issues" (1 entry — below threshold)

For the recurring theme, GC agent checks HARNESS.md:
  - ShellCheck constraint exists? Yes (promoted to deterministic)
  - Markdownlint constraint exists? Yes (deterministic)
  - Meta-pattern "prefer deterministic over agent" documented? No

GC agent creates issue:
  "Recurring pattern: agent-based review misses issues that
  deterministic tools catch. Consider adding guidance to the
  constraint-design skill that every agent constraint should have
  a deterministic tool aspiration."
```

## What Is NOT In Scope

- Automatically adding constraints without human review — the GC rule
  proposes via GitHub issues, humans decide
- Real-time analysis of reflections as they're written — this is a
  periodic (weekly) batch check
- Cross-project reflection analysis — scoped to one project's
  REFLECTION_LOG.md
