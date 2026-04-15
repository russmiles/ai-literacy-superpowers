# GitHub Pages Documentation Site — Design Spec

## Problem

The plugin has extensive content (24 skills, 10 agents, 15 commands,
templates, design specs) but no public documentation site. The README
covers everything in one long page. Potential users can't discover
what the plugin does without reading source files. Contributors can't
understand the architecture without reading skill internals.

## Decision

Create a GitHub Pages documentation site using Jekyll with the
just-the-docs theme, organized using the Diataxis framework
(tutorials, how-to guides, reference, explanation).

## Approach: Jekyll + just-the-docs + Diataxis

Jekyll is natively supported by GitHub Pages — no CI workflow needed.
The just-the-docs theme provides navigation hierarchy, search, and
dark mode out of the box. Diataxis provides the information
architecture.

Content is written fresh for human readers, not copied from
agent-facing skill files. Docs reference skill files but don't
duplicate their terse, instructional style.

## Artifacts

### 1. Jekyll configuration — `docs/_config.yml`

- Theme: `just-the-docs` via `remote_theme`
- Title, description, color scheme with dark mode toggle
- `aux_links` pointing to GitHub repo
- Search enabled

### 2. Landing page — `docs/index.md`

What the plugin is, the four documentation sections, quick install
command, and links to get started.

### 3. Diataxis sections (4 index pages + content)

**Tutorials** (`docs/tutorials/`):

- `index.md` — section overview
- `getting-started.md` — full tutorial: install, harness-init, first constraint
- Stubs: `your-first-skill.md`, `harness-from-scratch.md`

**How-to Guides** (`docs/how-to/`):

- `index.md` — section overview
- `set-up-secret-detection.md` — full guide: gitleaks setup
- Stubs: `add-a-constraint.md`, `sync-conventions.md`,
  `set-up-auto-enforcer.md`, `run-a-harness-audit.md`,
  `add-fitness-functions.md`

**Reference** (`docs/reference/`):

- `index.md` — section overview
- `skills.md` — full catalogue: all 24 skills with descriptions
- Stubs: `agents.md`, `commands.md`, `hooks.md`,
  `harness-md-format.md`, `templates.md`

**Explanation** (`docs/explanation/`):

- `index.md` — section overview
- `harness-engineering.md` — full explanation: three components,
  Boeckeler's framing
- Stubs: `three-enforcement-loops.md`, `progressive-hardening.md`,
  `self-improving-harness.md`, `garbage-collection.md`,
  `fitness-functions.md`

### 4. GitHub Pages enablement

Enable Pages via API to serve from `docs/` on `main` branch.

### 5. CHANGELOG and README updates

Update CHANGELOG with the docs site entry. Add docs site URL to README.

## What Is NOT In Scope

- Custom theme or CSS (use just-the-docs defaults)
- CI workflow for building (native Jekyll support)
- Full content for all pages (stubs for future sessions)
- Versioned docs (YAGNI for now)
- Blog or news section
