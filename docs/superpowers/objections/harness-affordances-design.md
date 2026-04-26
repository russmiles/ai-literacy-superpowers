---
spec: docs/superpowers/specs/2026-04-26-harness-affordances-design.md
date: 2026-04-26
mode: spec
diaboli_model: claude-opus-4-7
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The spec asserts that no existing location surfaces tool/identity/audit information, but does not show that practitioners actually fail the governance task today; the gap is asserted, not demonstrated."
    evidence: "Spec lines 30-44: 'None of those locations are read by humans during governance review. None of them surface the questions a reviewer needs to ask...' and 'Today the answer to each of those is \"you'd have to grep several config files and reverse-engineer it.\" That is governance debt.'"
    disposition: accept
    disposition_rationale: "Spec will add a concrete contractor scenario as justification — a walkthrough of what a non-veteran reviewer (e.g. a contractor or new team member with limited project knowledge) faces when asked to answer the four reviewer questions today. This grounds the premise in a recognisable failure mode without requiring an actual logged incident."
  - id: O2
    category: alternatives
    severity: high
    claim: "A single garbage-collection rule that scans existing config files (settings.json, .mcp.json, hook scripts, agent frontmatter) and emits a generated read-only inventory would deliver the same governance visibility without introducing a hand-maintained fourth top-level section, a new command, a runtime tuple recorder, and a HARNESS-writing reconciler."
    evidence: "Spec lines 73-77 explicitly defer 'Automated discovery' as a 'separate workstream', and lines 327-340 enumerate at least seven artefacts (template section, command, hook, reconciler, three docs pages, audit updates) the manual-first path commits to. The discovery alternative is acknowledged but not weighed against the manual-first cost."
    disposition: accept
    disposition_rationale: "Spec will be restructured to ship the discovery scanner first, producing a draft inventory generated from existing config (settings.json, .mcp.json, hook scripts, agent frontmatter). Humans then annotate that draft with the governance-only fields that configs do not supply (Identity, Audit Trail, Last Reviewed). This addresses the design inversion: the inventory is observed, not authored; only the governance metadata is authored. Sequencing in the spec flips accordingly — discovery becomes step 2, manual annotation step 3, command and chained constraints later. Non-Goals section will be updated to remove the 'discovery is a separate workstream' framing."
  - id: O3
    category: implementation
    severity: high
    claim: "The 'Invoked by' auto-population mechanism violates a principle the spec itself names — 'humans own HARNESS.md' — and the proposed mitigation (the reconciler only edits one sub-line) is a convention, not a structural guarantee; nothing in markdown prevents a future refactor of the reconciler from over-writing more."
    evidence: "Spec lines 231-236: 'The trade-off: the affordance section becomes partially machine-written, which conflicts with the harness principle of \"humans own HARNESS.md.\" Mitigation: the reconciler only updates the Invoked by sub-line of an existing affordance entry; it never adds, removes, or modifies any other field.'"
    disposition: accept
    disposition_rationale: "Spec restructured to enforce the invariant structurally: runtime data lives in observability/ (e.g. observability/affordance-invocations.json), declared inventory lives in HARNESS.md, and discovery scanning bridges the two. HARNESS.md remains 100% human-authored. The Invoked-by field is removed from the schema; instead, the section header references the runtime invocations file by path, and a chained constraint can join the two at audit time. Combined with O2, the architecture becomes: discovery scanner reads config + observability/ → produces draft inventory → humans annotate with governance metadata → HARNESS.md never written by a tool."
  - id: O4
    category: specification quality
    severity: high
    claim: "The schema does not define what counts as 'one' affordance, so two reviewers given the same tool surface will produce different entries. The hook-plus-CLI rule (lines 386-388) shows the spec is aware of the granularity problem but resolves it for one case only."
    evidence: "Spec lines 175-178 say each hook is its own entry AND the CLI it invokes is its own entry. But the schema gives no rule for: a single CLI run under two identities (e.g. `gh` with PAT vs `gh` after `gh auth switch`); a wildcard MCP method set; an MCP server that fronts multiple remote APIs. The 'Resolved Design Decisions' section (lines 353-402) does not address granularity beyond the hook case."
    disposition: accept
    disposition_rationale: "Adopt rule (a): **one affordance per permission pattern**. `Bash(gh *)` is one affordance; `Bash(gh pr *)` is a separate (narrower) affordance. MCP server with N tools = one affordance per `mcp__server__*` pattern, not per method. The discovery scanner produces the inventory grouped by permission entries, which makes the chained constraint's 'matching' relation trivially deterministic — it becomes identity, not subset or wildcard reasoning. Same-CLI-different-identity (the `gh` with `$GITHUB_TOKEN` vs keychain case) is treated as one affordance entry with the runtime ambiguity flagged in Notes (and addressed structurally by O7's resolution)."
  - id: O5
    category: specification quality
    severity: high
    claim: "The 'Permission' field's matching rule is under-specified. A real settings.json contains overlapping wildcards (e.g. `Bash(*)`, `Bash(gh *)`, `Bash(gh pr *)`); the spec does not say which match the affordance entry should record, nor what the chained constraint should treat as 'matching'."
    evidence: "Spec line 159 defines Permission as 'the matching pattern from settings.json / .claude/settings.local.json permissions allowlist that authorises this affordance at runtime' and lines 217-219 promise a constraint that 'every declared affordance has a matching permission, every granted permission has a matching affordance entry' — but 'matching' is not defined for overlapping or hierarchical patterns."
    disposition: accept
    disposition_rationale: "Resolved as a corollary of O4. Once 'one affordance per permission pattern' is the granularity rule, 'matching' becomes string equality on the permission pattern — no subset or wildcard reasoning needed. Broader patterns subsume narrower invocations rather than producing separate affordance entries; an action like `gh pr merge` authorised by a `Bash(gh *)` permission is recorded against the single broader-pattern affordance, not as a separate narrower one. The chained constraint becomes: 'For every entry in the Permission allowlist, there exists exactly one Affordance entry whose Permission field equals that pattern, and vice versa.' Trivially deterministic. Spec will state this matching algorithm explicitly."
  - id: O6
    category: scope
    severity: high
    claim: "Sequencing step 6 (runtime tuple recorder + reconciler with HARNESS write access) is the riskiest piece of work in the spec — it touches a session hook, a periodic GC writer, and the harness-edits-itself boundary — yet the spec defers its design to a future spec while still listing it as a Component (M effort) in the current one and using it to motivate the 'Invoked by' field's existence."
    evidence: "Spec lines 222-230 outline the mechanism in two sentences and defer it to 'a separate spec'; the Components table (lines 336-337) lists 'Runtime tuple recorder (SessionEnd hook)' and 'Invoked by reconciler (GC rule with HARNESS.md write access)' as M effort; the Sequencing section (line 311) states step 6 'warrants its own spec PR before implementation.'"
    disposition: accept
    disposition_rationale: "Dissolves once O3 is accepted. With the Invoked-by field removed from the schema and runtime data relocated to observability/affordance-invocations.json, there is no required field with no source. The runtime tuple recorder becomes a clean follow-on spec producing an observability/ artefact — completely separable from this spec's scope. The chained constraint that previously depended on Invoked-by becomes 'is the observability/affordance-invocations.json file fresh?' — sourced from observability/, not from HARNESS.md. Components table entries for the runtime recorder and reconciler are removed from this spec."
  - id: O7
    category: premise
    severity: medium
    claim: "The 'Identity' framing assumes a sharp boundary between user-sso, service-account, current-user, and none, but in practice the boundary is often a runtime configuration choice (e.g. `gh` reads `GITHUB_TOKEN` if set, otherwise falls back to keychain). A static declaration in HARNESS.md will be wrong some non-trivial fraction of the time."
    evidence: "Spec lines 180-196 enumerate four identity values as if they are mutually exclusive properties of the tool. The example entry for `gh-cli` (lines 103-106) hard-codes `user-sso (GitHub PAT in $GITHUB_TOKEN)` as if this is a tool property, not a session-environment property."
    disposition: accept
    disposition_rationale: "Add a fifth Identity value `runtime-resolved` meaning 'depends on session configuration; see Notes for the resolution order'. This matches the project's honesty-encouraged pattern (where 'Audit trail: none' is welcomed). For tools like `gh`, `aws`, and `kubectl` the entry will read `Identity: runtime-resolved` with Notes documenting the precedence chain (env var → profile → keychain → IAM role). Chained constraints that key on Identity treat `runtime-resolved` as a known unknown — they may flag it for human review rather than deterministically passing or failing. Five-value schema (user-sso, service-account, current-user, runtime-resolved, none) replaces the four-value schema in Field Schema and Resolved Design Decisions."
  - id: O8
    category: scope
    severity: medium
    claim: "The spec proposes that template projects adopt the affordance scaffold during /harness-init (line 416) but does not address backfill for existing harness adopters; without an opinionated backfill path, the section will exist in new projects and be empty in every project that adopted the harness before this version."
    evidence: "Spec line 416: 'Template projects that adopt the plugin get an affordance scaffold during /harness-init and a guided way to populate it.' Sequencing steps 2-8 describe forward additions; no step describes how existing HARNESS.md files acquire the section, who owns the backfill, or what the chained constraint behaves like in projects that have not yet declared a single affordance."
    disposition: accept
    disposition_rationale: "Resolved by O2's flip to discovery-first. The discovery scanner IS the backfill path — any existing project gets a draft affordance inventory the moment the scanner runs against its existing config. The chained constraint ships as `unverified` until the first discovery + human-annotation pass completes, then graduates to `agent` or `deterministic`. This matches the existing harness pattern where new constraints start unverified and graduate via /harness-constrain. Spec will state this explicitly in the Sequencing section."
  - id: O9
    category: risk
    severity: medium
    claim: "The chained constraint 'every permission allowlist entry must have a matching affordance' (line 218) creates a one-way ratchet that punishes the safer state: if a project has a tightly scoped permission allowlist with twelve entries and only three declared affordances, the constraint fails even though the runtime grants are well-governed. The natural human response is to either delete permissions or fabricate affordance entries, both worse than the status quo."
    evidence: "Spec lines 217-219: 'every declared affordance has a matching permission, every granted permission has a matching affordance entry. Affordances without permissions are dead inventory; permissions without affordances are ungoverned grants.' The framing treats both directions as symmetrically bad; this is asserted, not argued."
    disposition: accept
    disposition_rationale: "The two directions warrant different severities. **Affordance-without-permission** is a real safety concern (the agent has declared a tool it cannot actually invoke — likely indicates either the permission was removed without reviewing the affordance, or the affordance was added without authorising it) — this stays **blocking**. **Permission-without-affordance** is paperwork debt (the grant exists, the governance metadata is missing) — this becomes **advisory**, optionally with a 30-day deadline to either declare an affordance or revoke the permission. Spec will split the chained constraint into two named constraints with these distinct severities."
  - id: O10
    category: alternatives
    severity: medium
    claim: "The 'Identity is the load-bearing question' insight could be delivered as a single new field on the existing per-tool surface (a comment in `.claude/settings.local.json` next to each permission line, or a structured frontmatter block in agent files) rather than as a new top-level HARNESS.md section. The spec does not consider co-locating the metadata with the existing definitions."
    evidence: "Spec lines 56-62 frame Identity and Audit as the load-bearing fields; the design (lines 89-150) places them in a brand-new section. No discussion of why the metadata should be denormalised into HARNESS.md rather than annotated on the source-of-truth files."
    disposition: clarify
    disposition_rationale: "Spec will add explicit rationale for the split rather than restructure. Two-part argument: (1) Tool surface metadata that machines own (the permission patterns, the MCP server names, the hook script paths) is already in source files and stays there — the discovery scanner reads it. (2) Governance metadata that humans own (Identity-as-narrative, Audit Trail prose, Last Reviewed dates, Notes) is review-facing and needs to live where reviewers already read, which is HARNESS.md. Splitting governance prose across N JSON config files would fragment the reviewer's attention. The 'humans own HARNESS.md' invariant (preserved by O3) is the load-bearing structural property; co-locating with source would violate it the same way the original Invoked-by reconciler did. Spec adds this rationale to a new 'Why a separate section' subsection in Design."
  - id: O11
    category: specification quality
    severity: medium
    claim: "The 'Last reviewed' field's semantics are imprecise: the spec says it dates 'when this affordance entry was last validated against reality' but does not define what 'validated' means concretely, who has authority to bump the date, or whether running /harness-affordance against an existing entry counts as a re-review."
    evidence: "Spec line 161: 'YYYY-MM-DD; the date this affordance entry was last validated against reality (Identity correct, Audit trail still works, Permission still in settings).' Without a defined re-validation procedure, the date will be bumped whenever the entry is edited, eroding the staleness GC rule's value (line 259)."
    disposition: accept
    disposition_rationale: "Define re-validation concretely as three specific checks, all of which must pass before Last Reviewed is bumped: (1) the Identity claim still matches reality (the resolution chain has not changed for runtime-resolved entries; the named credential still exists for fixed entries), (2) the Audit Trail still produces a record where claimed (the log endpoint exists, retention matches what is stated, access scope holds), (3) the Permission entry is still present in settings.json with the recorded pattern. The date is bumped only by running `/harness-affordance review <name>`, which walks through the three checks interactively. Editing other fields (Notes, Constraint references) does not bump Last Reviewed. This separates re-validation from routine editing, which preserves the staleness GC rule's value and avoids the file-mtime degeneration."
  - id: O12
    category: implementation
    severity: medium
    claim: "Hook entries are declared first-class affordances, but Claude Code hooks are configured by event (PreToolUse, Stop, etc.) and a single script can be wired to multiple events; the schema has no field to capture the triggering event, so two hook entries with the same script-name field but different triggers cannot be distinguished and the chained constraint cannot detect a script wired into a wrong event."
    evidence: "Spec lines 139-148 example shows `sync-to-global-cache-hook` with `Permission: configured in .claude/settings.local.json hooks.Stop` — encoding the event in the Permission field as freeform text rather than as a schema field. Resolved Decision 4 (lines 383-388) treats hooks as first-class but does not introduce a Trigger or Event field."
    disposition: accept
    disposition_rationale: "Add a `Trigger` field that is required for `Mode: hook` entries and not used for other modes. Values match Claude Code hook events: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreCompact`, `Notification`. A single script wired to two events produces two distinct affordance entries differentiated by Trigger. The discovery scanner populates this directly from settings.json's hook structure, so no extra human work in the discovery-first flow. Future constraints can then key on Trigger (e.g. 'no PreToolUse hooks without an audit trail'). Permission field for hooks reverts to the actual permission pattern (e.g. the script path), with the trigger no longer encoded as freeform text."
---

# Adversarial Review — harness-affordances-design

Spec: `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
Mode: spec
Reviewer: advocatus-diaboli (Claude Opus 4.7)

## O1 — premise — high

### Claim

The spec asserts that no existing location surfaces tool, identity, and audit
information, but it does not demonstrate that practitioners actually fail the
governance task today. The gap is asserted, not evidenced.

### Evidence

> None of those locations are read by humans during governance review. None of
> them surface the questions a reviewer needs to ask...
>
> Today the answer to each of those is "you'd have to grep several config
> files and reverse-engineer it." That is governance debt.

(Lines 30-44 of the spec.)

### Why this matters

The Problem section makes a strong empirical claim — "no one reads these
files during governance review" — without citing a review that failed, an
audit that produced wrong answers, or an incident that the proposed section
would have prevented. The four bullet questions on lines 35-43 are framed as
unanswerable today; in practice all four are answerable in 5-10 minutes by a
reviewer who knows the project layout. If the real friction is "this takes
10 minutes and we want it to take 30 seconds," the proposed cost (a new
section, a new command, a runtime tuple recorder, a writing reconciler, and
three docs pages) is large relative to the savings. Without one concrete
example of a governance review that produced the wrong answer, the premise
is plausible but unproven, and a less-invasive intervention may be sufficient.

## O2 — alternatives — high

### Claim

A single garbage-collection rule that *reads* existing config (settings.json,
.mcp.json, hook scripts, agent frontmatter) and emits a generated, read-only
affordance inventory would deliver the same governance visibility without
introducing a hand-maintained fourth section, a new command, a runtime
tuple recorder, and a HARNESS-writing reconciler.

### Evidence

The spec defers automated discovery as "a separate workstream":

> Automated discovery — scanning ~/.claude/settings.json, .mcp.json, and
> shell env to populate the section. Discovery is valuable but is a
> separate workstream; the format must prove itself with manual declaration
> first.

(Lines 73-77.)

The Components table (lines 327-340) commits to seven new artefacts in the
manual-first path: a template section, a new command, three command updates,
a runtime hook, a reconciler, and three docs pages.

### Why this matters

The spec acknowledges the discovery alternative exists but does not justify
why "prove the format manually first" is the right ordering. If the eventual
end state is a generated inventory (because hand-maintenance is known to drift,
which is why "Invoked by" is auto-populated), then the manual-first path
incurs design cost twice: once for the manual schema and again when discovery
forces schema changes to fit what real config files contain. The honest
question is: does discovery first reveal the schema, or does the schema reveal
what discovery should produce? The spec assumes the latter without argument.

## O3 — implementation — high

### Claim

The "Invoked by" auto-population mechanism violates a principle the spec
itself names — "humans own HARNESS.md" — and the proposed mitigation (the
reconciler only edits one sub-line) is a convention, not a structural
guarantee. Markdown has no schema enforcement; nothing prevents a future
refactor of the reconciler from over-writing more.

### Evidence

> The trade-off: the affordance section becomes partially machine-written,
> which conflicts with the harness principle of "humans own HARNESS.md."
> Mitigation: the reconciler only updates the Invoked by sub-line of an
> existing affordance entry; it never adds, removes, or modifies any other
> field. Humans still control which affordances exist and how they are
> described.

(Lines 231-236.)

### Why this matters

The harness's value comes from being a high-trust, human-edited document.
Once one tool is known to write into it, every subsequent agent that wants
to write a "small, scoped" update will cite the same precedent. The
mitigation is "the reconciler is well-behaved," which is a property of the
current implementation, not a structural property of the design. A safer
design would write tuples to a separate file (e.g. `observability/affordance-
invocations.json`) and have HARNESS.md reference it by file path, preserving
the "humans own HARNESS.md" invariant. The spec does not weigh this
alternative.

## O4 — specification quality — high

### Claim

The schema does not define what counts as "one" affordance, so two reviewers
given the same tool surface will produce different entries. The hook-plus-CLI
rule shows the spec is aware of the granularity problem but resolves it for
one case only.

### Evidence

> Each hook is its own affordance entry; if a hook invokes a CLI internally,
> the CLI is also an affordance entry — the hook is the surface the agent
> triggers, the CLI is the underlying capability.

(Lines 175-178.)

But the schema gives no rule for:

- A single CLI used under two identities in the same session (e.g. `gh`
  with `$GITHUB_TOKEN` set vs after `gh auth switch`).
- An MCP server that exposes many tools under one server name — is it one
  affordance per server, or per method?
- An MCP server that fronts multiple remote APIs (a wrapper MCP).
- A `Bash(*)` permission entry — is that one affordance or many?

### Why this matters

The chained constraint that "every permission has a matching affordance"
(line 218) is only meaningful if "matching" is well-defined. If two reviewers
disagree on whether `gh pr merge` and `gh pr create` are one affordance or
two, the constraint will fail or pass non-deterministically across projects
and over time within a single project. Specification ambiguity at this layer
poisons the enforcement layer downstream.

## O5 — specification quality — high

### Claim

The "Permission" field's matching rule is under-specified. A real
settings.json contains overlapping wildcards (e.g. `Bash(*)`, `Bash(gh *)`,
`Bash(gh pr *)`); the spec does not say which the affordance entry should
record, nor what "matching" means for the chained constraint.

### Evidence

> Permission | yes | declared | the matching pattern from settings.json /
> .claude/settings.local.json permissions allowlist that authorises this
> affordance at runtime

(Line 159.) And:

> A chained constraint can then verify the two are in sync — every declared
> affordance has a matching permission, every granted permission has a
> matching affordance entry.

(Lines 217-219.)

### Why this matters

Permission allowlists are intentionally hierarchical — `Bash(gh *)`
authorises `gh pr merge` and a thousand other invocations. If the affordance
records the most-specific match, the most-general match, or any-overlapping
match, the chained constraint produces three different verdicts. Without a
defined matching algorithm, the "deterministic" enforcement loop is not
deterministic, and the spec's most load-bearing design decision (Resolved
Decision 2, lines 365-372) rests on a foundation it has not laid.

## O6 — scope — high

### Claim

Sequencing step 6 — the runtime tuple recorder plus reconciler with
HARNESS.md write access — is the riskiest piece of work in the spec. It
touches a session hook, a periodic GC writer, and the harness-edits-itself
boundary. The spec defers its design to a future spec while still listing
it as a Component in the current one *and* using it to motivate the
"Invoked by" field's inclusion in the schema.

### Evidence

> Implementation outline (deferred to a separate spec): a SessionEnd hook
> records (tool_name, invoking_agent_or_command) tuples for the session;
> a periodic reconciler (weekly GC) updates the Invoked by list in
> HARNESS.md from the accumulated record.

(Lines 224-229.)

The Components table (lines 336-337) lists "Runtime tuple recorder
(SessionEnd hook)" as M effort and "Invoked by reconciler (GC rule with
HARNESS.md write access)" as M effort.

### Why this matters

The schema includes "Invoked by" as a required field. The field's value is
asserted to come from a mechanism that does not yet exist and is acknowledged
to need a separate spec. Until that mechanism exists, every affordance entry
will have an empty or placeholder "Invoked by" line. The chained constraint
"every affordance must show at least one auto-populated Invoked by consumer
within 30 days of declaration" (line 256) will either fire universally
(failing every entry) or be silently disabled. Either outcome erodes trust in
the section. The honest sequencing would be: defer "Invoked by" until step 6
ships, or remove the chained constraint that depends on it.

## O7 — premise — medium

### Claim

The "Identity" framing assumes a sharp boundary between `user-sso`,
`service-account`, `current-user`, and `none`, but in practice the boundary
is often a runtime configuration choice. A static declaration in HARNESS.md
will be wrong some non-trivial fraction of the time.

### Evidence

> Identity | yes | declared | user-sso / service-account / current-user /
> none (with optional detail in parens)

(Line 158.) And the gh-cli example:

> Identity: user-sso (GitHub PAT in $GITHUB_TOKEN)

(Line 105.)

### Why this matters

`gh` uses `$GITHUB_TOKEN` if set; otherwise it uses the keychain auth from
`gh auth login`; otherwise it fails. Whether the action is `user-sso` or
`service-account` depends on which token the human happened to export. The
same applies to `aws` (profile vs env vars vs IAM role), `kubectl` (kubeconfig
vs in-cluster service account), and many others. A declaration that pins a
single identity per tool will mislead reviewers when the runtime reality
differs. The schema needs a "depends on session config — see Notes" value or
the field needs to be probed at runtime. Neither path is in the spec.

## O8 — scope — medium

### Claim

The spec proposes that template projects adopt the affordance scaffold during
/harness-init but does not address backfill for existing harness adopters.
Without an opinionated backfill path, the section will exist in new projects
and be empty in every project that adopted the harness before this version.

### Evidence

> Template projects that adopt the plugin get an affordance scaffold during
> /harness-init and a guided way to populate it.

(Line 416.)

Sequencing steps 2-8 (lines 293-318) describe forward additions only.

### Why this matters

The chained constraint "every permission has a matching affordance" applies
the day it ships. In a project that has been using the harness for months
with a populated `.claude/settings.local.json` and an empty `## Affordances`
section, every permission will fail the constraint. The graceful handling of
this is unspecified — does the constraint default to advisory? Is there a
template-version gate? Is there a `/harness-affordance backfill` step? Until
this is decided, adopting the section in an existing project will produce a
flood of failures or be silently ignored. Either outcome is poor.

## O9 — risk — medium

### Claim

The chained constraint "every permission allowlist entry must have a matching
affordance" creates a one-way ratchet that punishes the safer state. A project
with a tightly scoped permission allowlist of twelve entries and only three
declared affordances fails the constraint even though its runtime grants are
well-governed. The natural human response is to either delete permissions or
fabricate affordance entries, both worse than the status quo.

### Evidence

> every declared affordance has a matching permission, every granted
> permission has a matching affordance entry. Affordances without permissions
> are dead inventory; permissions without affordances are ungoverned grants.

(Lines 217-219.)

### Why this matters

The spec frames both directions of mismatch as symmetrically problematic, but
the consequences are not symmetric. A permission without an affordance is
"undocumented" — a paperwork gap. Punishing it equally with a true safety
violation creates pressure to either reduce permission specificity (replace
twelve narrow rules with one `Bash(*)` rule that has one matching affordance)
or to add token affordance entries to satisfy the check. Both are worse than
the starting state. The spec should weigh whether the two directions warrant
different severities, or whether the "permission without affordance" check
should be advisory rather than blocking.

## O10 — alternatives — medium

### Claim

The "Identity is the load-bearing question" insight could be delivered as a
single new field on the existing per-tool surfaces (a comment in
`.claude/settings.local.json` next to each permission line, or a structured
frontmatter block in agent files) rather than as a brand-new top-level
HARNESS.md section. The spec does not consider co-locating the metadata
with its source-of-truth files.

### Evidence

The Problem section (lines 56-62) frames Identity and Audit as the load-
bearing fields. The Design section (lines 89-150) places them in a new
top-level section, denormalised from the configuration files that already
list the tools.

### Why this matters

Denormalising metadata into HARNESS.md introduces drift between the harness
declaration and the source-of-truth config. The spec acknowledges this drift
risk for "Invoked by" (which is why that field is auto-populated) but does
not acknowledge the same drift for Identity, Audit Trail, and Permission.
A simpler intervention — a field convention attached to existing files,
plus a /harness-affordance command that *generates* the HARNESS.md view from
those files — would have one source of truth. The spec does not consider
this shape.

## O11 — specification quality — medium

### Claim

The "Last reviewed" field's semantics are imprecise. The spec says it dates
"when this affordance entry was last validated against reality" but does not
define what "validated" means, who has authority to bump the date, or whether
running /harness-affordance against an existing entry counts as a re-review.

### Evidence

> Last reviewed | yes | declared | YYYY-MM-DD; the date this affordance
> entry was last validated against reality (Identity correct, Audit trail
> still works, Permission still in settings)

(Line 161.)

### Why this matters

Without a defined re-validation procedure, the date will be bumped whenever
the entry is edited (because the editor will tick the field as a matter of
habit). The staleness GC rule (line 259) — "every affordance's Last reviewed
date must be within the last 6 months" — then degrades to a "has anyone
touched this file in six months" check, which the existing `git log` mtime
check on the file already provides. Without procedural specification, the
field collapses into noise.

## O12 — implementation — medium

### Claim

Hook entries are declared first-class affordances, but Claude Code hooks are
configured by event (PreToolUse, Stop, etc.) and a single script can be wired
to multiple events. The schema has no field to capture the triggering event,
so two hook entries with the same script name but different triggers cannot
be distinguished, and the chained constraint cannot detect a script wired
into a wrong event.

### Evidence

The example hook entry encodes the event in the Permission field as freeform
text rather than as a schema field:

> Permission: configured in .claude/settings.local.json hooks.Stop

(Line 144.)

Resolved Decision 4 (lines 383-388) treats hooks as first-class but does not
introduce a Trigger or Event field.

### Why this matters

A hook fired on PostToolUse vs Stop has different governance properties (one
runs after every tool invocation; one runs once per session). Conflating them
because they share a script means the affordance entry under-describes the
risk surface. A future chained constraint that wants to enforce "no hooks on
PreToolUse without an audit trail" cannot be expressed against the current
schema.

## Explicitly not objecting to

- **The choice of four Identity values** (`user-sso`, `service-account`,
  `current-user`, `none`): the taxonomy is simple, defensible, and orthogonal;
  whether the boundary is sharp at runtime is challenged in O7, but the
  taxonomy itself is fine.
- **The `/harness-affordance` command following the `/harness-constrain`
  pattern**: this is correctly identified as the cheapest UX path and matches
  prior project convention; no honest objection here.
- **The "Audit trail: none is encouraged" framing**: explicitly inviting the
  honest "no audit" answer is a strong design choice that resists fabrication
  pressure; this is one of the spec's clearer ideas.
- **The decision to keep Mode in the schema (Resolved Decision 1)**: the
  reasoning ("cheap to maintain, helps reviewers categorise at a glance") is
  pragmatic and correctly weighed against Identity being load-bearing; not
  worth challenging.
- **Naming the section "Affordances" rather than "Tools" or "Capabilities"**:
  the term carries the right connotation (granted, not assumed) from
  capability-based security; this is a deliberate and defensible naming
  choice.
- **The non-goal "this spec does not enumerate MCP method lists"**: keeping
  the inventory at the *server* level rather than the *method* level is the
  right scope for governance review — the contrary would produce unmanageable
  surface.
- **The Intellectual Foundations section's framing**: capability-based
  security and identity-aware computing are correctly cited as the design
  precedents; nothing rhetorically suspect there.
