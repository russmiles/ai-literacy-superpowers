---
name: harness-affordances-design
description: Design spec for a discovery-first Affordances section in HARNESS.md that declares the agent's tool inventory (CLI / MCP / hook), the identity each tool runs under, and the audit trail each tool produces — making implicit capability surface a first-class governance concern while preserving HARNESS.md as a 100% human-authored document
date: 2026-04-26
status: draft
---

# Harness Affordances — Design Spec

> **Adjudication trail.** This spec was reviewed via `/diaboli` in
> spec mode; 12 objections raised, 11 accepted, 1 clarified. The full
> objection record with dispositions and rationales is at
> `docs/superpowers/objections/harness-affordances-design.md`. The
> design below is the post-adjudication version. Where a section
> derives directly from a disposition, the relevant objection ID is
> noted.

## Problem

`HARNESS.md` today tells agents three things: what conventions exist
(Context), what must be true (Constraints), and what periodic checks
fight entropy (Garbage Collection). It does not tell anyone — human
or agent — *what tools the agent has been granted, under whose
authority each tool executes, and what record (if any) is left behind
when the agent uses one*.

That information exists somewhere. It is spread across:

- `~/.claude/settings.json` (user-level MCP servers, permissions)
- Project `.claude/settings.local.json` (project-level allowlists,
  hooks)
- Project `.mcp.json` (MCP server declarations)
- Shell environment (`GITHUB_TOKEN`, `HONEYCOMB_API_KEY`, etc.)
- Hook scripts in `ai-literacy-superpowers/hooks/scripts/`
- Agent definitions (`agents/*.agent.md` `tools:` frontmatter)

It is *implicit*. None of those locations are read by humans during
governance review. None of them surface the questions a reviewer
needs to ask:

- When the agent runs `gh pr merge`, whose credentials authorise it?
- When the agent queries Honeycomb via MCP, who owns the API key?
  Where is the query logged?
- When the agent invokes a local MCP that wraps a remote service, is
  the boundary between local execution and remote API call observable?
- If an audit asked "show me everything the agent did this quarter
  under my SSO," could we answer?

### The contractor scenario *(per O1)*

To make the gap concrete: imagine a contractor is brought in for a
two-week engagement to help review the project's AI governance
posture. Their first task is to answer those four questions for the
person who hired them.

Today, here is what that contractor faces:

1. They open `HARNESS.md`. The Constraints section talks about
   `gh pr merge` and Honeycomb queries as actions, but does not say
   what credentials those actions use. The Garbage Collection
   section invokes scripts but does not say who owns them. The
   Context section names the languages but not the tools.
2. They open `~/.claude/settings.json`. They see permission
   patterns like `Bash(gh *)` and `mcp__honeycomb__*`. The patterns
   tell them *what is allowed* but not *under whose authority*.
3. They open `.claude/settings.local.json`. They find hook scripts
   referenced by path. To find out what the hooks actually do, they
   open and read each script. To find out under what identity the
   scripts run, they have to reason about the parent process and the
   shell environment at session start.
4. They open `.mcp.json`. They see server declarations. To find out
   whether each MCP runs locally or hits a remote API under what
   credential, they have to read the server's documentation.
5. They open every `agents/*.agent.md` file and read the `tools:`
   frontmatter to map agents to tools. None of these files mention
   identity or audit trails.

A diligent contractor can complete this exercise in two to four
hours and produce a reasonable inventory. A less-diligent one
produces a wrong inventory, or skips the exercise. *Neither outcome
is the project's fault — the inventory simply does not exist as a
review-facing artefact.* The project's governance review pace is
gated on how thorough the contractor was on day one.

The deeper failure mode this enables: **agents executing under
shared or escalated identity without that fact being visible at
governance review time**. A constraint like "all production-affecting
actions require human review" is unenforceable if no one knows which
actions are production-affecting — which depends on which identity
executes them.

## Goals

1. Make the agent's tool inventory **declarative and versioned** in
   `HARNESS.md` alongside Context, Constraints, and Garbage Collection.
2. Surface **Identity** as a first-class field — *whose credentials
   does this tool run under?* — because identity, not transport, is
   the load-bearing governance question.
3. Surface **Audit Trail** as a first-class field — *where would you
   find a record of what the agent did with this tool?* — including
   the honest answer "nowhere" when that is the case.
4. Enable **chained constraints** that reason about the affordance
   inventory ("every affordance has a matching `Permission` allowlist
   entry" / "tools running under shared service accounts require an
   extra reviewer").
5. Provide a **discovery scanner** that produces a draft inventory
   from existing config files, so existing harness adopters get a
   backfill path on day one and ongoing changes to config are
   surfaced via diff.
6. Provide a **guided annotation command** (`/harness-affordance`)
   that walks humans through filling in the governance-only fields
   the discovery scanner cannot infer — Identity narrative, Audit
   Trail prose, Last Reviewed.
7. Preserve the structural invariant that **HARNESS.md is 100%
   human-authored**. Runtime data and machine-derivable inventory
   live in `observability/` and config files; HARNESS.md is the
   review-facing prose layer that humans own.

## Non-Goals

- **Replacing or duplicating Cost Tracking or Model Routing.**
  Affordances declare the tool inventory; cost-tracking and model-
  routing reason about that inventory. Avoid restating per-tool cost
  or model assignments in the affordance entry.
- **Tool capability discovery.** This spec does not catalogue what
  each MCP server *can do* (its method list). It catalogues that the
  agent *can reach* it, under what identity, with what audit trail.
- **Permission enforcement at runtime.** Existing Claude Code
  permission prompts and hooks already handle that. Affordances are
  for governance review, not runtime gating; the chained constraint
  closes the *declaration vs enforcement* loop, not the runtime
  enforcement itself.
- **Writing into HARNESS.md from any automated tool.** Every other
  harness section is human-authored; the affordance section will be
  too. The discovery scanner produces drafts in a separate
  scratch-file (or stdout); humans copy chosen entries into
  HARNESS.md and add governance metadata. Runtime invocation data
  lives in `observability/affordance-invocations.json`, referenced
  by path from the affordance section header — never inlined.

## Design

### Why a separate section *(per O10)*

The most natural alternative — co-locate Identity and Audit metadata
with the existing per-tool surface (comments next to permission
lines in `settings.local.json`, structured frontmatter on agent
files) — was considered and rejected. The split between machine-
owned source files and human-owned governance metadata is
intentional:

- **Tool surface metadata that machines own** (the permission
  patterns, the MCP server names, the hook script paths, the
  trigger events) already lives in source files and stays there.
  The discovery scanner reads it. There is no value in duplicating
  it into HARNESS.md.
- **Governance metadata that humans own** (Identity-as-narrative,
  Audit Trail prose, Last Reviewed dates, Notes, links to
  Constraints) is review-facing and needs to live where reviewers
  already read, which is HARNESS.md. Splitting governance prose
  across N JSON config files would fragment the reviewer's
  attention — exactly the failure mode the contractor scenario
  describes.

The "humans own HARNESS.md" invariant is the load-bearing
structural property of the harness; co-locating governance prose
with source would violate it the same way an automated reconciler
writing to HARNESS.md would. Both are rejected for the same reason.

### The Affordance Block in HARNESS.md

A new top-level section, sibling to `## Constraints` and `## Garbage
Collection`:

```markdown
## Affordances

<!-- Each entry declares one tool the agent can invoke. Identity is
     the load-bearing governance question — whose credentials authorise
     the action. Audit Trail's honest answer "none" is itself useful
     governance signal.

     Runtime invocation data (which agent invoked which tool, when,
     how often) lives in observability/affordance-invocations.json
     and is referenced — not inlined — here. HARNESS.md remains
     entirely human-authored.

     The discovery scanner (run via /harness-affordance discover)
     produces a draft inventory from existing config files. Humans
     paste chosen entries here and add the governance-only fields
     (Identity narrative, Audit Trail prose, Last Reviewed). -->

<!-- Runtime invocation data: observability/affordance-invocations.json -->

### gh-cli

- **Mode**: cli
- **Identity**: runtime-resolved
- **Audit trail**: github-audit (org audit log, 90-day retention,
  admin-only access) — assumes credentials resolve to a real GitHub
  identity; if `$GITHUB_TOKEN` resolves to a service account the
  audit trail will record that account, not the user
- **Permission**: `Bash(gh *)` (allowlist in
  `.claude/settings.local.json`)
- **Last reviewed**: 2026-04-26
- **Constraint references**: spec-first-commit-ordering,
  release-traceability
- **Notes**: `gh` resolves credentials in this order:
  `$GITHUB_TOKEN` → keychain (`gh auth login`) → fail. The
  reviewer should confirm which path is active in the session
  configuration before relying on this entry.

### honeycomb-mcp

- **Mode**: central-mcp (api.honeycomb.io)
- **Identity**: service-account (HONEYCOMB_API_KEY shared across team)
- **Audit trail**: honeycomb-query-log (per-team, 30-day retention,
  team-admin access)
- **Permission**: `mcp__honeycomb__*` (allowlist in user
  `~/.claude/settings.json`)
- **Last reviewed**: 2026-04-26

### shell-write-to-tmp

- **Mode**: cli
- **Identity**: current-user (the human running the Claude Code
  session)
- **Audit trail**: none
- **Permission**: `Bash(echo *)`, `Bash(touch *)` (allowlist)
- **Last reviewed**: 2026-04-26
- **Notes**: ephemeral session-local writes; if persistence is
  required, promote to a tracked artefact

### sync-to-global-cache-hook

- **Mode**: hook
- **Trigger**: Stop
- **Identity**: current-user
- **Audit trail**: none (hook stderr, lost at session end)
- **Permission**: `hooks.Stop` entry in
  `.claude/settings.local.json` invoking
  `ai-literacy-superpowers/scripts/sync-to-global-cache.sh`
- **Last reviewed**: 2026-04-26
- **Notes**: invokes `rsync` under the current user; rsyncs plugin
  content into `~/.claude/plugins/cache/` after every session

---
```

### Field Schema

| Field | Required | Source | Values |
| --- | --- | --- | --- |
| `Mode` | yes | declared (machine-derivable) | `local-mcp` / `central-mcp` / `cli` / `hook` |
| `Trigger` | yes for `Mode: hook`; absent otherwise | declared (machine-derivable) | one of the Claude Code hook events: `PreToolUse` / `PostToolUse` / `Stop` / `SubagentStop` / `SessionStart` / `SessionEnd` / `UserPromptSubmit` / `PreCompact` / `Notification` |
| `Identity` | yes | declared (human-owned) | `user-sso` / `service-account` / `current-user` / `runtime-resolved` / `none` (with optional detail in parens) |
| `Audit trail` | yes | declared (human-owned) | named log/store with retention + access scope, or `none` |
| `Permission` | yes | declared (machine-derivable) | the permission pattern from `settings.json` / `.claude/settings.local.json` allowlist that authorises this affordance |
| `Last reviewed` | yes | declared (procedure-controlled) | YYYY-MM-DD; bumped only by `/harness-affordance review <name>` after the three re-validation checks pass (see below) |
| `Constraint references` | optional | declared (human-owned) | constraints in HARNESS.md that depend on this affordance |
| `Notes` | optional | declared (human-owned) | freeform context the schema does not capture |

**Granularity rule — one affordance per permission pattern** *(per O4)*:

The unit of an affordance is one entry in the permissions allowlist.
`Bash(gh *)` is one affordance. `Bash(gh pr *)` is a separate,
narrower affordance. An MCP server with twenty methods exposed under
`mcp__server__*` is one affordance, not twenty. Same CLI used under
two different identities in different sessions is one entry with the
runtime ambiguity flagged in Notes (or declared with
`Identity: runtime-resolved`).

This makes the chained-constraint matching relation trivially
deterministic — no subset reasoning, no wildcard expansion.

**Matching algorithm — string equality** *(per O5)*:

When the chained constraint compares affordances against
permissions, "matching" means string equality on the permission
pattern. A permission entry `Bash(gh pr *)` matches the affordance
entry whose `Permission` field is `Bash(gh pr *)` and no other.
Broader patterns subsume narrower invocations rather than producing
separate affordance entries — an action like `gh pr merge`
authorised by a `Bash(gh *)` permission is recorded against the
single broader-pattern affordance, not as a separate narrower one.

**Mode values explained:**

- `local-mcp` — MCP server running on the user's machine (local
  process, may call out to remote APIs)
- `central-mcp` — MCP server hosted remotely (e.g. by the tool
  provider)
- `cli` — shell command invoked by the agent (`gh`, `git`, `npx`,
  custom scripts)
- `hook` — Claude Code hook script registered in `settings.json`.
  Each hook is its own affordance entry; if a hook invokes a CLI
  internally, the CLI is *also* an affordance entry — the hook is
  the surface the agent triggers, the CLI is the underlying
  capability. The `Trigger` field disambiguates a script wired to
  multiple events.

**Identity values explained** *(per O7)*:

- `user-sso` — uses the human user's *external* SSO credentials
  (their GitHub PAT, their Slack token, their cloud SSO). Actions
  appear in remote audit logs as if the user did them. **Highest-
  attribution failure mode.**
- `service-account` — uses dedicated bot credentials shared across
  the team or pinned to the project (CI tokens, shared API keys).
  Actions appear in audit logs as the service account; per-user
  attribution is lost.
- `current-user` — the human running the Claude Code session, with
  no special credentials and no boundary crossing. Filesystem reads
  and writes, local network, `git status`, etc. Distinct from
  `none`: a `current-user` action is still attributable to a real
  principal, even if there is no remote audit trail.
- `runtime-resolved` — identity depends on session configuration
  (env vars, profile selection, IAM role assumption). The Notes
  field MUST document the resolution chain. Chained constraints
  treat `runtime-resolved` as a known unknown — they may flag it
  for human review rather than deterministically pass or fail.
  Examples: `gh` (env → keychain), `aws` (env → profile → IAM
  role), `kubectl` (kubeconfig context → in-cluster service
  account).
- `none` — no authentication boundary crossed at all (pure local
  computation, no filesystem effects, no network).

**Audit trail values:**

Free-text but should follow the pattern `<source>: <retention>,
<access scope>`. The honest answer `none` is encouraged and is
itself governance signal — it tells reviewers where the gaps are
without forcing fabrication.

**Permission and the enforcement loop:**

The `Permission` field links each affordance to the corresponding
entry in Claude Code's `permissions` allowlist. This pairing makes
the governance loop explicit:

- *Affordances declare what tools the agent should have access to.*
- *Permissions enforce what tools the agent actually has access to.*

Two chained constraints verify the pairing; see Chained Constraints
below.

**Re-validation procedure** *(per O11)*:

`Last reviewed` is bumped only by `/harness-affordance review
<name>`, which walks through three concrete checks interactively:

1. **Identity check.** The Identity claim still matches reality.
   For `runtime-resolved`, the resolution chain has not changed.
   For fixed identity values, the named credential still exists
   and still belongs to the named principal.
2. **Audit Trail check.** The audit log endpoint exists, retention
   matches what is stated, access scope holds. For `none`, confirm
   no audit log has been added since last review.
3. **Permission check.** The recorded permission pattern is still
   present in `settings.json` (or the relevant settings layer).

Editing other fields — Notes, Constraint references — does *not*
bump Last Reviewed. This separates re-validation from routine
editing and prevents the staleness GC rule from degenerating into
a `git log` mtime check.

### Chained Constraints

The new shape this section introduces: constraints that reason about
the affordance inventory rather than about code or process.

The two load-bearing constraints — different severities, asymmetric
treatment per O9 — are:

- **Affordance-without-permission (blocking).** Every affordance in
  HARNESS.md must have a matching `Permission` entry in
  `settings.json` or `.claude/settings.local.json`. An affordance
  that lacks a permission means the agent has declared a tool it
  cannot actually invoke — likely either the permission was removed
  without reviewing the affordance, or the affordance was declared
  without authorising it. Both are real safety concerns.
  *Deterministic, blocking.*
- **Permission-without-affordance (advisory).** Every entry in the
  permissions allowlist should have a matching affordance. A
  permission without an affordance is paperwork debt — the grant
  exists, the governance metadata is missing. Optionally enforce a
  30-day deadline to either declare an affordance or revoke the
  permission. *Deterministic, advisory.*

Other examples that become writable once affordances exist:

- *"Every affordance with `Audit trail: none` must be declared in
  the project's REFLECTION_LOG within 30 days, or be linked to a
  GC rule that captures usage in `observability/`."* —
  agent-enforced.
- *"Affordances with `Identity: user-sso` may not be invoked by
  agents that also have `Identity: service-account` affordances."*
  — prevents privilege confusion. Deterministic.
- *"No `Mode: hook` affordance with `Trigger: PreToolUse` may have
  `Audit trail: none`."* — pre-tool hooks affect every tool
  invocation; auditless ones are too dangerous to ship without
  governance attention.
- *"Every affordance's `Last reviewed` date must be within the last
  6 months; stale entries flagged for re-validation via
  `/harness-affordance review`."* — GC rule, weekly.
- *"The runtime invocation file
  `observability/affordance-invocations.json` must be no more than
  N days stale."* — proxy for whether the runtime tuple recorder is
  operational.

These are not implemented in this spec; they are exemplars that
motivate the section's existence.

### The `/harness-affordance` command

Mirrors the `/harness-constrain` and `/governance-constrain`
pattern. Three subcommands: `discover`, `add`, `review`.

**`/harness-affordance discover`** — produces a draft affordance
inventory from existing config:

```text
1. Read all four sources: ~/.claude/settings.json,
   .claude/settings.local.json, .mcp.json, agent frontmatter
   (tools: lists), and hook scripts
2. For each permission pattern, hook trigger entry, and MCP
   server declaration: emit a draft affordance entry with Mode,
   Trigger (where applicable), Permission, and a *placeholder*
   for the human-owned fields (Identity, Audit Trail, Notes)
3. Write the draft to a scratch file (e.g.
   .claude/affordance-discovery-<date>.md), NOT to HARNESS.md
4. Diff against the current ## Affordances section in HARNESS.md
   if one exists; flag new permissions (would add an entry),
   removed permissions (would remove an entry), and unchanged
   ones
5. Suggest: "Run /harness-affordance add <name> to copy a draft
   entry into HARNESS.md and fill in governance metadata"
```

**`/harness-affordance add <name>`** — guided annotation:

```text
1. If a draft entry exists in the discovery scratch file, use it
   as the starting point; otherwise prompt for Mode, Trigger
   (if Mode=hook), and Permission
2. Ask Identity (with five-value definitions and load-bearing-
   question framing); for runtime-resolved, prompt for the
   resolution chain narrative
3. Ask Audit Trail (with explicit "none is fine" guidance)
4. Set Last Reviewed to today's date automatically
5. Optional: Constraint References, Notes
6. Validate: no duplicate name; required fields present; mode/
   trigger pairing valid (Trigger only for Mode=hook); permission
   pattern actually exists in some settings.json file
7. Append to HARNESS.md ## Affordances section
8. Suggest: "Add a constraint that references this affordance?"
   → /harness-constrain pre-filled with the affordance name
```

**`/harness-affordance review <name>`** — re-validation:

```text
1. Walk the user through the three re-validation checks
   (Identity, Audit Trail, Permission); prompt for each:
   "still correct?" → yes/no/needs-edit
2. For any "needs-edit" answer, open the field for inline edit
3. If all three pass, bump Last Reviewed to today's date
4. If any check fails the user cannot fix in-session, leave
   Last Reviewed unchanged and add a Notes line describing the
   gap (so the staleness GC rule continues to fire)
```

### Sequencing *(restructured per O2 and O8)*

1. **This spec.** Get the schema, the chained-constraint pattern,
   and the discovery-first architecture reviewed before any code
   lands.
2. **Discovery scanner — `/harness-affordance discover`.** Reads
   existing config, emits draft inventory to a scratch file. This
   is also the **backfill path for existing harness adopters** — a
   project with a populated `.claude/settings.local.json` runs the
   scanner once and gets a draft for every existing permission.
   Bumps minor.
3. **Section + template + annotation command.** Add `## Affordances`
   to `templates/HARNESS.md` with comments and the schema; ship
   `/harness-affordance add` for guided annotation. Bumps minor.
4. **First chained constraint: affordance-without-permission
   (blocking).** Adopt the asymmetric pair (per O9). Ships
   `unverified` until the project has run discovery + annotation
   at least once; then graduates to `deterministic`. Bumps minor.
5. **Second chained constraint: permission-without-affordance
   (advisory).** Same pattern, advisory severity, optional 30-day
   deadline.
6. **Re-validation command — `/harness-affordance review`.** Plus
   the staleness GC rule keying on Last Reviewed dates.
7. **Runtime tuple recorder.** *Separate spec, separate PR.* Adds
   a SessionEnd hook that writes
   `observability/affordance-invocations.json`; HARNESS.md is
   never written by this mechanism. The chained constraint that
   keys on the file's freshness ships in the same PR.
8. **Discovery automation in CI.** Adds a GC rule that runs
   `/harness-affordance discover` and fails if any new draft
   entries exist that have not been promoted to HARNESS.md.

Steps 2-6 could ship together as a single minor version bump
(proposed `0.28.0` once this spec is approved); steps 7 and 8 each
warrant their own spec.

## Components

| Component | Type | Effort | Sequencing step |
| --- | --- | --- | --- |
| `templates/HARNESS.md` `## Affordances` section + comments | template | XS | 3 |
| `commands/harness-affordance.md` (`discover` / `add` / `review` subcommands) | command | M | 2-6 |
| Discovery scanner script (reads settings.json, .mcp.json, agent frontmatter, hook configs) | bash | M | 2 |
| Update `commands/harness-init.md` to surface affordances during init | command | XS | 3 |
| Update `commands/harness-status.md` to count affordances | command | XS | 3 |
| Update `commands/harness-audit.md` to report affordance count + drift via discovery diff | command | S | 8 |
| Two chained constraints in `templates/HARNESS.md` (asymmetric: blocking + advisory) | template | XS | 4-5 |
| One staleness GC rule in `templates/HARNESS.md` (keyed on Last Reviewed) | template | XS | 6 |
| `docs/explanation/harness-affordances.md` (why this exists, the contractor scenario, the source-of-truth split) | docs | S | 3 |
| `docs/how-to/declare-an-affordance.md` (using the three subcommands) | docs | XS | 3 |
| `docs/reference/affordance-schema.md` (field-by-field reference) | docs | S | 3 |

Notably absent from this spec's components (deferred to step 7's
separate spec): the runtime tuple recorder hook, any reconciler that
writes into HARNESS.md, and the `Invoked by` field that previously
required them.

## Dependencies

- **CLAUDE.md "Docs Site Review" convention** (already in place):
  every plugin behaviour change must come with docs updates in the
  same PR.
- **`/harness-constrain` pattern** (already in place): the new
  command follows the same interaction shape so users do not have
  to learn a new mental model.
- **No new external libraries.** Pure markdown + bash, like the
  rest of the plugin.

## Resolved Design Decisions

The following were resolved during initial design discussion or via
the `/diaboli` adjudication trail. Captured here as a record of
*why* the schema looks the way it does, so future readers do not
re-litigate without context.

1. **Mode retained.** Identity is load-bearing for governance, but
   Mode helps onboarding reviewers categorise the inventory at a
   glance and is cheap to maintain. Both stay in the schema.

2. **Permissions are the enforcement layer; affordances are the
   declaration layer.** Each affordance has a `Permission` field
   linking to the matching pattern in settings.json. Two chained
   constraints verify declaration and enforcement match — the
   asymmetric pair per Decision 11 below.

3. **Hook scripts are first-class affordance entries, with
   `Trigger`** *(per O12)*. Each hook gets its own entry with
   `Mode: hook` and a required `Trigger` field naming the Claude
   Code event. A single script wired to two events is two
   affordance entries differentiated by Trigger. If a hook invokes
   a CLI internally, the CLI is *also* a separate affordance.

4. **`current-user` covers ephemeral local actions.** No `intrinsic`
   value is needed; the current user IS the intrinsic identity for
   filesystem reads, `git status`, local network calls, etc.

5. **`Last reviewed` field added per affordance, with a defined
   re-validation procedure** *(per O11)*. Three checks (Identity,
   Audit Trail, Permission) all pass before Last Reviewed bumps;
   only `/harness-affordance review` bumps the date.

6. **A contractor scenario grounds the Problem** *(per O1)*. The
   gap is concrete enough for a reader who has never run a
   governance review on this codebase.

7. **Discovery-first sequencing** *(per O2)*. Affordances are
   observed artefacts, not authored ones — the inventory should
   come from a scanner reading existing config; humans annotate
   the draft with governance-only fields. Manual-first would have
   incurred design cost twice (once for the manual schema, again
   when discovery forced changes).

8. **Runtime data lives in `observability/`, not in HARNESS.md**
   *(per O3)*. The `Invoked by` field is removed from the schema;
   runtime invocation tuples live in
   `observability/affordance-invocations.json`, referenced by path
   from the affordance section header. HARNESS.md remains 100%
   human-authored as a structural invariant, not a behavioural
   convention.

9. **Granularity rule: one affordance per permission pattern**
   *(per O4)*. `Bash(gh *)` is one affordance, `Bash(gh pr *)` is
   another. Same-CLI-different-identity is one entry with
   `Identity: runtime-resolved` and a Notes field explaining the
   resolution chain.

10. **Matching algorithm: string equality on permission pattern**
    *(per O5)*. Broader patterns subsume narrower invocations
    rather than producing separate entries. No subset reasoning,
    no wildcard expansion.

11. **Chained constraints are split asymmetrically** *(per O9)*.
    Affordance-without-permission is blocking (real safety
    concern); permission-without-affordance is advisory (paperwork
    debt). Two constraints, two severities.

12. **Five Identity values** *(per O7)*. `user-sso` /
    `service-account` / `current-user` / `runtime-resolved` /
    `none`. The `runtime-resolved` value handles tools whose
    identity depends on session config (gh, aws, kubectl).

13. **Discovery scanner is the backfill path** *(per O8)*.
    Existing harness adopters get a draft inventory the moment
    they run `/harness-affordance discover`. The chained
    constraints ship `unverified` until the first review pass
    completes.

14. **The split between machine-owned source files and
    human-owned governance metadata is intentional** *(per O10)*.
    Tool surface metadata stays in source files (the discovery
    scanner reads it); governance metadata lives in HARNESS.md
    where reviewers already look. Co-locating governance prose
    with source would fragment reviewer attention.

## Expected Outcome

- A `HARNESS.md` reviewer can answer, in under 30 seconds: "What
  tools does the agent have, whose credentials run them, and where
  would I find an audit trail?"
- The contractor scenario from the Problem section becomes a 30-
  minute exercise instead of a four-hour one — the contractor reads
  one section instead of grepping six file types.
- A new constraint that says "production-affecting actions require
  human review" becomes meaningfully enforceable, because
  "production-affecting" can be defined as "any affordance with
  `Identity: user-sso` plus a `Constraint references` value of
  `release-traceability`."
- Governance debt around "no audit trail" becomes visible and
  countable rather than buried in config files.
- Existing harness adopters get a backfill path on day one
  (`/harness-affordance discover` produces a draft from current
  config); new adopters get the same scaffold via `/harness-init`.

## Version Impact

If this spec is approved and Sequencing steps 2-6 ship together:

- Minor bump (proposed `0.28.0`)
- New section in `templates/HARNESS.md`
- New command `commands/harness-affordance.md` with three
  subcommands
- New discovery scanner bash script under `scripts/`
- Updates to `commands/harness-init.md`, `commands/harness-status.md`
- Two new chained constraints + one staleness GC rule in
  `templates/HARNESS.md`
- New docs pages under `docs/explanation/`, `docs/how-to/`,
  `docs/reference/`
- CHANGELOG entry under new heading

Steps 7 (runtime tuple recorder) and 8 (discovery-in-CI) each
warrant their own spec PR with their own version bumps.

## Exemptions

None requested. This is a normal feature spec; the implementation
PR(s) will need spec-mode and code-mode objection records per the
standard adjudicated-objections constraint.

## Intellectual Foundations

- **Capability-based security.** Treating tool affordances as
  declared capabilities — not ambient grants — makes the principle
  of least privilege legible at the governance layer rather than
  only at the runtime layer.
- **Identity-aware computing.** Audit and accountability collapse
  when actions cannot be attributed back to a real principal. The
  `Identity` field forces that question to be answered, not assumed.
- **Source-of-truth normalisation.** Each piece of data has one
  authoritative location. Tool surface metadata lives in source
  files (the discovery scanner reads it from there); governance
  metadata lives in HARNESS.md (humans write it there). The two
  layers compose via the discovery scanner; neither duplicates the
  other.
- **Honest debt accounting.** Per the harness-engineering
  tradition, the section is most valuable when it lets people
  record `none` for audit trail without flinching. The visibility
  is the point.
- **Declarative inventory + chained constraints** is the same
  pattern as governance-constraint design (declare the requirement,
  attach enforcement, periodic re-review). The harness already has
  the scaffolding; affordances reuse it rather than invent
  something new.
