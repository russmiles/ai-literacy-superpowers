# ai-literacy-superpowers

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Lint Markdown](https://github.com/Habitat-Thinking/ai-literacy-superpowers/actions/workflows/lint-markdown.yml/badge.svg)](https://github.com/Habitat-Thinking/ai-literacy-superpowers/actions/workflows/lint-markdown.yml)
[![Plugin Version](https://img.shields.io/badge/Plugin-v0.16.0-4682B4?style=flat-square)](https://github.com/Habitat-Thinking/ai-literacy-superpowers)
[![Skills](https://img.shields.io/badge/Skills-27-2E8B57?style=flat-square)](#skills-27)
[![Agents](https://img.shields.io/badge/Agents-11-2E8B57?style=flat-square)](#agents-11)
[![Commands](https://img.shields.io/badge/Commands-18-2E8B57?style=flat-square)](#commands-18)
[![Harness](https://img.shields.io/badge/Harness-11%2F11_enforced-2E8B57?style=flat-square)](HARNESS.md)
[![Harness Health](https://img.shields.io/badge/Harness_Health-Attention-DAA520?style=flat-square)](observability/snapshots/2026-04-14-snapshot.md)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-D97757?style=flat-square&logo=anthropic&logoColor=white)](https://claude.ai/claude-code)
[![Copilot CLI](https://img.shields.io/badge/Copilot_CLI-Plugin-000000?style=flat-square&logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Agent Harness Enabled](https://img.shields.io/badge/Agent_Harness-Enabled-000000?style=flat-square)](HARNESS.md)
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_5-DAA520?style=flat-square)](assessments/2026-04-11-assessment.md)

A plugin for [Claude Code](https://claude.ai/claude-code) and [GitHub Copilot CLI](https://github.com/features/copilot) that gives you the AI Literacy framework's complete development workflow — harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops.

Install the plugin, run `/superpowers-init`, and get a fully operational habitat for AI-assisted development.

---

## Installation

### Claude Code

```bash
# Add the marketplace
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers

# Install the plugin
claude plugin install ai-literacy-superpowers
```

### GitHub Copilot CLI

```bash
/plugin install ai-literacy-superpowers
```

Once installed, the plugin's skills, agents, hooks, and commands (or prompts) are available in any session within your project.

> Commands are available as `/command-name` in Claude Code and as `/prompt-name` in Copilot CLI.

### Updating

#### Update the plugin

When a new version is released, update your local installation:

```bash
# Claude Code
claude plugin update ai-literacy-superpowers

# Copilot CLI
/plugin update ai-literacy-superpowers
```

Check the [CHANGELOG](CHANGELOG.md) for what changed between versions.

#### Update the marketplace listing

If you maintain your own marketplace that includes this plugin, refresh
the index so new versions are discoverable:

```bash
claude plugin marketplace update Habitat-Thinking/ai-literacy-superpowers
```

This pulls the latest `plugin.json` metadata (version, description,
keywords) into the marketplace index. Users who have already installed
the plugin still need to run `claude plugin update` separately.

See [How to Update the Plugin](docs/how-to/update-the-plugin.md) for
the full guide.

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

### Tool Compatibility

This plugin works with both Claude Code and GitHub Copilot CLI from the same repository. The formats have converged:

| Component | Claude Code | Copilot CLI | Shared? |
| --------- | ----------- | ----------- | ------- |
| Skills | `skills/*/SKILL.md` | `skills/*/SKILL.md` | Identical |
| Agents | `agents/*.agent.md` | `agents/*.agent.md` | Identical |
| Hooks | `hooks/hooks.json` | `hooks/hooks.json` | Identical |
| Commands | `commands/*.md` | `.github/prompts/*.prompt.md` | Translated |
| Instructions | Via `templates/CLAUDE.md` | `.github/copilot-instructions.md` | Adapted |

---

## What You Get

### Skills (27)

Code quality, harness engineering, and governance knowledge that agents read when working in your codebase.

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
| ai-literacy-assessment | Assessment instrument — scan repo, ask questions, produce timestamped assessment with prioritised improvement plans |
| harness-observability | Four-layer observability guidance — snapshot format, telemetry export, meta-observability checks |
| convention-extraction | Five extraction questions, artefact mapping, four-element anatomy — surfaces tacit team conventions |
| cross-repo-orchestration | Git-mediated (L4) and specification-mediated (L5) patterns for syncing artefacts and governing portfolios |
| secrets-detection | Gitleaks-based secret scanning — configuration, baselining, and CI integration |
| auto-enforcer-action | Automatic PR constraint checking via GitHub Actions |
| convention-sync | Syncing HARNESS.md conventions to Cursor, Copilot, and Windsurf convention files |
| fitness-functions | Architectural fitness functions as GC rules — periodic checks for layer boundaries, coupling, and complexity |
| model-sovereignty | Decision framework for model selection, hosting, fine-tuning, and vendor independence |
| literacy-improvements | Prioritised improvement plan mapping assessment gaps to plugin commands and skills |
| portfolio-assessment | Multi-repo assessment aggregation — level distribution, shared gaps, and portfolio improvement plans |
| portfolio-dashboard | Generate a self-contained HTML dashboard from portfolio assessment data with trend visualisation |
| team-api | Create or update a Team Topologies Team API document with AI literacy portfolio data |
| cost-tracking | Quarterly AI cost capture — record spend, compare trends, inform model routing |
| governance-constraint-design | Falsifiable governance constraint authoring — three-frame translation, anti-patterns gallery, governance constraint template |
| governance-audit-practice | Governance audit methodology — five-stage semantic drift model, debt scoring matrix, frame alignment review |
| governance-observability | Governance metrics catalogue, snapshot format extension, and HTML dashboard specification |

### Agents (11)

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
| governance-auditor | Governance specialist — semantic drift analysis, debt inventory, three-frame alignment | Read + limited Write |

### Commands (18)

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
| `/assess` | AI literacy assessment with immediate fixes, workflow recommendations, and prioritised improvement plans |
| `/harness-health` | Harness health snapshot — enforcement ratio, trends, meta-observability checks |
| `/extract-conventions` | Guided session — surfaces tacit team conventions and maps them to CLAUDE.md and HARNESS.md |
| `/convention-sync` | Sync HARNESS.md conventions to Cursor, Copilot, and Windsurf convention files |
| `/portfolio-assess` | Multi-repo AI literacy assessment — aggregate across local repos, GitHub orgs, or topic tags |
| `/cost-capture` | Capture AI tool cost data — record spend, compare to previous snapshot, update model routing |
| `/governance-constrain` | Guided governance constraint authoring with three-frame alignment check |
| `/governance-audit` | Deep governance investigation — semantic drift, debt inventory, frame alignment |
| `/governance-health` | Governance health pulse check and dashboard generation |

### Templates (9)

Opinionated defaults scaffolded by `/superpowers-init`:

- **CLAUDE.md** — framework-aligned conventions (literate programming, CUPID, spec-first, TDD)
- **HARNESS.md** — living harness with starter constraints and enforcement timing
- **AGENTS.md** — compound learning memory (human-curated, agent-proposed)
- **MODEL_ROUTING.md** — model-tier guidance and token budget thresholds (see below)
- **REFLECTION_LOG.md** — append-only agent reflection log
- **ci-github-actions.yml** — CI enforcement template for GitHub Actions
- **ci-mutation-testing.yml** — weekly mutation testing template
- **ci-generic.sh** — fallback CI script for non-GitHub systems
- **harness-health-icon.svg** — monochrome shield icon for the README health badge

**MODEL_ROUTING.md** guides cost-conscious model selection. It maps each agent to a model tier (most capable, standard, fast) based on the judgment required. The orchestrator consults it when dispatching agents — spec-writers and code-reviewers get the most capable model; implementers and integration agents get standard models. Token budget guidance prevents runaway costs.

### Hooks (9)

All nine hooks are registered in `hooks/hooks.json` and active in every Claude Code session.

- **PreToolUse constraint gate** — reads HARNESS.md, warns on violations during edits (prompt-based, advisory)
- **PreToolUse markdownlint check** — runs markdownlint on `.md` files being written or edited (deterministic, advisory)
- **Stop drift check** — detects when CI, linter, or dependency configs change, nudges `/harness-audit`
- **Stop snapshot staleness check** — detects when the harness snapshot is stale (> 30 days), nudges `/harness-health`
- **Stop reflection prompt** — detects commits during the session, nudges `/reflect` to capture learnings
- **Stop framework-change prompt** — detects `framework.md` modifications, nudges `/reflect` + `/sync-repos` + downstream README checks
- **Stop secrets check** — scans for accidentally committed secrets or credentials using gitleaks
- **Stop rotating GC check** — runs one deterministic GC rule per session (rotating by day), catching entropy between weekly CI runs
- **Stop curation nudge** — detects unpromoted reflections in `REFLECTION_LOG.md` and nudges curation into `AGENTS.md`
- **Stop governance drift check** — detects governance-related file changes and audit staleness, nudges `/governance-audit`

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
│   ├── PreToolUse markdownlint check  Runs markdownlint on .md files being
│   │                                   written or edited (deterministic)
│   ├── Stop drift check               Detects CI/linter/dependency changes at
│   │                                   session end, nudges /harness-audit
│   ├── Stop snapshot staleness check  Detects stale harness snapshot (> 30 days),
│   │                                   nudges /harness-health
│   ├── Stop reflection prompt          Detects commits during session,
│   │                                    nudges /reflect to capture learnings
│   ├── Stop framework-change prompt   Detects framework.md modifications,
│   │                                    nudges /reflect + /sync-repos +
│   │                                    downstream README checks
│   ├── Stop secrets check             Scans for committed secrets using gitleaks
│   ├── Stop rotating GC check         Runs one deterministic GC rule per session,
│   │                                    rotating by day-of-year
│   ├── Stop curation nudge            Detects unpromoted reflections, nudges
│   │                                    curation into AGENTS.md
│   └── Stop governance drift check    Detects governance file changes, nudges
│                                        /governance-audit
├── Context (read by agents at session start)
│   ├── CLAUDE.md                       Workflow rules, conventions, disciplines
│   ├── AGENTS.md                       Compound learning memory (human-curated)
│   ├── MODEL_ROUTING.md                Model-tier guidance + token budgets
│   └── Skills (27)                     Domain knowledge for agents
│
└── Commands
    ├── /reflect                        Capture post-task learnings
    └── /worktree spin|merge|clean      Parallel agent isolation


STRICT LOOP (merge time — block until green)
│
├── CI Workflows (generated from templates)
│   ├── ci-github-actions.yml           PR-scoped constraint enforcement
│   │                                    (markdownlint, gitleaks, shell checks)
│   ├── gc.yml                           Weekly GC for deterministic rules
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
│   ├── Weekly CI workflow (gc.yml)      Deterministic rules: secret scanner,
│   │                                    snapshot staleness, shell checks
│   ├── Rotating Stop hook               One deterministic GC rule per session
│   └── Agent-scoped rules               Documentation freshness, command-prompt
│                                         sync, plugin manifest currency
├── Compound Learning
│   ├── REFLECTION_LOG.md               Agent reflections (append-only)
│   └── AGENTS.md                       Human-curated from reflections
│
├── Harness Commands
│   ├── /harness-audit                  Full meta-verification
│   ├── /harness-health                 Snapshot with trends and meta-observability checks
│   ├── /harness-status                 Quick health read
│   └── /harness-gc                     Run GC checks on demand
│
└── Governance Commands
    ├── /governance-constrain           Guided governance constraint authoring
    ├── /governance-audit               Deep governance investigation
    └── /governance-health              Governance pulse check and dashboard
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

This plugin packages the practical workflow from the AI Literacy for Software Engineers framework. The design draws on three lineages — architecture, craft, and engineering practice — that converge on a single idea: the environment matters as much as the code.

### Architecture and Habitability

- **Christopher Alexander** — *A Pattern Language* (1977); *The Timeless Way of Building* (1979). The "quality without a name" — design for inhabitants, not spectators. Alexander's insight that environments shape the behaviour of their occupants is the conceptual root of habitat engineering.
- **Richard P. Gabriel** — *Patterns of Software* (1996). Habitability: code as a place to live in. Gabriel extended Alexander's architectural philosophy to software, arguing that code should be welcoming to the people who maintain it.

### Code as Literature

- **Donald Knuth** — "Literate Programming" (1984); *TeX: The Program* (1986). Code is written for humans to read, and only incidentally for machines to execute. The literate-programming skill applies Knuth's discipline: narrative preambles, reasoning-based documentation, presentation ordered by understanding.
- **Daniel Terhorst-North** — "CUPID — for joyful coding" (2022). Five properties that good code tends toward: Composable, Unix philosophy, Predictable, Idiomatic, Domain-based. The cupid-code-review skill uses these as a review and refactoring lens.

### Harness Engineering

- **Birgitta Boeckeler** — ["Harness Engineering"](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) (2026). *Exploring Gen AI*, martinfowler.com. The three components of a complete harness: context engineering, architectural constraints, and garbage collection. The theoretical foundation for the plugin's three enforcement loops.
- **Mitchell Hashimoto** — "AI Harness" (2025). Blog post referenced by Boeckeler as a possible origin of the harness terminology.
- **Chad Fowler** — "Relocating Rigor." Essay on how rigor moves from writing code to designing the systems that generate and verify code. Frames the shift from manual discipline to environmental enforcement.

### Convention Discovery

- **Rahul Garg** — ["Encoding Team Standards"](https://martinfowler.com/articles/reduce-friction-ai/encoding-team-standards.html) (2026). *Patterns for Reducing Friction in AI-Assisted Development*, martinfowler.com. Treats AI instructions as infrastructure, not individual craft. Structured extraction interviews surface tacit team knowledge. Informed the convention-extraction skill and `/extract-conventions` command.

### Agent Orchestration

- **Addy Osmani** — ["The Code Agent Orchestra"](https://addyosmani.com/blog/code-agent-orchestra/) (2026). addyosmani.com. Subagent delegation, quality gates, compound learning, and the orchestrator pattern. Informed the agent pipeline design, worktree isolation, and the review loop guardrail.

### Specification-Driven Development

- **Gojko Adzic** — *Specification by Example: How Successful Teams Deliver the Right Software*. Manning. Concrete examples as tests; specifications as the shared language between intent and implementation. Informed the spec-first workflow and the spec-writer agent.

### Verification and Quality

- **Dave Farley** — Controlled study of 150 participants comparing AI-generated and human-written code across creation and maintenance phases. Evidence for AI as an amplifier of existing discipline — the core argument for why harnesses matter.
- **2025 DORA Report** — DevOps Research and Assessment. Findings on AI as an amplifier of existing engineering discipline: teams with strong practices benefit; teams without them are harmed.

### Cognitive Science (Framework Foundation)

The plugin implements practical workflows, but the framework's design decisions are grounded in cognitive science research on how human and artificial intelligence differ:

- **Andy Clark** — *Surfing Uncertainty* (2015). Predictive processing and the embodied mind.
- **George Lakoff & Mark Johnson** — *Metaphors We Live By* (1980). Embodied cognition and conceptual metaphor.
- **Edwin Hutchins** — *Cognition in the Wild* (1995). Distributed cognition — intelligence as a property of systems, not individuals.
- **Lucy Suchman** — *Plans and Situated Actions* (1987). The gap between plans and situated human action.
- **James J. Gibson** — *The Ecological Approach to Visual Perception* (1979). Affordances — the environment offers possibilities for action.
- **John Boyd** — The OODA Loop. Observe-Orient-Decide-Act as a cognitive cycle — the basis for the harness's replanning-after-each-action pattern.
- **Donella Meadows** — *Thinking in Systems* (2008). Systems thinking, leverage points, and feedback loops — the conceptual model for the three enforcement loops.

The mission: building habitats where human and AI intelligence thrive together.

---

## See It in Action

For a complete worked example of this plugin applied to a real project, see the [ai-literacy-exemplar](https://github.com/russmiles/ai-literacy-exemplar) repository — a Go CLI tool built using the full agent pipeline, with authentic git history showing the framework workflow.

---

## License

[Apache License 2.0](LICENSE)
