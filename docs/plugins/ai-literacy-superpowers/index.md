---
title: ai-literacy-superpowers
layout: default
parent: Plugins
nav_order: 2
has_children: true
redirect_from:
  - /tutorials/
  - /how-to/
  - /reference/
  - /explanation/
---

# ai-literacy-superpowers

The flagship plugin in this marketplace — harness engineering, agent
orchestration, literate programming, CUPID code review, compound
learning, and the three enforcement loops.

The plugin's source lives at [`ai-literacy-superpowers/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/ai-literacy-superpowers)
in the repository.

---

## Install

```bash
# Claude Code
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers

# GitHub Copilot CLI
copilot plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers
```

Then in any project:

```bash
/harness-init    # Set up a living harness
/harness-status  # Check enforcement health
```

`/harness-init` lets you select which features to configure — context
engineering, constraints, garbage collection, CI, and observability.
All are selected by default. Re-run at any time to add more; existing
configuration is preserved.

---

## Documentation

This documentation follows the
[Diataxis framework](https://diataxis.fr/). Use the section that
matches the kind of reading you're doing right now.

### Tutorials — learning-oriented

Start here if you're new to the plugin.

- [Getting Started]({% link plugins/ai-literacy-superpowers/getting-started.md %})
- [First Time Tour]({% link plugins/ai-literacy-superpowers/first-time-tour.md %})
- [Harness From Scratch]({% link plugins/ai-literacy-superpowers/harness-from-scratch.md %})
- [Your First Skill]({% link plugins/ai-literacy-superpowers/your-first-skill.md %})
- [Your First Assessment]({% link plugins/ai-literacy-superpowers/your-first-assessment.md %})
- [Surfacing Tacit Knowledge]({% link plugins/ai-literacy-superpowers/surfacing-tacit-knowledge.md %})
- [Governance for Your Harness]({% link plugins/ai-literacy-superpowers/governance-for-your-harness.md %})
- [The Improvement Cycle]({% link plugins/ai-literacy-superpowers/the-improvement-cycle.md %})
- [From Assessment to Dashboard]({% link plugins/ai-literacy-superpowers/from-assessment-to-dashboard.md %})

### How-to guides — task-oriented

Practical guides for specific tasks.

#### Harness lifecycle

- [Add a Constraint]({% link plugins/ai-literacy-superpowers/add-a-constraint.md %})
- [Add Fitness Functions]({% link plugins/ai-literacy-superpowers/add-fitness-functions.md %})
- [Run a Harness Audit]({% link plugins/ai-literacy-superpowers/run-a-harness-audit.md %})
- [Run a Calibration Review]({% link plugins/ai-literacy-superpowers/run-a-calibration-review.md %})
- [Update the Plugin]({% link plugins/ai-literacy-superpowers/update-the-plugin.md %})
- [Upgrade Your Harness]({% link plugins/ai-literacy-superpowers/upgrade-your-harness.md %})
- [Understand Harness Engineering]({% link plugins/ai-literacy-superpowers/understand-harness-engineering.md %})

#### Assessment and portfolio

- [Run an Assessment]({% link plugins/ai-literacy-superpowers/run-an-assessment.md %})
- [Run Portfolio Assessment]({% link plugins/ai-literacy-superpowers/run-portfolio-assessment.md %})
- [Build Portfolio Dashboard]({% link plugins/ai-literacy-superpowers/build-portfolio-dashboard.md %})
- [Generate Improvement Plan]({% link plugins/ai-literacy-superpowers/generate-improvement-plan.md %})
- [Create Team API]({% link plugins/ai-literacy-superpowers/create-team-api.md %})

#### Governance

- [Write a Governance Constraint]({% link plugins/ai-literacy-superpowers/write-a-governance-constraint.md %})
- [Run a Governance Audit]({% link plugins/ai-literacy-superpowers/run-a-governance-audit.md %})
- [Check Governance Health]({% link plugins/ai-literacy-superpowers/check-governance-health.md %})
- [Build a Governance Dashboard]({% link plugins/ai-literacy-superpowers/build-a-governance-dashboard.md %})
- [Detect Semantic Drift]({% link plugins/ai-literacy-superpowers/detect-semantic-drift.md %})

#### Adversarial and decision-archaeology review

- [Review a Spec Adversarially]({% link plugins/ai-literacy-superpowers/review-a-spec-adversarially.md %})
- [Run Choice Cartograph]({% link plugins/ai-literacy-superpowers/run-choice-cartograph.md %})
- [Review Code with CUPID]({% link plugins/ai-literacy-superpowers/review-code-with-cupid.md %})

#### Setup and integration

- [Set Up Verification Slots]({% link plugins/ai-literacy-superpowers/set-up-verification-slots.md %})
- [Set Up Garbage Collection]({% link plugins/ai-literacy-superpowers/set-up-garbage-collection.md %})
- [Set Up Auto-Enforcer]({% link plugins/ai-literacy-superpowers/set-up-auto-enforcer.md %})
- [Set Up Context Engineering]({% link plugins/ai-literacy-superpowers/set-up-context-engineering.md %})
- [Set Up Secret Detection]({% link plugins/ai-literacy-superpowers/set-up-secret-detection.md %})
- [Set Up Model Routing]({% link plugins/ai-literacy-superpowers/set-up-model-routing.md %})
- [Configure Observability]({% link plugins/ai-literacy-superpowers/configure-observability.md %})
- [Verify Observatory Signals]({% link plugins/ai-literacy-superpowers/verify-observatory-signals.md %})
- [Sync Conventions]({% link plugins/ai-literacy-superpowers/sync-conventions.md %})
- [Extract Conventions]({% link plugins/ai-literacy-superpowers/extract-conventions.md %})
- [Generate Onboarding]({% link plugins/ai-literacy-superpowers/generate-onboarding.md %})
- [Discover Affordances]({% link plugins/ai-literacy-superpowers/discover-affordances.md %})
- [Orchestrate Across Repos]({% link plugins/ai-literacy-superpowers/orchestrate-across-repos.md %})

#### Security and supply chain

- [Audit Dependencies]({% link plugins/ai-literacy-superpowers/audit-dependencies.md %})
- [Audit Docker Images]({% link plugins/ai-literacy-superpowers/audit-docker-images.md %})
- [Harden GitHub Actions]({% link plugins/ai-literacy-superpowers/harden-github-actions.md %})

#### Other

- [Track AI Costs]({% link plugins/ai-literacy-superpowers/track-ai-costs.md %})
- [Enforce Human Pace]({% link plugins/ai-literacy-superpowers/enforce-human-pace.md %})
- [Write Literate Code]({% link plugins/ai-literacy-superpowers/write-literate-code.md %})

### Reference — exact details

- [Commands]({% link plugins/ai-literacy-superpowers/commands.md %})
- [Agents]({% link plugins/ai-literacy-superpowers/agents.md %})
- [Skills]({% link plugins/ai-literacy-superpowers/skills.md %})
- [Hooks]({% link plugins/ai-literacy-superpowers/hooks.md %})
- [Templates]({% link plugins/ai-literacy-superpowers/templates.md %})
- [HARNESS.md format]({% link plugins/ai-literacy-superpowers/harness-md-format.md %})
- [Output validation]({% link plugins/ai-literacy-superpowers/output-validation.md %})
- [Governance summary format]({% link plugins/ai-literacy-superpowers/governance-summary-format.md %})

### Explanation — concepts

These pages introduce the core ideas behind the framework, building
from first principles to the complete system:

1. [The Environment Hypothesis]({% link plugins/ai-literacy-superpowers/the-environment-hypothesis.md %}) — why AI output quality is an environment problem
2. [Context Engineering]({% link plugins/ai-literacy-superpowers/context-engineering.md %}) — teaching your AI what your team already knows
3. [Constraints and Enforcement]({% link plugins/ai-literacy-superpowers/constraints-and-enforcement.md %}) — from good intentions to automated enforcement
4. [Codebase Entropy]({% link plugins/ai-literacy-superpowers/codebase-entropy.md %}) — why codebases rot and how to fight back
5. [Agent Orchestration]({% link plugins/ai-literacy-superpowers/agent-orchestration.md %}) — specialised agents with trust boundaries
6. [Compound Learning]({% link plugins/ai-literacy-superpowers/compound-learning.md %}) — how your AI gets smarter every session
7. [The Loops That Learn]({% link plugins/ai-literacy-superpowers/the-loops-that-learn.md %}) — four operational loops that make AI environments compound

#### Deep dives

- [HARNESS.md, the Document]({% link plugins/ai-literacy-superpowers/harness-md.md %}) — what `HARNESS.md` is, how it is operated, and how it compares to `AGENTS.md`, CI config, and hooks
- [The Self-Improving Harness]({% link plugins/ai-literacy-superpowers/self-improving-harness.md %}) — the audit-and-amendment feedback loop that keeps the harness honest
- [Habitat Engineering]({% link plugins/ai-literacy-superpowers/habitat-engineering.md %}) — the broader environment around the harness
- [Harness Engineering]({% link plugins/ai-literacy-superpowers/harness-engineering.md %}) — what the harness is and isn't
- [Decision Archaeology]({% link plugins/ai-literacy-superpowers/decision-archaeology.md %}) — the choice-cartographer's role; intent debt and cognitive debt
- [Adversarial Review]({% link plugins/ai-literacy-superpowers/adversarial-review.md %}) — the advocatus-diaboli's role and the human-cognition gate
- [Progressive Hardening]({% link plugins/ai-literacy-superpowers/progressive-hardening.md %}) — the promotion ladder from unverified to agent to deterministic
- [Determinacy Calibration]({% link plugins/ai-literacy-superpowers/determinacy-calibration.md %}) — the bidirectional review practice that uses the ladder over time
- [The Three Enforcement Loops]({% link plugins/ai-literacy-superpowers/three-enforcement-loops.md %}) — inner, middle, and outer loops operating at different timescales
- [Garbage Collection]({% link plugins/ai-literacy-superpowers/garbage-collection.md %}) — fighting entropy with periodic checks and scheduled agents
- [Fitness Functions]({% link plugins/ai-literacy-superpowers/fitness-functions.md %}) — testing architectural properties continuously
- [Regression Detection]({% link plugins/ai-literacy-superpowers/regression-detection.md %}) — patterns that surface from the reflection log
- [Governance as Meaning Alignment]({% link plugins/ai-literacy-superpowers/governance-as-meaning-alignment.md %}) — the three-frame check
