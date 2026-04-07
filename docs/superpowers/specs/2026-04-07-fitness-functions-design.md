# Architectural Fitness Functions for GC — Design Spec

## Problem

The GC catalogue covers five entropy categories: documentation freshness,
convention drift, dead code, dependency currency, and harness health. But
it misses a crucial dimension: **architectural fitness functions** — periodic
automated checks that verify system-wide architectural properties.

These checks are:
- Too slow or expensive for every PR (full dependency graph analysis,
  coupling metric computation, churn-complexity correlation)
- Too important to skip entirely (architectural erosion is cumulative
  and invisible until it becomes painful)
- A natural fit for the GC system's weekly cadence

The concept comes from Ford, Parsons, Kua & Sadalage's *Building
Evolutionary Architectures* (O'Reilly, 2017/2022). Their key insight:
architecture degrades not through single bad changes but through
accumulated small violations. Fitness functions catch the accumulation
that per-change constraints miss.

## Decision

Expand the GC system with an architectural fitness functions category.
Deliver it as a new skill (conceptual framework + tool catalogue), a
reference file (concrete HARNESS.md GC rule entries), updates to the
existing GC skill and catalogue, and example entries in the HARNESS.md
template.

## Approach: Fitness Functions as GC Rules

The distinction between constraints and fitness functions maps directly
to the harness's existing architecture:

| Aspect | Constraint | Fitness Function |
|--------|-----------|-----------------|
| Scope | Per-change (commit or PR) | System-wide (weekly) |
| What it checks | This change violates a rule | The system has drifted from a property |
| Trigger | Code is written or merged | Scheduled GC run |
| Example | "This file imports from a forbidden layer" | "Coupling between modules A and B has increased 15% over 4 weeks" |
| Enforcement | Deterministic or agent | Deterministic (tool output) + agent (trend interpretation) |

Fitness functions are GC rules with a specific character: they measure
architectural properties over time, not entropy in individual files.

## Artifacts

### 1. Skill — `fitness-functions/SKILL.md`

New skill at `ai-literacy-superpowers/skills/fitness-functions/SKILL.md`.

Structure:

1. **Overview** — what fitness functions are, the Ford et al. framing,
   how they complement per-change constraints
2. **The Constraint vs Fitness Function Distinction** — a constraint
   gates individual changes; a fitness function measures system-wide
   properties over time. Both are harness enforcement, but at different
   timescales.
3. **Fitness Function Catalogue** organised by category:
   - **Structural**: layer boundary violations, circular dependency
     detection, import direction enforcement
   - **Coupling**: afferent/efferent coupling metrics, instability
     index, module fan-in/fan-out
   - **Complexity**: cognitive complexity trending, file size growth,
     method length growth correlated with git churn (code-maat /
     CodeScene hotspot pattern from Adam Tornhill)
   - **Coverage**: test coverage per architectural layer, mutation
     testing kill rate trends across snapshots
4. **Tool Reference** per language ecosystem:
   - JavaScript/TypeScript: `dependency-cruiser --validate`, `knip`
   - Java/Kotlin: ArchUnit test classes, JDepend
   - Go: `go-cleanarch`, custom `go vet` analyzers
   - Python: `import-linter`, `pydeps`
   - Any language: `semgrep` with custom architectural rules
5. **Mapping to GC Rules** — how to write a HARNESS.md GC entry for
   each fitness function type, with the correct frequency, enforcement,
   and auto-fix settings
6. **Interpreting Results** — fitness functions produce trend data, not
   pass/fail. The agent interprets whether a trend is healthy (stable
   or improving), concerning (slow decline), or critical (sustained
   decline across 3+ snapshots). These thresholds align with the
   health snapshot's trend detection.
7. **When to Promote to a Constraint** — if a fitness function
   consistently finds the same type of violation, it may be worth
   promoting the check to a per-PR constraint. This is the reverse
   of the normal promotion ladder: instead of unverified → agent →
   deterministic, it's periodic observation → targeted constraint.

### 2. Reference — `fitness-functions/references/fitness-catalogue.md`

Detailed reference with concrete HARNESS.md GC rule entries for each
fitness function type. Each entry includes:

- The HARNESS.md GC rule block (copy-pasteable)
- The exact tool command
- Example output and how to interpret it
- When the finding is actionable vs informational
- Language/framework prerequisites

Example entries:

```markdown
### Layer boundary compliance

- **What it checks**: Whether modules respect declared architectural
  boundaries (no imports from forbidden layers)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false

### Complexity hotspots

- **What it checks**: Whether any files show increasing cognitive
  complexity correlated with high git churn (decay hotspots)
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using git log --format='%H' --after='30 days ago'
  + complexity metrics from tool of choice)
- **Auto-fix**: false

### Coupling trend

- **What it checks**: Whether inter-module coupling metrics have
  increased since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using dependency-cruiser metrics output
  or custom coupling script)
- **Auto-fix**: false
```

### 3. Update to GC Skill and Catalogue

Update `ai-literacy-superpowers/skills/garbage-collection/SKILL.md` to
add fitness functions as a sixth category alongside the existing five.
Frame it as: "Fitness functions are GC rules that measure architectural
properties rather than fighting entropy in individual files."

Update `ai-literacy-superpowers/skills/garbage-collection/references/gc-catalogue.md`
to add the fitness functions category with the same structure as existing
categories: description, examples table, auto-fix safety rubric.

### 4. Update to HARNESS.md Template

Add commented-out example fitness function GC rules to
`ai-literacy-superpowers/templates/HARNESS.md`, after the existing GC
rules and before the Status section:

```markdown
<!-- Uncomment fitness function rules relevant to your stack:

### Layer boundary compliance
- **What it checks**: Whether modules respect declared architectural
  boundaries (no imports from forbidden layers)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false

### Complexity hotspots
- **What it checks**: Whether any files show increasing cognitive
  complexity correlated with high git churn
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false

### Coupling trend
- **What it checks**: Whether inter-module coupling metrics have
  increased since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
-->
```

These are commented out because they are stack-specific — not every
project needs every fitness function. The `/harness-init` flow can
offer to uncomment relevant ones based on the discovered stack.

## What Is NOT In Scope

- Building new deterministic tools — the skill references existing
  open-source tools (dependency-cruiser, ArchUnit, semgrep, etc.)
- Running fitness functions in CI — they are GC-scoped (weekly), not
  PR-scoped. If a fitness function consistently finds the same issue,
  the recommendation is to promote it to a per-PR constraint.
- Mutation testing specifics — already covered by the existing
  `ci-mutation-testing.yml` template and health snapshot system
- Implementing fitness functions for the plugin itself — it has no
  application code with architectural layers to check
- Real-time fitness function evaluation — these are batch checks by
  design; real-time equivalents are constraints
