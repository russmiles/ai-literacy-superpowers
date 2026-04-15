# Selective Harness Init Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a feature selection step to `/harness-init` so users choose which harness features to configure, with additive re-run support.

**Architecture:** The only file that changes is the command prompt `ai-literacy-superpowers/commands/harness-init.md`. The template, agents, CI templates, and scripts are unchanged. The command gains a new step 3 (feature selection menu) and each subsequent step gets a gate condition based on the user's selections.

**Tech Stack:** Markdown (Claude Code command prompt format)

**Spec:** `docs/superpowers/specs/2026-04-07-selective-harness-init-design.md`

---

## Task 1: Add the feature selection step after discovery

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md:16-30`

This task inserts a new step 3 between "Present Findings" and the current "Ask About Conventions" step, and renumbers all subsequent steps.

- [ ] **Step 1: Insert the feature selection step**

After the current `### 2. Present Findings` section (line 23-30), add a new `### 3. Select Features` section. The full content to insert after line 30:

```markdown
### 3. Select Features

Present a feature selection menu. The five selectable areas are:

| Feature | What it configures | Default (first run) |
|---|---|---|
| Context engineering | Stack declaration + conventions | on |
| Architectural constraints | Enforcement rules + secret detection | on |
| Garbage collection | Periodic entropy checks | on |
| CI configuration | GitHub Actions workflow + auto-enforcer | on |
| Observability | README badge + status section | on |

**First run** (no HARNESS.md exists): all features default to on.

**Re-run** (HARNESS.md exists): detect which sections are already
configured by checking for the placeholder marker
`<!-- Not yet configured. Run /harness-init and select this feature to set up. -->`
in each section. Already-configured sections default to off (skip).
Unconfigured sections default to on. The user can toggle any combination.

Tell the user: "All features are selected by default. Deselect any you
want to skip for now — you can always add them later by re-running
/harness-init."

On re-run, tell the user which features are already configured and
frame unconfigured features as recommendations: "These features aren't
set up yet. I recommend adding them."
```

- [ ] **Step 2: Renumber steps 3-10 to 4-11**

The current steps are numbered 3 through 10. Renumber them to 4 through 11:

- `### 3. Ask About Conventions` becomes `### 4. Ask About Conventions`
- `### 4. Ask About Constraints` becomes `### 5. Ask About Constraints`
- `### 5. Ask About Garbage Collection` becomes `### 6. Ask About Garbage Collection`
- `### 6. Generate HARNESS.md` becomes `### 7. Generate HARNESS.md`
- `### 7. Generate CI Configuration` becomes `### 8. Generate CI Configuration`
- `### 8. Add README Badge` becomes `### 9. Add README Badge`
- `### 9. Commit` becomes `### 10. Commit`
- `### 10. Summary` becomes `### 11. Summary`

- [ ] **Step 3: Verify the renumbering is consistent**

Read through the full file and check that:

- No step number is duplicated
- No step references an old number in its body text
- The flow reads correctly from 1 through 11

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Add feature selection step to harness-init command"
```

---

## Task 2: Gate convention and constraint steps on feature selection

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md` (steps 4 and 5)

This task adds conditional gates so the conversational steps only run when their feature is selected.

- [ ] **Step 1: Add gate to the conventions step**

At the top of `### 4. Ask About Conventions` (formerly step 3), add:

```markdown
**Gate**: only run this step if "Context engineering" was selected in
step 3. If not selected, skip to the next step silently.
```

- [ ] **Step 2: Add gate to the constraints step**

At the top of `### 5. Ask About Constraints` (formerly step 4), add:

```markdown
**Gate**: only run this step if "Architectural constraints" was selected
in step 3. If not selected, skip to the next step silently.
```

- [ ] **Step 3: Add gate to the garbage collection step**

At the top of `### 6. Ask About Garbage Collection` (formerly step 5), add:

```markdown
**Gate**: only run this step if "Garbage collection" was selected in
step 3. If not selected, skip to the next step silently.
```

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Gate convention, constraint, and GC steps on feature selection"
```

---

## Task 3: Update HARNESS.md generation for additive mode

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md` (step 7, formerly step 6)

This task rewrites the generation step to support both first-run and additive re-run modes.

- [ ] **Step 1: Rewrite the Generate HARNESS.md step**

Replace the current content of `### 7. Generate HARNESS.md` with:

```markdown
### 7. Generate HARNESS.md

**First run** (no HARNESS.md exists):

Read the template from `${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.
For each selected feature, replace placeholder values with discovered
facts and user responses as before. For each unselected feature, replace
the section body with the placeholder marker:

```markdown
<!-- Not yet configured. Run /harness-init and select this feature to set up. -->
```

Write the result to `HARNESS.md` at the project root.

**Re-run** (HARNESS.md exists):

Read the existing `HARNESS.md`. For each selected feature, replace the
corresponding section (`## Context`, `## Constraints`,
`## Garbage Collection`, or `## Status`) with freshly generated content
from user responses. For unselected features, preserve the existing
section content verbatim — do not modify it.

Section boundaries are defined by the `##` headings in the template:
`## Context`, `## Constraints`, `## Garbage Collection`, `## Status`.
Each section runs from its `##` heading to the next `##` heading or
end of file.

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Update HARNESS.md generation for additive re-run support"
```

---

## Task 4: Gate CI and observability steps with dependency handling

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md` (steps 8 and 9)

- [ ] **Step 1: Add gate and dependency logic to CI configuration step**

Replace the opening of `### 8. Generate CI Configuration` with:

```markdown
### 8. Generate CI Configuration

**Gate**: only run this step if "CI configuration" was selected in
step 3.

**Dependency**: CI configuration requires constraints to exist. If
"Architectural constraints" was not selected in step 3 and no
`## Constraints` section exists in HARNESS.md (or it contains only the
placeholder marker), tell the user: "CI configuration requires at least
one constraint to enforce. Skipping CI setup — run /harness-init again
after adding constraints." Then skip to the next step.

If constraints exist (either just configured or from a previous run),
proceed with the existing CI generation logic:
```

Keep the rest of the step (GitHub Actions generation, auto-enforcer offer) unchanged.

- [ ] **Step 2: Add gate and dependency logic to observability step**

Replace the opening of `### 9. Add README Badge` with:

```markdown
### 9. Add README Badge

**Gate**: only run this step if "Observability" was selected in step 3.

**Dependency**: the badge requires HARNESS.md to exist with at least
one configured section. If HARNESS.md contains only placeholder markers
(no real content was generated), tell the user: "No harness features
configured yet — skipping badge. Run /harness-init to add features
first." Then skip to the next step.

If HARNESS.md has content, proceed with badge generation as before:
```

Keep the rest of the step unchanged.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Gate CI and observability steps with dependency checks"
```

---

## Task 5: Update the summary step to show configuration status

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md` (step 11, formerly step 10)

- [ ] **Step 1: Rewrite the summary step**

Replace the content of `### 11. Summary` with:

```markdown
### 11. Summary

Tell the user:

- Which features were configured in this run
- How many constraints were declared and how many are enforced (if
  constraints were configured)
- Which features remain unconfigured, framed as next steps:
  "To add garbage collection later, run /harness-init and select it"
- What to do next: `/harness-constrain` to add more rules,
  `/harness-status` to check health, `/harness-audit` to verify
  enforcement
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Update summary step to show per-feature configuration status"
```

---

## Task 6: Update the command description and re-run check

**Files:**

- Modify: `ai-literacy-superpowers/commands/harness-init.md` (frontmatter and step 1)

- [ ] **Step 1: Update the frontmatter description**

Change the frontmatter `description` field from:

```yaml
description: Set up a living harness for this project — discover the stack, define conventions, generate HARNESS.md with enforcement
```

to:

```yaml
description: Set up a living harness for this project — select features, discover the stack, define conventions, generate HARNESS.md with enforcement. Re-run to add features incrementally.
```

- [ ] **Step 2: Update the introduction paragraph**

Change the opening paragraph (line 7-9) from:

```markdown
Set up a living harness for this project. This is the guided on-ramp
that produces a working HARNESS.md from a conversation.
```

to:

```markdown
Set up a living harness for this project. Choose which features to
configure — context engineering, constraints, garbage collection, CI,
and observability — then walk through a guided conversation for each.
Re-run at any time to add features incrementally; existing
configuration is preserved.
```

- [ ] **Step 3: Update the Discover step for re-run awareness**

In `### 1. Discover`, after the line about dispatching the harness-discoverer agent, add:

```markdown
Also check whether `HARNESS.md` already exists. If it does, note which
sections contain real content (not the placeholder marker
`<!-- Not yet configured. Run /harness-init and select this feature to set up. -->`).
Pass this information to the feature selection step so it can set
appropriate defaults.
```

Remove the existing re-initialisation check ("Checks if HARNESS.md already
exists / Asks user if they want to re-initialize") since the feature
selection menu now handles this naturally — users pick what to reconfigure.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Update command description and discovery for selective re-run"
```

---

## Task 7: Update CHANGELOG and create PR

**Files:**

- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add CHANGELOG entry**

Add a new section under `## 2026-04-07`:

```markdown
### Selective Harness Init

- Enhance /harness-init with feature selection menu — users choose which
  harness features to configure (context, constraints, GC, CI,
  observability) with all selected by default
- Support additive re-runs — existing configuration is preserved when
  adding new features incrementally
- Gate each conversational step on feature selection so users only
  answer questions for features they chose
```

- [ ] **Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "Add changelog entry for selective harness-init"
```

- [ ] **Step 3: Push and create PR**

```bash
git push -u origin <branch-name>
gh pr create --title "Enhance harness-init with selective feature configuration" --body "..."
```

- [ ] **Step 4: Watch CI and verify green**

```bash
gh pr checks <number> --watch
```
