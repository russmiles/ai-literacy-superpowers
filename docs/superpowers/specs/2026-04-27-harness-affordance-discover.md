---
name: harness-affordance-discover
description: Implementation spec for /harness-affordance discover — the discovery scanner that reads project config (settings.json, .mcp.json, hook entries) and emits a draft affordance inventory to a scratch file. First implementation step of the harness-affordances design (sequencing step 2).
date: 2026-04-27
status: draft
---

# /harness-affordance discover — Implementation Spec

> Implements **sequencing step 2** of
> `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`.
> The design spec is the source of truth for *why* this exists, the
> schema, and the full command surface. This spec covers *what to
> build first*: the discovery scanner only.

## Problem

The harness-affordances design (PR #198) is approved on main, but
no implementation has shipped. The first step is the discovery
scanner — without it, populating the new `## Affordances` section
requires hand-typing every entry, which collides with the
"discovery-first sequencing" decision (Resolved Decision 7) and
gives existing harness adopters no backfill path (Resolved
Decision 13).

## Goals

1. Ship `/harness-affordance discover` as a working command that
   produces a draft affordance inventory from the current project's
   config.
2. The output is a standalone scratch file (not appended to
   HARNESS.md), preserving the "humans own HARNESS.md" structural
   invariant (Resolved Decision 8).
3. Existing harness adopters gain the backfill path immediately on
   v0.28.0 — they run the command once and get a draft for every
   permission, hook, and MCP server already declared in config.
4. The scanner is idempotent — running it twice produces the same
   output (modulo timestamps), so it can be safely run on a
   schedule or in CI.

## Non-Goals

- **`add` and `review` subcommands.** Out of scope; sequencing
  steps 3 and 6 respectively. The command file is structured so
  both can be wired up later without rewrites.
- **Diff against existing HARNESS.md `## Affordances` section.**
  Out of scope for this PR; will be added when the section itself
  ships in step 3 (no point diffing against a section that does not
  yet exist on any project).
- **Reading `~/.claude/settings.json`.** User-level settings are
  out of scope for project-level governance review. Project
  affordances come from project-level config only.
- **Inferring Identity, Audit Trail, or Last Reviewed.** These are
  the human-owned governance fields; the scanner emits empty
  placeholders for the human to fill in via the `add` subcommand
  (or by hand) in a later step.
- **Writing to HARNESS.md.** The scanner only ever writes to
  `.claude/affordance-discovery-<date>.md`.

## Design

### Sources read

In order of precedence (later sources override earlier when the same
permission pattern appears in both):

1. `<project>/.claude/settings.json`
2. `<project>/.claude/settings.local.json`
3. `<project>/.mcp.json`

For each source, the scanner extracts:

- **`permissions.allow` entries** → one draft affordance per
  pattern, with `Mode` inferred from the pattern shape:
  - `Bash(...)` → `Mode: cli`
  - `mcp__<server>__...` → `Mode: local-mcp` *or* `central-mcp`
    depending on whether the matching MCP server in `.mcp.json` has
    a remote URL (default `local-mcp` if cannot determine)
  - other → `Mode: cli` with a Notes flag
- **`hooks.<event>` entries** → one draft affordance per hook,
  with `Mode: hook` and `Trigger: <event>` (matching the nine
  Claude Code hook event names per the design spec)
- **MCP servers in `.mcp.json` not already covered by a
  `mcp__<server>__*` permission entry** → emit a draft affordance
  with a `WARN: no permission allowlist entry` Notes flag (this is
  the asymmetric case from O9 — permission-without-affordance is
  advisory, but affordance-without-permission is blocking, so an
  MCP declared without authorisation is worth surfacing).

### Output format

A markdown file at `<project>/.claude/affordance-discovery-<date>.md`.
The `.claude/` directory is gitignored, so drafts do not pollute
git. Filename includes the date so re-running creates a new draft
side-by-side with prior drafts.

Output structure:

```markdown
# Affordance Discovery — <YYYY-MM-DD>

Draft affordance inventory generated from project config.
Review each entry, fill in the human-owned fields (**Identity**,
**Audit trail**, optional **Notes**), then copy approved entries
into `HARNESS.md` under `## Affordances`.

Source files scanned:
- .claude/settings.json (N entries)
- .claude/settings.local.json (M entries)
- .mcp.json (P servers)

---

### <derived-name>

- **Mode**: cli
- **Identity**: TODO
- **Audit trail**: TODO
- **Permission**: `Bash(gh *)`
- **Last reviewed**: TODO (run `/harness-affordance review` once
  Identity and Audit trail are filled in)
- **Notes**: <any warnings emitted by the scanner; otherwise omit>

### <derived-name-2>
...
```

### Derived names

The affordance name is derived deterministically from the
permission pattern, so re-runs produce stable identifiers:

- `Bash(gh *)` → `gh-cli`
- `Bash(git *)` → `git-cli`
- `Bash(npx *)` → `npx-cli`
- `Bash(<single-token>)` → `<single-token>-cli`
- `mcp__honeycomb__*` → `honeycomb-mcp`
- `mcp__honeycomb__query` → `honeycomb-mcp-query` (rare; the
  granularity rule prefers per-pattern, so per-method permissions
  produce per-method affordances)
- Hook entry → `<script-basename>-<trigger-lowercase>` (e.g.
  `sync-to-global-cache-stop`)

If two derived names collide (e.g. two unrelated permissions hash
to the same name), the second appends a numeric suffix.

### Idempotency

Running the scanner twice on the same input produces output that
differs only in the date in the heading. Entry order is alphabetical
by derived name. No timestamps inside entries. This makes it safe to
diff successive runs.

### Error handling

- Missing source file → skip silently (not all projects have all
  three).
- Malformed JSON → emit the file path and parse error to stderr,
  exit non-zero so CI can catch.
- `jq` not installed → fail with a clear message: "jq is required
  for /harness-affordance discover. Install via `brew install jq`
  or `apt install jq`."

## Components

| Component | Type | Effort |
| --- | --- | --- |
| `ai-literacy-superpowers/commands/harness-affordance.md` (parent command with subcommand routing; `add` and `review` produce "not yet implemented" pointing at the design spec) | command | XS |
| `ai-literacy-superpowers/scripts/harness-affordance-discover.sh` (the scanner) | bash | M |
| `docs/how-to/discover-affordances.md` (one-page how-to: prerequisites, invocation, reading the output) | docs | XS |
| `CHANGELOG.md` entry under new `## 0.28.0` heading | docs | XS |
| Plugin version bump to `0.28.0` in three locations | meta | XS |

## Dependencies

- **`jq`** — required at runtime for JSON parsing. Documented in
  the how-to and in the script's failure message.
- **CLAUDE.md "Docs Site Review" convention** (already in place):
  the how-to lands in this PR, not as a follow-up.
- **Affordances design spec** (PR #198, on main): defines the
  schema and the discovery-first sequencing this implements.

## Test plan

The scanner is verifiable end-to-end by running it against this
project's own config. Expected output: at minimum, draft entries
for the existing permission patterns in
`.claude/settings.local.json` (gitignored, but present on the
maintainer's machine), the hooks declared there, and any MCP
servers declared in `.mcp.json`.

CI cannot run the scanner against `.claude/settings.local.json`
(the file is gitignored), but the script's `bash -n` syntax check,
`shellcheck` clean run, and dry-run against a fixture file (added
under `tests/fixtures/affordance-discover/` if needed) cover the
core paths.

## Version Impact

- Plugin minor bump: `0.27.0` → `0.28.0`
- Files updated:
  - `ai-literacy-superpowers/.claude-plugin/plugin.json`
  - `.claude-plugin/marketplace.json` (`plugin_version` and
    per-plugin `version`)
  - `README.md` Plugin Version badge
  - `CHANGELOG.md` new heading

## Exemptions

None. Standard feature PR; spec-first satisfied by this file as the
first commit; `/diaboli` code-mode review will run on the
implementation before merge.

## Open Questions

None at spec time — the design decisions were already locked in
PR #198. The `/diaboli` code-mode review will surface any
implementation-level objections that need adjudication.
