# ai-literacy-superpowers

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Lint Markdown](https://github.com/russmiles/ai-literacy-superpowers/actions/workflows/lint-markdown.yml/badge.svg)](https://github.com/russmiles/ai-literacy-superpowers/actions/workflows/lint-markdown.yml)
[![Plugin Version](https://img.shields.io/badge/Plugin-v0.1.0-4682B4?style=flat-square)](https://github.com/russmiles/ai-literacy-superpowers)
[![Skills](https://img.shields.io/badge/Skills-12-2E8B57?style=flat-square)](#skills-12)
[![Agents](https://img.shields.io/badge/Agents-10-2E8B57?style=flat-square)](#agents-10)
[![Commands](https://img.shields.io/badge/Commands-11-2E8B57?style=flat-square)](#commands-11)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-black?style=flat-square)](https://claude.ai/claude-code)

A [Claude Code](https://claude.ai/claude-code) plugin that gives you the AI Literacy framework's complete development workflow — harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops.

Install the plugin, run `/superpowers-init`, and get a fully operational habitat for AI-assisted development.

---

## Installation

Add the marketplace and install the plugin:

```bash
# Add the marketplace
claude plugin marketplace add russmiles/ai-literacy-superpowers

# Install the plugin
claude plugin install ai-literacy-superpowers
```

Once installed, the plugin's skills, agents, commands, and hooks are available in any Claude Code session within your project.

### Quick start

After installation, run these commands to set up your project:

```bash
# Full habitat setup (recommended for new projects)
/superpowers-init

# Harness-only setup (if you want constraints without the agent pipeline)
/harness-init

# Check the status of your harness
/harness-status

# Run a health check
/harness-health

# Run an AI literacy assessment
/assess
```

**`/superpowers-init`** sets up the complete habitat: CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, REFLECTION_LOG.md, the full agent team, skills, hooks, and CI workflow templates. Use this for new projects.

**`/harness-init`** sets up only the harness: HARNESS.md with starter constraints and GC rules. Use this if you want the constraint and enforcement machinery without the full agent pipeline.

---

## What You Get

### Skills (12)

Code quality and harness engineering knowledge that agents read when working in your codebase.

| Skill | What it provides |
| ----- | ---------------- |
| literate-programming | Knuth's five rules — code as literature, reader-first |
| cupid-code-review | Terhorst-North's five properties — composable, unix, predictable, idiomatic, domain-based |
| github-actions-supply-chain | CI hardening checklist — SHA pinning, permissions, dependabot |
| dependency-vulnerability-audit | Go and Maven CVE scanning procedures |
| docker-scout-audit | Docker image CVE triage and remediation |
| harness-engineering | Foundational concepts — the three components, promotion ladder, enforcement timing |
| context-engineering | Writing conventions precise enough for humans and LLMs to enforce |
| constraint-design | Designing enforceable constraints with the verification slot model |
| garbage-collection | Entropy-fighting patterns and the auto-fix safety rubric |
| verification-slots | The unified interface for deterministic and agent-based checks |
| ai-literacy-assessment | Assessment instrument — scan repo, ask questions, produce timestamped assessment with remediation |
| harness-observability | Four-layer observability guidance — snapshot format, telemetry export, meta-observability checks |

### Agents (10)

A coordinated team that handles the full development lifecycle.

| Agent | Role | Trust boundary |
| ----- | ---- | -------------- |
| orchestrator | Pipeline coordinator — dispatches agents in sequence | Full access |
| spec-writer | Updates specs and plans before any code is written | No Bash |
| tdd-agent | Writes failing tests from spec scenarios | Can execute tests |
| code-reviewer | Reviews code through CUPID and literate programming lenses | No Write |
| integration-agent | CHANGELOG, commit, PR, CI, merge, cleanup, reflection | Full git access |
| harness-discoverer | Read-only project scanner | Read only |
| harness-enforcer | Unified verification engine for all constraint types | Read + Bash |
| harness-gc | Periodic entropy fighter | Read + Write |
| harness-auditor | Meta-agent — checks whether the harness matches reality | Write to Status only |
| assessor | AI literacy assessment — scans repo, asks questions, applies fixes, recommends workflow changes | Read + Write |

### Commands (11)

| Command | What it does |
| ------- | ------------ |
| `/superpowers-init` | Guided setup — scaffolds the full habitat |
| `/superpowers-status` | Health dashboard — harness, agents, learning, CI |
| `/harness-init` | Harness-specific init |
| `/harness-status` | Quick harness health read |
| `/harness-constrain` | Add or promote a constraint |
| `/harness-gc` | Manage and run garbage collection rules |
| `/harness-audit` | Full meta-verification of the harness |
| `/reflect` | Capture a post-task reflection |
| `/worktree` | Git worktree lifecycle — spin, merge, clean |
| `/assess` | AI literacy assessment with immediate fixes and workflow recommendations |
| `/harness-health` | Harness health snapshot — enforcement ratio, trends, meta-observability checks |

### Templates (8)

Opinionated defaults scaffolded by `/superpowers-init`:

- **CLAUDE.md** — framework-aligned conventions (literate programming, CUPID, spec-first, TDD)
- **HARNESS.md** — living harness with starter constraints and enforcement timing
- **AGENTS.md** — compound learning memory (human-curated, agent-proposed)
- **MODEL_ROUTING.md** — model-tier guidance and token budget thresholds (see below)
- **REFLECTION_LOG.md** — append-only agent reflection log
- **ci-github-actions.yml** — CI enforcement template for GitHub Actions
- **ci-mutation-testing.yml** — weekly mutation testing template
- **ci-generic.sh** — fallback CI script for non-GitHub systems

**MODEL_ROUTING.md** guides cost-conscious model selection. It maps each agent to a model tier (most capable, standard, fast) based on the judgment required. The orchestrator consults it when dispatching agents — spec-writers and code-reviewers get the most capable model; implementers and integration agents get standard models. Token budget guidance prevents runaway costs.

### Hooks (5)

All five hooks are registered in `hooks/hooks.json` and active in every Claude Code session.

- **PreToolUse constraint gate** — reads HARNESS.md, warns on violations during edits (advisory, does not block)
- **Stop drift check** — detects when CI, linter, or dependency configs change, nudges `/harness-audit`
- **Stop snapshot staleness check** — detects when the harness snapshot is stale (> 30 days), nudges `/harness-health`
- **Stop reflection prompt** — detects commits during the session, nudges `/reflect` to capture learnings
- **Stop framework-change prompt** — detects `framework.md` modifications, nudges `/reflect` + `/sync-repos` + downstream README checks

---

## Quick Start

### Install

```bash
# Install the plugin (method depends on your Claude Code setup)
claude plugin install ai-literacy-superpowers
```

### Initialize

```bash
cd your-project
```

Then in Claude Code:

```text
/superpowers-init
```

The init command will:

1. Scan your project to discover the stack, existing linters, CI, and test frameworks
2. Ask about your conventions (one topic at a time)
3. Ask which constraints to enforce and how
4. Offer the full agent pipeline or a subset
5. Generate CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, REFLECTION_LOG.md, CI workflows, and a README badge
6. Commit everything

### Check Health

```text
/superpowers-status
```

Shows harness enforcement ratio, agent team configuration, compound learning state, model routing, and CI summary.

---

## How to Extend

### Adding a language-specific implementer

The plugin provides the agent pipeline pattern but does not ship language-specific implementers — these are created per project for each language in the stack. To create one:

1. Copy the pattern from any existing implementer (e.g. the exemplar's `go-implementer.md`)
2. Adapt the tool permissions, file scope, and build commands for your language
3. Save to `.claude/agents/<language>-implementer.md` in your project
4. The orchestrator will discover and dispatch it automatically

### Adding a new skill

1. Create a directory: `skills/<skill-name>/`
2. Add `SKILL.md` with YAML frontmatter (`name`, `description` with trigger conditions)
3. Optionally add a `references/` subdirectory for supporting material
4. The plugin auto-discovers skills by directory structure

### Adding a new command

1. Create `commands/<command-name>.md` with YAML frontmatter (`name`, `description`)
2. Define the process steps the command should follow
3. The command becomes available as `/<command-name>` in Claude Code sessions

### Adding a new hook

1. Create a script in `hooks/scripts/<script-name>.sh`
2. Add an entry to `hooks/hooks.json` under the appropriate event (`PreToolUse`, `PostToolUse`, or `Stop`)
3. Hook scripts receive context via environment variables (`CLAUDE_PROJECT_DIR`, etc.)
4. Always make hooks advisory (warn, don't block) unless enforcement is critical

---

## The Three Enforcement Loops

Every mechanism in the plugin operates at one of three timescales:

| Loop | Trigger | Strictness | Purpose |
| ---- | ------- | ---------- | ------- |
| Advisory | PreToolUse hook | Warn | Catch issues while context is fresh |
| Strict | CI on PR | Fail | Prevent violations from reaching main |
| Investigative | Scheduled GC + audit | Report | Fight slow entropy that gates miss |

### Mechanism Map

```text
ADVISORY LOOP (edit time — warn, do not block)
│
├── Hooks
│   ├── PreToolUse constraint gate     Reads HARNESS.md commit-scoped constraints,
│   │                                  warns on violations during Write/Edit
│   ├── Stop drift check               Detects CI/linter/dependency changes at
│   │                                   session end, nudges /harness-audit
│   ├── Stop snapshot staleness check  Detects stale harness snapshot (> 30 days),
│   │                                   nudges /harness-health
│   ├── Stop reflection prompt          Detects commits during session,
│   │                                    nudges /reflect to capture learnings
│   └── Stop framework-change prompt   Detects framework.md modifications,
│                                        nudges /reflect + /sync-repos +
│                                        downstream README checks
├── Context (read by agents at session start)
│   ├── CLAUDE.md                       Workflow rules, conventions, disciplines
│   ├── AGENTS.md                       Compound learning memory (human-curated)
│   ├── MODEL_ROUTING.md                Model-tier guidance + token budgets
│   └── Skills (12)                     Domain knowledge for agents
│
└── Commands
    ├── /reflect                        Capture post-task learnings
    └── /worktree spin|merge|clean      Parallel agent isolation


STRICT LOOP (merge time — block until green)
│
├── CI Workflows (generated from templates)
│   ├── ci-github-actions.yml           PR-scoped constraint enforcement
│   └── ci-mutation-testing.yml         Language-specific mutation testing
│
├── Agent Pipeline
│   ├── orchestrator                    Coordinates full pipeline
│   │   ├── GATE: plan approval         User reviews spec before implementation
│   │   └── GUARDRAIL: MAX_REVIEW_CYCLES=3
│   ├── spec-writer                     Spec + plan updates (no Bash)
│   ├── tdd-agent                       Failing tests from spec scenarios
│   ├── implementer(s)                  Makes tests green — user-created per
│   │                                   language, not shipped by the plugin
│   ├── code-reviewer                   CUPID + LP review (no Write)
│   └── integration-agent               CHANGELOG, PR, CI, merge, reflection
│
└── Harness Constraints (HARNESS.md)
    ├── Deterministic                   Backed by CI tools
    ├── Agent-backed                    Backed by harness-enforcer
    └── Unverified                      Declared intent, not yet automated


INVESTIGATIVE LOOP (scheduled — sweep for entropy)
│
├── Garbage Collection Rules (HARNESS.md)
│   └── Configurable per project        Documentation freshness, dependency
│                                        currency, convention drift
├── Compound Learning
│   ├── REFLECTION_LOG.md               Agent reflections (append-only)
│   └── AGENTS.md                       Human-curated from reflections
│
└── Harness Commands
    ├── /harness-audit                  Full meta-verification
    ├── /harness-health                 Snapshot with trends and meta-observability checks
    ├── /harness-status                 Quick health read
    └── /harness-gc                     Run GC checks on demand
```

### Observability as the Enabling Layer

The three enforcement loops generate signals that, when collected, make the entire habitat observable. The plugin's mechanisms produce the data; observability tools (OpenTelemetry, Claude Code analytics, Grafana) make it visible.

| Panel | What it shows | Sources |
| ----- | ------------- | ------- |
| **Cost** | Spend trend, model-tier distribution, cost per PR | Provider API, MODEL_ROUTING.md compliance |
| **Quality** | Coverage trend, mutation score trend, change failure rate | CI artifacts, mutation testing workflow |
| **Adoption** | Active AI users, sessions per developer, acceptance rate | Provider analytics |
| **Habitat health** | Harness enforcement ratio, compound learning growth, ALCI progression | /harness-status, REFLECTION_LOG.md, ALCI surveys |

Without observability, cost discipline is aspirational, mutation testing is a one-time experiment, and the harness is a document that may or may not match reality. With it, every mechanism gains an evidence layer.

---

## Harness Observability

The plugin includes a four-layer observability model for monitoring harness health over time:

| Layer | Question | How |
| ----- | -------- | --- |
| Operational cadence | Is the harness running? | `/harness-health` generates snapshots; a Stop hook nudges when the last snapshot is older than 30 days |
| Trend visibility | How has the harness changed? | Snapshots are diffed to show deltas; `--trends` produces multi-period views |
| Telemetry export | Can I visualise this externally? | Snapshot data can be exported as OpenTelemetry metrics to any OTLP-compatible backend |
| Meta-observability | Is the observability itself working? | Five self-checks: snapshot currency, cadence compliance, learning flow, GC effectiveness, trend direction |

### Health snapshots

`/harness-health` generates structured markdown snapshots stored in `observability/snapshots/`. Each snapshot captures:

- Enforcement ratios (deterministic / agent / unverified breakdown)
- Garbage collection rule status and findings
- Mutation testing kill rates per language
- Compound learning velocity (reflections and promotions)
- Operational cadence compliance
- Meta-observability results

Trends are derived by diffing consecutive snapshots — no external tooling required.

### README health badge

`/harness-health` maintains a shields.io badge in the project README:

- **Healthy** (green) — all layers operating, no overdue cadences
- **Attention** (amber) — one layer degraded or outer loop overdue
- **Degraded** (red) — multiple layers degraded or no snapshot in 30+ days

### Telemetry export

For teams that want external dashboards, the `references/telemetry-export.md` reference documents OTel metric names and a reference export script. The file-based approach (snapshots in git) is the default — telemetry export is optional.

### Related plugin components

- Skill: `skills/harness-observability/SKILL.md`
- Command: `commands/harness-health.md`
- Meta-checks: `skills/harness-observability/references/meta-observability-checks.md`
- Snapshot format: `skills/harness-observability/references/snapshot-format.md`
- Telemetry export: `skills/harness-observability/references/telemetry-export.md`
- Hook: snapshot staleness check in `hooks/hooks.json`
- Script: `scripts/update-health-badge.sh`

---

## The Agent Pipeline

When you use the orchestrator agent, it runs this pipeline:

```text
orchestrator
  → spec-writer
  → GATE: plan approval (user reviews before proceeding)
  → tdd-agent
  → implementer(s) (parallel, one per language — user-created per project)
  → code-reviewer
  → GUARDRAIL: MAX_REVIEW_CYCLES=3 (escalate after 3 loops)
  → integration-agent (includes reflection step)
```

The plan approval gate catches bad plans before they become bad code. The loop guardrail prevents unbounded reviewer cycles. Both keep the orchestration from running away.

The plugin ships the orchestrator, spec-writer, tdd-agent, code-reviewer, and integration-agent. Language-specific implementers are not included — each project creates its own based on the stack. See [How to Extend](#how-to-extend) for instructions.

---

## Compound Learning

Agents learn across sessions through curated documentation:

```text
Agent completes work
  → integration-agent appends to REFLECTION_LOG.md
  → Human reviews periodically
  → Worthy entries promoted to AGENTS.md
  → All agents read AGENTS.md at next session start
```

Research shows LLM-generated documentation files reduce success rates. Human-curated files provide modest but real improvement. The rule: agents propose; humans curate.

### Compound learning flow

The plugin implements a three-stage learning cycle:

1. **Capture** — the integration-agent appends a structured reflection to `REFLECTION_LOG.md` after each task (date, agent, task, surprise, proposal, improvement)
2. **Curate** — during the quarterly operating cadence, humans review reflections and promote worthy entries to `AGENTS.md` as GOTCHA or ARCH_DECISION entries
3. **Benefit** — all agents read `AGENTS.md` at session start, incorporating prior learnings into their decision-making

The GC rule "Stale AGENTS.md" flags reflections older than 30 days that haven't been reviewed for promotion. This prevents the common failure mode where reflections are captured but nobody reads them.

---

## Intellectual Foundations

This plugin packages the practical workflow from the AI Literacy for Software Engineers framework, drawing on:

- **Christopher Alexander** — the quality without a name; design for inhabitants
- **Donald Knuth** — literate programming; code as literature for readers
- **Richard P. Gabriel** — habitability; code as a place to live in
- **Daniel Terhorst-North** — CUPID; code as a place of joy; properties over principles
- **Birgitta Boeckeler** — harness engineering; deterministic and LLM-based enforcement
- **Addy Osmani** — agent orchestration; subagents, agent teams, quality gates

The mission: building habitats where human and AI intelligence thrive together.

---

## See It in Action

For a complete worked example of this plugin applied to a real project, see the [ai-literacy-exemplar](https://github.com/russmiles/ai-literacy-exemplar) repository — a Go CLI tool built using the full agent pipeline, with authentic git history showing the framework workflow.

---

## License

[Apache License 2.0](LICENSE)
