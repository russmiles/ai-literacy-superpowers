---
spec: docs-advocatus-diaboli-and-harness-upgrade
date: 2026-04-19
diaboli_model: claude-sonnet-4-6
objections:
  - id: O1
    category: design
    severity: major
    claim: "The proposed /diaboli commands-reference entry describes the wrong six categories and a wrong four-point severity scale, directly contradicting the SKILL.md it is documenting."
    evidence: "Spec lines 49-51: 'up to six objections across six categories (premise, scope, implementation, risk, alternatives, specification quality), each with a severity rating (critical / high / medium / low).' SKILL.md defines the categories as premise, design, threat, failure, operational, cost — and severity as the binary major/minor."
    disposition: fix
    disposition_rationale: Align SKILL.md with spec for objections as a different taxonomy only for objections.
  - id: O2
    category: design
    severity: major
    claim: "The proposed agents.md entry for advocatus-diaboli lists the same wrong six categories, meaning the reference documentation for the agent will contradict the SKILL.md that governs it."
    evidence: "Spec lines 78-79: 'steel-manned objections across six categories: premise validity, scope creep, implementation risk, unaddressed alternatives, specification quality, and systemic risk.' None of these names match the SKILL.md category set (premise, design, threat, failure, operational, cost)."
    disposition: fix
    disposition_rationale: Make the SKILL.md match the spec as part of the work.
  - id: O3
    category: design
    severity: major
    claim: "The proposed /diaboli commands-reference entry states the agent produces 'up to six objections,' but SKILL.md caps the objection record at twelve."
    evidence: "Spec line 48: 'The record contains up to six objections across six categories.' SKILL.md states: 'Cap at 12 objections per spec.'"
    disposition: fix
    disposition_rationale: Correct the commsnds reference.
  - id: O4
    category: failure
    severity: major
    claim: "The spec does not list commands.md's intro sentence ('All 21 slash commands') as a location requiring updating, which means the artefact list is incomplete and the intro will be stale after /diaboli is added."
    evidence: "Spec 'Artefacts' section (lines 145-146): 'docs/reference/commands.md — /diaboli entry added, command count updated in intro if present.' The actual commands.md line 10 reads 'All 21 slash commands registered in commands/.' The qualifier 'if present' is incorrect — the count is unambiguously present — and the spec's expected outcome says 'The commands reference lists all 22 commands' without resolving the ambiguity."
    disposition: fix
    disposition_rationale: make sure the spec aligns with /diaboli addition.
  - id: O5
    category: failure
    severity: minor
    claim: "The first-time-tour.md opens by stating 'The plugin ships with twenty-one slash commands' — this sentence is not listed as a required update, but it becomes inaccurate once /diaboli is added."
    evidence: "first-time-tour.md line 10: 'The plugin ships with twenty-one slash commands, a dozen agents.' The spec's tour update instructions (lines 107-113) address only the workflow-phase section and 'What Happens Next,' not the opening count sentence."
    disposition: fix
    disposition_rationale: Make the documentation match the real state of things.
  - id: O6
    category: failure
    severity: minor
    claim: "The agent-orchestration.md pipeline diagram is concrete and present in the file but the spec hedges its update with 'if one exists,' creating risk that the implementer leaves the five-agent diagram unchanged."
    evidence: "Spec line 132: 'Also update the pipeline description and the sequence diagram (if one exists) to show the updated 6-step pipeline.' The diagram exists at agent-orchestration.md lines 94-126 and explicitly shows a five-agent sequence. The hedge 'if one exists' is factually wrong."
    disposition: fix
    disposition_rationale: remove the conditional in the spec.
  - id: O7
    category: design
    severity: minor
    claim: "The spec instructs adding a further-reading link to agent-orchestration.md without noting that the file already has a duplicate 'Agents Reference' link in that section, leaving the implementer to reproduce the duplication."
    evidence: "Spec line 130: 'Update the Further Reading section to link to adversarial-review.md.' agent-orchestration.md lines 199 and 203 both read '- [Agents Reference]({% link reference/agents.md %}) — detailed catalogue of all agents in this plugin' — an existing duplication the spec does not acknowledge."
    disposition: fix
    disposition_rationale: remove the duplication
  - id: O8
    category: operational
    severity: minor
    claim: "The two new explanation pages and the new how-to are specified without YAML frontmatter metadata, making deterministic sidebar navigation positioning impossible to implement from the spec alone."
    evidence: "File 5 (spec lines 115-127) and File 3 (spec lines 94-105) describe page content in full but include no frontmatter. Every existing docs page carries frontmatter with title, layout, parent, and nav_order fields."
    disposition: fix
    disposition_rationale: add tbe YAML frontmatter to the spec.
  - id: O9
    category: design
    severity: minor
    claim: "The proposed adversarial-review.md explanation page includes 'disposition distribution as a signal' as a content item, but no aggregate view of dispositions is defined anywhere in the plugin at v0.23.0, making this content speculative."
    evidence: "Spec line 125: 'Disposition distribution as a signal: what deferred — not material clustering means.' No command, agent, or dashboard aggregates disposition values across objection records at v0.23.0."
    disposition: leave
    disposition_rationale: Leave this as the extra functionality is coming very, very soon.
---

## O1 — Wrong categories and severity scale in /diaboli commands entry

The proposed `/diaboli` commands-reference entry describes the wrong six objection categories and a four-point severity scale that does not exist, directly contradicting the SKILL.md the entry is meant to document.

The spec's proposed commands.md entry reads: "The record contains up to six objections across six categories (premise, scope, implementation, risk, alternatives, specification quality), each with a severity rating (critical / high / medium / low)."

SKILL.md defines the six categories as `premise`, `design`, `threat`, `failure`, `operational`, `cost`. The severity scale is strictly binary: `major` or `minor`. Neither the category names nor the severity vocabulary in the spec match the actual skill.

Commands reference entries are the primary source of truth consulted before running a command. A reader who runs `/diaboli` and then reads the objection record will find categories like `design` and `threat` that are nowhere in the entry they just read. A reader trying to interpret a `major` severity finding will search the commands page for what `major` means and find only `critical / high / medium / low`. The documentation will actively mislead users about the tool they are using from the first day it ships.

---

## O2 — Wrong categories in agents.md advocatus-diaboli entry

The proposed agents.md entry for advocatus-diaboli lists the same wrong six categories, meaning both reference pages will describe a different agent from the one that is actually deployed.

The spec's proposed agents.md entry reads: "steel-manned objections across six categories: premise validity, scope creep, implementation risk, unaddressed alternatives, specification quality, and systemic risk."

The actual SKILL.md categories are `premise`, `design`, `threat`, `failure`, `operational`, `cost`. None of the six names in the spec match any of the six names in the skill. This is not a paraphrase — `scope creep`, `specification quality`, and `systemic risk` do not correspond to any SKILL.md category at all.

A user who reads the agents reference to understand what advocatus-diaboli produces, then receives an objection record containing an `operational` or `cost` category, will have no framework for interpreting it. The mismatch between both reference pages and the actual output will generate confusion on every first use. Because the error appears in two separate files, it cannot be dismissed as a typo — it reflects a systematic confusion between the spec's own invented taxonomy and the one the skill actually implements.

---

## O3 — Wrong objection cap in /diaboli commands entry

The proposed `/diaboli` entry caps the objection record at six objections; SKILL.md caps it at twelve. Any reader who relies on the commands reference will have a false ceiling when reviewing an objection record.

Spec line 48: "The record contains up to six objections across six categories." SKILL.md states: "Cap at **12 objections** per spec." The justification for the twelve-cap is also given in SKILL.md and is non-trivial — it exists because more than twelve signals the spec is not ready for review.

A reader told to expect at most six will incorrectly conclude that a seven-objection record is malformed or that the agent misfired. The cap is a meaningful operational signal, not an implementation detail. Twelve versus six is a factor of two — large enough that no reader would assume it is a minor rounding error.

---

## O4 — Artefact list hedges on commands.md count update that is not optional

The spec's artefact description for commands.md uses the hedge "if present" for the count update, but the count sentence unambiguously exists; this ambiguity risks the implementer leaving "All 21 slash commands" unchanged after adding `/diaboli`.

Spec artefact entry: "docs/reference/commands.md — /diaboli entry added, command count updated in intro if present." The actual commands.md line 10 reads: "All 21 slash commands registered in `commands/`." The count is present. The spec's expected outcome states: "The commands reference lists all 22 commands including /diaboli." There is a direct contradiction between an artefact description that hedges ("if present") and an outcome statement that is unhedged.

A commands reference that opens by declaring 21 commands and then lists 22 is incorrect from line 10. The count sentence is the first substantive claim the reader encounters. Leaving it at 21 after adding `/diaboli` means every subsequent reader is immediately given wrong information before they reach the new entry.

---

## O5 — First-time-tour opening count sentence not flagged for update

The first-time-tour.md opening sentence states "The plugin ships with twenty-one slash commands" but the spec's tour update instructions do not include updating this sentence, leaving it stale after `/diaboli` is added.

first-time-tour.md line 10 reads: "The plugin ships with twenty-one slash commands, a dozen agents, and dozens of skills." The spec's instructions for updating the tour address only the workflow-phase section and the "What Happens Next" paragraph. The opening count sentence is not mentioned.

The first-time-tour is the primary onboarding path. A new user whose first encounter with the plugin is this tutorial will be told there are twenty-one commands, then later see `/diaboli` in the commands reference as a twenty-second entry. Since the spec already correctly identifies the analogous agent count error in agents.md as "critical," omitting the equivalent tour fix is inconsistent with the spec's own severity judgements.

---

## O6 — Pipeline diagram update hedged as optional when diagram concretely exists

The agent-orchestration.md pipeline diagram showing a five-agent sequence exists concretely in the file, but the spec hedges its update requirement with "if one exists," creating risk that an implementer treats the diagram as optional to update.

Spec line 132: "Also update the pipeline description and the sequence diagram (if one exists) to show the updated 6-step pipeline." The diagram exists at agent-orchestration.md lines 94-126, beginning with `Requirements` and ending with `[Integrator] --> Changelog, commit, PR, CI` — a specific, labelled five-agent ASCII flow with gates and cycle annotations. The hedge "if one exists" is factually false for this file.

The pipeline diagram in agent-orchestration.md is the most concrete visual representation of the pipeline in the entire docs site. If it continues to show five agents after the advocatus-diaboli is added, a reader who follows the diagram to understand how the pipeline works will have an incorrect mental model. The "Key Takeaways" section also summarises "five focused jobs" — both require updating.

---

## O7 — Further-reading update doesn't address existing duplicate link

The spec instructs adding a link to agent-orchestration.md's further-reading section without acknowledging the duplicate "Agents Reference" entry that already exists there, leaving the implementer to reproduce the duplication.

Spec line 130: "Update the 'Further Reading' section to link to adversarial-review.md." agent-orchestration.md lines 199 and 203 are identical: both read `- [Agents Reference]({% link reference/agents.md %}) — detailed catalogue of all agents in this plugin`. The spec asks the implementer to add a third link to an already-duplicated section.

Adding a link to a further-reading section that already has a broken duplicate is a missed cleanup opportunity that an implementer with the file open will notice but may not feel authorised to fix without spec coverage. The net result is a section with one duplicated entry and one new entry, leaving the section's quality worse than when it started.

---

## O8 — New pages specified without Jekyll frontmatter nav_order values

The two new explanation pages and the new how-to are specified without YAML frontmatter metadata, making deterministic sidebar navigation positioning impossible to implement from the spec alone.

File 5 and File 3 describe page content in detail but include no frontmatter block. Every existing docs page carries frontmatter specifying `title`, `layout`, `parent`, and `nav_order`. The spec references other how-tos as patterns but does not specify nav_order values for the new pages, which are required for deterministic sidebar positioning.

Without explicit nav_order values, the implementer must inspect every sibling page to determine the next available slot, or guess — either of which may place the new pages in an unintended position in the sidebar. A page placed at the wrong nav_order slot may be buried or may displace an existing page, and no CI check will catch it.

---

## O9 — Disposition distribution as a signal has no tooling affordance at v0.23.0

The proposed adversarial-review.md explanation page includes "disposition distribution as a signal" as a content item, but no aggregate view of dispositions is defined anywhere in the plugin at v0.23.0, making this content speculative and potentially misleading.

Spec line 125: "Disposition distribution as a signal: what `deferred — not material` clustering means." The SKILL.md objection record format defines individual disposition fields per objection. No command, agent, or dashboard aggregates disposition values across objection records. No GC rule, health check, or observatory signal references disposition distributions.

Writing an explanation page that teaches readers to interpret a signal — clustering of `deferred — not material` dispositions — before the tooling to observe that signal exists requires manual counting across multiple markdown files. The explanation page would be more accurate if it either scoped this item to a future affordance or described the current manual approach explicitly.

---

## Explicitly not objecting to

- **The decision to create adversarial-review.md as a standalone page rather than a section in agent-orchestration.md**: The intellectual foundations (Promoter Fidei, Popper, Schopenhauer) are substantive enough to warrant their own page, and splitting them out avoids bloating the orchestration page.

- **The gap inventory table's identification of harness-upgrade as already-covered in commands.md**: The spec correctly identifies (lines 30-34) that `/harness-upgrade` is present at line 125 of commands.md and removes it from the gap list. This is accurate and appropriately removes unnecessary work.

- **The placement of the /diaboli mention in the first-time-tour's "What Happens Next" section and the workflow phase**: The spec's proposed addition ("after spec-writer when starting any feature — before plan approval") is correctly placed — it belongs in a workflow-cadence section, not a one-time setup phase.

- **The choice not to bump the plugin version**: The CLAUDE.md conventions explicitly state that docs-only changes outside `ai-literacy-superpowers/` do not require a version bump. The spec's exemption section correctly applies this rule.

- **The two-sentence description of the human-cognition gate in both the commands and agents entries**: Explaining why the agent cannot write its own dispositions is the load-bearing pedagogical point of the feature. Including it in both reference pages, even at the cost of repetition, is the right call for a concept that is deliberately counter-intuitive.
