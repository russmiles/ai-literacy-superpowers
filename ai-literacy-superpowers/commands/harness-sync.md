---
name: harness-sync
description: Detect drift across all push-direction control surfaces, present the full picture, and apply the user's selected fixes via the existing primitives — single human-instigated entry point for keeping convention files and ONBOARDING.md in sync with HARNESS.md.
---

# /harness-sync

Detect drift across every push-direction surface, present the full picture as
a structured table, and apply the selected fixes via the existing primitives
(`/convention-sync`, `/harness-onboarding`). This command is a multiplexer —
it composes existing commands and does not introduce new propagation logic.

**What this command does NOT do:**

- It does _not_ write to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md` —
  those files are the harness source of truth; `/harness-sync` only writes to
  the generated surfaces derived from them.
- It does _not_ pull upstream template changes into `HARNESS.md` — that is
  `/harness-upgrade`.

## Invocation

- `/harness-sync` — full interactive mode: drift scan → selection → apply →
  verify → commit/PR.
- `/harness-sync --check` — drift scan only, no fix step. Exits after printing
  the status table. Useful for dry-run from CI or as the deep-scan step inside
  `/harness-health --deep`.

## Process

### 1. Branch Enforcement

Read the current branch:

```bash
git branch --show-current
```

**If the branch is `main`:** Refuse to apply changes directly to main.
Tell the user:

> You are on `main`. `/harness-sync` cannot apply changes directly to the
> default branch. Shall I create `chore/sync-surfaces-YYYY-MM-DD` for you?
> (Substitute today's date.) You can also supply a custom branch name.

Wait for the user's response:

- If the user accepts the default name or supplies a custom name, run:

  ```bash
  git checkout -b chore/sync-surfaces-YYYY-MM-DD
  ```

  (Substitute the confirmed branch name.) Record that a fresh `chore/` branch
  was created — this determines the commit/PR path in step 7.

- If the user declines to create a branch, exit cleanly with no changes.

**If the branch is anything other than `main`:** Proceed without creating a
new branch. Record that the user is on an existing feature branch — this
determines the lighter commit path in step 7.

### 2. Working-Tree-Clean Check

Run:

```bash
git status --porcelain
```

If the output is non-empty, refuse to proceed. List the dirty paths and tell
the user:

> Working tree is not clean. Resolve the following before running
> `/harness-sync`:
>
> `[list each dirty path on its own line]`
>
> Suggestion: stash with `git stash` or commit your work-in-progress first.

Exit without making any changes.

### 3. Phase 1 — Drift Scan

**If invoked with `--check`, run only this phase and then exit.**

Read `HARNESS.md` from the project root. If it does not exist, stop and tell
the user:

> No `HARNESS.md` found. Run `/harness-init` first, then re-run
> `/harness-sync`.

For each push-direction surface, evaluate its state against the current
`HARNESS.md` content. Reuse the drift detection logic described by the
`convention file sync` and `ONBOARDING.md staleness` GC rules in `HARNESS.md`
— do _not_ invent new drift criteria; reference those GC rules by name.

#### Surface evaluation

For each surface, determine its state using the named GC rule as the
canonical detector. States: `missing` (files absent), `drifted` (files exist
but diverge from HARNESS.md), `in sync` (files match), `managed` (not
actionable here).

**`.cursor/rules/`** — Apply the `convention file sync` GC rule's check
against `.cursor/rules/conventions.mdc` and `.cursor/rules/constraints.mdc`.

**`.github/copilot-instructions.md`** — Apply the `convention file sync` GC
rule's check against `.github/copilot-instructions.md`.

**`.windsurf/rules/`** — Apply the `convention file sync` GC rule's check
against `.windsurf/rules/conventions.md` and `.windsurf/rules/constraints.md`.

**`ONBOARDING.md`** — Apply the `ONBOARDING.md staleness` GC rule's check:
compare `ONBOARDING.md` against the current state of `HARNESS.md`, `AGENTS.md`,
and `REFLECTION_LOG.md` (modification times and content alignment).

**CI / CD (constraint scope)** — Always report as `managed`. Handled at
runtime by the `harness-enforcer` agent; surfaced for completeness only.

#### Drift scan output table

Build and print this structured table, substituting the evaluated statuses:

```text
Surface                                              Status      Action on apply
───────────────────────────────────────────────────  ──────────  ─────────────────────────
.cursor/rules/                                       drifted     /convention-sync
.github/copilot-instructions.md                      in sync     —
.windsurf/rules/                                     missing     /convention-sync (create)
ONBOARDING.md                                        drifted     /harness-onboarding
CI / CD (constraint scope)                           managed     handled at runtime
─────────────────────────────────────────────────────────────────────────────────────────
5 surfaces tracked · 2 drifted · 1 missing · 1 in sync · 1 managed at runtime
```

State vocabulary:

- `drifted` — file exists but does not match HARNESS.md.
- `missing` — file is not present; would be created on apply.
- `in sync` — file matches HARNESS.md.
- `managed` — runtime-managed; surfaced for completeness, not actionable here.

If `--check` was passed, stop here and exit zero (or non-zero if any surface
is `drifted` or `missing`, so CI can gate on drift). Do not proceed to
Phase 2.

### 4. Phase 2 — Selection

If all surfaces are `in sync` or `managed`, tell the user:

> All surfaces are in sync. Nothing to apply.

Exit cleanly with no changes.

Otherwise, present a multi-select prompt. Use `AskUserQuestion` with
`multiSelect: true`. List each `drifted` or `missing` surface as a separate
option. Default selection is _all_ drifted/missing surfaces. The `managed` row
never appears as a selectable option.

```json
{
  "type": "AskUserQuestion",
  "multiSelect": true,
  "question": "Select which surfaces to bring in sync. All drifted/missing surfaces are selected by default.",
  "options": [
    {
      "id": "cursor",
      "label": ".cursor/rules/  [drifted — /convention-sync]",
      "selected": true
    },
    {
      "id": "windsurf",
      "label": ".windsurf/rules/  [missing — /convention-sync (create)]",
      "selected": true
    },
    {
      "id": "onboarding",
      "label": "ONBOARDING.md  [drifted — /harness-onboarding]",
      "selected": true
    },
    {
      "id": "none",
      "label": "Apply nothing — exit without changes",
      "selected": false
    }
  ]
}
```

Only include options for surfaces that are `drifted` or `missing`. Omit
options for `in sync` surfaces. Always include the "Apply nothing" option.

If the user selects "Apply nothing — exit without changes" (or deselects all
surfaces), exit cleanly with no changes.

### 5. Phase 3 — Apply

For each surface the user selected, invoke the corresponding primitive
_in series_ (not in parallel — order matters for the verification scan):

1. **`.cursor/rules/` or `.windsurf/rules/`** — invoke `/convention-sync`.
   This handles all three convention-file surfaces in a single run; if both
   are selected they share the same invocation.
2. **`ONBOARDING.md`** — invoke `/harness-onboarding`.

If an underlying command errors out for one surface:

- Continue with the remaining selected surfaces.
- Mark the errored surface as `still drifted (error)` in the verification
  scan.
- The overall run will exit non-zero (see step 6 below).

### 6. Verification Scan

After all selected surfaces are applied, re-run the drift scan from Phase 1.
Build and print the delta table:

```text
Apply complete — verification scan:

Surface                                              Before      After
───────────────────────────────────────────────────  ──────────  ──────────
.cursor/rules/                                       drifted     in sync ✓
.windsurf/rules/                                     missing     in sync ✓
ONBOARDING.md                                        drifted     in sync ✓
```

If any selected surface is _not_ now `in sync`, mark it as
`still drifted (error)` in the After column. Do _not_ proceed to commit.
Report the failed surfaces and exit non-zero.

If all selected surfaces are now `in sync`, proceed to the trust-boundary
guard.

### 7. Trust-Boundary Pre-Commit Guard

Before staging or committing, verify that no out-of-bounds file was touched.

Run:

```bash
git diff --name-only
```

Verify every modified path matches the allow-list:

- `.cursor/rules/**`
- `.github/copilot-instructions.md`
- `.windsurf/rules/**`
- `ONBOARDING.md`

If any path falls _outside_ the allow-list (including `HARNESS.md`,
`AGENTS.md`, or `REFLECTION_LOG.md`), refuse to commit. Tell the user:

> Trust-boundary violation: the underlying primitive modified a file outside
> the allowed set. This is a bug in the underlying command, not a
> `/harness-sync` failure. Investigate before committing.
>
> Unexpected path(s): `[list each offending path]`

Do _not_ silently un-stage and continue. Exit non-zero.

### 8. Commit and Ship

#### Path A — Fresh `chore/` branch (created in step 1)

Stage the surface files only:

```bash
git add .cursor/rules/ .github/copilot-instructions.md .windsurf/rules/ ONBOARDING.md
```

(Only add paths that were actually modified.)

Parameterise the commit message based on which surfaces were applied:

- Both convention files and `ONBOARDING.md`:
  `"chore: sync convention files and ONBOARDING.md to HARNESS.md"`
- Convention files only: `"chore: sync convention files to HARNESS.md"`
- `ONBOARDING.md` only: `"chore: sync ONBOARDING.md to HARNESS.md"`

```bash
git commit -m "chore: <parameterised message above>"
```

Push the branch:

```bash
git push -u origin <branch-name>
```

Open a PR with `--label chore`. The auto-generated body must include:

- **Why these changes:** latest HARNESS.md constraint changes (from `git log`).
- **Drift scan (before):** the Phase 1 table.
- **Verification scan (after):** the Phase 3 delta table.
- **Surfaces applied:** each surface and the command used.

```bash
gh pr create --label chore \
  --title "chore: sync surfaces to HARNESS.md" \
  --body "<auto-generated body as above>"
```

Report the PR URL and the verification delta.

#### Path B — Existing feature branch (step 1 skipped)

Stage and commit only — do _not_ push and do _not_ open a PR:

```bash
git add .cursor/rules/ .github/copilot-instructions.md .windsurf/rules/ ONBOARDING.md
git commit -m "chore: sync convention files and ONBOARDING.md to HARNESS.md"
```

Report the commit hash and tell the user:

> Changes committed to `<branch-name>`. Push when ready:
> `git push -u origin <branch-name>`

## Error and Refusal Cases

| Situation | Behaviour |
| --- | --- |
| Uncommitted changes on working tree | Refuse to run; print dirty paths; suggest stash or commit-first |
| Underlying command errors out for one surface | Continue with other surfaces; mark errored surface `still drifted (error)`; exit non-zero overall |
| Verification scan still shows drift after apply | Exit non-zero; report failed surfaces; do not commit |
| User declines all surfaces in Phase 2 | Exit cleanly with no changes |
| Pre-commit guard rejects HARNESS.md/AGENTS.md/REFLECTION_LOG.md path | Refuse to commit; treat as bug in underlying primitive |

## Idempotency

Running `/harness-sync` twice consecutively with no `HARNESS.md` changes
between runs MUST be a no-op on the second run. All surfaces will report
`in sync` in Phase 1, Phase 2 will offer nothing actionable, and the command
exits cleanly without committing anything.

## Output Format

On success with a fresh `chore/` branch:

```text
Harness Sync complete.

Verification:
  .cursor/rules/                  drifted → in sync ✓
  .github/copilot-instructions.md drifted → in sync ✓
  .windsurf/rules/                missing → in sync ✓ (created)
  ONBOARDING.md                   drifted → in sync ✓

Branch:   chore/sync-surfaces-2026-05-07
Commit:   a1b2c3d  chore: sync convention files and ONBOARDING.md to HARNESS.md
Pushed:   origin/chore/sync-surfaces-2026-05-07
PR:       https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/N
```

On an existing feature branch (no auto-PR):

```text
Harness Sync complete.

Verification:
  .cursor/rules/                  drifted → in sync ✓
  ONBOARDING.md                   drifted → in sync ✓

Commit:   a1b2c3d  chore: sync convention files and ONBOARDING.md to HARNESS.md
Push when ready: git push -u origin <branch-name>
```

## Validation Checkpoint

**This step is mandatory.** After generating the verification scan table in
step 6, read the table back and verify its structure matches this spec.

**Structural checks:**

1. Every selected surface appears in the After column.
2. Every After value is one of: `in sync ✓`, `in sync ✓ (created)`, or
   `still drifted (error)`.
3. No selected surface is missing from the table.
4. The Before value for each row matches the status recorded during Phase 1.

If any check fails, fix the table in place:

- Add missing surface rows using the Phase 1 status as the Before value.
- Correct any After value that does not match the vocabulary above.

Do not re-run the apply phase. Fix the output table directly, then proceed
to the trust-boundary guard.
