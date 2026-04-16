<!-- Generated from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md.
     Do not edit directly — regenerate with /harness-onboarding. -->

# Welcome to ai-literacy-superpowers

This is a Claude Code and GitHub Copilot CLI plugin that provides the
AI Literacy framework's complete development workflow — harness
engineering, agent orchestration, literate programming, CUPID code
review, compound learning, and the three enforcement loops. You'll be
working with markdown skills, bash hook scripts, JSON configuration,
and YAML CI workflows. There is no compiled application code here; the
plugin's "code" is content that agents and tools read and execute.

---

## Tech Stack

- **Markdown** — the primary language. Skills, agents, commands,
  templates, and documentation are all markdown files with YAML
  frontmatter. Markdownlint enforces consistent formatting across
  every `.md` file.
- **Bash** — hook scripts and utility scripts. Every `.sh` file uses
  strict mode (`set -euo pipefail`) and passes ShellCheck.
- **JSON** — plugin configuration (`plugin.json`, `marketplace.json`)
  and hook registration (`hooks/hooks.json`).
- **YAML** — GitHub Actions CI workflows that enforce constraints on
  PRs and run weekly garbage collection.
- **No build system** — this is a plugin, not a compiled application.
  There is nothing to build or compile.
- **No test framework** — quality is enforced by linters and
  deterministic tools (markdownlint, gitleaks, ShellCheck, bash
  syntax checks), not by a test suite.

---

## How We Write Code

**Naming matters.** Skills live in `skills/<name>/SKILL.md` (the
directory is kebab-case, the file is always `SKILL.md`). Agents are
`<name>.agent.md`. Commands are `<name>.md`. Hook scripts are
`<name>.sh`. Everything is lowercase kebab-case except `SKILL.md`.

**One component per file.** Agents go in `agents/`, skills in
`skills/<name>/SKILL.md`, commands in `commands/`, hook scripts in
`hooks/scripts/`, templates in `templates/`, utility scripts in
`scripts/`. If you're adding something new, put it in the right
directory.

**Hook scripts are advisory only.** They warn but never block. Output
uses JSON `systemMessage` format so Claude Code surfaces the message
without interrupting the session. When writing a hook script, start
with `set -euo pipefail` and exit silently (`exit 0`) when the hook
doesn't apply.

**Everything needs frontmatter.** Every `.agent.md`, `SKILL.md`, and
command `.md` file must have YAML frontmatter with `name` and
`description` fields. Skills also need an Overview section. Bash
scripts need a header comment block explaining purpose and behaviour.

---

## What's Enforced

### At commit time

These checks warn you while you're editing. They're advisory — they
won't stop you from committing, but they'll flag problems early.

- **Markdown formatting** — all `.md` files must pass markdownlint.
  Run `npx markdownlint-cli2 "**/*.md"` locally to check.
- **No secrets** — no API keys, tokens, passwords, or private keys in
  source files. Gitleaks scans for these automatically.
- **Shell syntax** — all `.sh` files must pass `bash -n` syntax
  checking.
- **Strict mode** — every `.sh` file must contain `set -euo pipefail`
  within the first 15 lines.
- **ShellCheck** — all `.sh` files must pass ShellCheck with no
  errors.

### At PR time

These are CI gates that block merges. Your PR will not go green until
these pass.

- **Frontmatter completeness** — every agent, skill, and command file
  must have `name` and `description` in its frontmatter.
- **Spec-first ordering** — for feature PRs, the first commit must
  contain only a spec file in `docs/superpowers/specs/`. Bug-fix and
  maintenance PRs (labelled `bug`, `fix`, `chore`, `maintenance` or
  branch-prefixed `fix/`, `chore/`) are exempt.
- **Spec scoping** — each feature PR traces to a single spec. Don't
  bundle unrelated changes.
- **Spec intent** — the spec must describe the problem, approach, and
  expected outcome. The implementation should trace back to it.
- **Version consistency** — `plugin.json` version, README badge, and
  CHANGELOG heading must all match. Changes inside
  `ai-literacy-superpowers/` require a version bump.
- **Marketplace sync** — `marketplace.json` `plugin_version` must
  match `plugin.json` `version`.
- **Release traceability** — every version needs a matching CHANGELOG
  heading and a git tag. The tag is created automatically on merge.
- **Output validation** — commands that produce structured output must
  include a validation checkpoint that reads the output back and
  checks it against the format spec.
- **Tests must pass** — the test suite (such as it is) must pass with
  zero failures. Currently unverified because there is no application
  test suite.

### On schedule

Periodic checks run weekly or monthly to catch slow drift.

- **Documentation freshness** — checks whether README, HARNESS.md, and
  CLAUDE.md reference things that no longer exist.
- **Secret scanner operational** — confirms gitleaks is still installed
  and running.
- **Snapshot staleness** — flags if the harness health snapshot is
  older than 30 days.
- **Command-prompt sync** — detects when commands and their
  corresponding `.github/prompts/` files have diverged.
- **Change cadence drift** — watches whether PR sizes or cycle times
  are increasing, which can signal that AI-speed production is
  outpacing human review.
- **Plugin manifest currency** — checks whether `plugin.json` counts
  still match actual skills, agents, and commands.
- **Marketplace listing drift** — checks whether `marketplace.json`
  has drifted from `plugin.json`.
- **Release tag completeness** — confirms every CHANGELOG version has
  a git tag.
- **Onboarding staleness** — flags if ONBOARDING.md is older than
  HARNESS.md, AGENTS.md, or REFLECTION_LOG.md.
- **Template currency** — detects when the HARNESS.md template version
  is behind the installed plugin version.
- **Dependency currency** — checks for known vulnerabilities in
  dependencies.
- **Convention file sync** — checks whether Cursor, Copilot, and
  Windsurf convention files reflect current HARNESS.md conventions.
- **Reflection regression detection** — looks for recurring failure
  patterns in REFLECTION_LOG.md that should become constraints.
- **Observability archive** — moves snapshots older than 6 months to
  the archive directory.

---

## Common Pitfalls

**Run deterministic tools before promoting constraints.** When adding
a new linter or check (like ShellCheck), run it against the entire
codebase first — including files created earlier in the same session.
ShellCheck found 4 issues in scripts that had already passed LLM
review. Deterministic tools catch what review misses.

**Don't use worktrees for parallel subagents.** Worktree-isolated
subagents lose Bash permissions because `.claude/settings.local.json`
doesn't propagate to worktree paths. Use regular background agents on
separate branches instead, but plan for branch cross-contamination and
cherry-pick cleanup.

**Background subagents may lack write permissions.** For write-heavy
tasks, use foreground agents so the user can approve tool calls, or
have the parent agent extract content from subagent output and do the
writes itself.

**Check for existing CI workflows before proposing new ones.** This
project already has `version-check.yml`, `lint-markdown.yml`,
`harness.yml`, `gc.yml`, and `pages.yml` in `.github/workflows/`.
Proposing a duplicate wastes a branch cycle.

**The plugin is self-referential.** This plugin defines the harness
framework, and its own HARNESS.md uses that framework. Changes to
template files (`templates/HARNESS.md`) do not automatically propagate
to the project's root `HARNESS.md`. The command-prompt sync and plugin
manifest currency GC rules catch this drift.

**Plugin files live in two locations.** Root-level `skills/`, `hooks/`,
`templates/` are the plugin's own development files. Files under
`ai-literacy-superpowers/` are the packaged plugin that gets
distributed. When a spec references a file path, check both locations.

---

## Architecture Decisions

**Hook scripts never block.** This plugin is used across diverse
projects, so blocking hooks could break workflows the plugin authors
cannot predict. Advisory messages let users decide how to act. The
alternative of configurable blocking was rejected — the complexity
wasn't justified.

**Health snapshots are committed directly to main.** They don't affect
behaviour, and gating them on PR review would add friction to the
observability cadence. This is an intentional exception to the
branch-and-PR workflow.

**Every structured-output command has a validation checkpoint.** The
pattern is: generate output, read it back, check against the format
spec, fix in place. This was added because agents consistently drift
from format specs under cognitive load — reference templates set intent
but don't guarantee compliance. The checkpoint is the verification
layer, analogous to type checking in compiled code.

---

## How We Test

This project has no application code or test suite. Quality is assured
by four deterministic tools that run in CI:

1. **markdownlint** — enforces consistent markdown formatting
2. **ShellCheck** — catches shell script bugs and style issues
3. **bash -n** — verifies shell script syntax
4. **gitleaks** — detects accidentally committed secrets

All four run on every PR via the harness CI workflow. Run them locally
before pushing to avoid CI failures.

---

## How the Harness Works

The project uses three enforcement loops that protect the codebase at
different timescales:

- **Advisory loop** — hooks run during editing and warn about
  potential issues, but never block your work. You'll see system
  messages nudging you to run audits, capture reflections, or check
  for secrets.
- **Strict loop** — CI workflows run on every PR and block merges
  until all checks pass. This includes markdownlint, gitleaks, shell
  checks, version consistency, and spec-first ordering.
- **Investigative loop** — garbage collection rules run weekly (or
  monthly) to catch slow drift that neither hooks nor CI gates
  detect. Things like documentation staleness, marketplace listing
  drift, and unpromoted reflections.

The project runs on a monthly observability cadence:

- Harness health snapshots: monthly
- Harness audits: quarterly
- AI literacy assessments: quarterly
- Reflection review and promotion: monthly
- Cost captures: quarterly

---

## Your First PR Checklist

1. Create a branch — never commit directly to `main`
2. For feature work, commit the spec first (in
   `docs/superpowers/specs/`) before any implementation
3. Run `npx markdownlint-cli2 "**/*.md"` and fix any warnings
4. Run `shellcheck` on any `.sh` files you changed or created
5. Confirm every `.sh` file has `set -euo pipefail` in the first
   15 lines
6. Ensure all `.agent.md`, `SKILL.md`, and command `.md` files have
   `name` and `description` in their YAML frontmatter
7. Run `gitleaks detect --source . --no-banner` to check for secrets
8. If you changed files inside `ai-literacy-superpowers/`, bump the
   version in `plugin.json`, the README badge, and the CHANGELOG
   heading (all three must match)
9. Update `marketplace.json` `plugin_version` to match `plugin.json`
10. Update `CHANGELOG.md` with a dated section describing your changes
11. Push and create a PR — wait for all CI checks to pass before
    requesting review

---

## Where to Learn More

- [HARNESS.md](HARNESS.md) — the full constraint and convention
  reference
- [AGENTS.md](AGENTS.md) — accumulated team knowledge, gotchas, and
  architecture decisions
- [REFLECTION_LOG.md](REFLECTION_LOG.md) — session-by-session
  learnings from agent pipeline runs
- [CLAUDE.md](CLAUDE.md) — project conventions for Claude Code
  sessions
- [README.md](README.md) — full plugin documentation with component
  listings
