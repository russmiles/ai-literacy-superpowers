---
name: cross-repo-orchestration
description: Use when coordinating changes across multiple repositories — syncing skills, templates, agents, or harness policies between upstream and downstream repos, or designing portfolio-level agent orchestration
---

# Cross-Repo Orchestration

When a project spans multiple repositories, the practices that work
within a single repo — specification-driven development, harness
enforcement, compound learning — must extend across repo boundaries.
This skill teaches two patterns for cross-repo coordination, each
suited to a different maturity level.

This skill does not cover single-repo agent orchestration (see the
orchestrator agent), CI/CD pipeline design, or monorepo tooling.

For worked examples and the sync workflow, consult
`references/sync-patterns.md`.

## When to Use

| Situation | Pattern |
| ----------- | --------- |
| Syncing skills, templates, or hooks from a framework repo to a plugin repo | L4: Git-mediated |
| Propagating harness changes to downstream consumers | L4: Git-mediated |
| Rolling out a new convention across 2-5 related repos | L4: Git-mediated |
| Managing shared standards across 10+ repos in a portfolio | L5: Specification-mediated |
| Aggregating health snapshots across an organisation | L5: Specification-mediated |
| Designing platform-level harness policies | L5: Specification-mediated |

## Pattern 1: Git-Mediated Coordination (Level 4)

A single agent (or human) applies changes from an upstream repo to
one or more downstream repos using git's standard workflow.

### The Workflow

1. **Identify what changed upstream** — review the changelog, diff,
   or commit log to determine which exported artefacts were modified
2. **For each downstream repo:**
   a. Check out main and pull latest
   b. Create a feature branch
   c. Copy or apply the upstream changes
   d. Update the downstream README if counts or descriptions changed
   e. Run lint and verify
   f. Commit with a message referencing the upstream change
   g. Push and create a PR
   h. Watch CI checks
   i. Merge when green
   j. Clean up the branch

### What Gets Synced

Not everything should flow downstream. Define clear boundaries:

| Sync | Don't sync |
| ------ | ----------- |
| Skills (tool-agnostic knowledge) | HARNESS.md (project-specific constraints) |
| Agent definitions (pipeline patterns) | AGENTS.md (project-specific learnings) |
| Hook scripts and hooks.json | REFLECTION_LOG.md (project-specific reflections) |
| Templates (starting points) | Specs and plans (project-specific features) |
| CI workflow templates | Project source code |

### Declaring Exports

Document what the upstream repo exports in its README or a dedicated
manifest section. At minimum, state:

- Which directories contain reusable artefacts
- What the downstream repos are
- What triggers a sync (e.g. "after any PR that modifies skills/")

### Anti-Patterns

| Anti-pattern | Problem | Fix |
| ------------- | --------- | ----- |
| Sync without contracts | Nobody knows what should flow where | Declare exports in README or manifest |
| Bidirectional sync | Changes flow both ways, causing conflicts | Pick one direction — upstream is authoritative |
| Sync everything | Downstream repos lose their identity | Only sync what's declared as exported |
| Manual ad-hoc copies | Drift accumulates silently | Use a documented sync command or workflow |
| Sync without CI | Broken changes propagate downstream | Every sync goes through a PR with CI checks |

## Pattern 2: Specification-Mediated Orchestration (Level 5)

At organisational scale, git-mediated sync becomes unwieldy. Repos
declare their dependencies through specification manifests, and a
platform orchestrator resolves and propagates changes.

### Specification Manifests

Each repo declares what it exports and imports:

```yaml
# .repo-manifest.yml (sketch — not yet a formal standard)
name: ai-literacy-superpowers
version: 0.1.0

exports:
  skills:
    - literate-programming
    - cupid-code-review
    - harness-engineering
    - convention-extraction
    - cross-repo-orchestration
  agents:
    - orchestrator
    - code-reviewer
    - integration-agent
  hooks:
    - constraint-gate
    - drift-check
    - snapshot-staleness

imports: []  # This is a root/platform repo — it imports nothing
```

A downstream repo declares what it consumes:

```yaml
name: ai-literacy-exemplar
version: 0.1.0

exports:
  agents:
    - go-implementer  # project-specific, not imported

imports:
  - source: ai-literacy-superpowers
    version: ">=0.1.0"
    artefacts:
      - skills/*
      - hooks/*
```

### Platform Harness Propagation

When the platform repo changes a harness policy (e.g. raises the
mutation testing threshold), downstream repos that import that policy
inherit the change through their manifest contract. The platform
orchestrator:

1. Reads all downstream manifests
2. Identifies which repos consume the changed artefact
3. Opens sync PRs in each affected repo
4. Reports the sync status to the portfolio dashboard

### Portfolio-Level Health

Health snapshots aggregate across the portfolio:

```text
Portfolio Health — 2026-04-01

Repos: 12
At L3+: 9 (75%)
Below threshold: 3 (api-gateway, legacy-auth, billing-service)
Enforcement average: 84%
Mutation score average: 76%
Repos with stale snapshots: 1 (legacy-auth, 45 days)
```

This extends the single-repo harness observability pattern to
organisational scale.

## Choosing the Right Pattern

| Factor | Git-Mediated (L4) | Specification-Mediated (L5) |
| -------- | ------------------- | --------------------------- |
| Number of repos | 2-5 | 10+ |
| Sync frequency | After specific changes | Continuous/automated |
| Coordination | Single agent or human | Platform orchestrator |
| Contract format | README documentation | Formal manifest files |
| Portfolio visibility | Per-repo snapshots | Aggregated dashboard |
| Team maturity needed | L4 (spec-first workflow) | L5 (platform engineering) |

Start with git-mediated. Graduate to specification-mediated when the
portfolio grows beyond what a single agent can manage.
