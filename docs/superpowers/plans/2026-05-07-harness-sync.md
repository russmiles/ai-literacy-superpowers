# /harness-sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `/harness-sync` command to `ai-literacy-superpowers` that consolidates push-direction propagation from `HARNESS.md` to all control surfaces under one human-instigated entry point, then ship it as v0.33.0 with the docs cascade.

**Architecture:** A new markdown command prompt at `ai-literacy-superpowers/commands/harness-sync.md` that orchestrates three phases (drift scan → multi-select → apply with verification) and composes existing primitives (`/convention-sync`, `/harness-onboarding`). No new skill, no new agent. Trust boundary: never writes to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md` (enforced via a pre-commit allow-list guard inside the command). Branch enforcement at start-of-run refuses to apply on `main` and offers to create a `chore/sync-surfaces-YYYY-MM-DD` branch.

**Tech Stack:** Plain markdown command prompt (Claude Code plugin format), Bash for shell-script-style steps in the prompt, `gh` CLI for the PR step, `markdownlint` for lint validation, the existing `convention file sync` and `ONBOARDING.md staleness` GC rules for drift detection.

**Spec:** [`docs/superpowers/specs/2026-05-07-harness-sync-design.md`](../specs/2026-05-07-harness-sync-design.md) — committed as the first commit on this branch (`df7bc52`).

**Branch:** `feat-harness-sync` — feature branch (no `chore/` prefix, so the spec-first-check workflow runs and validates the discipline).

**Tracked deferred follow-up:** Issue #256 — HARNESS.md template update after this PR ships.

---

## Task 1: Research — read existing command files for format reference

**Files:**
- Read: `ai-literacy-superpowers/commands/reflect.md`
- Read: `ai-literacy-superpowers/commands/convention-sync.md`
- Read: `ai-literacy-superpowers/commands/harness-onboarding.md`
- Read: `ai-literacy-superpowers/commands/harness-init.md`

This task produces no commits. It establishes the format conventions the new command file must follow.

- [ ] **Step 1: Read `commands/reflect.md`**

Note its frontmatter, the structure of its numbered process list, how it handles user interaction, and how it handles the PR workflow at the end.

- [ ] **Step 2: Read `commands/convention-sync.md`**

This is one of the underlying primitives the new command will compose. Note its inputs, outputs, and any interactive prompts.

- [ ] **Step 3: Read `commands/harness-onboarding.md`**

The other underlying primitive. Note same as Step 2.

- [ ] **Step 4: Read `commands/harness-init.md`**

This is the closest existing command to a multiplexer (it does selective feature configuration). Note its multi-select pattern.

- [ ] **Step 5: Capture conventions in a working note**

In your scratchpad (do not commit), record the format conventions you'll apply to `harness-sync.md`:
- Frontmatter shape (description field, any other fields)
- Heading style (`#` levels)
- Numbered process list vs bullet list
- How interactive prompts are described
- How the PR workflow is described

---

## Task 2: Write the `/harness-sync` command file

**Files:**
- Create: `ai-literacy-superpowers/commands/harness-sync.md`

This is the load-bearing change. The command file is a structured prompt; "implementation" is the prompt content.

- [ ] **Step 1: Create the file with frontmatter**

Open the new file. Write the frontmatter using the convention you noted in Task 1 Step 5. Description field should match the spec §1 summary in one sentence:

```yaml
---
description: Detect drift across all push-direction control surfaces, present the full picture, and apply the user's selected fixes via the existing primitives — single human-instigated entry point for keeping convention files and ONBOARDING.md in sync with HARNESS.md.
---
```

- [ ] **Step 2: Write the command title and overview**

Below the frontmatter, write a `# /harness-sync` heading and a one-paragraph overview explaining what the command does and what it does not do (it does not write to HARNESS.md/AGENTS.md/REFLECTION_LOG.md; it does not pull upstream changes — that's `/harness-upgrade`).

- [ ] **Step 3: Write the invocation forms section**

Document `/harness-sync` (interactive) and `/harness-sync --check` (drift scan only, no apply). Mention that `--check` is useful for dry-run from CI or `/harness-health --deep`.

- [ ] **Step 4: Write the branch enforcement section (start-of-run check)**

Per spec §4. The prompt instructs the agent to:

1. Read the current branch via `git branch --show-current`.
2. If the branch is `main`: refuse to apply changes; ask the user whether to create `chore/sync-surfaces-YYYY-MM-DD` (substituting today's date), accept a custom name if the user prefers, then `git checkout -b` the chosen branch.
3. If the branch is anything else: proceed without creating a new branch.

Include the exact bash incantations and the user-facing prompt wording.

- [ ] **Step 5: Write the working-tree-clean check**

Per spec §6 row 1. The prompt instructs the agent to run `git status --porcelain` and refuse to proceed if the output is non-empty, listing the dirty paths and suggesting `git stash` or commit-first.

- [ ] **Step 6: Write Phase 1 — Drift scan**

Per spec §3. The prompt instructs the agent to:

1. Read `HARNESS.md` and the relevant generated files.
2. For each surface in the allow-list:
   - `.cursor/rules/` — agent-evaluate against current HARNESS.md (reuses the `convention file sync` GC rule's check description)
   - `.github/copilot-instructions.md` — same
   - `.windsurf/rules/` — same
   - `ONBOARDING.md` — agent-evaluate against `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md` modified-time (reuses the `ONBOARDING.md staleness` GC rule's check description)
   - CI / CD (constraint scope) — always reported as `managed` (status, not action)
3. Build the structured table per spec §3.
4. Print the table and the summary line ("N surfaces tracked · N drifted · N missing · N in sync · N managed at runtime").

The prompt MUST instruct the agent to reuse the existing GC-rule detection descriptions (do not invent new drift criteria). Reference the GC rules in `HARNESS.md` by name.

- [ ] **Step 7: Write Phase 2 — Selection**

Per spec §3. The prompt instructs the agent to use `AskUserQuestion` with `multiSelect: true`, listing each `drifted` or `missing` surface as a separate option, plus an "Apply nothing — exit without changes" option. Default selection is all drifted/missing surfaces. The `managed` row never appears as a selectable option.

Provide the exact AskUserQuestion JSON shape the agent should use.

- [ ] **Step 8: Write Phase 3 — Apply**

Per spec §3. The prompt instructs the agent to invoke `/convention-sync` and/or `/harness-onboarding` for each selected surface (in series, not parallel — order matters for the verification scan). After all selected surfaces are applied, re-run the drift scan (Phase 1) as verification and produce the delta table.

- [ ] **Step 9: Write the trust-boundary pre-commit guard**

Per spec §5. Before committing, the prompt instructs the agent to:

1. Run `git diff --name-only --cached` to list staged paths.
2. Verify every staged path matches the allow-list:
   - `.cursor/rules/**`
   - `.github/copilot-instructions.md`
   - `.windsurf/rules/**`
   - `ONBOARDING.md`
3. If any staged path is outside the allow-list, refuse to commit and surface this as a bug in the underlying primitive (do not silently un-stage and continue).

Include the exact bash check the agent should run.

- [ ] **Step 10: Write the commit / push / PR section**

Per spec §4. Two paths:

**Fresh `chore/` branch (created in Step 4):**

1. Run `git add` for the surface files only.
2. Commit with `git commit -m "chore: sync convention files and ONBOARDING.md to HARNESS.md"` (parameterise the message based on which surfaces were applied).
3. Push with `git push -u origin <branch>`.
4. Open PR with `gh pr create --label chore --title "chore: sync surfaces to HARNESS.md" --body "<auto-generated>"`. The auto-generated body must include the before/after drift scan table and a "Why these changes" line linking to the latest HARNESS.md constraint changes (parsed from `git log`).
5. Report the PR URL plus the verification delta.

**Existing feature branch (Step 4 skipped):**

1. `git add` and `git commit` only.
2. Do not push, do not open a PR.
3. Report the commit hash and a hint that the user should push when ready.

- [ ] **Step 11: Write the error and refusal cases section**

Per spec §6. Document each row of the error table as a behaviour the prompt must follow.

- [ ] **Step 12: Write the idempotency note**

Per spec §6. The prompt should explicitly state: "Running `/harness-sync` twice consecutively with no HARNESS.md changes between runs MUST be a no-op on the second run."

- [ ] **Step 13: Write the output format section**

Per spec §7. Show the example output the prompt should produce on success.

- [ ] **Step 14: Add the validation checkpoint section**

Per `CLAUDE.md`'s "Output Validation Checkpoints" rule. The new command writes structured output (the verification scan table) that downstream tools may parse, so it must include a validation checkpoint that re-reads the table after generation and verifies its structure matches the spec.

- [ ] **Step 15: Save the file**

The file should now be complete. Estimated length: 200–300 lines.

- [ ] **Step 16: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-sync.md
git commit -m "feat: add /harness-sync command for unified surface sync"
```

---

## Task 3: Lint and structurally validate the command file

**Files:**
- Test: `ai-literacy-superpowers/commands/harness-sync.md`

- [ ] **Step 1: Run markdownlint locally on the new file**

```bash
npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-sync.md
```

Expected: no errors. The repo's lint config requires underscore emphasis (`_..._` not `*...*`) — be careful when writing emphasis. PR references like `#248` at line-start trigger MD018 — keep them mid-line.

- [ ] **Step 2: If lint fails, fix in place and re-run**

Common issues from this session:
- MD049 (emphasis style) — change `*foo*` to `_foo_`
- MD018 (no space after hash) — `#NNN` at line start; rewrap so it's mid-line

- [ ] **Step 3: Structural sanity check against the convention from Task 1**

Manually verify:
- Frontmatter present and valid YAML
- Heading hierarchy is consistent (one `#`, multiple `##`, `###` for sub-sections)
- Numbered process list matches the convention used by `reflect.md` / `harness-init.md`
- All references to other commands (`/convention-sync`, `/harness-onboarding`) use backticks

- [ ] **Step 4: Commit any lint or structural fixes**

```bash
git add ai-literacy-superpowers/commands/harness-sync.md
git commit -m "fix: address lint and structural feedback in harness-sync.md"
```

(Skip this commit if Steps 1 and 3 produced no changes.)

---

## Task 4: Bump plugin version (3 of 4 locations)

**Files:**
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `README.md`
- Modify: `.claude-plugin/marketplace.json`

(The fourth location, `CHANGELOG.md`, is its own task because the entry content is substantial.)

- [ ] **Step 1: Read current version from plugin.json**

```bash
grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json
```

Expected: `"version": "0.32.0"`. If the value is anything else, stop and reconcile — the plan was written assuming 0.32.0 was the current version.

- [ ] **Step 2: Update plugin.json**

Edit `ai-literacy-superpowers/.claude-plugin/plugin.json` and change `"version": "0.32.0"` to `"version": "0.33.0"`.

- [ ] **Step 3: Update README.md badge**

Edit `README.md`. Find the line containing `ai--literacy--superpowers-v0.32.0` (note the doubled hyphens — shields.io renders single hyphens in the label as double hyphens in the URL). Change to `ai--literacy--superpowers-v0.33.0`.

Verify with:

```bash
grep 'ai--literacy--superpowers-v0' README.md
```

Expected: `0.33.0` only.

- [ ] **Step 4: Update marketplace.json**

Edit `.claude-plugin/marketplace.json`. Find the `"plugin_version"` field (top-level or per-plugin entry — check the structure). Change from `"0.32.0"` to `"0.33.0"`.

Verify with:

```bash
grep -E '"plugin_version"|"version"' .claude-plugin/marketplace.json
```

Expected: every plugin entry's `version` field plus the top-level `plugin_version` reflects the bump.

- [ ] **Step 5: Verify all three files are consistent**

```bash
grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json
grep 'ai--literacy--superpowers-v0' README.md
grep '"plugin_version"' .claude-plugin/marketplace.json
```

All three should now show `0.33.0`.

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json README.md .claude-plugin/marketplace.json
git commit -m "chore: bump plugin version to 0.33.0"
```

---

## Task 5: Add CHANGELOG entry

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Read the current top of CHANGELOG.md**

```bash
head -10 CHANGELOG.md
```

Expected: First version heading is `## 0.32.0 — 2026-05-01`. The new heading goes above it.

- [ ] **Step 2: Insert the new top-level heading and entry**

Insert immediately after the `# Changelog` line (or whatever the file's top heading is). Use this content:

````markdown
## 0.33.0 — 2026-05-07

### Feature — Unified surface sync via /harness-sync

Adds `/harness-sync`, a new command that consolidates push-direction
propagation from `HARNESS.md` to all control surfaces (Cursor / Copilot /
Windsurf rule files, `ONBOARDING.md`) under a single human-instigated
entry point.

The command is a multiplexer over the existing primitives (`/convention-sync`,
`/harness-onboarding`) — no new skill, no new agent. It runs three phases
interactively: drift scan with the full picture (drifted, missing, in sync,
managed), multi-select of surfaces to apply, and apply-with-verification.
A pre-commit guard enforces the trust boundary: the command never writes
to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md`.

Branch enforcement at start-of-run: refuses to apply on `main` and offers
to create a `chore/sync-surfaces-YYYY-MM-DD` branch (the `chore/` prefix
satisfies the spec-first exemption deterministically). On a feature branch,
the command commits in place without opening a new PR.

`/harness-upgrade` is explicitly out of scope — it is a different
direction (pull from upstream) and stays separate. `/extract-conventions`
is also separate (pulls tacit knowledge from team into HARNESS.md).

Spec: `docs/superpowers/specs/2026-05-07-harness-sync-design.md`.
Plan: `docs/superpowers/plans/2026-05-07-harness-sync.md`.
Deferred follow-up #256: HARNESS.md template update so existing
harnesses pick up the new command via `/harness-upgrade` after they
upgrade to v0.33.0+.

### Docs — sync-harness how-to + cross-references

New how-to page `docs/plugins/ai-literacy-superpowers/sync-harness.md`
covers the three phases, the on-main vs on-branch distinction, the
refusal cases, and the example output. Existing how-to pages
`sync-conventions.md` and `generate-onboarding.md` updated with
"See also" pointers to the new multi-surface entry. The
`the-harness-tuning-loop.md` and `the-harness-lifecycle.md` Explanation
pages updated to reference `/harness-sync` at their respective
propagation stages.

````

- [ ] **Step 3: Verify the heading is parseable by the version-check workflow**

```bash
grep -m1 '^## [0-9]' CHANGELOG.md
```

Expected: `## 0.33.0 — 2026-05-07` (the first match is the new heading).

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add CHANGELOG entry for 0.33.0"
```

---

## Task 6: Create the sync-harness.md how-to page

**Files:**
- Create: `docs/plugins/ai-literacy-superpowers/sync-harness.md`

- [ ] **Step 1: Read an existing how-to page for format reference**

Read `docs/plugins/ai-literacy-superpowers/sync-conventions.md` end-to-end. Note:
- Frontmatter (title, layout, parent, grand_parent, nav_order, redirect_from)
- Section structure (Prerequisites, numbered steps, common errors)

- [ ] **Step 2: Pick the right nav_order**

Open `docs/plugins/ai-literacy-superpowers/index.md` and find the "Setup and integration" how-to section. Pick a `nav_order` value that places `sync-harness.md` next to `sync-conventions.md`. If `sync-conventions.md` has `nav_order: 30`, pick `31` for `sync-harness.md` (or whatever doesn't conflict).

```bash
grep -A3 "^---" docs/plugins/ai-literacy-superpowers/sync-conventions.md | head -10
```

- [ ] **Step 3: Write the new how-to page**

Use this skeleton, filling in details from the spec:

```markdown
---
title: Sync Harness Surfaces
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: <PICK FROM STEP 2>
redirect_from:
  - /how-to/sync-harness/
  - /how-to/sync-harness.html
---

# Sync Harness Surfaces

Run `/harness-sync` to detect drift across all push-direction control
surfaces (Cursor / Copilot / Windsurf rule files, `ONBOARDING.md`) and
apply fixes via the existing primitives in one interactive pass.

This page covers the multi-surface command. For single-surface deep
dives see [Sync Conventions]({% link plugins/ai-literacy-superpowers/sync-conventions.md %})
and [Generate Onboarding]({% link plugins/ai-literacy-superpowers/generate-onboarding.md %}).

## Prerequisites

- Plugin version 0.33.0 or later.
- A `HARNESS.md` exists in your project root.
- Working tree is clean (commit or stash anything in progress first).

## 1. Run the drift scan

[Phase 1 description from spec §3 — show the table format]

## 2. Pick which surfaces to update

[Phase 2 description from spec §3 — show the multi-select prompt]

## 3. Apply and verify

[Phase 3 description from spec §3 — show the verification delta table]

## Branch and PR discipline

[Spec §4 — explain the on-main vs on-branch behaviour, the chore/ prefix rationale, and the auto-generated PR body]

## Refusal cases

[Spec §6 — table of situations and behaviours]

## Trust boundary

[Spec §5 — never writes to HARNESS.md / AGENTS.md / REFLECTION_LOG.md; pre-commit guard]

## See also

- [Sync Conventions]({% link plugins/ai-literacy-superpowers/sync-conventions.md %}) — single-surface focus on rule files
- [Generate Onboarding]({% link plugins/ai-literacy-superpowers/generate-onboarding.md %}) — single-surface focus on `ONBOARDING.md`
- [The Harness Tuning Loop]({% link plugins/ai-literacy-superpowers/the-harness-tuning-loop.md %}) — explanation of where this fits in the propagation step (Stage 5)
- [The Harness Lifecycle]({% link plugins/ai-literacy-superpowers/the-harness-lifecycle.md %}) — explanation of where this fits in the Renewal Years stage
- [Upgrade Your Harness]({% link plugins/ai-literacy-superpowers/upgrade-your-harness.md %}) — the inverse direction (pull from upstream)
```

- [ ] **Step 4: Run markdownlint on the new file**

```bash
npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/sync-harness.md
```

Fix any errors in place.

- [ ] **Step 5: Verify all `{% link %}` references resolve**

For each `{% link plugins/ai-literacy-superpowers/X.md %}` in the file, confirm the target file exists:

```bash
for f in sync-conventions generate-onboarding the-harness-tuning-loop the-harness-lifecycle upgrade-your-harness; do
  test -f "docs/plugins/ai-literacy-superpowers/$f.md" && echo "OK: $f.md" || echo "MISSING: $f.md"
done
```

Expected: all OK.

- [ ] **Step 6: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/sync-harness.md
git commit -m "docs: add sync-harness how-to page"
```

---

## Task 7: Update existing how-to pages with cross-references

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/sync-conventions.md`
- Modify: `docs/plugins/ai-literacy-superpowers/generate-onboarding.md`

- [ ] **Step 1: Read sync-conventions.md and identify the right insertion point**

The "See also" pointer should land near the top — either after the page's intro paragraph or as a callout above the prerequisites. Pick the location that matches existing conventions in other how-to pages.

- [ ] **Step 2: Add the "See also" pointer to sync-conventions.md**

Insert text equivalent to:

```markdown
> **See also:** [Sync Harness Surfaces]({% link plugins/ai-literacy-superpowers/sync-harness.md %})
> is the multi-surface entry point that runs this command alongside any
> other drifted surfaces in one interactive pass. Use that when you want
> to apply propagation across all surfaces; use this page when you want
> to focus on the convention files alone.
```

- [ ] **Step 3: Add the same pattern of "See also" pointer to generate-onboarding.md**

Same wording, adjusted to point at `ONBOARDING.md`-only focus.

- [ ] **Step 4: Run markdownlint on both files**

```bash
npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/sync-conventions.md docs/plugins/ai-literacy-superpowers/generate-onboarding.md
```

Fix any errors in place.

- [ ] **Step 5: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/sync-conventions.md docs/plugins/ai-literacy-superpowers/generate-onboarding.md
git commit -m "docs: add /harness-sync cross-references in single-surface how-tos"
```

---

## Task 8: Update Explanation pages (tuning loop + lifecycle)

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md`
- Modify: `docs/plugins/ai-literacy-superpowers/the-harness-lifecycle.md`

- [ ] **Step 1: Update the-harness-tuning-loop.md Stage 5a**

Stage 5 is "Propagate the change to the enforcement surfaces". Sub-section 5a is the `AGENTS.md` / `CLAUDE.md` turn-time-context surface. Find that subsection and add a sentence at the end:

```markdown
The unified entry point that runs all of these in one interactive pass is
`/harness-sync` — see [Sync Harness Surfaces]({% link plugins/ai-literacy-superpowers/sync-harness.md %}).
The single-surface commands (`/convention-sync`, `/harness-onboarding`)
remain available for focused work.
```

- [ ] **Step 2: Update the-harness-lifecycle.md Renewal Years stage**

Find the "Renewal Years — Upgrades and Refresh" stage's "Tools at work" table. Add a new row:

```markdown
| Command | `/harness-sync` | Multi-surface entry point: detects drift, multi-selects, applies via the underlying primitives in one pass |
```

The new row goes between the existing entries for `/convention-sync` and `/harness-onboarding` (or as a leading row above both, framing them as the primitives the multiplexer composes — pick the position that reads cleanly).

Then update the "How they work together" paragraph in that stage to mention `/harness-sync` as the typical entry point.

- [ ] **Step 3: Run markdownlint on both files**

```bash
npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md docs/plugins/ai-literacy-superpowers/the-harness-lifecycle.md
```

Fix any errors in place.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md docs/plugins/ai-literacy-superpowers/the-harness-lifecycle.md
git commit -m "docs: reference /harness-sync in tuning-loop and lifecycle pages"
```

---

## Task 9: Update index.md

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/index.md`

- [ ] **Step 1: Find the "Setup and integration" section in index.md**

```bash
grep -n "Setup and integration\|sync-conventions\|generate-onboarding" docs/plugins/ai-literacy-superpowers/index.md
```

- [ ] **Step 2: Add the new how-to link**

Insert a new line in the "Setup and integration" subsection, immediately above or below the line that links to `sync-conventions.md`. Pick the position that reads naturally:

```markdown
- [Sync Harness Surfaces]({% link plugins/ai-literacy-superpowers/sync-harness.md %})
```

- [ ] **Step 3: Verify the link resolves**

```bash
test -f docs/plugins/ai-literacy-superpowers/sync-harness.md && echo OK
```

Expected: `OK`.

- [ ] **Step 4: Run markdownlint**

```bash
npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/index.md
```

- [ ] **Step 5: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/index.md
git commit -m "docs: link sync-harness page from index"
```

---

## Task 10: Manual smoke test on this very project

**Files:**
- Verify: `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`, `ONBOARDING.md`, `HARNESS.md`

- [ ] **Step 1: Verify pre-conditions**

```bash
git status --short
git branch --show-current
```

Expected: clean tree (no uncommitted changes), branch `feat-harness-sync`.

If the working tree is dirty, commit or stash before running the smoke test.

- [ ] **Step 2: Run `/harness-sync --check`**

In Claude Code (not via Bash), invoke `/harness-sync --check`. Expected behaviour:

- The command reads the current branch (`feat-harness-sync`).
- Since the branch is not `main`, branch enforcement does not refuse.
- The drift scan runs and prints the table.
- The selection phase is skipped (because `--check`).
- Verification scan does not run (no apply happened).
- The command exits without changing any files.

Expected output: a drift scan table showing the current state of `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`, `ONBOARDING.md`, and CI/CD.

- [ ] **Step 3: Run `/harness-sync` (interactive)**

Now invoke `/harness-sync` without `--check`. Expected behaviour:

- The command runs the drift scan (Phase 1).
- The command presents the multi-select prompt (Phase 2).
- Decline all surfaces (pick "Apply nothing — exit without changes") to verify the no-op path.
- The command exits cleanly with no changes.

Expected: working tree still clean after the run.

- [ ] **Step 4: Run `/harness-sync` again, this time accepting drifted surfaces**

If the drift scan shows any drifted surfaces, run the command again and accept them. Expected behaviour:

- The command applies the underlying primitives.
- The verification scan shows all selected surfaces in sync.
- The command stages and commits the changes.
- The command does NOT push and does NOT open a PR (because we're on a feature branch, not on main).

Expected: a new commit on `feat-harness-sync` with only the surface files modified. Run `git diff --name-only HEAD~1 HEAD` to verify no HARNESS.md/AGENTS.md/REFLECTION_LOG.md path appears.

If the drift scan shows no drifted surfaces, this step is N/A — note that in your smoke-test record.

- [ ] **Step 5: Run `/harness-sync` a third time to verify idempotency**

Expected: drift scan shows all surfaces in sync; selection phase offers nothing actionable; the command exits without committing anything new.

- [ ] **Step 6: Test the trust-boundary pre-commit guard**

This is harder to test cleanly because triggering it would require introducing a bug. Spot-check by reading the guard's logic in the command file: confirm the allow-list matches the spec §5 surfaces and that the refusal path does not silently un-stage.

- [ ] **Step 7: Test refusal on main (in a scratch worktree)**

Create a temporary worktree, switch to main, run `/harness-sync`. Expected: the command refuses to apply, offers to create a `chore/sync-surfaces-2026-05-07` branch, accepts your decline, and exits cleanly. Clean up the worktree afterwards.

```bash
git worktree add /tmp/harness-sync-test main
cd /tmp/harness-sync-test
# In Claude Code: /harness-sync
# Decline branch creation, verify clean exit
cd -
git worktree remove /tmp/harness-sync-test
```

- [ ] **Step 8: Record the smoke-test results**

In your scratchpad (do not commit), record:
- Which steps passed cleanly
- Any unexpected behaviour
- Whether the verification scan after apply produced the expected delta table

If any step failed, return to Task 2 and fix the command file. Re-run from the failed step.

---

## Task 11: Push the branch and open the PR

**Files:**
- None modified — this is the integration step.

- [ ] **Step 1: Verify the commit history is clean**

```bash
git log --oneline main..HEAD
```

Expected: the spec commit (`df7bc52`) followed by the implementation commits in order:
1. `spec: /harness-sync command for unified surface sync`
2. `feat: add /harness-sync command for unified surface sync`
3. (Optional) `fix: address lint and structural feedback in harness-sync.md`
4. `chore: bump plugin version to 0.33.0`
5. `docs: add CHANGELOG entry for 0.33.0`
6. `docs: add sync-harness how-to page`
7. `docs: add /harness-sync cross-references in single-surface how-tos`
8. `docs: reference /harness-sync in tuning-loop and lifecycle pages`
9. `docs: link sync-harness page from index`
10. (Optional) Smoke-test commits if Task 10 Step 4 produced any

- [ ] **Step 2: Push the branch**

```bash
git push -u origin feat-harness-sync
```

- [ ] **Step 3: Open the PR with the right labels at creation time**

```bash
gh pr create --label enhancement --title "feat: add /harness-sync command for unified surface sync" --body "$(cat <<'EOF'
Closes nothing directly (introduces a new command). Tracks deferred follow-up #256.

## Summary

Adds `/harness-sync`, a new command in the `ai-literacy-superpowers` plugin that consolidates push-direction propagation from `HARNESS.md` to all control surfaces under a single human-instigated entry point.

The command is a multiplexer over existing primitives (`/convention-sync`, `/harness-onboarding`) — no new skill, no new agent. It runs three interactive phases:

1. **Drift scan** — full picture of every push-direction surface (drifted, missing, in sync, managed at runtime).
2. **Selection** — multi-select of surfaces to apply.
3. **Apply with verification** — run the underlying primitives, re-scan to confirm in-sync state.

Branch enforcement at start-of-run refuses to apply on `main` and offers to create a `chore/sync-surfaces-YYYY-MM-DD` branch. A pre-commit guard enforces the trust boundary mechanically: the command never writes to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md`.

## Spec and plan

- Spec: \`docs/superpowers/specs/2026-05-07-harness-sync-design.md\` (committed as the first commit on this branch)
- Plan: \`docs/superpowers/plans/2026-05-07-harness-sync.md\`

## Files changed

- \`ai-literacy-superpowers/commands/harness-sync.md\` — new command file
- \`ai-literacy-superpowers/.claude-plugin/plugin.json\` — version bump to 0.33.0
- \`README.md\` — version badge bump
- \`.claude-plugin/marketplace.json\` — \`plugin_version\` bump
- \`CHANGELOG.md\` — new \`## 0.33.0 — 2026-05-07\` heading with feature + docs entries
- \`docs/plugins/ai-literacy-superpowers/sync-harness.md\` — new how-to
- \`docs/plugins/ai-literacy-superpowers/sync-conventions.md\`, \`generate-onboarding.md\` — "See also" cross-references
- \`docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md\`, \`the-harness-lifecycle.md\` — reference \`/harness-sync\` at the appropriate stages
- \`docs/plugins/ai-literacy-superpowers/index.md\` — link to new how-to

## Versioning

Plugin version bumped from 0.32.0 to 0.33.0 (minor — new command). All four locations updated per CLAUDE.md.

## Deferred follow-up

Issue #256 — Add \`/harness-sync\` to the HARNESS.md template's command inventory so existing harnesses pick up the addition via \`/harness-upgrade\` after upgrading to v0.33.0+. Out of scope for this PR to keep the review surface tight.

## Test plan

- [x] Spec-first check passes (spec is the first commit on this branch)
- [x] Markdownlint passes (verified locally)
- [x] Version consistency check passes (all four locations on 0.33.0)
- [x] Manual smoke test: drift scan, selection, apply with verification, idempotency on this project (results in plan Task 10 Step 8)
- [x] Manual refusal test: on \`main\` via scratch worktree (Task 10 Step 7)
- [x] Trust boundary spot-check: pre-commit guard logic reviewed (Task 10 Step 6)
EOF
)"
```

- [ ] **Step 4: Watch CI checks until they complete**

```bash
gh pr checks <PR_NUMBER> --watch
```

Expected: all checks pass on first try (because the spec is the first commit, version consistency is satisfied, and the docs are markdownlint-clean).

- [ ] **Step 5: If any check fails, diagnose with `gh run view`**

```bash
gh run view <RUN_ID> --log-failed
```

Common failures and recovery:
- Markdownlint MD049 (asterisk emphasis): change to underscore.
- Markdownlint MD018 (no space after hash): rewrap so PR references like `#NNN` don't sit at line-start.
- Version-check workflow finds mismatch: re-verify all four locations match `0.33.0`.

Fix in place, commit, push, repeat.

- [ ] **Step 6: Report the green PR URL to the user**

The user merges. After merge, the marketplace cache auto-sync hook will pick up the new version, and existing harnesses' SessionStart hooks will surface a `/harness-upgrade` prompt offering the new command in their template diff (once issue #256 ships, which references this PR's version).

---

## Self-Review

**Spec coverage check** (every spec §9 acceptance criterion mapped to a task):

| Spec acceptance criterion | Plan task |
| --- | --- |
| `/harness-sync` command file added | Task 2 |
| Plugin version bumped in 4 locations | Task 4 (3 locations) + Task 5 (CHANGELOG, the 4th) |
| CHANGELOG entry under new `## 0.33.0` heading | Task 5 |
| `sync-harness.md` created and linked from index.md | Task 6 + Task 9 |
| `sync-conventions.md` and `generate-onboarding.md` updated | Task 7 |
| Tuning-loop and lifecycle pages reference `/harness-sync` | Task 8 |
| Drift scan reuses GC-rule detection logic | Task 2 Step 6 |
| Branch enforcement: refuses on main; offers chore/ branch | Task 2 Step 4; verified in Task 10 Step 7 |
| Pre-commit guard rejects out-of-allow-list paths | Task 2 Step 9; spot-checked in Task 10 Step 6 |
| `--check` flag runs scan only with no apply | Task 2 Step 3; verified in Task 10 Step 2 |
| Idempotent — second consecutive run is no-op | Task 2 Step 12; verified in Task 10 Step 5 |
| Verification scan after apply; non-zero exit on still-drifted | Task 2 Step 8 |
| PR created with `--label chore` at creation | Task 2 Step 10 |
| Manual smoke test on this project | Task 10 |

All acceptance criteria covered.

**Placeholder scan:** No "TBD", no "implement later", no "similar to Task N", no "fill in details". Some how-to-page subsections in Task 6 are described as "[Phase 1 description from spec §3]" which is a deliberate cross-reference, not a placeholder — the agent reads the spec section and writes the prose. Acceptable.

**Type consistency:** No code types in this plan (markdown-only), but command names are referenced consistently throughout (`/harness-sync`, `/convention-sync`, `/harness-onboarding`, `/harness-upgrade`, `/extract-conventions`). File paths are exact and consistent.

**Scope check:** This is a single coherent implementation — one command file, four version-bump locations, one new doc, four updated docs, one smoke test. Not multiple independent subsystems; no decomposition needed.

Plan complete.
