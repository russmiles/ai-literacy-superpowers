# Selective Harness Init — Design Spec

## Problem

The `/harness-init` command walks users through a 10-step conversational wizard
that configures all harness features: context engineering, architectural
constraints, garbage collection, CI configuration, and observability. There is
no way to configure a subset of features or to add features incrementally
across multiple runs.

This creates two problems:

1. **Adoption friction.** A team that only wants context engineering and a
   couple of constraints must sit through questions about all 8 GC rule types,
   CI auto-enforcer setup, and badge configuration. The time-to-value is
   longer than it needs to be.

2. **No incremental growth.** Re-running `/harness-init` offers to
   re-initialise from scratch. A team that started with constraints and later
   wants to add garbage collection has no guided path — they must either
   re-answer all questions or manually edit HARNESS.md.

Both problems work against the progressive adoption story that maps to the
AI literacy levels: Level 2 teams want verification (constraints), Level 3
teams want the full habitat (everything). The init command should meet teams
where they are.

## Decision

Add a feature selection step to `/harness-init` that lets users choose which
harness features to configure. All features default to selected on first run.
On re-run, the command detects which sections are already configured and
operates additively — only populating selected sections while preserving
existing content.

## Design

### Feature Menu

After stack discovery (steps 1-2, unchanged), the command presents a feature
selection menu with five areas:

| Feature | What it configures | HARNESS.md section |
|---|---|---|
| Context engineering | Stack declaration + conventions | `## Context` |
| Architectural constraints | Enforcement rules + secret detection | `## Constraints` |
| Garbage collection | Periodic entropy checks | `## Garbage Collection` |
| CI configuration | GitHub Actions workflow + auto-enforcer | (separate files) |
| Observability | README badge + status section | `## Status` + README |

**First run** (no HARNESS.md exists): all features default to on.

**Re-run** (HARNESS.md exists): the menu shows which features are already
configured. Already-configured features default to off (skip). Unconfigured
features default to on. The user can toggle any combination. Selecting an
already-configured feature means "reconfigure it" — the section gets replaced
with fresh answers.

### Additive HARNESS.md Generation

**First run:** Generate the full file from the template. Populate sections for
selected features. Unselected sections get a placeholder marker:

```markdown
## Garbage Collection

<!-- Not yet configured. Run /harness-init and select this feature to set up. -->
```

**Re-run:** Read the existing HARNESS.md. For each selected feature, replace
that section with freshly generated content. For unselected features, preserve
the existing content verbatim.

Section boundaries map to the existing `## Context`, `## Constraints`,
`## Garbage Collection`, and `## Status` headings in the template.

### Dependent Features

CI configuration and observability generate separate files rather than
HARNESS.md sections. They have dependencies:

**CI configuration** depends on constraints existing:
- If selected but no constraints exist (first run without constraints): warn
  that there's nothing to enforce, skip CI generation
- If selected and constraints exist (re-run or both selected): generate the
  workflow from current constraints. Offer auto-enforcer if agent PR
  constraints exist.

**Observability** (README badge) depends on HARNESS.md existing:
- If selected but nothing else is configured: skip with a note
- Otherwise add/update the badge reflecting current state

Both features are toggleable in the menu. The command handles dependencies
gracefully with informative messages rather than errors.

### Revised Command Flow

The 10-step process becomes:

1. **Discover** — unchanged, always runs
2. **Present findings** — unchanged, always runs
3. **Feature selection** — NEW. Present the menu with defaults based on
   existing state. User toggles features on/off.
4. **Ask about conventions** — only if Context engineering selected
5. **Ask about constraints** — only if Architectural constraints selected
   (includes secret detection sub-flow)
6. **Ask about garbage collection** — only if Garbage collection selected
7. **Generate/update HARNESS.md** — always runs. Populates selected sections,
   preserves existing unselected sections, marks unconfigured sections with
   placeholder comments.
8. **Generate CI configuration** — only if CI configuration selected and
   constraints exist
9. **Add README badge** — only if Observability selected
10. **Commit & summary** — unchanged, always runs. Summary shows what was
    configured this run and what remains unconfigured as next steps.

### What Does Not Change

- The **template** (`templates/HARNESS.md`) stays the same — it's the full
  template with all sections and placeholders. The command decides which
  sections to populate.
- The **discovery agent** (`harness-discoverer`) stays the same — it always
  scans everything regardless of feature selection.
- The **conversational depth** within each feature area stays the same — the
  questions about conventions, constraints, and GC rules are unchanged.
- The **CI templates** and **badge script** stay the same.

## Files Changed

| File | Change |
|---|---|
| `ai-literacy-superpowers/commands/harness-init.md` | Add feature selection step, gate subsequent steps on selections, add re-run detection and additive generation logic |

## Files Unchanged

- `ai-literacy-superpowers/templates/HARNESS.md`
- `ai-literacy-superpowers/agents/harness-discoverer.agent.md`
- `ai-literacy-superpowers/templates/ci-github-actions.yml`
- `ai-literacy-superpowers/templates/ci-auto-enforcer.yml`
- `ai-literacy-superpowers/scripts/update-badge.sh`
