---
diaboli: exempt-pre-existing
---

# Convention Sync Across AI Tools — Design Spec

## Problem

Teams use multiple AI coding tools simultaneously. Each tool has its own
convention file format:

- Claude Code: `CLAUDE.md` / `HARNESS.md`
- Cursor: `.cursor/rules/*.mdc` (frontmatter with `globs` and `description`)
- Copilot: `.github/copilot-instructions.md` + `.github/prompts/*.prompt.md`
- Windsurf: `.windsurf/rules/*.md`

Conventions defined in HARNESS.md — the source of truth for a project's
context and constraints — are invisible to Cursor, Copilot, and Windsurf.
Teams either duplicate conventions manually across all files or leave other
tools operating without project context. Both outcomes cause drift: the
tools diverge from HARNESS.md and from each other as conventions evolve.

## Decision

Add a `convention-sync` skill that reads the Context and Constraints sections
of HARNESS.md and generates the corresponding tool-specific convention files.
HARNESS.md is the single source of truth. Sync is one-way only: HARNESS.md
drives the other files; no tool-specific file feeds back into HARNESS.md.

Deliver it as:

1. A skill (`convention-sync/SKILL.md`) for on-demand generation
2. A GC rule in the template for weekly drift detection
3. A slash command (`convention-sync.md`) for direct invocation

## Approach: HARNESS.md as Single Source of Truth

Every project that uses this plugin already has HARNESS.md structured with
named sections (Context, Constraints, etc.). Parsing those sections into
tool-specific output is deterministic: the conventions do not need
interpretation, only reformatting. This follows the same pattern as
`secrets-detection` (which takes an existing HARNESS.md constraint and
adds enforcement tooling) and `dependency-vulnerability-audit` (which
reads project structure and produces an audit report).

Scoping to Cursor + Copilot + Windsurf covers the three most common
alternatives to Claude Code used by teams in enterprise settings. Other
tools are not blocked from being added later, but are not in scope now.

## Artifacts

### 1. Skill — `skills/convention-sync/SKILL.md`

New skill at `ai-literacy-superpowers/skills/convention-sync/SKILL.md`.

Structure:

1. **Overview** — why convention drift happens and what this skill does
2. **What Gets Synced** — which HARNESS.md sections map to which outputs:
   - Context section → tool description/context blocks
   - Constraints section → rule entries with enforcement notes
   - Each constraint's `Scope` field → Cursor glob patterns where applicable
3. **Running the Sync** — invoke via `/convention-sync` or the skill directly;
   the agent reads HARNESS.md, generates each target file, reports what changed
4. **Output Format Reference** — one sub-section per tool:
   - **Cursor** — `.cursor/rules/conventions.mdc` (context from HARNESS.md
     Context section) and `.cursor/rules/constraints.mdc` (one rule block per
     constraint; glob set from constraint Scope if present, otherwise `**/*`);
     frontmatter fields: `description`, `globs`, `alwaysApply`
   - **Copilot** — `.github/copilot-instructions.md` (flat markdown file
     combining context and constraints); optionally one
     `.github/prompts/<constraint-name>.prompt.md` per constraint tagged
     `enforcement: agent`
   - **Windsurf** — `.windsurf/rules/conventions.md` and
     `.windsurf/rules/constraints.md`; same content structure as Cursor but
     without frontmatter globs (Windsurf does not support glob scoping in
     the same way)
5. **Conflict Resolution** — if a target file already exists, the agent
   diffs the generated content against the existing file and reports
   divergence; the user is prompted before overwriting; HARNESS.md wins
6. **Verification** — after generation, the agent spot-checks each output
   file to confirm every constraint in HARNESS.md appears in each target

### 2. GC Rule for Template — `templates/HARNESS.md`

Add a new GC rule for convention file drift:

```markdown
### Convention file sync

- **What it checks**: Whether `.cursor/rules/`, `.github/copilot-instructions.md`,
  and `.windsurf/rules/` exist and reflect the current HARNESS.md Context and
  Constraints sections (checks for stale or missing entries)
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false — report drift and prompt user to run `/convention-sync`
```

The GC rule does not auto-regenerate files because overwriting tool-specific
convention files without user review risks discarding intentional tool-specific
additions. It reports and delegates.

### 3. Command — `commands/convention-sync.md`

New slash command at `ai-literacy-superpowers/commands/convention-sync.md`.

Behaviour:

- Reads HARNESS.md from the project root (errors if not found)
- Parses Context and Constraints sections
- Generates or updates convention files for each supported tool
- For each file: shows a summary of what was created or changed
- Prompts before overwriting any file that already exists and has diverged
- Reports a final table: `Tool | File | Status` (created / updated / unchanged / skipped)

## What Is NOT In Scope

- Syncing FROM other tool files back to HARNESS.md — one-way only; reverse
  sync introduces merge conflicts and ambiguity about which tool is authoritative
- Auto-detecting which tools are installed or in use — the skill generates all
  supported tool files unconditionally; unused files are harmless
- Tool-specific features with no HARNESS.md equivalent — Cursor's
  `alwaysApply: true` flag, Copilot's prompt chaining, Windsurf's action
  blocks — these are not generated because they have no source in HARNESS.md
- Supporting AI tools beyond Cursor, Copilot, and Windsurf — YAGNI
- New agents — the existing harness-gc agent handles the weekly GC rule;
  no new background agent is needed
