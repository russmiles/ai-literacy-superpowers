---
name: harness-affordances-design
description: Design spec for an Affordances section in HARNESS.md that declares the agent's tool inventory (MCP / CLI), the identity each tool runs under, and the audit trail each tool produces — making implicit capability surface a first-class governance concern
date: 2026-04-26
status: draft
---

# Harness Affordances — Design Spec

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

Today the answer to each of those is "you'd have to grep
several config files and reverse-engineer it." That is governance
debt.

The deeper failure mode this enables: **agents executing under shared
or escalated identity without that fact being visible at governance
review time**. A constraint like "all production-affecting actions
require human review" is unenforceable if no one knows which actions
are production-affecting — which depends on which identity executes
them.

## Goals

1. Make the agent's tool inventory **declarative and versioned** in
   `HARNESS.md` alongside Context, Constraints, and Garbage Collection.
2. Surface **Identity** as a first-class field — *whose credentials does
   this tool run under?* — because identity, not transport, is the load-
   bearing governance question.
3. Surface **Audit Trail** as a first-class field — *where would you
   find a record of what the agent did with this tool?* — including the
   honest answer "nowhere" when that is the case.
4. Enable **chained constraints** that reason about the affordance
   inventory ("every tool with `audit-trail: none` must have a
   matching GC capture rule" / "tools running under shared service
   accounts require an extra reviewer").
5. Provide a **guided authoring command** (`/harness-affordance`) that
   matches the existing `/harness-constrain` and `/governance-constrain`
   pattern — interactive, no manual YAML editing required for routine
   declarations.

## Non-Goals

- **Automated discovery** — scanning `~/.claude/settings.json`,
  `.mcp.json`, and shell env to populate the section. Discovery is
  valuable but is a separate workstream; the format must prove itself
  with manual declaration first. (See "Sequencing" below.)
- **Replacing or duplicating Cost Tracking or Model Routing.**
  Affordances declare the tool inventory; cost-tracking and model-
  routing reason about that inventory. Avoid restating per-tool cost
  or model assignments in the affordance entry.
- **Tool capability discovery.** This spec does not catalogue what
  each MCP server *can do* (its method list). It catalogues that the
  agent *can reach* it, under what identity, with what audit trail.
- **Permission enforcement at runtime.** Existing Claude Code
  permission prompts and hooks already handle that. Affordances are
  for governance review, not runtime gating.

## Design

### The Affordance Block in HARNESS.md

A new top-level section, sibling to `## Constraints` and `## Garbage
Collection`:

```markdown
## Affordances

<!-- Each entry declares one tool the agent can invoke. Identity is
     the load-bearing governance question — whose credentials authorise
     the action. Audit Trail's honest answer "none" is itself useful
     governance signal. -->

### gh-cli

- **Mode**: cli
- **Identity**: user-sso (GitHub PAT in $GITHUB_TOKEN)
- **Audit trail**: github-audit (org audit log, 90-day retention,
  admin-only access)
- **Permission**: `Bash(gh *)` (allowlist in `.claude/settings.local.json`)
- **Invoked by**: orchestrator, integration-agent, harness-enforcer
  *(auto-populated)*
- **Last reviewed**: 2026-04-26
- **Constraint references**: spec-first-commit-ordering,
  release-traceability

### honeycomb-mcp

- **Mode**: central-mcp (api.honeycomb.io)
- **Identity**: service-account (HONEYCOMB_API_KEY shared across team)
- **Audit trail**: honeycomb-query-log (per-team, 30-day retention,
  team-admin access)
- **Permission**: `mcp__honeycomb__*` (allowlist in user `~/.claude/settings.json`)
- **Invoked by**: honeycomb-investigator, instrumentation-advisor
  *(auto-populated)*
- **Last reviewed**: 2026-04-26

### shell-write-to-tmp

- **Mode**: cli
- **Identity**: current-user (the human running the Claude Code session)
- **Audit trail**: none
- **Permission**: `Bash(echo *)`, `Bash(touch *)` (allowlist)
- **Invoked by**: harness-gc, observatory-verify *(auto-populated)*
- **Last reviewed**: 2026-04-26
- **Notes**: ephemeral session-local writes; if persistence is required,
  promote to a tracked artefact

### sync-to-global-cache-hook

- **Mode**: hook
- **Identity**: current-user
- **Audit trail**: none (hook stderr, lost at session end)
- **Permission**: configured in `.claude/settings.local.json` `hooks.Stop`
- **Invoked by**: Claude Code runtime (Stop event) *(auto-populated)*
- **Last reviewed**: 2026-04-26
- **Notes**: invokes `rsync` under the current user; rsyncs plugin
  content into `~/.claude/plugins/cache/` after every session

---
```

### Field Schema

| Field | Required | Source | Values |
| --- | --- | --- | --- |
| `Mode` | yes | declared | `local-mcp` / `central-mcp` / `cli` / `hook` |
| `Identity` | yes | declared | `user-sso` / `service-account` / `current-user` / `none` (with optional detail in parens) |
| `Audit trail` | yes | declared | named log/store with retention + access scope, or `none` |
| `Permission` | yes | declared | the matching pattern from `settings.json` / `.claude/settings.local.json` `permissions` allowlist that authorises this affordance at runtime |
| `Invoked by` | yes | **auto-populated** | comma-separated list of agents or commands that invoked this tool, observed at runtime by Claude Code; declared affordances with no observed invocations are flagged by GC |
| `Last reviewed` | yes | declared | YYYY-MM-DD; the date this affordance entry was last validated against reality (Identity correct, Audit trail still works, Permission still in settings) |
| `Constraint references` | optional | declared | constraints in HARNESS.md that depend on this affordance |
| `Notes` | optional | declared | freeform context the schema does not capture |

**Mode values explained:**

- `local-mcp` — MCP server running on the user's machine (local
  process, may call out to remote APIs)
- `central-mcp` — MCP server hosted remotely (e.g. by the tool
  provider)
- `cli` — shell command invoked by the agent (`gh`, `git`, `npx`,
  custom scripts)
- `hook` — Claude Code hook script (PreToolUse, PostToolUse, Stop,
  etc.) registered in `settings.json`. Each hook is its own
  affordance entry; if a hook invokes a CLI internally, the CLI is
  *also* an affordance entry — the hook is the surface the agent
  triggers, the CLI is the underlying capability.

**Identity values explained:**

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
  and writes, local network, `git status`, etc. This is the default
  for most local CLI affordances and is distinct from `none`: a
  `current-user` action is still attributable to a real principal,
  even if there is no remote audit trail.
- `none` — no authentication boundary crossed at all (pure local
  computation, no filesystem effects, no network).

**Audit trail values:**

Free-text but should follow the pattern `<source>: <retention>,
<access scope>`. The honest answer `none` is encouraged and is itself
governance signal — it tells reviewers where the gaps are without
forcing fabrication.

**Permission and the enforcement loop:**

The `Permission` field links each affordance to the corresponding
entry in Claude Code's `permissions` allowlist (in `~/.claude/settings.json`
or project `.claude/settings.local.json`). This pairing makes the
governance loop explicit:

- *Affordances declare what tools the agent should have access to.*
- *Permissions enforce what tools the agent actually has access to.*

A chained constraint can then verify the two are in sync — every
declared affordance has a matching permission, every granted
permission has a matching affordance entry. Affordances without
permissions are dead inventory; permissions without affordances are
ungoverned grants.

**Invoked by — auto-populated, not hand-maintained:**

The `Invoked by` field is populated by Claude Code at runtime, not
edited by hand. Implementation outline (deferred to a separate spec):
a SessionEnd hook records `(tool_name, invoking_agent_or_command)`
tuples for the session; a periodic reconciler (weekly GC) updates the
`Invoked by` list in `HARNESS.md` from the accumulated record. This
keeps the field accurate as the agent ecosystem evolves and prevents
the drift that hand-maintained lists always suffer from.

The trade-off: the affordance section becomes partially machine-
written, which conflicts with the harness principle of "humans own
HARNESS.md." Mitigation: the reconciler only updates the `Invoked by`
sub-line of an existing affordance entry; it never adds, removes, or
modifies any other field. Humans still control which affordances
exist and how they are described.

### Chained Constraints

The new shape this introduces: constraints that reason about the
affordance inventory rather than about code or process. Examples that
become writable once affordances exist:

- *"Every affordance must have a matching `Permission` entry in
  `settings.json` / `.claude/settings.local.json`; every permission
  allowlist entry must have a matching affordance."* — closes the
  declaration-vs-enforcement loop. Deterministic.
- *"Every affordance with `Audit trail: none` must have a matching
  GC rule that captures usage in `observability/`."* — agent-enforced.
- *"Affordances with `Identity: user-sso` may not be invoked by agents
  that also have `Identity: service-account` affordances."* — prevents
  privilege confusion. Deterministic.
- *"Every affordance must show at least one auto-populated `Invoked
  by` consumer within 30 days of declaration; an affordance with no
  observed invocations is dead inventory and should be removed or
  documented as latent."* — GC rule, monthly.
- *"Every affordance's `Last reviewed` date must be within the last 6
  months; stale entries flagged for re-validation."* — GC rule,
  weekly.

These are not implemented in this spec; they are exemplars that
motivate the section's existence.

### The `/harness-affordance` Command

Mirrors the `/harness-constrain` and `/governance-constrain` pattern:

```text
1. Detect or accept tool name (--name flag, or interactive prompt)
2. Ask Mode (with definitions)
3. Ask Identity (with definitions and load-bearing-question framing)
4. Ask Audit Trail (with explicit "none is fine" guidance)
5. Ask Permission — propose the matching pattern from settings.json
   if one exists; warn if no permission entry covers the proposed
   tool (the affordance would be ungranted at runtime)
6. Set Last Reviewed to today's date automatically
7. Skip Invoked By — leave it as a placeholder *(auto-populated by
   runtime reconciler; never authored by hand)*
8. Optional: Constraint References, Notes
9. Validate: no duplicate name; required fields present; mode/identity
   pairing makes sense (warn if `central-mcp` + `none` identity);
   permission pattern actually exists in some settings.json file
10. Append to HARNESS.md `## Affordances` section
11. Suggest next:
    - "Add a constraint that references this affordance?" →
      `/harness-constrain` pre-filled with the affordance name
    - If no Permission entry matched: "Add a permission allowlist
      entry that authorises this affordance?" → guided edit of
      settings.json
```

### Sequencing

1. **This spec.** Get the schema and the chained-constraint pattern
   reviewed before any code lands.
2. **Section + template.** Add `## Affordances` to `templates/HARNESS.md`
   with 3-4 example entries and the schema in comments. Bumps minor.
3. **`/harness-affordance` command.** Guided authoring with a
   permission-pattern proposal step. Bumps minor.
4. **First chained constraint: declaration vs enforcement.** Adopt
   *"Every affordance has a matching `Permission` entry in some
   `settings.json`; every permission allowlist entry has a matching
   affordance entry."* This is the proof-of-concept for the chained-
   constraint pattern and gives the section concrete enforcement
   value from day one.
5. **Last-reviewed staleness GC rule.** *"Every affordance's `Last
   reviewed` date must be within 6 months."* Weekly check.
6. **Auto-population of `Invoked by`.** Separate spec — adds a
   SessionEnd hook that records `(tool, invoker)` tuples and a
   reconciler GC that updates the `Invoked by` line in
   `HARNESS.md`. Includes the human-control mitigation (reconciler
   only touches the `Invoked by` sub-line, never any other field).
7. **`/harness-affordance audit`.** GC rule that compares declared
   affordances against actual settings (`.mcp.json`, hook scripts,
   agent `tools:` frontmatter) and flags drift. Deferred.
8. **Discovery automation.** `/harness-affordance discover` that
   scans config and proposes entries. Deferred until manual format is
   stable.

Each step is a separate PR. Steps 2-5 could ship together as a single
minor version (proposed `0.28.0` once this spec is approved). Step 6
is a meaningful change in how `HARNESS.md` is maintained (machine-
written sub-fields) and warrants its own spec PR before
implementation.

## Components

| Component | Type | Effort | Sequencing step |
| --- | --- | --- | --- |
| `templates/HARNESS.md` `## Affordances` section + comments | template | XS | 2 |
| `commands/harness-affordance.md` | command | S | 3 |
| Update `commands/harness-init.md` to surface affordances during init | command | XS | 2 |
| Update `commands/harness-status.md` to count affordances | command | XS | 2 |
| Update `commands/harness-audit.md` to report affordance count + drift | command | S | 7 |
| Two chained constraints in `templates/HARNESS.md` (declaration-vs-enforcement + last-reviewed staleness) | template | XS | 4-5 |
| Runtime tuple recorder (SessionEnd hook) | hook | M | 6 |
| `Invoked by` reconciler (GC rule with HARNESS.md write access) | hook + GC | M | 6 |
| `docs/explanation/harness-affordances.md` (why this exists) | docs | S | 2 |
| `docs/how-to/declare-an-affordance.md` (using the command) | docs | XS | 3 |
| `docs/reference/affordance-schema.md` (field-by-field reference) | docs | S | 2 |

## Dependencies

- **CLAUDE.md "Docs Site Review" convention** (already in place):
  every plugin behaviour change must come with docs updates in the
  same PR.
- **`/harness-constrain` pattern** (already in place): the new command
  follows the same interaction shape so users do not have to learn a
  new mental model.
- **No new external libraries.** Pure markdown + bash, like the rest
  of the plugin.

## Resolved Design Decisions

The following questions were raised during initial design and resolved
before this spec went to PR. Captured here as a record of *why* the
schema looks the way it does, so future readers do not re-litigate
without context.

1. **Mode retained.** Identity is load-bearing for governance, but
   Mode helps onboarding reviewers categorise the inventory at a
   glance and is cheap to maintain. Both stay in the schema.

2. **Permissions are the enforcement layer; affordances are the
   declaration layer.** Each affordance has a `Permission` field
   linking to the matching pattern in `settings.json` /
   `.claude/settings.local.json`. A chained constraint verifies
   declaration and enforcement match: every affordance has a
   permission, every permission has an affordance. This is the most
   load-bearing design decision in the spec — it gives the section
   a concrete enforcement loop instead of leaving it as documentation
   only.

3. **`Invoked by` is auto-populated, never hand-maintained.** Claude
   Code records `(tool, invoking_agent_or_command)` tuples at runtime
   (likely via a SessionEnd hook) and a periodic reconciler updates
   the `Invoked by` line in HARNESS.md. The reconciler only touches
   the `Invoked by` sub-line of an existing affordance; it never adds,
   removes, or modifies any other field. Humans still own which
   affordances exist; runtime owns which agents actually use them.
   Implementation outline deferred to a follow-up spec.

4. **Hook scripts are first-class affordance entries.** Each hook
   gets its own entry with `Mode: hook`. If a hook invokes a CLI
   internally (e.g. an `rsync` call from a Stop hook), the CLI is
   *also* a separate affordance entry. The hook is the surface the
   agent triggers; the CLI is the underlying capability. Both deserve
   independent governance attention.

5. **`current-user` covers ephemeral local actions; no `intrinsic`
   value needed.** The current user IS the intrinsic identity for
   filesystem reads, `git status`, local network calls, etc. The
   schema uses `current-user` as the value (clearer than the original
   `process-owner` proposal) and leaves `none` for true zero-boundary
   actions like pure local computation.

6. **`Last reviewed` field added per affordance.** Date-stamp every
   entry. Pairs with a GC rule: "all affordances must be re-validated
   within the last 6 months." This catches the failure mode where an
   audit log changes (Honeycomb adds one, GitHub deprecates one) and
   the affordance description silently goes stale.

## Expected Outcome

- A `HARNESS.md` reviewer can answer, in under 30 seconds: "What
  tools does the agent have, whose credentials run them, and where
  would I find an audit trail?"
- A new constraint that says "production-affecting actions require
  human review" becomes meaningfully enforceable, because
  "production-affecting" can be defined as "any affordance with
  `Identity: user-sso` plus a `Constraint references` value of
  `release-traceability`."
- Governance debt around "no audit trail" becomes visible and
  countable rather than buried in config files.
- Template projects that adopt the plugin get an affordance scaffold
  during `/harness-init` and a guided way to populate it.

## Version Impact

If this spec is approved and Sequencing steps 2-4 ship together:

- Minor bump (proposed `0.28.0`)
- New section in `templates/HARNESS.md`
- New command `commands/harness-affordance.md`
- Updates to `commands/harness-init.md`, `commands/harness-status.md`,
  `commands/harness-audit.md`
- New docs pages under `docs/explanation/`, `docs/how-to/`,
  `docs/reference/`
- CHANGELOG entry under new heading

Discovery automation (Sequencing step 6) would be a separate later
minor bump.

## Exemptions

None requested. This is a normal feature spec; the implementation PR(s)
will need spec-mode and code-mode objection records per the standard
adjudicated-objections constraint.

## Intellectual Foundations

- **Capability-based security.** Treating tool affordances as
  declared capabilities — not ambient grants — makes the principle of
  least privilege legible at the governance layer rather than only at
  the runtime layer.
- **Identity-aware computing.** Audit and accountability collapse
  when actions cannot be attributed back to a real principal. The
  `Identity` field forces that question to be answered, not assumed.
- **Honest debt accounting.** Per the harness-engineering tradition,
  the section is most valuable when it lets people record `none` for
  audit trail without flinching. The visibility is the point.
- **Declarative inventory + chained constraints** is the same pattern
  as governance-constraint design (declare the requirement, attach
  enforcement, periodic re-review). The harness already has the
  scaffolding; affordances reuse it rather than invent something new.
