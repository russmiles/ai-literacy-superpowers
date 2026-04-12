# Changelog

## 0.11.0 — 2026-04-12

### Spec-First Discipline Gate

- Add spec-first commit ordering CI workflow — deterministic gate that
  verifies the first commit on feature branches contains only a spec
  file, with exemptions for bug-fix and maintenance PRs
- Add "Spec-first commit ordering" constraint to HARNESS.md —
  deterministic enforcement via the new CI workflow
- Add "Spec captures intent" constraint to HARNESS.md — agent review
  checking that specs describe problem, approach, and expected outcome
- Extend harness-enforcer agent with spec intent review guidance

## 0.10.0 — 2026-04-11

### Independent Marketplace Listing Versioning

- Add `plugin_version` field to `marketplace.json` — the listing now
  explicitly declares which plugin release it approves
- Add marketplace versioning convention to CLAUDE.md — agents know
  when to bump listing version vs update plugin pointer
- Add marketplace plugin version sync constraint to HARNESS.md —
  CI blocks PRs where `plugin_version` diverges from `plugin.json`
- Add marketplace listing drift GC rule to HARNESS.md — weekly
  check that listing metadata hasn't drifted from plugin metadata
- Extend `version-check.yml` to enforce marketplace sync on every PR
- Add updating guide to README and docs for plugin and marketplace

## 0.9.4 — 2026-04-11

### Documentation Completion

- Complete commands reference page — all 15 commands with skills,
  agents, flags, and modes documented
- Complete agents reference page — all 10 agents with tools, dispatch
  sources, trust boundaries, and design principles
- Complete templates reference page — all 10 templates with purpose,
  key sections, and generation commands
- Add The Loops That Learn explanation page and wire into docs nav
- Add Human Pace how-to guide covering constraint, GC rule, and
  assessment signals
- Fix stale component counts in GitHub Pages design spec (18→24
  skills, 13→15 commands)

## 0.9.3 — 2026-04-11

### Human Pace Template and Assessment Signals

- Add spec-scoped changes constraint to template HARNESS.md — new
  projects get one-concern-per-PR enforcement by default
- Add change cadence drift GC rule to template HARNESS.md — weekly
  monitoring of PR size distribution and cycle time
- Add Human Pace observable evidence signals to assessment skill at
  L2 (TDD-paced diffs), L3 (spec-scoped constraint, cadence drift GC),
  L4 (spec-to-PR mapping), and L5 (cadence metrics as health signal)

## 0.9.2 — 2026-04-10

### Bug Fix

- Fix curation-nudge Stop hook arithmetic error — `grep -c` outputs 0
  to stdout before exiting non-zero under `set -e`, causing the
  `|| echo "0"` fallback to produce `"0\n0"` which breaks arithmetic.
  Fixed both `reflection_count` (line 27) and `promoted_count` (line 42)
  to use `|| var=0` pattern instead.

## 0.9.1 — 2026-04-10

### Article 08: The Loops That Learn

- Add Article 08 — how four recurring practices (/reflect,
  /harness-health, /assess, /cost-capture) create interlocking
  feedback loops at four timescales, connect to the six literacy
  levels, and aggregate into the portfolio view

## 0.9.0 — 2026-04-10

### Cost Tracking

- Add cost-tracking skill — guides quarterly AI cost data capture from
  provider dashboards, records structured cost snapshots, compares
  trends, and updates MODEL_ROUTING.md with observed patterns
- Add /cost-capture command — interactive cost capture with provider
  dashboard guidance, comparison to previous snapshot, budget check
- Expand snapshot format Cost Indicators section with actual fields:
  last capture date, monthly average, budget status, cost trend
- Update /harness-health to read from observability/costs/ directory
- Add "Track AI Costs" how-to guide
- Closes the cost visibility gap identified in the L5 assessment

## 0.8.3 — 2026-04-10

### Reflection-Driven Improvements

- Add how-to template file (`docs/how-to/_template.md`) — explicit
  structure for subagents writing how-to guides, removing style
  inference from examples
- Add CI version consistency check (`version-check.yml`) — verifies
  plugin.json, README badge, and CHANGELOG heading all match, and
  that skill/agent/command changes trigger a version bump
- Add version consistency constraint to HARNESS.md (7/7 enforced)

## 0.8.2 — 2026-04-09

### Complete Tutorial Set

- Fill 2 tutorial stubs: Harness for an Existing Codebase, Creating
  Your First Skill
- Add 3 new tutorials: Your First Assessment, From Assessment to
  Dashboard, The Improvement Cycle
- Total: 6 tutorials covering the full journey from setup through
  measurement, scaling, and improvement

## 0.8.1 — 2026-04-09

### Complete How-To Guides

- Fill 5 stub how-to guides: add a constraint, add fitness functions,
  run a harness audit, set up auto-enforcer, sync conventions
- Add 16 new how-to guides covering all remaining skills: run an
  assessment, extract conventions, set up context engineering, review
  code with CUPID, audit dependencies, audit Docker images, harden
  GitHub Actions, set up garbage collection, write literate code,
  set up verification slots, set up model routing, run portfolio
  assessment, generate improvement plan, orchestrate across repos,
  create team API, understand harness engineering
- Total: 23 how-to guides (was 7, of which 5 were stubs)

## 0.8.0 — 2026-04-09

### Team API Skill

- Add team-api skill — create or update Team Topologies Team API
  documents with AI literacy portfolio assessment data
- Template mode generates a full Team API with AI Literacy section,
  communication preferences, services, dependencies, and ways of
  working
- Update mode adds or refreshes the AI Literacy section in an existing
  Team API document, preserving all other sections
- Includes Team API template in references/team-api-template.md

## 0.7.1 — 2026-04-09

### Agent Harness Enabled Topic Tag

- Add automatic `agent-harness-enabled` GitHub topic tagging to
  /harness-init (after commit) and /assess (at L3+)
- Add Agent Harness Enabled badge (black) to README
- Tag signals to portfolio assessments that a repo has a harness

## 0.7.0 — 2026-04-09

### Portfolio Dashboard Skill

- Add portfolio-dashboard skill — generates a self-contained HTML
  dashboard from portfolio assessment data with level distribution,
  repo table, shared gaps, improvement plan, and trend visualisation
  from multiple quarterly assessments
- Dashboard is single HTML file with inline CSS, no external
  dependencies, works offline, shareable via email or Slack

## 0.6.1 — 2026-04-09

### Documentation

- Add "Build an AI Literacy Portfolio Dashboard" how-to guide —
  step-by-step guide to generating a self-contained HTML dashboard
  from portfolio assessment data with trend visualisation from
  multiple quarterly assessments

## 0.6.0 — 2026-04-09

### Portfolio Assessment

- Add portfolio-assessment skill — aggregates AI literacy assessments
  across multiple repos into an organisational portfolio view with
  level distribution, shared gaps, outliers, and improvement plans
- Three discovery modes: local directories, GitHub org, GitHub topic
  tags — combinable for flexible portfolio scoping
- Lightweight evidence-only scan for repos without prior assessments —
  estimates level from observable signals via GitHub API without
  running a full assessment
- Portfolio improvement plan groups actions by impact scope:
  organisation-wide (50%+ repos), cluster (2-4 repos), individual
- Add /portfolio-assess command with --local, --org, --topic, and
  --no-scan-unassessed flags

## 0.5.0 — 2026-04-09

### Literacy Improvements Skill

- Add literacy-improvements skill — generates prioritised improvement
  plans from assessment gaps, mapping each gap to the specific plugin
  command or skill that closes it
- Includes improvement-mapping reference with level-to-action tables
  for L1→L2, L2→L3, L3→L4, and L4→L5 transitions
- Users choose a target level (next level or higher) and walk through
  improvements interactively with accept/skip/defer
- Integrates with /assess as Phase 5b — invoked automatically after
  workflow recommendations
- Also usable standalone when the user knows their current level

## 0.4.1 — 2026-04-09

### Companion Article

- Add Article 07 (The Assessment Practice) — companion to The
  Environment Hypothesis series covering assessment as a recurring
  quarterly discipline, the six literacy levels as diagnostic positions,
  evidence-based scoring, and how assessment feeds the learning loop

## 0.4.0 — 2026-04-08

### Article Updates

- Update Article 06 (The Learning Loop) with signal classification
  taxonomy and Feedback Flywheel citation — reflections now classify
  their signal type to route learnings during curation

### Model Sovereignty Skill

- Add model-sovereignty skill to the plugin — decision framework for
  model selection, hosting, fine-tuning, and vendor independence with
  three reference files (decision framework, hosting options, technique
  comparison)

### README Component Counts

- Update skills badge and section from 14 to 18 — add secrets-detection,
  auto-enforcer-action, convention-sync, and fitness-functions to the
  skills table
- Update commands badge and section from 12 to 13 — add /convention-sync
  to the commands table

### Feedback Flywheel Integration

- Add signal classification to reflections — each reflection now
  captures a signal type (context, instruction, workflow, failure, none)
  that routes the learning to the right harness component during curation,
  adopting the taxonomy from Birgitta Boeckeler's Feedback Flywheel article
- Add vocabulary mapping section to compound learning docs — maps plugin
  concepts to the Feedback Flywheel article's terminology with direct
  citation and links
- Add Feedback Flywheel article to further reading in compound learning
  and self-improving harness explanation pages
- Add Session Quality section to health snapshot format — tracks signal
  classification metrics (reflections with signal percentage, distribution
  by type, quality trend) derived from the new Signal field
- Update /harness-health command to gather and display Session Quality
  metrics in snapshots and delta summaries

### Organisation Transfer

- Update all references from russmiles to Habitat-Thinking after
  GitHub repo transfer — README badges, docs site config, install
  commands, and getting-started tutorial

### Documentation Fixes

- Fix docs homepage Quick Install section to use the correct two-step
  marketplace install commands matching the getting-started tutorial

### Three-Loop Improvements

- Add markdownlint to CI workflow — closes gap between declared and
  enforced constraints, bringing inner loop enforcement to 100%
- Create AGENTS.md with initial curated entries from REFLECTION_LOG —
  unblocks the compound learning promotion lifecycle
- Add weekly GC GitHub Action running deterministic GC rules (secret
  scanner operational, snapshot staleness, shell syntax, strict mode)
- Add rotating GC Stop hook that checks one rule per session by
  day-of-year rotation — catches entropy between weekly CI runs
- Add curation nudge Stop hook that detects unpromoted reflections
  and nudges curation into AGENTS.md
- Add markdownlint PreToolUse command hook for deterministic .md file
  checking alongside the existing prompt-based constraint evaluation
- Update HARNESS.md status: 6/6 constraints enforced, 2/5 GC active
- Generate health snapshot with trend comparison

### Documentation Alignment

- Update README badges (6/6 enforced, snapshot link to 2026-04-08),
  hook count (5→8), hook list, and mechanism map to reflect new hooks
  and GC execution mechanisms
- Update three-enforcement-loops explanation page: inner loop now
  describes 2 PreToolUse hooks and 7 Stop scripts
- Add "How GC Rules Are Triggered" section to garbage-collection
  explanation page covering weekly CI, rotating Stop hook, and manual
  invocation
- Populate hooks reference page (was "Coming Soon" stub) with full
  catalogue of all 8 hooks including design principles

## 0.3.0 — 2026-04-07

### Selective Harness Init

- Enhance /harness-init with feature selection menu — users choose which
  harness features to configure (context, constraints, GC, CI,
  observability) with all selected by default
- Support additive re-runs — existing configuration is preserved when
  adding new features incrementally
- Gate each conversational step on feature selection so users only
  answer questions for features they chose
- Update Getting Started tutorial with feature selection walkthrough,
  re-run guidance, and per-feature generation notes
- Update homepage with selective init description
- Update harness engineering explanation with incremental adoption paragraph

### Habitat Engineering Documentation

- Add habitat engineering explanation page covering the intellectual
  lineage (Alexander, Gabriel, Knuth, Terhorst-North), the central
  insight that AI failures are environment problems, habitat vs harness
  distinction, the six levels of AI literacy, and links to Software
  Enchiridion articles

### GitHub Pages Build Fix

- Fix Jekyll build by changing color_scheme from "default" to "light" —
  just-the-docs v0.12.0 renamed the default color scheme file from
  default.scss to light.scss, causing "Can't find stylesheet to import"

### Documentation Site

- Add GitHub Pages documentation site using Jekyll + just-the-docs theme
- Organize content using the Diataxis framework (tutorials, how-to,
  reference, explanation)
- Full pages: Getting Started tutorial, Set Up Secret Detection how-to,
  Skills reference catalogue, Harness Engineering explanation
- Stub pages for 17 additional topics ready for future content

### Auto-Constraint from Reflections

- Add auto-constraint proposal step to `/reflect` command — after
  capturing a reflection, the command now detects preventable failures
  in the Surprise and Improvement fields and offers to draft a
  constraint via `/harness-constrain`
- Add optional Constraint field to REFLECTION_LOG.md template — makes
  constraint proposals machine-readable for the regression suite GC rule

### Learnings in Agent Context

- Update orchestrator agent to read the 20 most recent REFLECTION_LOG.md
  entries at pipeline start — past reflections now inform approach decisions
- Update harness-enforcer agent to read the 10 most recent reflections
  before agent-based constraint checks — calibrates scrutiny to known gaps
- Update harness-gc agent to read the 10 most recent reflections when
  running GC rules — entropy signals from reflections guide deeper checks
- Add Learnings section to CLAUDE.md template advising agents to consult
  REFLECTION_LOG.md before starting work

### Regression Suite GC Rule

- Add reflection-driven regression detection GC rule to HARNESS.md
  template — weekly agent check that mines REFLECTION_LOG.md for
  recurring failure patterns not yet covered by constraints
- Add learning-driven GC category to the GC skill and catalogue —
  a new class of GC rules that use compound learning artifacts
  (reflections, assessments) as input rather than scanning code

### Self-Improving Harness (from auto-harness research)

- Add design spec for auto-constraint generation from reflections —
  closes the learning loop by offering to create constraints when
  reflections describe preventable failures
- Add design spec for regression suite GC rule — mines
  REFLECTION_LOG.md for recurring failure patterns and proposes
  constraints for uncovered themes
- Add design spec for feeding learnings into agent context —
  orchestrator, enforcer, and GC agents read recent reflections
  to avoid repeating past mistakes

### Complexity Hotspot Detection

- Expand fitness-functions skill with practical hotspot detection
  guide — churn extraction command, per-ecosystem complexity tools,
  worked Python example, and 3-snapshot threshold rule
- Expand fitness catalogue with complete bash script for churn x
  complexity correlation, annotated example output, and ecosystem
  prerequisites

### Executable Spec Integration

- Add executable spec constraint pattern to constraint-design skill —
  documents how to wire test suites into the harness as a spec
  conformance constraint, including the deterministic + agent
  enforcement pattern and BDD/Cucumber as gold standard
- Add commented-out spec conformance constraint to HARNESS.md template
  for projects using spec-first development

### Dependency Age Budget (libyear)

- Add dependency age (libyear) section to the dependency-vulnerability-audit
  skill — covers what libyear measures, commands per ecosystem (npm, Ruby,
  Python, Go), recommended thresholds, and how to read the output
- Add dependency age budget GC rule to HARNESS.md template as a commented-out
  fitness function for weekly deterministic checking

### Tier 2 Design Proposals

- Add design proposal for complexity hotspot detection — weekly GC rule
  correlating git churn with cognitive complexity to find decay hotspots
- Add design proposal for dependency age budget (libyear) — aggregate
  staleness metric complementing CVE scanning
- Add design proposal for executable spec integration — making specs
  load-bearing by wiring test suites into the constraint system

### Workflow and Conventions

- Add CHANGELOG convention to CLAUDE.md — changelog updates required
  before every PR
- Broaden Bash permission patterns in `.claude/settings.local.json`
  for reliable parallel worktree agent execution

### Tier 1 Feature: Auto-Enforcer GitHub Action

- Add `auto-enforcer-action` skill for setting up automatic PR constraint
  checking via GitHub Actions
- Add `ci-auto-enforcer.yml` CI template — reads HARNESS.md at runtime,
  runs deterministic constraints (blocking) and agent constraints
  (advisory PR comments) on every pull request
- Update `harness-init` to offer auto-enforcer setup when agent PR
  constraints exist

### Tier 1 Feature: Convention Sync Across AI Tools

- Add `convention-sync` skill — reads HARNESS.md and generates convention
  files for Cursor (`.cursor/rules/*.mdc`), Copilot
  (`.github/copilot-instructions.md`), and Windsurf (`.windsurf/rules/`)
- Add `/convention-sync` slash command for direct invocation
- Add "Convention file sync" GC rule to HARNESS.md template for weekly
  drift detection

### Tier 1 Feature: Architectural Fitness Functions

- Add `fitness-functions` skill with catalogue of periodic architectural
  checks (structural, coupling, complexity/hotspot, coverage)
- Add reference catalogue with concrete HARNESS.md GC rule entries and
  tool commands per language ecosystem
- Add fitness functions as sixth category in the GC skill and catalogue
- Add commented-out fitness function examples to HARNESS.md template

### Compound Learning

- Capture reflections on Tier 1 research and parallel implementation
- Diagnose worktree agent permission issue — root cause was user
  permission denials during parallel prompt chaos, not worktree
  isolation itself

## 0.2.0 — 2026-04-06

### Secrets Detection

- Add `secrets-detection` skill for gitleaks-based secret scanning —
  covers installation, scanning, baselining, configuration, CI
  integration, and remediation
- Promote "No secrets in source" constraint to deterministic with
  gitleaks in the HARNESS.md template
- Add `secrets-check.sh` Stop-scope hook script for advisory gitleaks
  scanning at session end
- Wire hook into `hooks.json` and add gitleaks discovery to
  `/harness-init` constraint setup
- Add "Secret scanner operational" GC rule

### Project Harness Initialization

- Initialize HARNESS.md for the plugin itself with 6 constraints and
  5 GC rules
- Add `.github/workflows/harness.yml` CI workflow enforcing gitleaks,
  bash syntax, strict mode, and ShellCheck on every PR
- Fix ShellCheck warnings in `secrets-check.sh`,
  `snapshot-staleness-check.sh`, and `update-health-badge.sh`
- Promote ShellCheck constraint from unverified to deterministic
  (5/6 constraints enforced)
- Add harness enforcement and health badges to README

### Compound Learning

- Initialize REFLECTION_LOG.md with first session reflections
- Generate baseline harness health snapshot

### Plugin Structure

- Move plugin into `ai-literacy-superpowers/` subdirectory for
  marketplace install compatibility
