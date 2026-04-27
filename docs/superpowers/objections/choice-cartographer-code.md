---
spec: docs/superpowers/specs/2026-04-27-choice-cartographer.md
date: 2026-04-27
mode: code
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "The advocatus-diaboli SKILL.md was not updated to reference the Routing Rule, leaving the symmetric two-side test mandated by the adjudicated spec-mode disposition implemented on only one side."
    evidence: "Spec O5 disposition required: 'Embed this in both the Henney skill and the spec's routing-rule section so both agents reference the same test.' The cartographer SKILL.md defines the rule and asserts 'The diaboli skill references the same test from its side.' But skills/advocatus-diaboli/SKILL.md does not mention the Routing Rule, the Cartographer, or the failures-vs-decisions partition. The branch diff does not include skills/advocatus-diaboli/SKILL.md."
    disposition: accepted
    disposition_rationale: null
  - id: O2
    category: risk
    severity: high
    claim: "The revisit disposition decouples plan-approval intent from merge-time enforcement, allowing PRs to ship with stories that explicitly mark the spec as needing change."
    evidence: "docs/how-to/run-choice-cartograph.md says revisit means 'the choice should be reconsidered before plan approval... the spec needs to change to reflect the reconsidered decision.' But the harness-enforcer agent treats revisit as passing: 'verify that every entry has disposition set to one of accepted, revisit, or promoted (no pending).' Nothing in the merge-time gate verifies that a revisit disposition was followed by an actual spec edit."
    disposition: accepted
    disposition_rationale: "I like revisit as meaning deferred."
  - id: O3
    category: implementation
    severity: high
    claim: "The harness-enforcer agent does not implement the date-cutoff or cartographer:exempt-pre-existing frontmatter exemption logic that the HARNESS.md constraint text specifies."
    evidence: "HARNESS.md constraint says: 'Specs created before 2026-04-27 are exempt — add cartographer: exempt-pre-existing to their frontmatter or rely on the dated cutoff.' The harness-enforcer.agent.md choice-story section lists exemption rules: bug/fix/chore/maintenance label, branch-prefixed fix/ or chore/, cross-repo. It does not parse spec frontmatter for cartographer: exempt-pre-existing, nor compare the spec filename date to 2026-04-27."
    disposition: accepted
    disposition_rationale: "Accepted with option A: extend the enforcer with date-cutoff and frontmatter-flag exemption checks."
  - id: O4
    category: implementation
    severity: high
    claim: "Cross-reference validation is underspecified for the prose Refs field, leaving multiple plausible parsing strategies that produce different validation results."
    evidence: "The skill places Refs in the prose body (format **Refs:** <O\\d+ and/or #N citations, or — if none>). The implementation does not specify: (a) how to locate the Refs field in prose; (b) what counts as 'an existing entry' in the target objections record (id: O3 in YAML, or any occurrence of O3?); (c) how to avoid false positives from O3 tokens elsewhere in the story prose. Two reasonable implementers will disagree."
    disposition: accepted
    disposition_rationale: "Accepted with the proposed solution: locate Refs via line regex `^\\*\\*Refs:\\*\\*\\s+(.+)$` scoped within each `## Story #N` section; an `existing entry` means an `id: O\\d+` parsed from the YAML frontmatter of the matching objections record (the `objections` array); whole-file scans are forbidden — only the `Refs` line is matched. Pin these in the spec, the skill, the command, and the orchestrator validation step."
  - id: O5
    category: implementation
    severity: medium
    claim: "The validator has no defined fix-in-place action for cross-reference resolution failures or selectivity-cap overshoots, contradicting the codified pattern that drove spec O6."
    evidence: "/choice-cartograph step 5: 'If any check fails, fix the deviation in place. Do not re-dispatch the agent.' But the spec does not specify what 'fix in place' means for: (a) cross-reference failures — strip the dangling reference? Drop the story? (b) story count >15 — truncate? Drop the highest-numbered? Both choices alter the agent's output without consent."
    disposition: accepted
    disposition_rationale: "Accepted with the proposed fix-recipes. (a) Cross-reference failure: replace the offending `O\\d+` or `#N` token with `—` in the `Refs` line; if the resulting `Refs` line is empty, write `—`. (b) Story count >15: validator should never receive this case (cap is enforced inside the agent per spec O6); if it somehow occurs, fail loudly with a count error rather than silently truncating, since silent mutation of agent output is a contract break worth surfacing."
  - id: O6
    category: implementation
    severity: medium
    claim: "The plan-approval gate is documented as soft but operationalised as an acknowledgement-with-choice prompt, collapsing the soft/hard distinction at the user-facing layer."
    evidence: "Spec 'Soft gate semantics': 'Continue execution after surfacing — no acknowledgement keypress is required at plan approval.' Orchestrator step 7 presents three options (Approve / Request changes / Take over) regardless of cartograph_pending_count. The user must press something to continue. The diaboli's hard gate uses the same plan-approval surface."
    disposition: accepted
    disposition_rationale: "Accepted with option A: spec wins. cartograph_pending_count is surfaced as an informational field in the plan-approval summary, not a separate decision point. Remove the `you are opting to defer` framing from the Approve branch; the soft gate genuinely continues without an extra keypress. The count is observability, not a gate."
  - id: O7
    category: implementation
    severity: medium
    claim: "The validation checkpoint does not verify the Refs field is present on every story, despite the skill making field presence non-optional."
    evidence: "skill SKILL.md: 'If no cross-references apply, write — (em-dash). Do not omit the field.' The /choice-cartograph command and orchestrator validation checks verify cross-reference resolution conditional on tokens existing — but neither checks that the Refs: line is actually present in every story's prose."
    disposition: accepted
    disposition_rationale: null
  - id: O8
    category: implementation
    severity: medium
    claim: "The /choice-cartograph command and the orchestrator carry two independent validation specifications for the same artefact, inviting silent drift."
    evidence: "/choice-cartograph step 5 lists 11 numbered checks. orchestrator.agent.md step 5 lists 6 numbered checks. Both validate the same file but the lists do not align. The codified pattern recommends 'Reference the format spec rather than inlining field definitions' — this implementation inlines them in two places."
    disposition: accepted
    disposition_rationale: "Accepted with option A: extract the validation checks to a single reference file (skills/choice-cartographer/references/validation-checks.md or similar). Both /choice-cartograph and the orchestrator step 5 link to it as the source of truth. Mirrors the existing references/snapshot-format.md pattern."
  - id: O9
    category: risk
    severity: medium
    claim: "The constraint treats 'PR has no spec' as trivially passing, creating a chained bypass path through any PR that elides spec-first ordering."
    evidence: "HARNESS.md rule: 'Every feature or behaviour-change PR with a spec must have a choice-story record...'. The harness-enforcer step 2 starts by finding spec files. Step 3 handles 'file does not exist' (missing stories record) but no branch handles 'PR has no spec at all'. A feature PR mislabelled as chore would skip both spec-first-commit-ordering and this constraint in sequence."
    disposition: accepted
    disposition_rationale: "Accepted. Re-phrase the HARNESS.md rule to be exemption-driven: every non-exempt PR must have either (a) a spec with a choice-story record, or (b) one of the exempt labels. Forces active labelling rather than silent elision. Parallel change to the harness-enforcer agent's choice-story review block."
  - id: O10
    category: implementation
    severity: low
    claim: "The docs/superpowers/stories/ directory is referenced by four implementation surfaces but no .gitkeep is shipped — the first invocation in any project must create the directory."
    evidence: "Repository check: docs/superpowers/objections/.gitkeep exists; docs/superpowers/stories/.gitkeep does not. /choice-cartograph step 4 ('Write to docs/superpowers/stories/<slug>.md'), orchestrator step 4 (same), /superpowers-status Section 8 ('count of docs/superpowers/stories/*.md, excluding .gitkeep'), and snapshot-format Cartographer section all assume the directory exists. None of the commands' processes specifies a directory-creation step."
    disposition: accepted
    disposition_rationale: null
---

# Objections — choice-cartographer (code mode)

This is the code-mode adversarial review of the Choice Cartographer
implementation on branch `add-henney-agent` (commit 4d06f0e). Spec-time
adjudication is at `docs/superpowers/objections/choice-cartographer.md`
— do not re-litigate those dispositions; this record focuses on what
the implementation does or fails to do.

## O1 — implementation — high

### Claim

The advocatus-diaboli SKILL.md was not updated to reference the Routing
Rule, leaving the symmetric two-side test mandated by the adjudicated
spec-mode disposition implemented on only one side.

### Evidence

Spec O5 disposition required:

> Adopt the following routing test: if removing the finding would leave a
> class of failures undetected, it's a diaboli risk; if removing it would
> leave a decision unrecorded but no failure undetected, it's a Henney
> story. **Embed this in both the Henney skill and the spec's
> routing-rule section so both agents reference the same test.**

The cartographer skill (`skills/choice-cartographer/SKILL.md`) defines the
Routing Rule and asserts "The diaboli skill references the same test from
its side." But `skills/advocatus-diaboli/SKILL.md` makes no mention of
the Routing Rule, the Cartographer, or the failures-vs-decisions
partition. The branch diff does not include
`skills/advocatus-diaboli/SKILL.md`.

### Why this matters

The Routing Rule is the only mechanism the spec offers to prevent
duplicate findings between the diaboli and the Cartographer. The fix
adopted at adjudication was *symmetry* — both agents apply the same
test before emitting. With the diaboli skill unchanged, only one of
the two agents has been instructed to apply the rule. Spec O5's
accepted disposition is implemented at half strength.

## O2 — risk — high

### Claim

The `revisit` disposition decouples plan-approval intent from merge-time
enforcement, allowing PRs to ship with stories that explicitly mark the
spec as needing change.

### Evidence

`docs/how-to/run-choice-cartograph.md` step 4 says `revisit` means "the
choice should be reconsidered before plan approval... the spec needs to
change to reflect the reconsidered decision." The harness-enforcer
agent treats `revisit` as passing: "verify that every entry has
`disposition` set to one of `accepted`, `revisit`, or `promoted` (no
`pending`)."

### Why this matters

The disposition value `revisit` carries a semantic load — "this needs
spec edits" — that disappears at merge time. A team can mark every
story `revisit`, never revise the spec, and merge freely. The
intent-debt motivation of the Cartographer is that decisions without
resolution accumulate; allowing `revisit` to ship without verification
that the spec was actually revised re-introduces exactly that pattern.

The fix is small (the gate could verify that any spec referenced by a
`revisit` story was modified after the story was written, or treat
`revisit` as a non-passing disposition), but the spec needs to make a
choice.

## O3 — implementation — high

### Claim

The harness-enforcer agent does not implement the date-cutoff or
`cartographer: exempt-pre-existing` frontmatter exemption logic that
the HARNESS.md constraint text specifies.

### Evidence

`HARNESS.md` constraint: "Specs created before 2026-04-27 are exempt —
add `cartographer: exempt-pre-existing` to their frontmatter or rely
on the dated cutoff."

`agents/harness-enforcer.agent.md` choice-story section lists exemption
rules but does not reference the date cutoff, does not reference the
`cartographer: exempt-pre-existing` frontmatter flag, and does not
include any spec-frontmatter parsing instruction.

### Why this matters

The constraint text declares two exemption mechanisms (date cutoff and
explicit frontmatter flag) that the enforcement agent does not honour.
A PR that touches a pre-cutoff spec or one with the exempt flag would
be flagged as a constraint violation despite the rule granting it
exemption. Symmetry with the diaboli's `diaboli: exempt-pre-existing`
mechanism was claimed but not implemented.

## O4 — implementation — high

### Claim

Cross-reference validation is underspecified for the prose `Refs`
field, leaving multiple plausible parsing strategies that produce
different validation results.

### Evidence

The skill places `Refs` in the prose body of each story:

> **Refs:** <O\d+ and/or #N citations, or — if none>

The /choice-cartograph command step 5 check 10 and orchestrator step 5
check 6 both require: "every `O\d+` token in any `Refs` field
corresponds to an existing entry in
`docs/superpowers/objections/<slug>.md`."

### Why this matters

The implementation does not specify: (a) how to locate the `Refs`
field in prose; (b) what counts as "an existing entry" in the target
objections record (`id: O3` line or any occurrence of `O3`?); (c) how
to avoid false positives from `O3` tokens that appear in other parts
of the story prose. Two reasonable implementers will disagree. The
lack of specification guarantees that one CI run will flag a story
that another run accepts.

## O5 — implementation — medium

### Claim

The validator has no defined "fix in place" action for cross-reference
resolution failures or selectivity-cap overshoots, contradicting the
codified pattern that drove spec O6.

### Evidence

`/choice-cartograph` step 5: "If any check fails, fix the deviation in
place. Do not re-dispatch the agent. The selectivity cap (15) is
enforced inside the agent's reasoning protocol, so the validator never
refuses to write."

### Why this matters

The implementation does not say what "fix in place" means in two cases:
(a) cross-reference failure — strip the dangling reference? Drop the
story? (b) story count above 15 — truncate? Drop the highest-numbered?
Each option silently alters the agent's output. The codified
"fix in place, no re-dispatch" pattern was supposed to prevent
re-dispatch loops, not license silent mutation. The implementation
needs an explicit fix recipe per check.

## O6 — implementation — medium

### Claim

The plan-approval gate is documented as soft but operationalised as
an acknowledgement-with-choice prompt, collapsing the soft/hard
distinction at the user-facing layer.

### Evidence

Spec "Soft gate semantics": "Continue execution after surfacing — no
acknowledgement keypress is required at plan approval."

Orchestrator step 7 'Plan Approval Gate' presents three options
(Approve / Request changes / Take over) regardless of
`cartograph_pending_count`. The user must press something to continue.

### Why this matters

The spec said no keypress is required, but the implementation requires
one. The diaboli's hard gate uses the same plan-approval surface, so
the user experience is identical. The spec's design choice was that
the soft gate would have *less* friction than the hard gate; as
implemented, the soft gate adds the same friction.

## O7 — implementation — medium

### Claim

The validation checkpoint does not verify the `Refs` field is present
on every story, despite the skill making field presence non-optional.

### Evidence

`skills/choice-cartographer/SKILL.md`: "If no cross-references apply,
write `—` (em-dash). Do not omit the field."

The /choice-cartograph command (checks 1-11) and orchestrator step 5
(checks 1-6) verify cross-reference resolution *conditional on tokens
existing*. Neither checks that the `Refs:` line is actually present.

### Why this matters

A story whose prose omits the `Refs:` line entirely would pass
validation. The skill's stated invariant is unenforced. The fix is one
field-presence check per story.

## O8 — implementation — medium

### Claim

The /choice-cartograph command and the orchestrator embed two
independent validation specifications for the same artefact, inviting
silent drift.

### Evidence

`commands/choice-cartograph.md` step 5 lists 11 numbered checks.
`agents/orchestrator.agent.md` step 5 lists 6 numbered checks. Both
validate the same file. The lists overlap but are not aligned: command
check 9 (consecutive numbering) is absent in the orchestrator; the
command separates `mode` value from field presence (checks 2 and 3),
the orchestrator inlines them.

### Why this matters

Both surfaces validate the same file but from independent
specifications. Without a shared reference, edits to one path silently
leave the other path weaker. The codified pattern recommends "Reference
the format spec rather than inlining field definitions" — this
implementation inlines them in two places.

## O9 — risk — medium

### Claim

The constraint treats "PR has no spec" as trivially passing, creating
a chained bypass path through any PR that elides spec-first ordering.

### Evidence

HARNESS.md rule: "Every feature or behaviour-change PR with a spec
must have a choice-story record..."

The harness-enforcer agent step 2 starts by finding spec files. Step 3
handles 'file does not exist' (missing stories record) but no branch
handles 'PR has no spec at all' — that case satisfies the rule
trivially.

### Why this matters

A feature PR mislabelled as `chore` would skip both spec-first-commit-
ordering and the choice-stories constraint in sequence. The
cartographer's merge-time forcing function disappears for PRs that
elide spec-first. The current shape rewards mislabelling.

## O10 — implementation — low

### Claim

The `docs/superpowers/stories/` directory is referenced by four
implementation surfaces but no `.gitkeep` is shipped — the first
invocation in any project must create the directory.

### Evidence

Repository check: `docs/superpowers/objections/.gitkeep` exists;
`docs/superpowers/stories/.gitkeep` does not. The directory is
referenced by `commands/choice-cartograph.md`,
`agents/orchestrator.agent.md`, `commands/superpowers-status.md`, and
`skills/harness-observability/references/snapshot-format.md`. The last
two explicitly exclude `.gitkeep` from counts, implying the
placeholder should exist.

### Why this matters

The first invocation of `/choice-cartograph` in a fresh project will
attempt to write to a directory that may not exist. The defensive fix
is trivial: ship `.gitkeep`.

## Explicitly not objecting to

- **The skill's six-lens definitions and the Routing Rule itself.**
  Adjudicated at spec time; the lens definitions are clear and aligned.
- **The read-only trust boundary on the agent.** The `tools: [Read,
  Glob, Grep]` declaration is correct, the agent.md reasoning protocol
  does not assume any write capability, and the trust-boundary section
  mirrors the diaboli's language. Sound.
- **The plugin-manifest, README, and CHANGELOG mechanics.**
  `plugin.json` 0.29.0, `marketplace.json` `plugin_version` matches,
  README badges and counts updated, CHANGELOG entries detailed.
- **The selectivity 5–8 / 15-cap protocol inside the agent's reasoning.**
  The skill places the cap inside the reasoning, mirroring the diaboli's
  pattern. Spec O6 closed this design well; the implementation reflects
  the resolution.
- **Symmetry of the choice-story file path with the objections file
  path.** `docs/superpowers/stories/<slug>.md` mirrors
  `docs/superpowers/objections/<slug>.md`. Navigability is good.
- **The Cartographer/Diaboli serial sequencing.** Step 1b dispatches
  the cartographer after spec-mode diaboli dispositions are resolved.
  Cross-reference benefit preserved.
- **The premise of the agent.** Adjudicated at spec time. Not
  re-litigated here.
