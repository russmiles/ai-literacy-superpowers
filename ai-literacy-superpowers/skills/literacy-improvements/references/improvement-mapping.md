# Improvement Mapping Reference

This file maps each level transition to the specific plugin commands
and skills that close the gaps. The `literacy-improvements` skill reads
this mapping to generate prioritised plans.

## How to Read This File

Each section covers one level transition (e.g., L1 → L2). Within each
section, gaps are listed with:

- **Gap** — what is missing
- **Action** — the plugin command or skill that closes it
- **Priority** — High / Medium / Low (see heuristic in SKILL.md)
- **Check** — how to verify whether the gap is already closed

## L1 → L2 (Prompting → Verification)

| Gap | Action | Priority | Check |
| --- | --- | --- | --- |
| No CI test pipeline | (manual — outside plugin scope) | High | `.github/workflows/*.yml` with test step |
| No linting in CI | `auto-enforcer-action` skill | Medium | `.github/workflows/*.yml` with lint step |
| No vulnerability scanning | `dependency-vulnerability-audit` skill | Medium | CI workflow with govulncheck, npm audit, or equivalent |
| No Docker image scanning | `docker-scout-audit` skill | Low | CI workflow with Docker Scout (skip if no Dockerfiles) |
| No secret scanning | `secrets-detection` skill | Medium | gitleaks in CI or pre-commit |

## L2 → L3 (Verification → Habitat Engineering)

| Gap | Action | Priority | Check |
| --- | --- | --- | --- |
| No CLAUDE.md or conventions | `/harness-init` (context feature) | High | `CLAUDE.md` exists with conventions |
| No HARNESS.md | `/harness-init` (constraints feature) | High | `HARNESS.md` exists with constraints |
| Constraints declared but not enforced | `/harness-constrain` | High | HARNESS.md constraints with enforcement = deterministic or agent |
| No CI constraint enforcement | `/harness-init` (CI feature) or `auto-enforcer-action` skill | Medium | `.github/workflows/harness.yml` exists |
| No reflections | `/reflect` | Medium | `REFLECTION_LOG.md` with at least one entry |
| No AGENTS.md | `/superpowers-init` or manual curation | Medium | `AGENTS.md` exists with entries |
| Conventions not extracted | `/extract-conventions` | Medium | HARNESS.md Context section has specific conventions |
| No GC rules | `/harness-init` (GC feature) | Medium | HARNESS.md Garbage Collection section with rules |
| No observability | `/harness-health` | Low | `observability/snapshots/` with at least one snapshot |

## L3 → L4 (Habitat → Specification Architecture)

| Gap | Action | Priority | Check |
| --- | --- | --- | --- |
| No spec-first workflow | `harness-engineering` skill (spec-first guidance) | High | `specs/` or `docs/superpowers/specs/` directory with spec files |
| No agent pipeline | `/superpowers-init` (agent team feature) | High | `.claude/agents/orchestrator.md` or equivalent |
| No safety gates in orchestrator | `constraint-design` skill | Medium | Orchestrator with MAX_REVIEW_CYCLES or equivalent guardrails |
| Convention drift across tools | `/convention-sync` | Medium | `.cursor/rules/`, `.github/copilot-instructions.md`, or `.windsurf/rules/` |
| No fitness functions | `fitness-functions` skill + `/harness-gc` | Low | HARNESS.md GC section with fitness function rules |

## L4 → L5 (Specification → Sovereign Engineering)

| Gap | Action | Priority | Check |
| --- | --- | --- | --- |
| No reusable plugin | `cross-repo-orchestration` skill | High | `.claude-plugin/plugin.json` or published plugin |
| No model routing | `model-sovereignty` skill | Medium | `MODEL_ROUTING.md` with routing rules |
| No cost tracking | `model-sovereignty` skill (cost section) | Medium | Cost analysis in MODEL_ROUTING.md or separate document |
| No observability export | `harness-observability` skill (telemetry layer) | Low | OTel configuration or telemetry export script |

## Maintaining This File

When new skills or commands are added to the plugin, check whether
they close a gap at any level. If so, add them to the appropriate
table. The mapping should always reflect the current plugin capability.
