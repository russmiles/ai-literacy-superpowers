# Fitness Function Reference Catalogue

Concrete HARNESS.md GC rule entries for each fitness function type. Each
entry includes the rule block (copy-pasteable into HARNESS.md), the exact
tool command, example output, interpretation guidance, and language
prerequisites.

---

## Structural Fitness Functions

### Layer boundary compliance

**HARNESS.md entry:**

```markdown
### Layer boundary compliance

- **What it checks**: Whether modules respect declared architectural
  boundaries (no imports from forbidden layers)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false
```

**Tool command (JS/TS):**

```bash
npx dependency-cruiser --validate .dependency-cruiser.js src/
```

**Tool command (Java/Kotlin):**

```bash
# Run ArchUnit tests that define layer rules:
mvn test -pl architecture-tests
```

**Tool command (Go):**

```bash
go-cleanarch -application app -domain domain -infrastructure infra ./...
```

**Tool command (Python):**

```bash
lint-imports
```

**Example output (dependency-cruiser):**

```
  error no-circular: src/api/handler.ts → src/service/user.ts →
    src/api/handler.ts

  ✖ 1 dependency violations (1 errors, 0 warnings, 0 informational).
```

**Interpretation:**

- Zero violations: boundaries are holding. Record the clean result.
- Any violations: the boundary has been breached. Create an issue with
  the specific import chain. This is binary — there is no "acceptable
  number" of boundary violations.

**When actionable vs informational:**

Always actionable. Layer boundary violations are architectural defects,
not trends. Each one should be resolved or the boundary redefined.

**Prerequisites:**

- JS/TS: `dependency-cruiser` installed, `.dependency-cruiser.js` config
  file defining forbidden patterns
- Java/Kotlin: ArchUnit on the classpath, test classes defining layer rules
- Go: `go-cleanarch` installed
- Python: `import-linter` installed, contracts defined in `setup.cfg`
  or `pyproject.toml`

---

### Circular dependency detection

**HARNESS.md entry:**

```markdown
### Circular dependency detection

- **What it checks**: Whether the module dependency graph contains
  cycles that create hidden coupling
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false
```

**Tool command (JS/TS):**

```bash
# dependency-cruiser's default rules include no-circular:
npx dependency-cruiser --validate .dependency-cruiser.js src/
```

**Tool command (Go):**

```bash
# Go's compiler prevents package-level cycles, but module-level
# cycles can still exist in multi-module repos:
go-cleanarch ./...
```

**Example output:**

```
  error no-circular: src/auth/token.ts → src/user/profile.ts →
    src/auth/token.ts
```

**Interpretation:**

- Cycles indicate modules that cannot be deployed, tested, or reasoned
  about independently. Each cycle should be broken by introducing an
  interface or restructuring the dependency direction.

**Prerequisites:**

- Same as layer boundary compliance — these often use the same tool
  with different rule configurations.

---

## Coupling Fitness Functions

### Coupling trend

**HARNESS.md entry:**

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

**Tool command (JS/TS):**

```bash
# Generate metrics JSON:
npx dependency-cruiser --output-type metrics src/

# Key metrics in the output:
# - instability: Ce / (Ca + Ce) per module
# - nDependencies: total dependency count
# - nDependents: total dependent count
```

**Tool command (Java/Kotlin):**

```bash
# JDepend metrics:
jdepend target/classes

# Key metrics:
# - Ca (afferent coupling): who depends on this package
# - Ce (efferent coupling): who this package depends on
# - I (instability): Ce / (Ca + Ce)
```

**Example output (dependency-cruiser metrics):**

```json
{
  "modules": [
    {
      "source": "src/api",
      "instability": 0.75,
      "nDependencies": 6,
      "nDependents": 2
    },
    {
      "source": "src/core",
      "instability": 0.20,
      "nDependencies": 1,
      "nDependents": 4
    }
  ]
}
```

**Interpretation:**

The agent compares current metrics against the previous snapshot:

| Change | Interpretation |
| --- | --- |
| Instability stable (within 0.05) | Healthy — architecture is holding |
| Instability increasing (>0.05 over 2 snapshots) | Warning — module is becoming more dependent on others |
| Fan-out increasing for a core module | Concern — core modules should have low efferent coupling |
| Fan-in increasing for a leaf module | Concern — leaf modules should not be widely depended upon |

**When actionable vs informational:**

- Informational when metrics fluctuate within a narrow band.
- Actionable when a trend persists across 3+ snapshots or when a core
  module's instability index exceeds 0.5.

**Prerequisites:**

- JS/TS: `dependency-cruiser` with metrics output support
- Java/Kotlin: JDepend or equivalent
- Previous snapshot stored in `observability/snapshots/` for comparison

---

### Module fan-in/fan-out

**HARNESS.md entry:**

```markdown
### Module fan-in/fan-out

- **What it checks**: Whether any module has excessive incoming or
  outgoing dependencies beyond a declared threshold
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using dependency-cruiser metrics)
- **Auto-fix**: false
```

**Interpretation:**

- High fan-out (>10 dependencies): the module knows too much. Consider
  splitting or introducing a facade.
- High fan-in (>10 dependents) on a volatile module: changes here
  ripple widely. Consider stabilising the interface.
- High fan-in on a stable module (e.g. a utility library): expected
  and healthy.

---

## Complexity and Hotspot Fitness Functions

### Complexity hotspots

**HARNESS.md entry:**

```markdown
### Complexity hotspots

- **What it checks**: Whether any files show increasing cognitive
  complexity correlated with high git churn (decay hotspots)
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using git log + complexity metrics)
- **Auto-fix**: false
```

**Tool commands:**

```bash
# Step 1: Get churn data (files changed most in the last 30 days):
git log --format=format: --name-only --after='30 days ago' | \
  sort | uniq -c | sort -rn | head -20

# Step 2: Get complexity for those files (JS/TS example):
npx eslint --rule '{"complexity": ["warn", 10]}' <file>

# Step 3: Cross-reference — files appearing in both lists are hotspots.
```

**Example output (churn data):**

```
     47 src/api/handler.ts
     31 src/service/user.ts
     28 src/core/engine.ts
      5 src/util/format.ts
      3 README.md
```

**Interpretation:**

The agent identifies files in the top churn quartile that also exceed
a complexity threshold. These are the "hotspot" files — they change
often and are hard to change safely.

| Finding | Action |
| --- | --- |
| File in top churn + high complexity | Create an issue — this file needs refactoring |
| File in top churn + low complexity | Healthy — frequent changes but manageable |
| File with high complexity + low churn | Low risk — complex but stable |
| Hotspot count increasing over snapshots | Systemic concern — create a tracking issue |

**When actionable vs informational:**

- Informational when hotspot count is stable or decreasing.
- Actionable when a new file enters the hotspot quadrant or when an
  existing hotspot's complexity is increasing.

**Prerequisites:**

- Git history (at least 30 days)
- A complexity measurement tool for the project's language

---

### File size growth

**HARNESS.md entry:**

```markdown
### File size growth

- **What it checks**: Whether any source files have grown beyond a
  declared line count threshold
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: find src/ -name '*.ts' -exec wc -l {} + | awk '$1 > 500'
- **Auto-fix**: false
```

**Interpretation:**

- Files exceeding the threshold are candidates for splitting.
- The threshold is project-specific — 300-500 lines is a common
  starting point.

---

## Coverage Fitness Functions

### Test coverage per architectural layer

**HARNESS.md entry:**

```markdown
### Test coverage per architectural layer

- **What it checks**: Whether test coverage has declined in any
  architectural layer since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using coverage reports per directory)
- **Auto-fix**: false
```

**Tool commands:**

```bash
# JS/TS (istanbul/nyc):
npx nyc --reporter=json report
# Then parse coverage-final.json by directory

# Go:
go test -coverprofile=cover.out ./...
go tool cover -func=cover.out
# Then aggregate by package

# Java (jacoco):
mvn jacoco:report
# Then parse target/site/jacoco/index.html or CSV output
```

**Interpretation:**

The agent compares coverage per directory/package against the previous
snapshot:

| Change | Action |
| --- | --- |
| Coverage stable or increasing | Healthy — record snapshot |
| Coverage dropped <5% in one layer | Note — may be temporary |
| Coverage dropped >5% in one layer | Create issue — investigate |
| Coverage dropped in multiple layers | Systemic concern — prioritise |

**When actionable vs informational:**

- Informational when coverage fluctuates within 2-3%.
- Actionable when a layer drops below a project-defined minimum or
  when a sustained decline spans 3+ snapshots.

---

### Mutation testing kill rate

**HARNESS.md entry:**

```markdown
### Mutation testing kill rate

- **What it checks**: Whether the mutation testing kill rate has
  declined since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using mutation testing reports)
- **Auto-fix**: false
```

**Tool commands:**

```bash
# JS/TS (Stryker):
npx stryker run

# Java (Pitest):
mvn org.pitest:pitest-maven:mutationCoverage

# Go (go-mutesting):
go-mutesting ./...
```

**Interpretation:**

- Kill rate >80%: tests are catching real bugs effectively.
- Kill rate 60-80%: tests exist but miss significant mutations.
- Kill rate <60%: tests provide a false sense of security.
- Declining kill rate across snapshots: test quality is degrading
  even if coverage numbers look stable.
