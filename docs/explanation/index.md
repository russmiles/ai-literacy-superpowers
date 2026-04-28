---
title: Explanation
layout: default
nav_order: 5
has_children: true
---

# Explanation

Conceptual discussions that explain why things work the way they do.

## Start here

These pages introduce the core ideas behind the framework, building from first principles to the complete system:

1. [The Environment Hypothesis]({% link explanation/the-environment-hypothesis.md %}) -- why AI output quality is an environment problem
2. [Context Engineering]({% link explanation/context-engineering.md %}) -- teaching your AI what your team already knows
3. [Constraints and Enforcement]({% link explanation/constraints-and-enforcement.md %}) -- from good intentions to automated enforcement
4. [Codebase Entropy]({% link explanation/codebase-entropy.md %}) -- why codebases rot and how to fight back
5. [Agent Orchestration]({% link explanation/agent-orchestration.md %}) -- specialised agents with trust boundaries
6. [Compound Learning]({% link explanation/compound-learning.md %}) -- how your AI gets smarter every session

7. [The Loops That Learn]({% link explanation/the-loops-that-learn.md %}) -- four operational loops that make AI environments compound

## Deep dives

These pages go deeper into the mechanics of each component:

- [HARNESS.md, the Document]({% link explanation/harness-md.md %}) -- what `HARNESS.md` is, how it is operated, and how it compares to `AGENTS.md`, CI config, and hooks
- [The Self-Improving Harness]({% link explanation/self-improving-harness.md %}) -- the audit-and-amendment feedback loop that keeps the harness honest
- [Decision Archaeology]({% link explanation/decision-archaeology.md %}) -- the choice-cartographer's role; intent debt and cognitive debt; the soft gate / hard gate asymmetry
- [Adversarial Review]({% link explanation/adversarial-review.md %}) -- the advocatus-diaboli's role and the human-cognition gate
- [Progressive Hardening]({% link explanation/progressive-hardening.md %}) -- the promotion ladder from unverified to agent to deterministic
- [The Three Enforcement Loops]({% link explanation/three-enforcement-loops.md %}) -- inner, middle, and outer loops operating at different timescales
- [Garbage Collection]({% link explanation/garbage-collection.md %}) -- fighting entropy with periodic checks and scheduled agents
- [Constraints and Enforcement]({% link explanation/constraints-and-enforcement.md %}) -- how constraints land in the harness and migrate from unverified to deterministic
