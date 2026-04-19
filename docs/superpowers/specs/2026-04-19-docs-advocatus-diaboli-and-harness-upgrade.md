---
name: docs-advocatus-diaboli-and-harness-upgrade
description: Spec for docs site additions covering the advocatus-diaboli (v0.23.0) and harness-upgrade features plus gap-fill for the updated pipeline
date: 2026-04-19
status: approved
---

# Docs: Advocatus Diaboli and Harness Upgrade Coverage

## Problem

The v0.23.0 plugin release shipped the `advocatus-diaboli` adversarial spec review feature. The docs site has no coverage for it — `/diaboli` is absent from the commands reference, the `advocatus-diaboli` agent is missing from the agents reference (count is wrong: says 11, is 12), the orchestrator pipeline description is outdated (still shows 5-agent linear sequence), no how-to exists for running adversarial review, and the first-time tour never mentions the command.

`/harness-upgrade` (added at v0.22.0) has a how-to and appears in the tour, but the commands reference entry was already present and does not need updating.

Additionally, the agent-orchestration explanation page mentions sycophantic agents and adversarial review in passing but never names the mechanism or connects it to the diaboli feature. The intellectual foundations in the spec (Promoter Fidei, Popper, Schopenhauer) are distinctive enough to warrant a standalone explanation page.

## Objection resolution notes

*Applied after advocatus-diaboli review of this spec:*

- **O1/O2 (design/major):** The spec had used wrong category names and severity scale in proposed reference entries. The correct taxonomy (adopted by the implementation's SKILL.md update) is: categories — `premise`, `scope`, `implementation`, `risk`, `alternatives`, `specification quality`; severity — `critical`, `high`, `medium`, `low`. Reference entries below have been corrected. SKILL.md is added to the artefact list.
- **O3 (design/major):** Cap corrected to 12 in the commands reference entry (SKILL.md cap unchanged at 12). The spec had incorrectly stated "up to six."
- **O4 (failure/major):** "If present" hedge removed from artefact description of commands.md count update. It is present; it must be updated.
- **O5 (failure/minor):** First-time-tour opening count sentence added to the list of required updates.
- **O6 (failure/minor):** "If one exists" hedge removed from pipeline diagram update instruction. The diagram exists at lines 94–126 of agent-orchestration.md and must be updated.
- **O7 (design/minor):** Instruction to remove duplicate "Agents Reference" link added to agent-orchestration.md update.
- **O8 (operational/minor):** YAML frontmatter specifications (title, layout, parent, nav_order) added for all new pages.
- **O9 (design/minor):** Disposition distribution content retained — additional tooling is expected imminently.

## Approach

Add all missing docs in the smallest number of well-scoped files. Each gap maps to exactly one file addition or update.

### Gap inventory

| Gap | File | Action |
|---|---|---|
| `/diaboli` missing from commands ref | `docs/reference/commands.md` | Add entry; update count from 21 to 22 |
| Agent count wrong; advocatus-diaboli absent | `docs/reference/agents.md` | Add entry; update count; update pipeline prose and diagram |
| SKILL.md uses old category taxonomy | `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` | Update categories and severity vocabulary |
| No how-to for adversarial spec review | `docs/how-to/review-a-spec-adversarially.md` | Create |
| First-time tour missing `/diaboli` | `docs/tutorials/first-time-tour.md` | Update opening count; add to workflow phase and "What Happens Next" |
| No explanation for adversarial review concept | `docs/explanation/adversarial-review.md` | Create |
| `agent-orchestration.md` doesn't name diaboli | `docs/explanation/agent-orchestration.md` | Update pipeline diagram; update "Where This Breaks Down"; update "Further Reading" |

---

## File specifications

### 1. `docs/reference/commands.md` — add `/diaboli`

**Count update:** Change "All 21 slash commands" (line 10) to "All 22 slash commands".

**New entry** — add to the Workflow section, after `/convention-sync` and before `/worktree`:

```markdown
### /diaboli

- **Skills read**: advocatus-diaboli
- **Agents dispatched**: advocatus-diaboli

Run the adversarial spec reviewer on a spec file. Takes a path to a spec
file under `docs/superpowers/specs/` and produces a structured objection
record at `docs/superpowers/objections/<spec-slug>.md`.

The record contains up to 12 objections across six categories — premise,
scope, implementation, risk, alternatives, and specification quality — each
rated critical, high, medium, or low severity. Every objection must include
evidence quoted from the spec. The agent cannot raise objections without
grounding them in the spec text.

Objection dispositions must be written by a human before the plan-approval
gate allows the pipeline to proceed. The agent's trust boundary is
read-only — it cannot write dispositions for itself. This is the structural
mechanism that enforces human cognitive engagement before implementation
begins.

Run `/diaboli <spec-path>` after spec-writer completes and before approving
the plan. Re-run it if the spec is substantively edited after initial review.
```

### 2. `docs/reference/agents.md` — add advocatus-diaboli

**Four changes:**

**a. Count:** "11 agents" → "12 agents" in the header paragraph.

**b. Pipeline intro:** "These five agents form the spec-first development pipeline. The orchestrator dispatches them in sequence: spec, test, implement, review, integrate." →

```
These six agents form the spec-first development pipeline. The orchestrator
dispatches them in sequence: after spec-writer produces the spec, the
advocatus-diaboli reviews it adversarially and a human adjudicates the
objections before plan approval; only then do tdd-agent, code-reviewer,
and integration-agent run.
```

**c. New agent entry** — insert after spec-writer and before tdd-agent:

```markdown
### advocatus-diaboli

- **Tools**: Read, Glob, Grep
- **Dispatched by**: orchestrator (after spec-writer, before plan approval)
- **Trust boundary**: Read-only

Adversarial spec reviewer. Reads the spec file produced by spec-writer and
raises steel-manned objections across six categories: premise, scope,
implementation, risk, alternatives, and specification quality. Produces a
structured objection record at `docs/superpowers/objections/<spec-slug>.md`.

Cannot modify the spec. Cannot write objection dispositions. Both
constraints are structural: the read-only boundary makes it impossible to
alter the problem statement, and the absence of a disposition-writing tool
forces a human to open the record and adjudicate before the pipeline
proceeds. This human-cognition gate is the primary purpose of the agent —
not finding objections, but ensuring a human engages with them.
```

**d. Tool summary table** — add row after spec-writer:

```
| advocatus-diaboli | x | | | x | x | | | | read-only |
```

### 3. `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` — update taxonomy

The existing SKILL.md uses categories `premise`, `design`, `threat`, `failure`, `operational`, `cost` and severity `major`/`minor`. Update to align with the user-facing taxonomy that the docs establish:

**Categories** — replace the six `### heading` blocks and their examples with:

- **premise** — the spec solves the wrong problem, or assumes the problem exists when it may not
- **scope** — the spec includes work that is unnecessary for the problem, or excludes work that is necessary
- **implementation** — the chosen approach has a structural flaw independent of the problem being real
- **risk** — the design creates or ignores a trust, safety, or operational risk gap
- **alternatives** — a materially better approach exists and the spec does not acknowledge it
- **specification quality** — the spec is ambiguous, incomplete, or internally inconsistent in ways that would cause divergent implementations

**Severity** — replace `major`/`minor` with `critical`, `high`, `medium`, `low`:

- **critical** — if unaddressed, the feature should not proceed as described
- **high** — significant structural concern requiring substantive human decision
- **medium** — real concern warranting acknowledgement; does not block the approach
- **low** — minor note; informational, no action required before proceeding

**Cap:** Unchanged at 12 objections per spec.

**YAML frontmatter schema:** Update `severity: major|minor` to `severity: critical|high|medium|low` and `category: premise|design|threat|failure|operational|cost` to `category: premise|scope|implementation|risk|alternatives|specification quality`.

### 4. `docs/how-to/review-a-spec-adversarially.md` (new)

```yaml
---
title: Review a Spec Adversarially
layout: default
parent: How-to Guides
nav_order: 38
---
```

Structure following the pattern of `review-code-with-cupid.md` and `run-a-harness-audit.md`:

1. **When to use this** — after spec-writer completes, before approving the plan; also when a spec is substantially edited after an objection record already exists
2. **Run `/diaboli <spec-path>`** — what the command does, where the output goes
3. **Read the objection record** — structure of the record (frontmatter + prose per objection); how to interpret categories and severities
4. **Write dispositions inline** — the four disposition values; that this cannot be delegated back to an agent; why the gate exists
5. **Re-run when the spec changes** — old dispositions are lost on regeneration (intentional)
6. **What you have now** — an adjudicated objection record that unblocks the pipeline
7. **Next steps** — present the plan for approval, link to `adversarial-review.md`

The how-to must make the human-cognition gate explicit — this is not a task to delegate back to an agent.

### 5. `docs/tutorials/first-time-tour.md` — add diaboli

**Opening count:** Change "The plugin ships with twenty-one slash commands" to "The plugin ships with twenty-two slash commands" in the intro paragraph.

**Workflow phase** — add a new `/diaboli` section alongside `/worktree` and `/harness-upgrade` in Phase 7 (or the applicable workflow capabilities phase):

```
### `/diaboli`

**What it does.** Dispatches the advocatus-diaboli agent against a spec file
to produce a structured objection record at
`docs/superpowers/objections/<slug>.md`. The agent raises up to 12 objections
across six categories, each with a severity rating. Objection dispositions
must be written by a human — the agent cannot do this for itself.

**When to reach for it.** After spec-writer produces a spec and before you
approve the plan. The orchestrator invokes it automatically in the pipeline;
run it manually when working outside the full pipeline or when a spec is
substantively revised after initial review.
```

**"What Happens Next" section** — add to the between-quarters list:

```
- `/diaboli <spec-path>` after spec-writer when starting any feature — before plan approval
```

### 6. `docs/explanation/adversarial-review.md` (new)

```yaml
---
title: Adversarial Review
layout: default
parent: Explanation
nav_order: 19
---
```

Content sections:

1. **The sycophancy problem** — why agentic pipelines structurally suppress disagreement; confirmation bias in same-agent review; sunk-cost pressure on premise-level objections once artefacts exist
2. **The Promoter of the Faith** — historical precedent; the role, its abolition in 1983, and the acceleration of beatifications; the lesson: removing adversarial gates does not improve decision quality, it removes the friction quality requires
3. **Popperian falsifiability** — a spec is only as strong as the attempts to falsify it that it survives; an unchallenged spec is an untested assertion
4. **Schopenhauer's non-goal** — what the agent must not do; the 38 rhetorical stratagems for winning arguments regardless of truth are explicitly off-limits; every objection requires evidence grounded in the spec
5. **The gate mechanism** — why the agent cannot write dispositions; the read-only trust boundary; the human-cognition gate as the structural mechanism; it is not about finding objections but ensuring a human engages with them
6. **Disposition distribution as a signal** — what the pattern of dispositions over time reveals about spec quality and charter tuning; clustering of `low` severity responses signals the objection charter needs tuning; clustering of `critical` accepted signals the spec pipeline needs strengthening upstream
7. **How this fits the three loops** — adversarial review is part of the commit-time loop; objection records accumulate in `docs/superpowers/objections/` and feed the reflection and GC loops

### 7. `docs/explanation/agent-orchestration.md` — three updates

**a. Pipeline diagram** (lines 94–126) — update to show the 6-stage pipeline including the advocatus-diaboli and the human-cognition gate between spec-writer and tdd-agent:

```text
Requirements
    |
    v
[Spec Writer] --> Spec document
    |
    v
[Advocatus Diaboli] --> Objection record
    |
    v
*** HUMAN ADJUDICATES OBJECTIONS ***
    |
    v
*** HUMAN REVIEWS AND APPROVES SPEC ***
    |
    v
[Test Writer] --> Failing tests
    |
    v
(tests run automatically to confirm they fail)
    |
    v
[Implementer] --> Implementation code
    |
    v
(tests run automatically to confirm they pass)
    |
    v
[Reviewer] --> Approve / Request changes
    |                       |
    |                       v
    |               [Implementer fixes]
    |                       |
    |               [Reviewer re-checks]
    |               (max 3 cycles!)
    |                       |
    v                       v
[Integrator] --> Changelog, commit, PR, CI
```

Also update the human-gate description below the diagram: the original text focuses on spec approval; add a sentence explaining that spec approval is now preceded by an adversarial review and human adjudication of the objections.

**b. "Where This Breaks Down" section** — after the existing paragraph on "Agents that agree too easily," add:

```
The structural solution to sycophantic reviewers is not better instructions — it is a
separate agent whose entire charter is disagreement, dispatched before any
implementation artefacts exist. This is the advocatus-diaboli: a read-only agent that
reviews the spec, raises evidence-grounded objections, and cannot write its own
dispositions. The last constraint is structural: a human must open the objection record
and adjudicate before the pipeline proceeds. This is not a quality filter — it is a
cognitive-engagement gate.
```

**c. Further Reading section** — remove the duplicate "Agents Reference" link (both line 199 and 203 are identical). Add:

```
- [Adversarial Review]({% link explanation/adversarial-review.md %}) — the concepts behind the advocatus-diaboli and the human-cognition gate
```

Also update the "Key Takeaways" bullet that says "Five focused jobs, no overlap" to reflect the six-agent pipeline.

---

## Expected outcome

After this work:

- The commands reference lists all 22 commands including `/diaboli`, with correct category taxonomy and 12-objection cap
- The agents reference counts 12 agents; the pipeline intro and diagram show the 6-stage sequence with two human gates
- SKILL.md uses the established category taxonomy (premise, scope, implementation, risk, alternatives, specification quality) and severity vocabulary (critical, high, medium, low)
- A reader who runs `/diaboli` for the first time can find a how-to at `docs/how-to/review-a-spec-adversarially.md`
- The first-time tour mentions `/diaboli` with an accurate command count (22) and plugin description
- The adversarial review concept has a standalone explanation page at `docs/explanation/adversarial-review.md`
- The agent-orchestration page names the advocatus-diaboli, shows the updated pipeline, and links to the explanation page

---

## Artefacts

1. `docs/reference/commands.md` — count updated to 22; `/diaboli` entry added
2. `docs/reference/agents.md` — count updated to 12; pipeline intro updated; advocatus-diaboli entry added; tool table updated; Key Takeaways updated
3. `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` — categories and severity vocabulary updated
4. `docs/how-to/review-a-spec-adversarially.md` — new how-to (nav_order: 38)
5. `docs/tutorials/first-time-tour.md` — opening count updated; `/diaboli` section added to workflow phase; "What Happens Next" updated
6. `docs/explanation/adversarial-review.md` — new explanation page (nav_order: 19)
7. `docs/explanation/agent-orchestration.md` — pipeline diagram updated; "Where This Breaks Down" updated; "Further Reading" de-duplicated and extended; "Key Takeaways" updated

---

## Exemptions

Docs-only change. The SKILL.md update is internal to the plugin directory — it changes category vocabulary and severity vocabulary only, with no behavioural change to the command or agent flow. Per CLAUDE.md: "If the change is a fix or doc update to plugin files only, bump the patch version." However, the taxonomy change may warrant a minor bump review — check whether the frontmatter schema change in SKILL.md constitutes a behavioural change. Apply `no-bump` label if judged cosmetic-only.
