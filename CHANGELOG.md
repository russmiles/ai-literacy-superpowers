# Changelog

## 0.25.0 — 2026-04-19

### Feature — diaboli observability panel

- Add Diaboli panel to `commands/superpowers-status.md` (Section 7) — surfaces
  in-scope vs exempt spec count, objection records present, in-scope specs without
  a record, fully-resolved record rate, objections total with severity breakdown,
  mean objections per spec, disposition distribution, and median days
  spec-to-disposition; summary uses standard `OK`/`MISSING` tokens; error handling
  for malformed YAML frontmatter
- Add Diaboli section to snapshot format (`skills/harness-observability/references/
  snapshot-format.md`) after Session Quality and before Operational Cadence, with
  field computation table
- Update `commands/harness-health.md` — Diaboli included in required section list;
  step 7 validation updated from 12 to 13 required section headings with Diaboli
  in enumerated list
- Update `skills/harness-observability/SKILL.md` — reference to Diaboli panel added
- Add `skills/advocatus-diaboli/references/observability.md` — metric computation
  definitions, interpretive notes, and watch-for patterns (what each field means
  and what it does NOT mean)
- Fix `commands/diaboli.md` validation checkpoint — category and severity taxonomy
  corrected to match SKILL.md: premise/scope/implementation/risk/alternatives/
  specification quality and critical/high/medium/low
- Add ARCH_DECISION to `AGENTS.md` — observability-before-enforcement principle,
  revisit conditions (10 fully-resolved records or 2026-07-19)
- Update `docs/explanation/adversarial-review.md` — disposition patterns section
  now references Diaboli panel surfaces; three-loops section adds observability loop
- Update `docs/how-to/review-a-spec-adversarially.md` — "What you have now" notes
  that disposition patterns accumulate and are visible in status/health surfaces

## 0.24.0 — 2026-04-19

### Docs and taxonomy — advocatus-diaboli coverage and SKILL.md update

- Add `docs/explanation/adversarial-review.md` — standalone explanation of
  the Promoter Fidei precedent, Popperian falsifiability, the Schopenhauer
  non-goal, the human-cognition gate, and disposition patterns as signals
- Add `docs/how-to/review-a-spec-adversarially.md` — practical guide for
  running `/diaboli`, reading the objection record, and writing dispositions
- Update `docs/reference/commands.md` — add `/diaboli` entry with correct
  taxonomy; count updated to 22
- Update `docs/reference/agents.md` — add `advocatus-diaboli` agent entry;
  count updated to 12; pipeline description updated to six-stage sequence
- Update `docs/explanation/agent-orchestration.md` — pipeline diagram now
  shows advocatus-diaboli and two human gates; "Where This Breaks Down"
  names the structural solution; duplicate link removed from Further Reading
- Update `docs/tutorials/first-time-tour.md` — `/diaboli` section added;
  count updated to twenty-two
- Update `skills/advocatus-diaboli/SKILL.md` — category taxonomy updated
  to premise/scope/implementation/risk/alternatives/specification quality;
  severity updated to critical/high/medium/low (replaces major/minor);
  change driven by spec-first review of the docs work itself via /diaboli

## 0.23.0 — 2026-04-19

### Feature — advocatus-diaboli adversarial spec review

- Add `skills/advocatus-diaboli/SKILL.md` — charter for the adversarial
  spec reviewer: six objection categories (premise, design, threat, failure,
  operational, cost), severity levels (major/minor), 12-objection cap,
  evidence requirement per objection, mandatory "Explicitly not objecting to"
  section; intellectual foundations grounded in the historical Promoter of
  the Faith, Popper on falsifiability, and an explicit anti-Schopenhauer
  framing (no rhetorical tricks, no winning for its own sake)
- Add `agents/advocatus-diaboli.agent.md` — read-only agent (Read/Glob/Grep
  only) that reads a spec and returns objection record content to the
  orchestrator; disposition fields cannot be written by any agent — this
  constraint is the human-cognition gate
- Add `commands/diaboli.md` — `/diaboli <spec-path>` for manual invocation
  and regeneration; includes a 10-point validation checkpoint per the
  output-validation-checkpoints constraint
- Add `.github/prompts/diaboli.prompt.md` — Copilot CLI equivalent
- Update `agents/orchestrator.agent.md` — pipeline is now: spec-writer →
  advocatus-diaboli → GATE (objection adjudication, blocked on `pending`) →
  GATE (plan approval with adjudicated record) → tdd-agent → …
- Update `HARNESS.md` — add "Spec has adjudicated objections" constraint
  (agent-enforced, scope pr) with pre-2026-04-19 exemption; add "Objection
  record freshness" GC rule (deterministic, weekly)
- Update `templates/HARNESS.md` — new projects scaffolded by `/superpowers-init`
  inherit both the constraint and the GC rule
- Update `MODEL_ROUTING.md` — advocatus-diaboli routed to most-capable tier
  (judgment-heavy, not throughput-heavy)
- Update `AGENTS.md` — ARCH_DECISION: diaboli hard-wired as PR constraint
  from the outset; rejected alternatives documented (manual-only, advisory
  gate, deterministic schema check alone)
- Create `docs/superpowers/objections/` — directory for objection records

## 0.22.0 — 2026-04-17

### Docs — first-time tour tutorial

- Add `docs/tutorials/first-time-tour.md` — a single route through
  every plugin capability in the order it is most useful on a first
  run, with the reason each step comes where it does; grouped into
  eight phases (orient, foundation, measure, adjust, learning loop,
  governance, cadence, share and scale) plus two day-to-day
  capabilities (`/worktree`, `/harness-upgrade`)
- Point `docs/tutorials/getting-started.md` "Next Steps" at the new
  tour so first-time users land on it naturally after the
  installation walkthrough
- Docs-only change; no plugin version bump (0.22.0 retained)

### Docs — surfacing-tacit-knowledge tutorial

- Add `docs/tutorials/surfacing-tacit-knowledge.md` — a five-phase
  walkthrough for turning tacit team knowledge into versioned,
  enforceable artefacts: scaffold the habitat with
  `/superpowers-init`, run guided extraction with
  `/extract-conventions`, mine existing code/PRs/wikis with AI,
  introduce lightweight ADRs captured in flow (plus `/reflect` for
  micro-decisions), and generate team-specific onboarding with
  `/harness-onboarding`. Each command is explained in terms of why
  it comes where it does and what it produces, with an ATM
  scheduling-service running example and a closing flywheel that
  turns the one-time exercise into a quarterly habit
- Docs-only change; no plugin version bump (0.22.0 retained)

### CLAUDE.md — CHANGELOG heading format made explicit

- Rewrite the "CHANGELOG" section of `CLAUDE.md` to state the hard
  invariant enforced by the `Check version consistency` CI step:
  every top-level `## ...` heading MUST begin with a semver version
  (`## X.Y.Z — YYYY-MM-DD`). Date-only headings silently parse as the
  first token (for example `2026`) and fail CI with a cryptic
  mismatch error.
- Make the docs-only path explicit: append entries under the most
  recent version's heading; do not create a new top-level heading
  without a version. Closes the recommendation from the 2026-04-16
  reflection that had gone unactioned and caused a repeat CI failure
  on PR #173 (captured in the 2026-04-18 reflection).

### Harness template-version marker bump

- Bump `HARNESS.md` template-version marker 0.21.0 → 0.22.0 after
  running `/harness-upgrade`; no new constraints, GC rules, or sections
  to adopt (template content is unchanged since 0.19.0 — the plugin
  version advanced three releases without template edits)
- Silences the template-currency GC finding until the next plugin
  upgrade introduces new template content

### Marketplace source schema fix

- Fix `source` field in `.claude-plugin/marketplace.json` — bare string
  form (`"ai-literacy-superpowers"`) from #164 is rejected by the
  Claude Code marketplace schema with `plugins.0.source: Invalid input`;
  restore the required `./` prefix (`"./ai-literacy-superpowers"`) so
  `claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers`
  parses again
- Bump listing `version` 0.2.2 → 0.2.3 (source path is a listing
  contract change per CLAUDE.md); `plugin_version` unchanged
- Documented behaviour: marketplace `source` as a plain string must be
  a relative path starting with `./`; the runtime resolves it to the
  plugin directory and loads `.claude-plugin/plugin.json` from there

### Copilot CLI install instructions

- Fix README Copilot CLI install block — add missing
  `copilot plugin marketplace add` step and correct the install
  command to `copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers`
  so users on Copilot CLI can actually install the plugin without
  hitting "plugin not found"
- Mirror the corrected install block in `docs/index.md` Quick Install
  so the docs site and README agree; Claude Code and Copilot CLI
  steps are now shown side-by-side in both places
- Partial fix for #168 (leaves `docs/how-to/install-the-plugin.md`
  how-to page and `docs/tutorials/getting-started.md` tutorial-step
  update for a follow-up)

### Marketplace cache auto-sync

- Add `ai-literacy-superpowers/scripts/sync-marketplace-cache.sh` —
  fast-forwards `~/.claude/plugins/marketplaces/ai-literacy-superpowers`
  when `marketplace.json` on `origin/main` differs from the cached
  copy (any byte difference — covers listing version, `plugin_version`,
  and per-plugin version bumps); no-ops silently when cache missing,
  offline, or already current
- Complements the existing `sync-to-global-cache.sh` (plugin content
  sync); this script handles the marketplace-clone side
- Wire via a `PostToolUse` hook on `Bash(gh pr merge*)` in
  `.claude/settings.local.json` so the cache refreshes the moment a
  marketplace-affecting PR is merged through the CLI
- Document the rule under **Marketplace Cache Auto-Sync** in CLAUDE.md
  so collaborators can opt in by adding the same hook locally

## 0.21.0 — 2026-04-15

### Observatory signal verification

- Add /observatory-verify command — runs the 82-signal checklist
  against the latest output files, reporting PRESENT/PARTIAL/MISSING
  status for each signal the Observatory expects to read
- Add observatory-signals.md reference — the authoritative checklist
  of all signals across 5 sources (snapshot, governance, reflections,
  HARNESS.md, assessments)

## 0.20.0 — 2026-04-15

### Human-readable harness onboarding

- Add /harness-onboarding command — generates ONBOARDING.md from
  HARNESS.md, AGENTS.md, and REFLECTION_LOG.md for new team members
- Add harness-onboarding skill — tone guidelines and section mapping
  for human-readable onboarding document generation
- Add ONBOARDING.md template with 10 section skeleton and placeholder
  markers
- Add onboarding document staleness GC rule (monthly) to both the
  template and the project's own HARNESS.md
- Command includes a validation checkpoint verifying all 10 sections
  are present and no placeholder markers remain
- Generated ONBOARDING.md is linked from the project README

Closes #37.

## 0.19.4 — 2026-04-15

### Output validation checkpoints

- Add validate-and-fix-in-place checkpoint to /harness-health —
  verifies all 12 snapshot sections present, no deprecated YAML block
- Add validation checkpoint to /assess — verifies assessment document
  has required sections and parseable level number for portfolio
  aggregation
- Add validation checkpoint to /reflect — verifies all 8 mandatory
  fields plus 4 session metadata subfields and Signal enum value
- Add validation checkpoint to /cost-capture — verifies cost snapshot
  has fields that /harness-health needs for Cost Indicators section
- Add validation checkpoint to /harness-constrain — verifies
  constraint block has required fields with valid enum values
- Add validation checkpoint to /harness-init — verifies generated
  HARNESS.md has all top-level sections, subsections, and template
  version marker
- Add validation checkpoint to /superpowers-init — verifies all 4
  habitat files (CLAUDE.md, AGENTS.md, MODEL_ROUTING.md,
  REFLECTION_LOG.md) have required sections

## 0.19.3 — 2026-04-15

### Governance Summary validation checkpoint

- Add step 5 to /governance-audit command: validate the Governance
  Summary section after the governance-auditor agent writes the report,
  fixing heading, field count, and value formats in place rather than
  re-dispatching the agent
- Strengthen governance-auditor agent instructions: mark the Governance
  Summary section as a critical format contract, add self-check
  instruction, explicitly forbid 0-based drift stage scale
- Fix existing governance audit report to use the correct
  `## Governance Summary` heading with all nine structured fields

## 0.19.2 — 2026-04-15

### Observatory signal completeness

- Add GC cadence compliance field to snapshot format — reports whether
  GC runs are within declared schedule, not just the last run date
- Add per-activity overdue annotations to Operational Cadence section —
  each activity now shows on-schedule/overdue status with target cadence
- Add `inactive` as third Learning flow state for projects with zero
  reflections, alongside existing `active` and `stalled`
- Add `Cadence compliance` and `Health` fields to Meta section template
  with full computation instructions — previously produced by agents
  but undocumented in the format spec
- Enforce `## Governance Summary` heading in governance-auditor output
  (was `## Summary`) — fixes regex parsing for Observatory consumers
- Require all nine Governance Summary fields to be present even when
  values are zero, with explicit computation instructions for each
- Enforce numeric `N/5` format for Semantic drift stage (was
  qualitative) and add `Frame alignment score` percentage computation

## 0.19.1 — 2026-04-15

### Markdownlint compliance

- Fix all 58 pre-existing markdownlint violations across articles, docs,
  commands, templates, and observability snapshots — MD036 (emphasis as
  heading), MD040 (code fence language), MD033 (inline HTML), MD001
  (heading increment), MD032 (blanks around lists), and others
- Upgrade HARNESS.md to template 0.19.0 with Observability section and
  governance constraint template; correct audit status counts and badge

### Version bump scoping

- Scope version bump requirement to `ai-literacy-superpowers/` plugin
  directory only — changes outside the plugin (articles, docs, CI,
  root config) no longer trigger the CI version bump check
- Add `no-bump` PR label exemption for formatting-only fixes to plugin
  files that don't warrant a version bump
- Update CLAUDE.md convention, HARNESS.md constraint, and
  version-check.yml workflow to reflect the scoped rules

## 0.19.0 — 2026-04-15

### Dev workflow — global plugin sync

- Add sync-to-global-cache.sh script and Stop hook in
  settings.local.json — syncs local plugin to the global Claude Code
  cache at session end so the installed version always reflects the
  working copy

### Harness template — Observability section

- Add `## Observability` section to HARNESS.md template with snapshot
  cadence, operating cadence, health thresholds, and regression
  detection configuration — new harnesses now include self-monitoring
  defaults out of the box

### Harness upgrade — adopt 0.18.1 template content

- Accept all new template items: 2 constraints (Tests must pass,
  Spec conformance), 4 active GC rules (Dependency currency,
  Observability archive, Convention file sync, Reflection-driven
  regression detection), and 7 commented-out GC rules (governance
  and fitness function templates)
- Update template-version marker to 0.19.0

## 0.18.1 — 2026-04-15

### Repo cleanup

- Remove 6 stale root-level directories (agents, commands, hooks,
  skills, scripts, templates) — all content already exists in the
  `ai-literacy-superpowers/` plugin directory
- Move template-currency-check.sh into plugin and wire up as
  SessionStart hook — completes the hook that 0.18.0 described
  but did not ship

## 0.18.0 — 2026-04-15

### Template adoption

- Add `/harness-upgrade` command — structural diff between user's
  HARNESS.md and plugin template, with accept/skip menu for new
  constraints, GC rules, sections, and optional blocks
- Add SessionStart hook for template currency — nudges user when
  plugin template has been updated since their harness was generated
- Add Template currency GC rule to template — weekly persistent
  reminder for un-reviewed template content
- Add `template-version` marker to generated HARNESS.md files for
  upgrade tracking
- Consolidate two diverged template files into single canonical copy
  at `ai-literacy-superpowers/templates/HARNESS.md`

## 0.17.1 — 2026-04-15

### Lint fix

- Fix markdownlint MD060 table separator spacing across 52 files —
  formatting only, no content changes

## 0.17.0 — 2026-04-15

### Release governance

- Add first governance constraint: release traceability — every
  plugin version must have a matching changelog heading and git tag
- Add auto-tag workflow (`.github/workflows/auto-tag.yml`) that
  creates `vX.Y.Z` tags on merge when the version changes
- Add "Release tag completeness" GC rule with auto-fix for missing
  tags
- HARNESS.md Status: 12/12 constraints enforced, 3/8 GC rules active

## 0.16.0 — 2026-04-15

### Observatory rebase: YAML to markdown

- Remove `observatory_metrics` YAML block from snapshot format and
  generation — snapshots now contain only markdown sections that
  agents read natively
- Delete `observatory-metrics-schema.md` — schema versioning is no
  longer needed; format evolution is handled by Claude's natural
  ability to read markdown regardless of structural changes
- Delete `observatory-events.md` and stop appending to
  `observability/events.jsonl` — event tracking is replaced by the
  new "Changes Since Last Snapshot" markdown section in each snapshot
- Remove `observability/violations.jsonl` and all violation logging
  from CI workflows (`harness.yml`, `gc.yml`) and advisory hook — CI
  failure annotations and GC findings already capture this data
- Downgrade CI workflow permissions from `contents: write` to
  `contents: read` (no longer committing violations.jsonl)
- Replace governance YAML block in `governance-auditor` with a
  markdown Governance Summary section containing all expanded metrics
- Remove `observatory_portfolio` YAML block from portfolio assessment
  — habitat aggregates are now a markdown section reading snapshot
  markdown directly
- Add Regression Indicators section to snapshots — stale detection,
  cadence non-compliance counting, consecutive zero-reflection weeks,
  and composite regression flag
- Add Enforcement Loop History section to snapshots — tracks when
  advisory, strict, and investigative loops were first activated
  using git history
- Add Changes Since Last Snapshot section — captures constraint
  lifecycle (added, promoted, removed) and completed assessments and
  audits by diffing against the previous snapshot
- Add Habitat Aggregates section to portfolio assessment template
- Remove event emission instructions from `/reflect`,
  `/harness-constrain`, `/assess`, and governance-auditor commands
- Update governance-observability skill to use markdown format
  instead of YAML for metrics catalogue and snapshot extension

## 0.15.2 — 2026-04-14

### Bug fix

- Fix intermittent YAML block omission in harness-health snapshots —
  split Step 6 into separate markdown generation and YAML block steps
  with mandatory marker and self-verification checkpoint. The trailing
  instruction was unreliable under cognitive load from trend computation.

## 0.15.1 — 2026-04-14

### Bug fix

- Fix `gc-rotate.sh` crash when HARNESS.md has no `## Observability`
  section — `set -euo pipefail` caused the grep pipeline to exit
  non-zero before reaching the default cadence fallback. Added
  `|| true` to let empty results fall through. Fixes #122.

## Marketplace 0.2.1 — 2026-04-14

### GC findings fix

- Fix `marketplace.json` nested `plugins[0].version` stuck at "0.1.0" —
  updated to "0.15.0" to match `plugin.json`
- Align `plugins[0].description` with `plugin.json` description
- Bump marketplace listing version to 0.2.1

## 0.15.0 — 2026-04-14

### Observatory Tier 3: Violation Tracking, Portfolio Metrics, Event Log

- Add violation tracking via `observability/violations.jsonl` — advisory
  hook, CI constraint checks, and GC workflow now log detected violations
  as JSON Lines entries with timestamp, loop, constraint, and context
- Add violation latency metrics to snapshot YAML block —
  `feedback_loops.latency` with per-loop counts and `violations_total`
- Add `observatory_portfolio` YAML block to portfolio assessment reports
  with summary, level distribution, habitat aggregates (mean enforcement
  ratio, learning velocity, GC active ratio, context depth), gaps,
  outliers, and per-project detail
- Add Observatory event log at `observability/events.jsonl` — 10 event
  types tracking state transitions (snapshot creation, assessments,
  governance audits, constraint lifecycle, regression transitions,
  reflections, cadence configuration)
- Add event emission to `/harness-health`, `/reflect`,
  `/harness-constrain`, `/assess`, and `governance-auditor`
- Add `observatory-events.md` reference documenting event log format,
  event types, and emission matrix
- Bump Observatory metrics schema to 1.2.0 (backwards-compatible)

## 0.14.0 — 2026-04-14

### Observatory Tier 2: Regression Detection, Loop Tracking, Session Metadata

- Add `regression_indicators` section to Observatory YAML block —
  `snapshot_stale`, `cadence_non_compliant_count`,
  `consecutive_zero_reflection_weeks`, and composite `regression_flag`
- Expand `feedback_loops` with per-loop `active` and `first_activated`
  date fields, determined via git history lookups with caching
- Add session metadata to reflection entries — duration, model tiers
  used, pipeline stages completed, and agent delegation mode
  (best-effort, "unknown" always valid)
- Standardise governance audit YAML block with `schema_version`,
  `falsifiable_count`, `vague_count`, `drift_stage`, and
  `debt_total_score` fields
- Support configurable snapshot cadence via HARNESS.md Observability
  section — weekly (10d), fortnightly (21d), monthly (30d, default).
  Staleness check scripts and meta-observability checks now respect
  the configured threshold
- Bump Observatory metrics schema to 1.1.0 (backwards-compatible)

## 0.13.0 — 2026-04-14

### Observatory-Ready Metrics

- Add YAML metrics block to harness health snapshots — structured,
  typed `observatory_metrics` block appended after all markdown
  sections, enabling machine consumption without brittle regex parsing
- Add per-context-layer freshness tracking in `context_depth.layers` —
  each of the five context layers reports `present` and `last_modified`
- Add per-constraint enforcement detail in `constraint_maturity.constraints` —
  each constraint listed with name, tier, and enforced status
- Add observatory metrics schema documentation with versioning policy
  (patch/minor/major) and changelog at
  `references/observatory-metrics-schema.md`

## 0.12.0 — 2026-04-13

### Governance Dimension Support

- Add `governance-auditor` agent for deep governance investigation —
  semantic drift analysis, governance debt inventory, constraint
  falsifiability scoring, three-frame alignment checks
- Add `governance-constraint-design` skill with falsifiability test,
  three-frame translation method, anti-patterns gallery, and
  governance constraint template
- Add `governance-audit-practice` skill with five-stage semantic drift
  model, governance debt scoring matrix, and audit methodology
- Add `governance-observability` skill with metrics catalogue, snapshot
  format extension, and HTML dashboard specification
- Add `/governance-audit` command for quarterly deep governance
  investigation
- Add `/governance-constrain` command for guided governance constraint
  authoring with three-frame alignment check
- Add `/governance-health` command for governance health pulse check
  and dashboard generation
- Add governance drift check stop hook — detects governance-related
  file changes and audit staleness at session end
- Extend `harness-enforcer` agent with governance constraint quality
  gate — checks falsifiability, operational meaning, and frame
  alignment for governance constraints
- Extend `assessor` agent with governance dimension in assessment
  output — governance ALCI items, readiness summary, improvement
  recommendations
- Extend `harness-gc` agent with governance GC rules — constraint
  freshness, semantic drift early warning, governance debt cycle check
- Extend HARNESS.md template with governance constraint example and
  governance GC rules

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
