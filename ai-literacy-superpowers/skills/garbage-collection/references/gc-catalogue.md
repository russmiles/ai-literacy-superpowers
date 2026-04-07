# Garbage Collection Rule Catalogue

A reference of common GC patterns, organised by the kind of entropy
they fight. Each pattern includes what to check, recommended frequency,
whether auto-fix is safe, and an example HARNESS.md entry.

## Documentation Entropy

### Stale References

**What it checks**: README, HARNESS.md, and doc comments that reference
files, functions, classes, or CLI flags that no longer exist.

**Frequency**: weekly

**Auto-fix**: false — stale references usually indicate a design change
that needs human judgement about what the correct new reference is.

**Detection approach**: Extract references (file paths, function names)
from documentation. Grep the codebase for each. Flag any that return
zero matches.

### Outdated Version Numbers

**What it checks**: Version numbers in README badges, documentation,
or configuration that do not match the actual installed version.

**Frequency**: weekly

**Auto-fix**: true — if the correct version can be determined from
package files (go.mod, pom.xml, package.json), the GC agent can update
the documentation.

## Convention Drift

### Naming Violations

**What it checks**: Source files where naming patterns have drifted from
declared conventions (e.g., new files using camelCase when the convention
says snake_case).

**Frequency**: weekly

**Auto-fix**: false — renaming has ripple effects.

### Style Drift

**What it checks**: Files that were committed without passing the
formatter, perhaps because the pre-commit hook was bypassed.

**Frequency**: weekly

**Auto-fix**: true — run the formatter and commit the result.

## Dead Code

### Orphaned Files

**What it checks**: Source files that are not imported, included, or
referenced by any other file. Configuration files that are not
referenced by any build or CI script.

**Frequency**: weekly

**Auto-fix**: false — orphaned files may be intentionally standalone.
Create an issue instead.

### Unused Exports

**What it checks**: Exported functions, types, or constants that are
not imported anywhere in the codebase.

**Frequency**: weekly

**Auto-fix**: false — removing exports is a breaking change for
consumers outside the repo. Create an issue.

## Dependency Entropy

### Known Vulnerabilities

**What it checks**: Dependencies with known CVEs, using the language
ecosystem's vulnerability database.

**Frequency**: weekly

**Auto-fix**: false — dependency upgrades can break things. Create
an issue with the CVE details.

### Major Version Lag

**What it checks**: Dependencies that are more than one major version
behind the latest release.

**Frequency**: weekly

**Auto-fix**: false — major version bumps often have breaking changes.

## Harness Entropy

### Constraint Tool Existence

**What it checks**: Deterministic constraints that reference tools not
installed in the project or CI.

**Frequency**: weekly

**Auto-fix**: false — the `harness-auditor` handles this, but the GC
agent can run the same check independently.

### Hook Script Validity

**What it checks**: Hook scripts referenced in hooks.json that do not
exist, are not executable, or fail a dry-run.

**Frequency**: weekly

**Auto-fix**: false — broken hooks need investigation.

## Architectural Fitness Functions

Fitness functions are GC rules that measure system-wide architectural
properties over time. Unlike the categories above which fight entropy in
individual files, fitness functions detect cumulative architectural
degradation — the kind that no single change causes but that accumulates
across weeks and months.

For the full framework and tool details, see the dedicated skill at
`../../fitness-functions/SKILL.md` and the detailed reference at
`../../fitness-functions/references/fitness-catalogue.md`.

### Layer Boundary Compliance

**What it checks**: Whether modules respect declared architectural
boundaries (no imports from forbidden layers).

**Frequency**: weekly

**Auto-fix**: false — boundary violations require restructuring code,
which has ripple effects and needs human judgement.

**Detection approach**: Run a dependency validation tool (dependency-cruiser,
ArchUnit, import-linter, go-cleanarch) against declared layer rules.
Tool exits non-zero on violations.

### Complexity Hotspots

**What it checks**: Whether any files show increasing cognitive
complexity correlated with high git churn (the hotspot pattern from
Tornhill's *Your Code as a Crime Scene*).

**Frequency**: weekly

**Auto-fix**: false — hotspot remediation requires refactoring decisions
about how to split or simplify code.

**Detection approach**: Cross-reference git churn data (files changed
most in the last 30 days) with complexity metrics. Files appearing in
both the high-churn and high-complexity sets are hotspots.

### Coupling Trend

**What it checks**: Whether inter-module coupling metrics have increased
since the last snapshot.

**Frequency**: weekly

**Auto-fix**: false — reducing coupling requires architectural decisions.

**Detection approach**: Generate coupling metrics (afferent coupling,
efferent coupling, instability index) and compare against the previous
snapshot. The agent interprets whether trends are stable, concerning,
or critical.

## Learning-Driven GC

Learning-driven GC rules use compound learning artifacts (reflections,
assessments) as input rather than scanning code or configuration. They
close the loop between what the team has learned and what the harness
enforces.

### Reflection-Driven Regression Detection

**What it checks**: Whether REFLECTION_LOG.md contains recurring failure
patterns (same type of surprise across 2+ entries) that are not yet
covered by a HARNESS.md constraint.

**Frequency**: weekly

**Auto-fix**: false — proposing new constraints requires human judgement
about scope, enforcement type, and priority.

**Detection approach**: Read all REFLECTION_LOG.md entries. Group
`Surprise` fields by theme using semantic similarity (e.g. "lint
failures", "branch discipline", "permission issues"). For any theme
appearing in 2+ entries, check whether a HARNESS.md constraint already
covers it. For uncovered patterns, create a GitHub issue proposing a
new constraint with the pattern description, evidence (reflection dates
and quotes), suggested enforcement type, and suggested scope.

**Example HARNESS.md entry**:

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

---

## The Auto-Fix Safety Rubric

Auto-fix is safe when:

1. The fix is deterministic — same input always produces same output
2. The fix is local — changes only the affected file, no ripple effects
3. The fix is verifiable — a test or check confirms the fix is correct
4. The fix is reversible — a git revert undoes it cleanly

Auto-fix is not safe when:

1. The fix requires judgement — multiple valid corrections exist
2. The fix has ripple effects — renaming, removing exports, changing APIs
3. The fix cannot be verified — no test covers the changed behaviour
4. The fix is destructive — deleting files, removing functionality
