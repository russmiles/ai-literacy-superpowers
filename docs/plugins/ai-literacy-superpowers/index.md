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

- [Getting Started](getting-started.md)
- [First Time Tour](first-time-tour.md)
- [Harness From Scratch](harness-from-scratch.md)
- [Your First Skill](your-first-skill.md)
- [Your First Assessment](your-first-assessment.md)
- [Surfacing Tacit Knowledge](surfacing-tacit-knowledge.md)
- [Governance for Your Harness](governance-for-your-harness.md)
- [The Improvement Cycle](the-improvement-cycle.md)
- [From Assessment to Dashboard](from-assessment-to-dashboard.md)

### How-to guides — task-oriented

Practical guides for specific tasks.

#### Harness lifecycle

- [Add a Constraint](add-a-constraint.md)
- [Add Fitness Functions](add-fitness-functions.md)
- [Run a Harness Audit](run-a-harness-audit.md)
- [Run a Calibration Review](run-a-calibration-review.md)
- [Update the Plugin](update-the-plugin.md)
- [Upgrade Your Harness](upgrade-your-harness.md)
- [Understand Harness Engineering](understand-harness-engineering.md)

#### Assessment and portfolio

- [Run an Assessment](run-an-assessment.md)
- [Run Portfolio Assessment](run-portfolio-assessment.md)
- [Build Portfolio Dashboard](build-portfolio-dashboard.md)
- [Generate Improvement Plan](generate-improvement-plan.md)
- [Create Team API](create-team-api.md)

#### Governance

- [Write a Governance Constraint](write-a-governance-constraint.md)
- [Run a Governance Audit](run-a-governance-audit.md)
- [Check Governance Health](check-governance-health.md)
- [Build a Governance Dashboard](build-a-governance-dashboard.md)
- [Detect Semantic Drift](detect-semantic-drift.md)

#### Adversarial and decision-archaeology review

- [Review a Spec Adversarially](review-a-spec-adversarially.md)
- [Run Choice Cartograph](run-choice-cartograph.md)
- [Review Code with CUPID](review-code-with-cupid.md)

#### Setup and integration

- [Set Up Verification Slots](set-up-verification-slots.md)
- [Set Up Garbage Collection](set-up-garbage-collection.md)
- [Set Up Auto-Enforcer](set-up-auto-enforcer.md)
- [Set Up Context Engineering](set-up-context-engineering.md)
- [Set Up Secret Detection](set-up-secret-detection.md)
- [Set Up Model Routing](set-up-model-routing.md)
- [Configure Observability](configure-observability.md)
- [Verify Observatory Signals](verify-observatory-signals.md)
- [Sync Harness Surfaces](sync-harness.md)
- [Sync Conventions](sync-conventions.md)
- [Extract Conventions](extract-conventions.md)
- [Generate Onboarding](generate-onboarding.md)
- [Discover Affordances](discover-affordances.md)
- [Orchestrate Across Repos](orchestrate-across-repos.md)

#### Security and supply chain

- [Audit Dependencies](audit-dependencies.md)
- [Audit Docker Images](audit-docker-images.md)
- [Harden GitHub Actions](harden-github-actions.md)

#### Other

- [Track AI Costs](track-ai-costs.md)
- [Enforce Human Pace](enforce-human-pace.md)
- [Write Literate Code](write-literate-code.md)

### Reference — exact details

- [Commands](commands.md)
- [Agents](agents.md)
- [Skills](skills.md)
- [Hooks](hooks.md)
- [Templates](templates.md)
- [HARNESS.md format](harness-md-format.md)
- [Output validation](output-validation.md)
- [Governance summary format](governance-summary-format.md)

### Explanation — concepts

These pages introduce the core ideas behind the framework, building
from first principles to the complete system:

1. [The Environment Hypothesis](the-environment-hypothesis.md) — why AI output quality is an environment problem
2. [Context Engineering](context-engineering.md) — teaching your AI what your team already knows
3. [Constraints and Enforcement](constraints-and-enforcement.md) — from good intentions to automated enforcement
4. [Codebase Entropy](codebase-entropy.md) — why codebases rot and how to fight back
5. [Agent Orchestration](agent-orchestration.md) — specialised agents with trust boundaries
6. [Compound Learning](compound-learning.md) — how your AI gets smarter every session
7. [The Loops That Learn](the-loops-that-learn.md) — four operational loops that make AI environments compound

#### Deep dives

- [HARNESS.md, the Document](harness-md.md) — what `HARNESS.md` is, how it is operated, and how it compares to `AGENTS.md`, CI config, and hooks
- [The Self-Improving Harness](self-improving-harness.md) — the audit-and-amendment feedback loop that keeps the harness honest
- [Habitat Engineering](habitat-engineering.md) — the broader environment around the harness
- [Harness Engineering](harness-engineering.md) — what the harness is and isn't
- [Decision Archaeology](decision-archaeology.md) — the choice-cartographer's role; intent debt and cognitive debt
- [Adversarial Review](adversarial-review.md) — the advocatus-diaboli's role and the human-cognition gate
- [Progressive Hardening](progressive-hardening.md) — the promotion ladder from unverified to agent to deterministic
- [Determinacy Calibration](determinacy-calibration.md) — the bidirectional review practice that uses the ladder over time
- [The Three Enforcement Loops](three-enforcement-loops.md) — inner, middle, and outer loops operating at different timescales
- [Garbage Collection](garbage-collection.md) — fighting entropy with periodic checks and scheduled agents
- [Fitness Functions](fitness-functions.md) — testing architectural properties continuously
- [Regression Detection](regression-detection.md) — patterns that surface from the reflection log
- [The Harness Tuning Loop](the-harness-tuning-loop.md) — one surprise traced end to end through reflection, GC, HARNESS.md, AGENTS.md, hooks, and CI
- [The Harness Lifecycle](the-harness-lifecycle.md) — one harness traced through six stages over months and years; the temporal axis of harness operation
- [Governance as Meaning Alignment](governance-as-meaning-alignment.md) — the three-frame check
