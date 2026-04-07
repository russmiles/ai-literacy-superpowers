---
name: fitness-functions
description: Use when designing architectural fitness functions as GC rules — periodic checks that verify system-wide properties like layer boundaries, coupling trends, and complexity hotspots, complementing per-change constraints with weekly architectural health monitoring
---

# Architectural Fitness Functions

## Overview

Architectural fitness functions are periodic automated checks that verify
system-wide architectural properties. The concept comes from Ford, Parsons,
Kua & Sadalage's *Building Evolutionary Architectures* (O'Reilly,
2017/2022). Their key insight: architecture degrades not through single
bad changes but through accumulated small violations. Each individual
change looks reasonable in isolation. The damage is cumulative and
invisible until it becomes painful.

Fitness functions catch the accumulation that per-change constraints miss.
They answer questions like:

- Has coupling between modules A and B increased over the last month?
- Are any files becoming complexity hotspots — high churn correlated
  with growing cognitive complexity?
- Do all modules still respect declared layer boundaries?
- Is test coverage declining in the most architecturally significant
  layers?

These checks are too slow or expensive for every PR (full dependency
graph analysis, coupling metric computation, churn-complexity
correlation). But they are too important to skip entirely. The GC
system's weekly cadence is a natural fit.

---

## The Constraint vs Fitness Function Distinction

A constraint gates individual changes. A fitness function measures
system-wide properties over time. Both are harness enforcement, but at
different timescales.

| Aspect | Constraint | Fitness Function |
| --- | --- | --- |
| Scope | Per-change (commit or PR) | System-wide (weekly) |
| What it checks | This change violates a rule | The system has drifted from a property |
| Trigger | Code is written or merged | Scheduled GC run |
| Example | "This file imports from a forbidden layer" | "Coupling between modules A and B has increased 15% over 4 weeks" |
| Enforcement | Deterministic or agent | Deterministic (tool output) + agent (trend interpretation) |

Constraints answer: "Is this change OK?"
Fitness functions answer: "Is the system still healthy?"

Both are necessary. Constraints prevent known-bad changes. Fitness
functions detect emergent degradation that no single change caused.

---

## Fitness Function Catalogue

### Structural

Structural fitness functions verify that code organisation respects
declared architectural boundaries.

| Check | What it detects | Tool examples |
| --- | --- | --- |
| Layer boundary violations | Imports crossing declared architectural boundaries (e.g. UI importing from database layer) | dependency-cruiser, ArchUnit, import-linter, go-cleanarch |
| Circular dependency detection | Cycles in the module dependency graph that create hidden coupling | dependency-cruiser, JDepend, go-cleanarch |
| Import direction enforcement | Imports flowing against the intended dependency direction | dependency-cruiser, ArchUnit, semgrep |

### Coupling

Coupling fitness functions track how tightly connected modules are and
whether that coupling is increasing.

| Check | What it detects | Tool examples |
| --- | --- | --- |
| Afferent/efferent coupling | How many modules depend on a module (Ca) vs how many it depends on (Ce) | dependency-cruiser metrics, JDepend |
| Instability index | Ce / (Ca + Ce) — modules with high instability and high importance are fragile | JDepend, dependency-cruiser |
| Module fan-in/fan-out | Modules with excessive incoming or outgoing dependencies | dependency-cruiser, custom scripts |

### Complexity and Hotspots

Complexity fitness functions find files where growing complexity
correlates with high change frequency — the "hotspot" pattern from
Adam Tornhill's *Your Code as a Crime Scene* and the code-maat /
CodeScene approach.

| Check | What it detects | Tool examples |
| --- | --- | --- |
| Cognitive complexity trending | Files where cognitive complexity score is increasing over time | SonarQube, eslint complexity rule, custom scripts |
| File size growth | Files growing beyond a threshold, suggesting they need splitting | wc -l, custom scripts |
| Churn-complexity correlation | Files with both high git churn and high complexity — the most dangerous hotspots | code-maat, CodeScene, git log + complexity tools |

### Coverage

Coverage fitness functions verify that testing effort is distributed
appropriately across the architecture.

| Check | What it detects | Tool examples |
| --- | --- | --- |
| Test coverage per architectural layer | Layers with declining coverage that may be undertested | Coverage tools (istanbul, jacoco, go cover) + custom aggregation |
| Mutation testing kill rate | Whether tests are actually catching bugs, not just exercising code | pitest, stryker, go-mutesting |

---

## Tool Reference

### JavaScript / TypeScript

**dependency-cruiser** — validates module dependencies against a rule set.

```bash
# Validate all imports against declared rules:
npx dependency-cruiser --validate .dependency-cruiser.js src/

# Generate a dependency graph as metrics JSON:
npx dependency-cruiser --output-type metrics src/
```

**knip** — finds unused exports, dependencies, and files.

```bash
# Report unused exports and dependencies:
npx knip
```

### Java / Kotlin

**ArchUnit** — architecture tests written as JUnit test classes.

```java
@AnalyzeClasses(packages = "com.example")
class ArchitectureTest {
    @ArchTest
    static final ArchRule layerRule = layeredArchitecture()
        .consideringAllDependencies()
        .layer("Controller").definedBy("..controller..")
        .layer("Service").definedBy("..service..")
        .layer("Repository").definedBy("..repository..")
        .whereLayer("Controller").mayOnlyBeAccessedByLayers()
        .whereLayer("Service").mayNotBeAccessedByLayer("Repository");
}
```

**JDepend** — calculates package-level coupling metrics (Ca, Ce,
instability, abstractness).

```bash
jdepend-2.9.1/bin/jdepend target/classes
```

### Go

**go-cleanarch** — validates clean architecture layer boundaries.

```bash
go-cleanarch -application app -domain domain -infrastructure infra ./...
```

**Custom go vet analyzers** — write project-specific static analysis
rules using the `analysis` package.

### Python

**import-linter** — enforces dependency contracts between Python packages.

```bash
# Define contracts in setup.cfg or pyproject.toml, then:
lint-imports
```

**pydeps** — visualises and analyses module dependencies.

```bash
pydeps --no-show --cluster src/mypackage
```

### Any Language

**semgrep** — pattern-based static analysis with custom architectural rules.

```bash
# Run custom rules from a local config:
semgrep --config .semgrep/architecture-rules.yml src/
```

Semgrep rules can enforce import restrictions, banned function calls,
and structural patterns across any language it supports.

---

## Mapping to GC Rules

Each fitness function becomes a GC rule in HARNESS.md. The mapping:

### Deterministic fitness functions

Use when a tool produces a clear pass/fail result.

```markdown
### Layer boundary compliance

- **What it checks**: Whether modules respect declared architectural
  boundaries (no imports from forbidden layers)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false
```

The tool exits non-zero on violations. No agent interpretation needed.

### Agent-interpreted fitness functions

Use when the check produces metrics that require trend analysis.

```markdown
### Coupling trend

- **What it checks**: Whether inter-module coupling metrics have
  increased since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using dependency-cruiser metrics output
  or custom coupling script)
- **Auto-fix**: false
```

The agent runs the tool, compares output against the previous snapshot,
and interprets whether the trend is healthy, concerning, or critical.

### Setting frequency

Most fitness functions run weekly. This matches the GC system's default
cadence and balances thoroughness against cost. Only move to daily if
architectural drift is actively causing production issues.

### Auto-fix

Fitness functions almost never have auto-fix set to true. Architectural
issues require human judgement about the right solution — splitting a
module, introducing an interface, restructuring layers. The GC agent
creates an issue instead.

---

## Interpreting Results

Fitness functions produce trend data, not pass/fail. The agent
interprets whether a trend is healthy, concerning, or critical.

| Trend | Interpretation | Action |
| --- | --- | --- |
| Stable or improving | The architecture is holding | No action — record the snapshot |
| Slow decline (1-2 snapshots) | Early warning — worth watching | Note in the snapshot, no issue yet |
| Sustained decline (3+ snapshots) | Active degradation | Create an issue with the trend data |
| Sudden spike | Likely a specific recent change | Investigate the commits since last snapshot |

These thresholds align with the health snapshot's trend detection. A
fitness function finding that has been declining for 3+ snapshots should
appear in the health snapshot's drift section.

### What "good" looks like

- Layer boundary violations: zero (this is binary — either boundaries
  are respected or they are not)
- Coupling metrics: stable or decreasing over time
- Complexity hotspots: the number of files in the "high churn + high
  complexity" quadrant is stable or decreasing
- Coverage per layer: stable or increasing, with no layer dropping
  below a project-defined threshold

---

## When to Promote to a Constraint

If a fitness function consistently finds the same type of violation, it
may be worth promoting the check to a per-PR constraint. This is the
reverse of the normal promotion ladder: instead of unverified -> agent ->
deterministic, it is periodic observation -> targeted constraint.

### Signs a fitness function should become a constraint

1. The same layer boundary violation appears in 3+ consecutive snapshots
2. A specific import pattern keeps recurring despite issue creation
3. The fitness function finding is always caused by new code (not legacy)
4. The check is fast enough to run on every PR without slowing CI

### How to promote

1. Extract the specific violation pattern from the fitness function
2. Create a targeted constraint in HARNESS.md's Constraints section
3. Configure the constraint's tool to check only that specific pattern
4. Keep the broader fitness function running — it catches violations
   the narrower constraint does not

Example: if the coupling trend fitness function consistently finds that
module A's fan-out is growing, promote a specific constraint that blocks
PRs adding new imports from module A to other modules. The broader
coupling trend fitness function continues to monitor all modules.

---

## Additional Resources

### Reference Files

- **`references/fitness-catalogue.md`** — Concrete HARNESS.md GC rule
  entries for each fitness function type with exact tool commands,
  example output, and interpretation guidance
