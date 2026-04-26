---
diaboli: exempt-pre-existing
---

# Design: Governance Dimension Documentation

**Date:** 2026-04-13
**Status:** Approved

## Summary

Add governance documentation to the plugin's Jekyll docs site following the existing Diataxis structure: 1 explanation page, 1 tutorial, 5 how-to guides, and updates to 4 existing reference pages. Covers the conceptual foundation (governance as meaning-alignment), a complete walkthrough (audit-then-fix-then-monitor), practical task guides (one per governance workflow), and reference entries for all new components.

## Motivation

The plugin now has governance support (v0.12.0) — a governance-auditor agent, three skills, three commands, a stop hook, and extensions to three existing agents. None of this is documented on the docs site. Users discovering the governance features have no explanation of why governance language drifts, no tutorial for getting started, no task-oriented guides for specific workflows, and no reference entries for the new components.

## Scope

### In scope

1. **One explanation page** — `explanation/governance-as-meaning-alignment.md`
2. **One tutorial** — `tutorials/governance-for-your-harness.md`
3. **Five how-to guides** — write constraint, run audit, check health, detect drift, build dashboard
4. **Four reference page updates** — agents.md, commands.md, skills.md, hooks.md
5. **Navigation updates** — nav_order values for new pages

### Out of scope

- Changes to the governance plugin components themselves
- New reference pages (governance entries go in existing pages)
- Docs site infrastructure changes (Jekyll config, theme, etc.)
- Cross-repo sync (follows separately)

## Design

### 1. Explanation: Governance as Meaning-Alignment

**File:** `docs/explanation/governance-as-meaning-alignment.md`

**Frontmatter:**

```yaml
---
title: Governance as meaning-alignment
layout: default
parent: Explanation
nav_order: 16
---
```

**Content structure:**

1. **Opening** — governance failures are not technical failures, they are reference frame translation failures. One paragraph framing the problem.

2. **The core problem** — governance language ("ensure fairness", "maintain transparency", "require human oversight") carries different meanings in different reference frames. The regulator, the engineer, and the AI system each interpret the same words differently. When all three frames are satisfied syntactically while governance fails semantically — the approval happens, but the oversight is absent.

3. **Semantic drift** — the five-stage process: coinage → adoption without frame → implementation from different frame → audit from yet another frame → crisis. Brief description of each stage with the "meaningful human oversight" running example.

4. **Governance debt** — the fourth form of debt alongside technical, cognitive, and intent debt. The vicious cycle: governance debt → intent debt → cognitive debt → technical debt → governance debt. Unlike technical debt (visible in hours), governance debt manifests over years.

5. **The three-frame translation problem** — table showing the three interfaces (Human ↔ AI, Human ↔ Institution, AI ↔ Institution), failure modes, and detection methods. The most dangerous failures occur when all three frames are misaligned simultaneously.

6. **Falsifiable governance** — a governance constraint must answer three questions: what do you verify, what counts as evidence, what happens on failure. If it cannot answer all three, it is governance language pretending to be a constraint. Brief comparison of a vague constraint and its falsifiable rewrite.

7. **How the plugin helps** — brief overview connecting concepts to tools: `/governance-constrain` for authoring, `/governance-audit` for detection, `/governance-health` for monitoring. Links to tutorial and how-to guides.

**Tone:** Conceptual, building from first principles. Matches existing explanation pages like `harness-engineering.md`. No code blocks except the constraint comparison example.

### 2. Tutorial: Governance for Your Harness

**File:** `docs/tutorials/governance-for-your-harness.md`

**Frontmatter:**

```yaml
---
title: Governance for your harness
layout: default
parent: Tutorials
nav_order: 8
---
```

**Content structure:**

1. **Opening** — one sentence: take your harness from "governance language without operational meaning" to "falsifiable governance constraints with drift detection."

2. **Prerequisites** — a project with the plugin installed and a HARNESS.md. Link to `harness-from-scratch` tutorial if needed.

3. **Step 1: Spot governance language in your constraints** — guide the reader to look at their existing HARNESS.md constraints for governance terms (fairness, oversight, transparency, compliance, accountability). Show an example of a constraint that uses governance language without operationalising it.

4. **Step 2: Run your first governance audit** — run `/governance-audit`. Walk through what the governance-auditor agent produces: the falsifiability scores (falsifiable / partially operationalised / vague), the drift stages, the debt inventory. Show example output.

5. **Step 3: Write your first governance constraint** — run `/governance-constrain` and walk through the guided workflow step by step. Show the three-frame alignment check in action. Show the before (vague) and after (falsifiable) constraint side by side in HARNESS.md.

6. **Step 4: Check governance health** — run `/governance-health`. Explain each metric in the summary table: constraint count, falsifiability ratio, drift score, debt items, frame alignment, drift velocity. Explain the colour coding.

7. **Step 5: Generate the dashboard** — run `/governance-health --dashboard`. Describe what opens in the browser — the six dashboard sections and what they show.

8. **What you have now** — summary: governance constraints that encode operational meaning, an audit baseline, a health snapshot, and a dashboard for tracking trends.

9. **Next steps** — add `/governance-audit` to your quarterly cadence (alongside `/assess` and `/harness-audit`). Write governance constraints for your other governance requirements. Explore the how-to guides for specific tasks.

**Tone:** Step-by-step, welcoming, practical. Matches `your-first-assessment.md`.

### 3. How-To Guides (5 pages)

All how-to guides follow the template in `how-to/_template.md`: title, one-line description, prerequisites, numbered steps (H2 headings), "What you have now", "Next steps".

#### 3.1 Write a Governance Constraint

**File:** `docs/how-to/write-a-governance-constraint.md`

**Frontmatter:**

```yaml
---
title: Write a governance constraint
layout: default
parent: How-To Guides
nav_order: 29
---
```

**Content:**

1. One-liner: translate a governance requirement into a falsifiable HARNESS.md constraint with three-frame alignment.
2. Prerequisites: HARNESS.md exists, plugin installed.
3. Steps: run `/governance-constrain`, walk through each prompt (governance requirement → operational meaning → verification → evidence/failure → three-frame check → write to HARNESS.md → promotion path).
4. Show one complete example: "human review of AI-generated code" → the full governance constraint template with all fields filled.
5. What you have now: a governance constraint in HARNESS.md that encodes operational meaning, with three-frame alignment confirmed.
6. Next steps: run `/governance-audit` to assess it, link to detect-semantic-drift guide.

#### 3.2 Run a Governance Audit

**File:** `docs/how-to/run-a-governance-audit.md`

**Frontmatter:**

```yaml
---
title: Run a governance audit
layout: default
parent: How-To Guides
nav_order: 30
---
```

**Content:**

1. One-liner: investigate governance health — falsifiability, semantic drift, governance debt, and three-frame alignment.
2. Prerequisites: HARNESS.md with at least one governance constraint.
3. Steps: run `/governance-audit`, describe what the governance-auditor agent does (7-step process), how to read the report (constraint assessment table, debt inventory, debt cycle analysis, prioritised recommendations), where the report is saved.
4. Show example report sections with annotations explaining each part.
5. What you have now: a governance audit report in `observability/governance/` and updated health snapshot.
6. Next steps: fix vague constraints with `/governance-constrain`, check trends with `/governance-health`, add to quarterly cadence.

#### 3.3 Check Governance Health

**File:** `docs/how-to/check-governance-health.md`

**Frontmatter:**

```yaml
---
title: Check governance health
layout: default
parent: How-To Guides
nav_order: 31
---
```

**Content:**

1. One-liner: quick governance pulse check between quarterly audits.
2. Prerequisites: at least one previous `/governance-audit` run (for meaningful data).
3. Steps: run `/governance-health`, read the summary table (each metric explained), understand the colour coding (green/amber/red thresholds), interpret the recommendations.
4. Show example summary output with annotations.
5. What you have now: a current view of governance health without running a full audit.
6. Next steps: if stale or unhealthy, run `/governance-audit`. Link to dashboard guide.

#### 3.4 Detect Semantic Drift in Your Constraints

**File:** `docs/how-to/detect-semantic-drift.md`

**Frontmatter:**

```yaml
---
title: Detect semantic drift in your constraints
layout: default
parent: How-To Guides
nav_order: 32
---
```

**Content:**

1. One-liner: find governance constraints whose meaning has diverged from the reality they govern.
2. Prerequisites: governance constraints in HARNESS.md.
3. Steps:
   - Recognise drift signals: implementation files changed substantially, team workflow changed, regulatory environment updated, team uses governance terms differently
   - Run `/governance-audit` to confirm — read the drift stage (1-5) and drift risk (low/medium/high) for each constraint
   - For constraints at Stage 3+, run `/governance-constrain` to rewrite with updated operational meaning
   - After fixing, run `/governance-health` to check drift velocity trend
4. Table: the five drift stages with detection heuristics (brief version).
5. What you have now: a method for detecting and fixing governance drift before it reaches crisis.
6. Next steps: set up quarterly cadence, link to governance audit guide.

#### 3.5 Build a Governance Dashboard

**File:** `docs/how-to/build-a-governance-dashboard.md`

**Frontmatter:**

```yaml
---
title: Build a governance dashboard
layout: default
parent: How-To Guides
nav_order: 33
---
```

**Content:**

1. One-liner: generate an HTML dashboard visualising governance health, constraint quality, debt trends, and frame alignment.
2. Prerequisites: at least one `/governance-audit` run.
3. Steps: run `/governance-health --dashboard`, describe the generated HTML file location, walk through each dashboard section (health summary cards, constraint quality table, debt inventory, drift timeline, three-frame heatmap, trend comparison).
4. Explain how to read each visualisation — what the colours mean, what trends to watch for, when to act.
5. Portfolio integration: mention that governance data feeds into the portfolio dashboard when using `/portfolio-assess`.
6. What you have now: a self-contained HTML governance dashboard.
7. Next steps: share with your team, regenerate after each quarterly audit, link to portfolio dashboard guide.

### 4. Reference Page Updates

#### 4.1 `reference/agents.md`

Add governance-auditor entry matching existing format:

- **Name:** governance-auditor
- **Role:** Governance specialist — semantic drift analysis, governance debt inventory, constraint falsifiability scoring, three-frame alignment checks
- **Trust boundary:** Read + limited Write (audit reports and snapshot updates only)
- **Tools:** Read, Write, Edit, Glob, Grep, Bash
- **Dispatched by:** `/governance-audit`, `/governance-health`, orchestrator (for governance-related tasks)
- **Model tier:** Best available (governance analysis requires nuanced judgement)

#### 4.2 `reference/commands.md`

Add three entries matching existing format:

- **/governance-constrain** — guided governance constraint authoring with three-frame alignment check. Reads `governance-constraint-design` skill. Writes to HARNESS.md.
- **/governance-audit** — deep governance investigation. Dispatches governance-auditor agent. Writes report to `observability/governance/`. Quarterly cadence.
- **/governance-health** — governance health pulse check. Reads most recent audit report. Pass `--dashboard` to generate HTML dashboard.

#### 4.3 `reference/skills.md`

Add three entries matching existing format:

- **governance-constraint-design** — falsifiable governance constraint authoring. Three-frame translation, anti-patterns gallery, governance constraint template. Referenced by `/governance-constrain` and harness-enforcer.
- **governance-audit-practice** — governance audit methodology. Five-stage semantic drift model, debt scoring matrix, frame alignment review. Referenced by governance-auditor agent.
- **governance-observability** — governance metrics, snapshot format extension, dashboard specification. Referenced by governance-auditor and `/governance-health`.

#### 4.4 `reference/hooks.md`

Add governance drift check entry matching existing format:

- **Name:** governance-drift-check
- **Event:** Stop
- **Type:** command (shell script)
- **What it detects:** governance-related file changes during session, governance audit staleness (>90 days), governance constraints without any audit
- **What it nudges:** `/governance-audit` or `/governance-health`
- **Advisory:** yes (never blocks)

### 5. Navigation

New pages use `nav_order` values that place them logically within their sections:

- Explanation: nav_order 16 (after existing explanation pages)
- Tutorial: nav_order 8 (after existing tutorials)
- How-to guides: nav_order 29-33 (after existing how-to guides)

## Component Summary

| Type | File | Status |
| ------ | ------ | -------- |
| Explanation | `explanation/governance-as-meaning-alignment.md` | New |
| Tutorial | `tutorials/governance-for-your-harness.md` | New |
| How-To | `how-to/write-a-governance-constraint.md` | New |
| How-To | `how-to/run-a-governance-audit.md` | New |
| How-To | `how-to/check-governance-health.md` | New |
| How-To | `how-to/detect-semantic-drift.md` | New |
| How-To | `how-to/build-a-governance-dashboard.md` | New |
| Reference | `reference/agents.md` | Updated |
| Reference | `reference/commands.md` | Updated |
| Reference | `reference/skills.md` | Updated |
| Reference | `reference/hooks.md` | Updated |
