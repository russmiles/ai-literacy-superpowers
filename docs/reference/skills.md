---
title: Skills
layout: default
parent: Reference
nav_order: 1
---

# Skills

The plugin ships 19 skills. Each skill is a focused unit of domain knowledge that Claude can invoke during a session. They are grouped below by category.

---

## Harness Core

### harness-engineering

The conceptual foundation of the harness framework. Covers what a harness is, why deterministic tooling surrounds AI generation, and how the enforcement loops relate to each other.

### context-engineering

Writing enforceable conventions for the Context section of HARNESS.md. Covers how to express rules that Claude will honour consistently rather than treat as advisory suggestions.

### constraint-design

Designing and promoting constraints. Covers the lifecycle of a constraint from informal team agreement through to a checked, versioned rule enforced in CI.

### verification-slots

Integrating deterministic tools into verification slots. Covers how to attach linters, scanners, and test runners to the pre-commit, pre-merge, and scheduled enforcement loops.

### garbage-collection

Entropy-fighting periodic checks. Covers how to define GC rules that detect drift, dead code, and stale configuration before they compound into larger problems.

### harness-observability

Harness health snapshots and observability. Covers how to read a health snapshot, interpret enforcement scores, and set up alerting when the harness degrades.

---

## Security

### secrets-detection

Gitleaks-based secret scanning. Covers configuration, baseline management, and integrating the scan into pre-commit and CI verification slots.

### dependency-vulnerability-audit

Go/Maven dependency CVE scanning. Covers running audits, triaging findings by severity, and deciding when to suppress versus remediate a vulnerability.

### docker-scout-audit

Docker image CVE scanning. Covers running Docker Scout against local and registry images, interpreting the report, and acting on critical findings.

### github-actions-supply-chain

CI pipeline security hardening. Covers pinning Actions to commit SHAs, reviewing third-party action permissions, and detecting supply-chain risks in workflow files.

---

## Code Quality

### cupid-code-review

CUPID properties for code review. Covers applying the CUPID principles (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based) when reviewing or refactoring a pull request.

### literate-programming

Code structured for humans to read first. Covers writing source files where narrative explanation and code are interleaved so that intent is always visible alongside implementation.

---

## Architecture

### fitness-functions

Periodic architectural health checks. Covers defining fitness functions that measure whether the system still satisfies its architectural properties, and running them on a schedule.

### convention-extraction

Surfacing tacit team knowledge. Covers guided sessions that turn unwritten team norms into explicit, versioned conventions that can be enforced by the harness.

### convention-sync

Syncing conventions to Cursor, Copilot, and Windsurf. Covers translating HARNESS.md conventions into the rule formats understood by each editor AI so enforcement is consistent across tools.

### cross-repo-orchestration

Coordinating changes across repos. Covers patterns for planning, sequencing, and verifying a change that touches more than one repository without breaking consumers.

### model-sovereignty

Model selection, hosting, and vendor independence. Covers the decision hierarchy (prompting → RAG → fine-tuning → distillation → local hosting), data classification for routing, cost break-even analysis, and maintenance awareness for custom models.

---

## Workflow

### ai-literacy-assessment

ALCI assessment instrument. Covers administering and interpreting the AI Literacy and Capability Index to measure a team's current AI fluency and track improvement over time.

### auto-enforcer-action

Automatic PR constraint checking via GitHub Actions. Covers installing and configuring the GitHub Action that runs harness constraint checks on every pull request without manual intervention.
