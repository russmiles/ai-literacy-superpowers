---
title: Agents
layout: default
parent: Reference
nav_order: 2
---

# Agents

The plugin ships 10 agents organised into three groups: the
**spec-first pipeline** that coordinates feature work end to end,
the **harness agents** that verify and maintain infrastructure
conventions, and the **assessor** that measures AI literacy.

Every agent reads `CLAUDE.md` and `AGENTS.md` before acting.
Agents that modify files are read-write; agents that only inspect
are read-only. The trust boundary column in the summary table
makes this explicit.

---

## Pipeline Agents

These five agents form the spec-first development pipeline.
The orchestrator dispatches them in sequence: spec, test, implement,
review, integrate.

### orchestrator

- **Tools**: Read, Write, Edit, Glob, Grep, Bash, Agent, WebFetch
- **Dispatched by**: User (any task description) or slash commands
  that trigger the full pipeline
- **Trust boundary**: Read-write

Entry point for all changes. Receives a plain-English task
description and coordinates the specialist agents in the correct
sequence, passing context between them. Reads `CLAUDE.md`,
`AGENTS.md`, and `MODEL_ROUTING.md` before dispatching any work.
The only agent with the Agent tool, which it uses to dispatch
the other four pipeline agents and, when needed, harness agents.

### spec-writer

- **Tools**: Read, Write, Edit, Glob, Grep
- **Dispatched by**: orchestrator (first in pipeline)
- **Trust boundary**: Read-write

First specialist in every pipeline run. Updates `spec.md` and
`plan.md` to describe a change before any implementation code is
written. Produces user stories, acceptance scenarios in
Given/When/Then format, and numbered functional requirements that
the TDD agent will translate into tests.

### tdd-agent

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Dispatched by**: orchestrator (after spec-writer, after user
  approves plan)
- **Trust boundary**: Read-write

Handles the RED phase of test-driven development only. Translates
acceptance scenarios from the spec into failing tests, runs them,
and confirms each fails for the right reason (missing feature, not
a syntax error). Does not write implementation code. Reports
failing test names and failure messages back to the orchestrator.

### code-reviewer

- **Tools**: Read, Glob, Grep, Bash
- **Dispatched by**: orchestrator (after tests are green)
- **Trust boundary**: Read-only

Reviews implementation code through two lenses: CUPID (Composable,
Unix philosophy, Predictable, Idiomatic, Domain-based) and Literate
Programming. Returns either PASS or a prioritised list of findings.
Does not modify any files. Its output either unblocks integration
or drives another revision cycle.

### integration-agent

- **Tools**: Read, Write, Edit, Bash
- **Dispatched by**: orchestrator (after code review passes)
- **Trust boundary**: Read-write

Handles everything after the code is written and reviewed. Updates
`CHANGELOG.md`, commits all changes, opens a PR, watches CI until
checks pass, merges when green, closes the linked GitHub issue, and
prunes the local branch. Follows the workflow rules in `CLAUDE.md`
exactly.

---

## Harness Agents

These four agents maintain the living harness that enforces project
conventions. They are dispatched by harness commands and scheduled
runs, not by the pipeline orchestrator.

### harness-discoverer

- **Tools**: Read, Glob, Grep, Bash
- **Model**: inherit
- **Color**: cyan
- **Dispatched by**: `/harness-init`, `/harness-constrain`
- **Trust boundary**: Read-only

Read-only project scanner. Discovers the tech stack (languages,
frameworks, build systems), existing linters and formatters, CI/CD
configuration, test frameworks, and pre-commit hooks. Produces a
factual baseline of what exists in the project so that other agents
can generate or verify `HARNESS.md` against reality.

### harness-auditor

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: yellow
- **Dispatched by**: `/harness-audit`, `/harness-health --deep`
- **Trust boundary**: Read-write

Meta-agent that keeps `HARNESS.md` honest. Compares what the
harness declares (constraints, enforcement types, GC rules) against
what the project actually has. Detects drift in both directions:
rules declared but not enforced, and enforcement present but not
declared. Updates the Status section of `HARNESS.md` with audit
results.

### harness-enforcer

- **Tools**: Read, Glob, Grep, Bash
- **Model**: inherit
- **Color**: blue
- **Dispatched by**: CI constraint checks, `/harness-constrain` test
  runs
- **Trust boundary**: Read-only

Unified verification engine for harness constraints. Given a
constraint from `HARNESS.md`, either executes a deterministic tool
(linter, formatter, secret scanner) or performs an agent-based
review. Output format is identical in both cases, so CI can treat
all constraint results uniformly.

### harness-gc

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: green
- **Dispatched by**: `/harness-gc`, scheduled weekly runs
- **Trust boundary**: Read-write

Entropy fighter. Runs garbage collection rules declared in the
Garbage Collection section of `HARNESS.md`. Handles both
deterministic checks (documentation staleness, dead code, shell
script hygiene) and agent-scoped checks (convention drift,
dependency currency). Either fixes issues directly or creates
GitHub issues for them.

---

## Assessment

### assessor

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: yellow
- **Dispatched by**: `/assess`
- **Trust boundary**: Read-write

Runs an AI literacy assessment against the repository. Scans for
observable evidence of AI collaboration practices (harness files,
reflections, conventions, CI integration), asks clarifying
questions where evidence is ambiguous, and produces a timestamped
assessment document with a level determination. Updates the README
with a literacy level badge.

---

## Tool Summary

| Agent | Read | Write | Edit | Glob | Grep | Bash | Agent | WebFetch | Trust |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| orchestrator | x | x | x | x | x | x | x | x | read-write |
| spec-writer | x | x | x | x | x | | | | read-write |
| tdd-agent | x | x | x | x | x | x | | | read-write |
| code-reviewer | x | | | x | x | x | | | read-only |
| integration-agent | x | x | x | | | x | | | read-write |
| harness-discoverer | x | | | x | x | x | | | read-only |
| harness-auditor | x | x | x | x | x | x | | | read-write |
| harness-enforcer | x | | | x | x | x | | | read-only |
| harness-gc | x | x | x | x | x | x | | | read-write |
| assessor | x | x | x | x | x | x | | | read-write |

---

## Design Principles

**Least privilege.** Each agent receives only the tools it needs.
The code-reviewer and harness-enforcer are read-only by design
because their job is to observe and report, not to change. The
orchestrator is the only agent with the Agent tool because dispatch
authority should not be distributed.

**Specialist over generalist.** Each agent has a narrow, well-defined
responsibility. The spec-writer does not test. The tdd-agent does
not implement. The code-reviewer does not fix. This separation
makes failures easier to diagnose and prevents agents from
overstepping their mandate.

**Convention-driven.** Every agent reads `CLAUDE.md` and `AGENTS.md`
before acting. This ensures accumulated team knowledge and workflow
rules are honoured across sessions, not just in the session where
they were discovered.

**Reflection-aware.** Agents that make judgement calls (orchestrator,
harness-enforcer, harness-gc) read recent entries from
`REFLECTION_LOG.md` to avoid repeating past mistakes and to surface
areas of known degradation.
