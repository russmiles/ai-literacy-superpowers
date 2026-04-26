---
diaboli: exempt-pre-existing
---

# Complexity Hotspot Detection — Design Proposal (Tier 2)

## Problem

The GC system catches dead code and stale docs but not *quality decay* —
files that are growing more complex over time without being "dead." The
code-maat / CodeScene pattern (git churn correlated with complexity)
identifies these decay hotspots: files that change often AND are growing
in complexity are the most expensive to maintain.

## Proposal

A new GC rule pattern: "Complexity Hotspots" — weekly check that
correlates file churn (from `git log`) with complexity metrics (from
a tool appropriate to the stack). Agent enforcement — the deterministic
tool produces data, the agent interprets the trend. Auto-fix: false.

### Artifacts

1. **GC rule entry** for HARNESS.md:

```markdown
### Complexity hotspots

- **What it checks**: Whether any files show increasing cognitive
  complexity correlated with high git churn (decay hotspots)
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using git log + complexity metrics)
- **Auto-fix**: false
```

1. **Guidance in the fitness-functions skill** — already added as part
   of Tier 1. The fitness catalogue includes a complexity hotspots entry
   with tool commands for multiple ecosystems.

### Tools by Ecosystem

- JavaScript/TypeScript: `eslint --rule 'complexity: error'` + `git log`
- Python: `radon cc` (cognitive complexity) + `git log`
- Go: `gocyclo` or `gocognit` + `git log`
- Java/Kotlin: SonarQube or PMD complexity rules + `git log`
- Any language: `scc` for file-level metrics + `git log --format='%H' --follow`

### Interpretation

The agent compares the current snapshot's hotspot list against the
previous snapshot. A file is a hotspot if it is in the top 10% by churn
AND the top 10% by complexity. The finding is actionable when a file
appears as a hotspot across 3+ consecutive snapshots — at that point,
it warrants refactoring attention.

## Status

Partially addressed by the fitness-functions skill (Tier 1). This
proposal adds the specific GC rule and interpretation guidance. Ready
for implementation when a project with application code needs it.
