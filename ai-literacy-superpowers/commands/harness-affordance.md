---
name: harness-affordance
description: Manage the project's affordance inventory — declared tools the agent can invoke, the identity each tool runs under, and the audit trail each tool produces. Subcommands - discover (scan config to produce a draft inventory), add (planned), review (planned). See docs/superpowers/specs/2026-04-26-harness-affordances-design.md for the design.
---

# /harness-affordance \<subcommand\> [args...]

Manage the project's affordance inventory — the declared tools the
agent can invoke, with their identity, audit trail, and permission
allowlist links.

## Subcommands

### `discover`

Scan the project's config (`.claude/settings.json`,
`.claude/settings.local.json`, `.mcp.json`) and emit a draft
affordance inventory to a scratch file at
`.claude/affordance-discovery-<date>.md`.

The scanner does not touch `HARNESS.md`. After review, the human
copies approved entries into the `## Affordances` section by hand
(or, in a future release, via `/harness-affordance add <name>`),
filling in the human-owned governance fields (Identity, Audit
trail, Notes).

This is the **backfill path** for projects that adopted the harness
before the affordances section shipped — running `discover` once
produces a draft for every existing permission, hook, and MCP
server.

### Process

1. **Verify prerequisites.** `jq` must be installed. If missing,
   the script aborts with a clear install hint. Verify the project
   directory contains at least one of `.claude/settings.json`,
   `.claude/settings.local.json`, or `.mcp.json`. If none exist,
   tell the user: "No project config found to scan — nothing to
   discover."
2. **Invoke the scanner.** Run
   `bash ${CLAUDE_PLUGIN_ROOT}/scripts/harness-affordance-discover.sh`
   from the project root. The script is responsible for reading
   sources, deriving entries, and writing the output file.
3. **Report.** Print to the user:
   - Output file path
   - Count of draft entries by Mode (`cli` / `local-mcp` /
     `central-mcp` / `hook`)
   - Any warnings the scanner emitted (e.g. MCP server declared
     without a matching permission entry)
   - Suggested next step: "Review the draft, then copy approved
     entries to HARNESS.md under `## Affordances`. Each entry needs
     **Identity** and **Audit trail** filled in (the scanner only
     supplies the machine-derivable fields)."

### `add` *(not yet implemented)*

Planned for sequencing step 3. Will guide annotation of a draft
entry — prompts for Identity, Audit trail, optional Notes, then
appends the completed entry to `HARNESS.md`.

If invoked today, tell the user: "`/harness-affordance add` is not
yet implemented (sequencing step 3 of the affordances design). For
now, copy entries from the discovery output to HARNESS.md by hand
and fill in Identity and Audit trail. See
`docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
for the design."

### `review` *(not yet implemented)*

Planned for sequencing step 6. Will walk through the three
re-validation checks (Identity, Audit trail, Permission) and bump
`Last reviewed` if all pass.

If invoked today, tell the user: "`/harness-affordance review` is
not yet implemented (sequencing step 6 of the affordances design).
For now, hand-edit `Last reviewed` after manually re-validating
the three checks listed in the design spec."

## Routing

If invoked without a subcommand, print the list of available
subcommands and a one-line summary of each. Do not assume a
default.

If invoked with an unknown subcommand, list the supported
subcommands and exit. Do not silently proceed.
