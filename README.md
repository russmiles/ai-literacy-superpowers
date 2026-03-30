# ai-literacy-superpowers

A [Claude Code](https://claude.ai/claude-code) plugin that gives you the AI Literacy framework's complete development workflow — harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops.

Install the plugin, run `/superpowers-init`, and get a fully operational habitat for AI-assisted development.

---

## What You Get

### Skills (10)

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

### Agents (9)

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

### Commands (9)

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

### Templates (8)

Opinionated defaults scaffolded by `/superpowers-init`:

- **CLAUDE.md** — framework-aligned conventions (literate programming, CUPID, spec-first, TDD)
- **HARNESS.md** — living harness with starter constraints and enforcement timing
- **AGENTS.md** — compound learning memory (human-curated, agent-proposed)
- **MODEL_ROUTING.md** — model-tier guidance and token budget thresholds
- **REFLECTION_LOG.md** — append-only agent reflection log
- **ci-github-actions.yml** — CI enforcement template for GitHub Actions
- **ci-mutation-testing.yml** — weekly mutation testing template
- **ci-generic.sh** — fallback CI script for non-GitHub systems

### Hooks (2)

- **PreToolUse constraint gate** — reads HARNESS.md, warns on violations during edits (advisory, does not block)
- **Stop drift check** — detects when CI, linter, or dependency configs change, nudges `/harness-audit`

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

## The Three Enforcement Loops

Every mechanism in the plugin operates at one of three timescales:

| Loop | Trigger | Strictness | Purpose |
| ---- | ------- | ---------- | ------- |
| Advisory | PreToolUse hook | Warn | Catch issues while context is fresh |
| Strict | CI on PR | Fail | Prevent violations from reaching main |
| Investigative | Scheduled GC + audit | Report | Fight slow entropy that gates miss |

---

## The Agent Pipeline

When you use the orchestrator agent, it runs this pipeline:

```text
orchestrator
  → spec-writer
  → GATE: plan approval (user reviews before proceeding)
  → tdd-agent
  → implementer(s) (parallel, one per language)
  → code-reviewer
  → GUARDRAIL: MAX_REVIEW_CYCLES=3 (escalate after 3 loops)
  → integration-agent (includes reflection step)
```

The plan approval gate catches bad plans before they become bad code. The loop guardrail prevents unbounded reviewer cycles. Both keep the orchestration from running away.

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

MIT
