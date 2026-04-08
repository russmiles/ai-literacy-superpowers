# Changelog

## 2026-04-08

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

## 2026-04-07

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

## 2026-04-06

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
