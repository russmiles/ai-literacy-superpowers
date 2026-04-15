# Feedback Flywheel Signals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add signal classification to reflections, align docs vocabulary with Boeckeler's Feedback Flywheel article, and add quality metrics to health snapshots.

**Architecture:** Three additive changes to existing plugin infrastructure. Signal classification adds a field to the reflection template and the `/reflect` command. Vocabulary alignment adds a section and links to two existing explanation pages. Quality metrics add a section to the snapshot format reference and the `/harness-health` command. No new files created (except this plan and the spec). All changes are to existing markdown files.

**Tech Stack:** Markdown (plugin commands, docs, reference files). No application code.

---

### Task 1: Update `/reflect` command with signal classification

**Files:**

- Modify: `ai-literacy-superpowers/commands/reflect.md`

- [ ] **Step 1: Add signal classification step to the `/reflect` command**

In `ai-literacy-superpowers/commands/reflect.md`, add a new step between the current step 1 (gathering fields) and step 3 (auto-constraint proposal). The updated process should read:

```markdown
## Process

1. Ask the user (or review the current session context) for:
   - What was just worked on (one sentence)
   - What was surprising or unexpected
   - What should future agents know about this area of the codebase

1. Format the entry:

   ```text
   ---

   - **Date**: [today's date in YYYY-MM-DD]
   - **Agent**: [you / the agent that did the work]
   - **Task**: [what was done]
   - **Surprise**: [what was unexpected]
   - **Proposal**: [what to add to AGENTS.md, or "none"]
   - **Improvement**: [what would make the process better]
   - **Signal**: [context | instruction | workflow | failure | none]
   - **Constraint**: [proposed constraint, or "none"]
   ```

1. **Signal classification** — review the Surprise and Improvement
   fields and classify the signal type:

   | Signal | When to use | Routes to |
   | --- | --- | --- |
   | `context` | Gap in priming — missing convention, outdated stack info, incomplete domain knowledge | HARNESS.md Context section |
   | `instruction` | A prompt or command produced notably better or worse results | Skills or shared commands |
   | `workflow` | A sequence or process pattern reliably succeeded or failed | AGENTS.md (STYLE, ARCH_DECISIONS) |
   | `failure` | A preventable error — missing check, wrong tool config, boundary condition | Constraints via `/harness-constrain` |
   | `none` | No classifiable signal — routine work, nothing novel | No routing needed |

   - Propose the signal type to the user with a one-sentence rationale
   - The user confirms or overrides the classification
   - If the signal is `failure`, this feeds directly into the
     auto-constraint step that follows

1. **Auto-constraint proposal** — review the Surprise and Improvement
   fields of the entry you just formatted:

   - If either field describes a preventable failure (e.g. a lint error
     that slipped through, a wrong branch, a missing check, a tool that
     should have caught something), offer to draft a constraint.
   - Propose the constraint to the user with:
     - **Rule**: one-sentence description of what the constraint enforces
     - **Enforcement**: `deterministic` or `agent`
     - **Tool**: the command or tool that checks it (if known)
     - **Scope**: when it runs (e.g. `commit`, `pr`, `session-end`)
   - If the user **accepts**, invoke `/harness-constrain` with the
     proposed rule, enforcement type, tool, and scope. Record the
     constraint in the reflection entry:
     `- **Constraint**: [short description] ([enforcement type])`
   - If the user **declines**, record:
     `- **Constraint**: none`
   - If neither field describes a preventable failure, skip this step
     and record:
     `- **Constraint**: none`

1. Append the entry to `REFLECTION_LOG.md` (after the last existing
   entry, preserving the `---` separator)

1. Do NOT modify `AGENTS.md` — only humans edit that file. If the
   reflection contains a proposal, note it and let the human decide.

1. Commit the updated REFLECTION_LOG.md:

   ```bash
   git add REFLECTION_LOG.md
   git commit -m "Add reflection: [one-line summary of the task]"
   ```

```

The key changes from the current file:
- The entry template now includes `- **Signal**: [context | instruction | workflow | failure | none]` between Improvement and Constraint
- A new step 3 "Signal classification" is added between step 2 (format entry) and what was step 3 (now step 4, auto-constraint proposal)
- The auto-constraint step is renumbered from 3 to 4; subsequent steps renumber accordingly

- [ ] **Step 2: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/commands/reflect.md`
Expected: No errors (or only pre-existing warnings)

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/commands/reflect.md
git commit -m "Add signal classification step to /reflect command

Reflections now classify signal type (context, instruction, workflow,
failure, none) before the auto-constraint step. Signal type is proposed
by the agent and confirmed by the user."
```

---

### Task 2: Update REFLECTION_LOG.md header comment

**Files:**

- Modify: `REFLECTION_LOG.md`

- [ ] **Step 1: Update the header comment to include the Signal field**

Replace the existing header comment block in `REFLECTION_LOG.md` with:

```markdown
<!-- Each entry is appended by integration-agent at the end of a pipeline run.
     Entries capture what was surprising, what went wrong, and what should be
     proposed for addition to AGENTS.md.

     Do NOT modify AGENTS.md directly from this log — only propose. Humans
     curate AGENTS.md. The value of this log is that it provides the raw
     material for curation, not that it auto-populates memory.

     Entry format:

     ---

     - **Date**: YYYY-MM-DD
     - **Agent**: integration-agent
     - **Task**: [one-sentence summary]
     - **Surprise**: [anything unexpected during the pipeline run]
     - **Proposal**: [pattern or gotcha to consider for AGENTS.md, or "none"]
     - **Improvement**: [what would make the pipeline smoother next time]
     - **Signal**: [context | instruction | workflow | failure | none]
     - **Constraint**: [proposed constraint, or "none"]

     Signal types classify where the learning should route:
       context     → HARNESS.md Context section (priming gaps)
       instruction → Skills or shared commands (prompt improvements)
       workflow    → AGENTS.md (process patterns)
       failure     → Constraints via /harness-constrain (preventable errors)
       none        → No routing needed (routine work)

     Entries written before 2026-04-08 predate the Signal field.
     Treat missing Signal fields as "none" when computing metrics.

     -->
```

The key additions:

- `Signal` field added to the entry format template
- Signal type routing table added below the format
- Backwards-compatibility note for pre-existing entries

- [ ] **Step 2: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 REFLECTION_LOG.md`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add REFLECTION_LOG.md
git commit -m "Add Signal field to REFLECTION_LOG.md header comment

Update the entry format template to include the signal classification
field with routing table. Note backwards compatibility for pre-existing
entries."
```

---

### Task 3: Update self-improving-harness.md docs

**Files:**

- Modify: `docs/explanation/self-improving-harness.md`

- [ ] **Step 1: Update "What Gets Captured" section**

In `docs/explanation/self-improving-harness.md`, find the "What Gets Captured" section (around line 20-40). Replace the entry template and the field descriptions.

The template block (lines 24-34) should become:

```text
---

- **Date**: YYYY-MM-DD
- **Agent**: [who did the work]
- **Task**: [one-sentence summary]
- **Surprise**: [anything unexpected during the work]
- **Proposal**: [pattern or gotcha to consider for AGENTS.md, or "none"]
- **Improvement**: [what would make the process smoother next time]
- **Signal**: [context | instruction | workflow | failure | none]
- **Constraint**: [proposed constraint text, or "none"]
```

After the existing paragraph about the **Constraint** field (line 40), add a new paragraph:

```markdown
The **Signal** field classifies what kind of learning the reflection represents, using the taxonomy from Birgitta Boeckeler's [Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html). A `context` signal means the priming document was missing something -- a convention, a version, a domain detail. An `instruction` signal means a prompt or command produced notably better or worse results. A `workflow` signal means a process pattern succeeded or failed in a way worth recording. A `failure` signal means the error was preventable -- a check that should have run, a tool that was misconfigured. The classification guides where the learning should route during curation: context signals route to HARNESS.md, instruction signals to skills or commands, workflow signals to AGENTS.md, and failure signals to constraints.
```

- [ ] **Step 2: Update "The `/reflect` Command" section**

In the same file, find "The `/reflect` Command" section (around line 47-56). The numbered list currently has 6 steps. Insert a new step 3 between the current steps 2 and 3:

Replace the current list:

```markdown
1. Gather context -- what was worked on, what was surprising, what should future agents know.
2. Format the entry using the standard template.
3. Run the auto-constraint proposal step: review the Surprise and Improvement fields for preventable failures. If one is found, draft a constraint with a rule, enforcement type, tool, and scope.
4. If the user accepts the proposed constraint, invoke `/harness-constrain` to add it to `HARNESS.md` immediately. Record the constraint in the reflection entry.
5. Append the entry to `REFLECTION_LOG.md`.
6. Commit the updated log.
```

With:

```markdown
1. Gather context -- what was worked on, what was surprising, what should future agents know.
2. Format the entry using the standard template.
3. Classify the signal type: review the Surprise and Improvement fields and propose a signal type (`context`, `instruction`, `workflow`, `failure`, or `none`) with a one-sentence rationale. The user confirms or overrides.
4. Run the auto-constraint proposal step: review the Surprise and Improvement fields for preventable failures. If one is found, draft a constraint with a rule, enforcement type, tool, and scope. A `failure` signal from step 3 feeds directly into this step.
5. If the user accepts the proposed constraint, invoke `/harness-constrain` to add it to `HARNESS.md` immediately. Record the constraint in the reflection entry.
6. Append the entry to `REFLECTION_LOG.md`.
7. Commit the updated log.
```

- [ ] **Step 3: Add Feedback Flywheel article to Further Reading**

At the end of `docs/explanation/self-improving-harness.md`, in the "Further reading" section (line 245-252), add a new entry:

```markdown
- [The Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) -- Birgitta Boeckeler's framework for converting session-level learning into shared infrastructure through four signal types and four cadences
```

- [ ] **Step 4: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 docs/explanation/self-improving-harness.md`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add docs/explanation/self-improving-harness.md
git commit -m "Add signal classification to self-improving harness docs

Update reflection template, field descriptions, and /reflect command
process to include the Signal field. Add Feedback Flywheel article to
further reading."
```

---

### Task 4: Add vocabulary mapping to compound-learning.md

**Files:**

- Modify: `docs/explanation/compound-learning.md`

- [ ] **Step 1: Add "Relationship to the Feedback Flywheel" section**

In `docs/explanation/compound-learning.md`, insert a new section after "Three Loops, One System" (after line 128, the link to Three Enforcement Loops) and before the `---` that precedes the FAQ section (line 129).

Insert this content between line 128 and line 129:

```markdown

---

## Relationship to the Feedback Flywheel

Birgitta Boeckeler's [Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) describes the same compound improvement mechanism using different vocabulary. The article is part of her [series on reducing friction with AI](https://martinfowler.com/articles/reduce-friction-ai/) on martinfowler.com — the same body of work that introduced harness engineering.

The mapping between the article's terms and this plugin's implementation:

| Feedback Flywheel term | Plugin equivalent |
| --- | --- |
| Feedback flywheel | The three-loop system (inner / middle / outer) |
| Priming document | HARNESS.md Context section + CLAUDE.md |
| Shared commands | Skills and slash commands |
| Team playbooks | AGENTS.md (STYLE, GOTCHAS, ARCH_DECISIONS) |
| Guardrails | Constraints + enforcement loops |
| Learning log | REFLECTION_LOG.md |
| Four signals (context, instruction, workflow, failure) | The `Signal` field on reflections |
| Four cadences (session, daily, retro, quarterly) | Stop hooks (session), snapshots (monthly), audit/assess (quarterly) |

The article's core insight — that every AI interaction generates exploitable signal, and that teams plateau when they lack mechanisms to convert individual learning into collective practice — is exactly what the three-loop system implements. The signal classification on reflections (the `Signal` field) adopts the article's four-signal taxonomy directly, giving each reflection an explicit routing destination during curation.

Where the article describes four cadences, this plugin automates the session-level cadence through Stop hooks and provides commands for the periodic cadences. The daily and sprint-level cadences are team process rather than plugin infrastructure — they require a conversation at standup, not a tool invocation.
```

- [ ] **Step 2: Add Feedback Flywheel to Further Reading**

At the end of `docs/explanation/compound-learning.md`, in the "Further reading" section (line 169-175), add a new entry:

```markdown
- [The Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) — Birgitta Boeckeler's framework for converting session-level learning into shared infrastructure, part of her series on [reducing friction with AI](https://martinfowler.com/articles/reduce-friction-ai/)
```

- [ ] **Step 3: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 docs/explanation/compound-learning.md`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add docs/explanation/compound-learning.md
git commit -m "Add Feedback Flywheel vocabulary mapping to compound learning docs

New section maps Boeckeler's Feedback Flywheel terminology to plugin
equivalents. Cites and links the article directly. Adds to further
reading."
```

---

### Task 5: Add Session Quality section to snapshot format

**Files:**

- Modify: `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`

- [ ] **Step 1: Add Session Quality section definition**

In `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`, insert a new section after `Compound Learning` (after line 95, which ends the Compound Learning section) and before `Operational Cadence` (line 97).

Insert this content:

```markdown

### Session Quality

```text
## Session Quality

- Reflections with signal: N/M (P%)
- Signal distribution: context: X | instruction: Y | workflow: Z | failure: W
- Quality trend: improving/stable/declining (vs previous snapshot)
```

**Source:** REFLECTION_LOG.md Signal fields.

| Field | How to compute |
| ------- | --------------- |
| Reflections with signal | Count reflections where Signal field exists and is not "none", divided by total reflections. Entries predating the Signal field (before 2026-04-08) count as "none". |
| Signal distribution | Count of each signal type across all reflections (cumulative, not just since last snapshot) |
| Quality trend | Compare "reflections with signal" percentage to previous snapshot. stable = ±2%, improving = >+2%, declining = <-2% |

```

- [ ] **Step 2: Add row to Trends table**

In the same file, find the Trends section table (around line 143-155). Add a new row after the `Promotions` row and before the `GC findings` row:

```markdown
| Reflections with signal | P% (N/M) | P% (N/M) | ±N% |
```

- [ ] **Step 3: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md
git commit -m "Add Session Quality section to snapshot format reference

New section tracks signal classification metrics: reflections with
signal percentage, signal distribution by type, and quality trend.
Adds corresponding row to the Trends table."
```

---

### Task 6: Update /harness-health command

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-health.md`

- [ ] **Step 1: Add REFLECTION_LOG.md Signal fields to data gathering**

In `ai-literacy-superpowers/commands/harness-health.md`, find the Quick Mode data sources list (around line 14-22). Add a new bullet after the REFLECTION_LOG.md entry:

Replace:

```markdown
- REFLECTION_LOG.md → entry count, latest date
```

With:

```markdown
- REFLECTION_LOG.md → entry count, latest date, Signal field values
```

- [ ] **Step 2: Add Session Quality to snapshot generation**

In the same file, find step 6 "Generate Snapshot" (around line 88-95). The section says to include all sections. Update the list to include Session Quality:

Replace:

```markdown
Include all sections: Enforcement, Garbage Collection, Mutation Testing,
Compound Learning, Operational Cadence, Cost Indicators, Meta, and
Trends (if previous snapshot exists).
```

With:

```markdown
Include all sections: Enforcement, Garbage Collection, Mutation Testing,
Compound Learning, Session Quality, Operational Cadence, Cost Indicators,
Meta, and Trends (if previous snapshot exists).
```

- [ ] **Step 3: Add Session Quality to the delta summary**

In the same file, find step 8 "Print Summary" (around line 108-118). Add a line to the delta summary output:

Replace:

```text
Since last snapshot (YYYY-MM-DD):
  Constraints: N/M → N/M (unchanged/changed)
  Mutation (Go): N% → N% (±N%)
  Reflections: N → N (+N)
  Cadence: on schedule / overdue
  Health: Healthy / Attention / Degraded
```

With:

```text
Since last snapshot (YYYY-MM-DD):
  Constraints: N/M → N/M (unchanged/changed)
  Mutation (Go): N% → N% (±N%)
  Reflections: N → N (+N)
  Reflections with signal: P% → P% (±N%)
  Cadence: on schedule / overdue
  Health: Healthy / Attention / Degraded
```

- [ ] **Step 4: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-health.md`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-health.md
git commit -m "Add Session Quality metrics to /harness-health command

Update data gathering to read Signal fields from REFLECTION_LOG.md.
Add Session Quality section to snapshot generation. Include signal
percentage in delta summary output."
```

---

### Task 7: Update CHANGELOG and final commit

**Files:**

- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add changelog entry**

At the top of `CHANGELOG.md`, under the existing `## 2026-04-08` heading, add a new group before the existing "Documentation Fixes" group:

```markdown
### Feedback Flywheel Integration

- Add signal classification to reflections — each reflection now
  captures a signal type (context, instruction, workflow, failure, none)
  that routes the learning to the right harness component during curation,
  adopting the taxonomy from Birgitta Boeckeler's Feedback Flywheel article
- Add vocabulary mapping section to compound learning docs — maps plugin
  concepts to the Feedback Flywheel article's terminology with direct
  citation and links
- Add Feedback Flywheel article to further reading in compound learning
  and self-improving harness explanation pages
- Add Session Quality section to health snapshot format — tracks signal
  classification metrics (reflections with signal percentage, distribution
  by type, quality trend) derived from the new Signal field
- Update /harness-health command to gather and display Session Quality
  metrics in snapshots and delta summaries
```

- [ ] **Step 2: Verify the file is valid markdown**

Run: `npx markdownlint-cli2 CHANGELOG.md`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add CHANGELOG.md
git commit -m "Update CHANGELOG for feedback flywheel integration"
```
