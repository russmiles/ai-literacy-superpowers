# Sync Patterns Reference

This reference provides the practical workflows and worked examples
for cross-repo orchestration. The main skill describes the patterns;
this file shows how to implement them.

## Git-Mediated Sync Workflow

The complete workflow for syncing changes from an upstream repo to a
downstream repo. This generalises the `/sync-repos` command used in
the AI Literacy project.

### Prerequisites

- Both repos cloned locally
- `gh` CLI installed and authenticated
- Write access to both repos

### Step-by-Step

```bash
# 1. Identify what changed upstream
cd $UPSTREAM_REPO
git log --oneline -5  # or check CHANGELOG.md

# 2. Switch to downstream and prepare
cd $DOWNSTREAM_REPO
git checkout main && git pull
git checkout -b sync-from-upstream-YYYY-MM-DD

# 3. Copy changed artefacts
# Only copy what the upstream declares as exported
cp $UPSTREAM_REPO/skills/changed-skill/SKILL.md \
   $DOWNSTREAM_REPO/skills/changed-skill/SKILL.md

# 4. Update downstream README if counts changed
# Check skill/agent/command counts and mechanism map

# 5. Lint and verify
npx markdownlint-cli2 "**/*.md"

# 6. Commit with upstream reference
git add -A
git commit -m "Sync from upstream: [describe what changed]

Synced from $UPSTREAM_REPO commit [SHA or PR number]."

# 7. Push and create PR
git push -u origin sync-from-upstream-YYYY-MM-DD
gh pr create --title "Sync: [description]" \
  --body "Synced from upstream. Changes: ..."

# 8. Watch CI and merge
gh pr checks <number> --watch
gh pr merge <number> --merge

# 9. Clean up
git checkout main && git pull
git fetch --prune
```

## Worked Example: Three-Repo Topology

The AI Literacy project demonstrates a concrete three-repo topology:

```text
ai-literacy-for-software-engineers (framework/source)
  │
  ├── exports: skills, agent patterns, hook scripts, templates
  │
  ├──→ ai-literacy-superpowers (plugin/distribution)
  │     │
  │     ├── repackages: skills, agents, hooks, commands
  │     ├── adds: prompts (Copilot CLI), marketplace manifest
  │     │
  │     └──→ ai-literacy-exemplar (demo/consumer)
  │           └── installs the plugin, demonstrates the workflow
  │
  └── sync trigger: /sync-repos command, framework-change-prompt.sh hook
```

### What flows downstream

| From framework → plugin | From plugin → exemplar |
| ------------------------ | ---------------------- |
| Skill content (SKILL.md files) | Via plugin install (automatic) |
| Agent definitions | Via plugin install (automatic) |
| Hook scripts + hooks.json | Via plugin install (automatic) |
| Template updates | Via plugin install (automatic) |
| README count updates | Manual (during sync) |

### What does NOT flow

| Stays in framework | Stays in exemplar |
| ------------------- | ------------------ |
| HARNESS.md (project constraints) | HARNESS.md (project constraints) |
| AGENTS.md (project learnings) | AGENTS.md (project learnings) |
| REFLECTION_LOG.md | REFLECTION_LOG.md |
| Specs and plans | Specs and plans |
| TUI source code | mdcheck source code |
| Assessment documents | Assessment documents |

### Sync triggers

The framework repo's `framework-change-prompt.sh` Stop hook detects
when `framework/framework.md` is modified and nudges: "Run /sync-repos
to roll out changes to the plugin and exemplar."

For non-framework changes (new skills, updated hooks), the developer
runs `/sync-repos` manually after merging the upstream PR.

## Specification Manifest Format (L5 Sketch)

For teams graduating to specification-mediated orchestration, a
manifest declares exports and imports:

```yaml
# .repo-manifest.yml
name: my-platform-plugin
version: 1.0.0

exports:
  skills:
    - literate-programming
    - cupid-code-review
    - harness-engineering
  agents:
    - orchestrator
    - code-reviewer
  hooks:
    - constraint-gate
    - drift-check
  templates:
    - CLAUDE.md
    - HARNESS.md

imports: []
```

```yaml
# downstream/.repo-manifest.yml
name: my-service
version: 2.3.0

exports:
  agents:
    - go-implementer  # project-specific

imports:
  - source: my-platform-plugin
    version: ">=1.0.0"
    artefacts:
      - skills/*
      - hooks/*
      - templates/HARNESS.md
```

This format is a sketch, not a formal standard. Teams adopting L5
orchestration should adapt it to their tooling.

## Portfolio Health Aggregation

For teams with 5+ repos, aggregate health snapshots:

1. Each repo runs `/harness-health` on its cadence
2. A portfolio script reads the latest snapshot from each repo
3. Aggregation produces portfolio-level metrics:
   - Average enforcement ratio
   - Repos below threshold
   - Mutation score trends across the portfolio
   - Stale snapshot count
4. The portfolio report lives in the platform repo

This extends single-repo observability to organisational scale without
requiring centralised infrastructure — just git and markdown.

## Decision Table

| Question | Git-Mediated | Specification-Mediated |
| ---------- | ------------- | ---------------------- |
| How many downstream repos? | 2-5 | 10+ |
| Who triggers sync? | Human or single agent | Platform orchestrator |
| How are exports declared? | README section | Formal manifest file |
| How are changes applied? | Branch/PR/merge per repo | Automated PR generation |
| How is health tracked? | Per-repo snapshots | Portfolio aggregation |
| What maturity is needed? | L4 (spec-first) | L5 (platform engineering) |
| What's the failure mode? | Forgotten sync (tribal knowledge) | Manifest drift (contract mismatch) |
