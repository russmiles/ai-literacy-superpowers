# /harness-sync — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-07 |
| Status | Draft — pending user review |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | v0.33.0 (minor bump — new command) |
| Related issues | #256 (deferred follow-up: HARNESS.md template update) |
| Related work | PR #248 (the-harness-tuning-loop docs), PR #253 (the-harness-lifecycle docs), PR #254 (CLAUDE.md exemption section), PR #255 (workflow `labeled` triggers) |

---

## 1. Summary

`/harness-sync` is a new command in the `ai-literacy-superpowers` plugin that consolidates push-direction propagation from `HARNESS.md` to the control surfaces under a single, clear, human-instigated entry point. It detects drift across all push-direction surfaces (Cursor / Copilot / Windsurf rule files, `ONBOARDING.md`), presents the full picture as a checklist, applies the user's selection via the existing primitives (`/convention-sync`, `/harness-onboarding`), and ships the result through the project's standard branch + label PR discipline.

The command does not introduce new propagation mechanism. It is a multiplexer over existing primitives. The existing commands remain — they stay as the named single-surface deep dives; `/harness-sync` is the multi-surface entry.

---

## 2. Why

The plugin currently has three push-direction propagation paths and a fourth pull-direction path:

- `/convention-sync` — pushes `HARNESS.md` content to `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`.
- `/harness-onboarding` — pushes `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md` content to `ONBOARDING.md`.
- CI / CD — propagates the constraint's `scope` field at runtime via the `harness-enforcer` agent and the workflow templates. No per-change command.
- `/harness-upgrade` — pulls upstream template content into `HARNESS.md` (inverse direction).

The first three are simple individually but cognitively expensive collectively. A user has to remember which command serves which surface, and there is no single place that surfaces drift across all of them. The GC rules detect drift weekly and file issues, but the *response* path (running the underlying command to close the gap) is fragmented across three command names.

`/harness-sync` collapses the response path to a single command while preserving the underlying primitives. The pull-direction operation (`/harness-upgrade`) stays separate — it is a different mental model and conflating it would dilute both.

---

## 3. Command shape

### Invocation

- `/harness-sync` — interactive multiplexer (the primary form)
- `/harness-sync --check` — drift scan only, no fix step (useful for dry-run from CI or `/harness-health --deep`)

### Phase 1 — Drift scan (full picture)

The command runs the drift detection that the existing GC rules already encode (`convention file sync`, `ONBOARDING.md staleness`). It reuses the underlying detection logic rather than reimplementing — the GC rules are the canonical detectors.

The scan output is a structured table covering every push-direction surface, including `in sync` and runtime-managed ones, so the picture is genuinely complete:

```text
Surface                                              Status      Action on apply
───────────────────────────────────────────────────  ──────────  ─────────────────────────
.cursor/rules/                                       drifted     /convention-sync
.github/copilot-instructions.md                      in sync     —
.windsurf/rules/                                     missing     /convention-sync (create)
ONBOARDING.md                                        drifted     /harness-onboarding
CI / CD (constraint scope)                           managed     handled at runtime
─────────────────────────────────────────────────────────────────────────────────────────
4 surfaces tracked · 2 drifted · 1 missing · 1 in sync · 1 managed at runtime
```

### Surface state vocabulary

- `drifted` — file exists but does not match HARNESS.md.
- `missing` — file is not present and would be created on apply.
- `in sync` — file matches HARNESS.md.
- `managed` — runtime-managed by the constraint's declared scope; surfaced for completeness, not actionable here.

### Phase 2 — Selection (interactive)

After the scan, `/harness-sync` presents a multi-select prompt listing each `drifted` or `missing` surface as a separate option. Default selection is **all drifted/missing surfaces**. The user can deselect anything they want to handle separately, or pick just one. The `managed` row never appears as a selectable option — it is status, not action.

A "Apply nothing — exit without changes" option is always present so the no-op path is an explicit choice.

### Phase 3 — Apply (compose the primitives)

For each selected surface, `/harness-sync` invokes the corresponding existing command (`/convention-sync` for the convention files, `/harness-onboarding` for ONBOARDING.md). The existing commands stay as the named primitives.

After apply, `/harness-sync` re-runs the drift scan as a verification pass and shows a delta table:

```text
Apply complete — verification scan:

Surface                                              Before      After
───────────────────────────────────────────────────  ──────────  ──────────
.cursor/rules/                                       drifted     in sync ✓
.windsurf/rules/                                     missing     in sync ✓
ONBOARDING.md                                        drifted     in sync ✓
```

If any surface fails to come into sync, the verification flags it as `still drifted (error)` and the command exits non-zero.

---

## 4. Branch and PR discipline

### Branch enforcement at start-of-run

`/harness-sync` checks the current branch before doing anything else.

- **On `main`** — refuses to apply changes directly. Offers to create a `chore/sync-surfaces-YYYY-MM-DD` branch (or accepts a user-supplied name), confirms, switches, then proceeds. The `chore/` prefix is deliberate — it satisfies the spec-first-check exemption via the branch-prefix path, dodging the label-payload race condition the workflow `pull_request: labeled` trigger now also covers (PR #255).
- **On any other branch** — proceeds without creating a new branch. The user is presumed to be in an existing flow; `/harness-sync` becomes another step in their work.

### Apply → commit → push → PR (fresh `chore/` branch)

```text
1. Apply selected fixes via /convention-sync, /harness-onboarding
2. Verification scan — re-detect drift; require selected surfaces to be in sync
3. Stage changed files (only surface files; never HARNESS.md, AGENTS.md, REFLECTION_LOG.md)
4. Commit: "chore: sync convention files and ONBOARDING.md to HARNESS.md"
5. Push branch with -u origin
6. Open PR via `gh pr create --label chore --title ... --body ...`
7. Report PR URL + verification scan delta
```

The PR body is auto-generated and includes the before/after drift scan, which underlying commands ran for which surfaces, and a "Why these changes" line linking to the latest `HARNESS.md` constraint changes (parsed from `git log` since the previous in-sync state).

### Apply on existing feature branch (lighter path)

Steps 1–4 only — apply, verify, stage the surface files, commit. No push, no PR creation. The user picks up the branch in their existing flow. This means `/harness-sync` integrates naturally with mid-flight feature work (e.g., immediately after `/harness-constrain` adds a new constraint).

---

## 5. Trust boundary

`/harness-sync` never writes to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md`. The trust boundary mirrors `harness-gc` and `governance-auditor`: read the harness, write to the surfaces, never write to the harness itself.

The command's commit must touch only generated/derived files:

- `.cursor/rules/`
- `.github/copilot-instructions.md`
- `.windsurf/rules/`
- `ONBOARDING.md`

A pre-commit guard in the command verifies this by checking the staged file list against an allow-list and refusing to commit if a non-allowed path appears. Crossing the boundary is treated as a bug in the underlying primitive that needs investigation, not a `/harness-sync` failure to suppress.

---

## 6. Error and refusal cases

| Situation | Behaviour |
| --- | --- |
| Uncommitted changes on the working tree at start | Refuse to run; print dirty paths and suggest stashing or committing first |
| Underlying command errors out for one surface | Continue with other selected surfaces; mark errored surface as `still drifted (error)`; exit non-zero overall |
| Verification scan still shows drift after apply | Exit non-zero; report failed surfaces; do not commit |
| User declines all surfaces in Phase 2 | Exit cleanly with no changes |
| Pre-commit guard rejects HARNESS.md / AGENTS.md / REFLECTION_LOG.md path | Refuse to commit; treat as bug in underlying primitive |

### Idempotency

Running `/harness-sync` twice in a row, with no `HARNESS.md` changes in between, is a no-op on the second run. All surfaces report `in sync` and Phase 2 offers nothing actionable. This property leaves the door open to future scheduled automation, though today's design is human-instigated only.

---

## 7. Output at end

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
PR:       https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/256
```

On a feature branch with no auto-PR, the last three lines collapse to just `Commit: a1b2c3d` and a hint that the user should push when ready.

---

## 8. Files added and changed

### Added (inside `ai-literacy-superpowers/` — warrants minor version bump)

- `ai-literacy-superpowers/commands/harness-sync.md` — the new command's prompt

No new skill, no new agent. The command composes existing primitives.

### Version bump (v0.32.0 → v0.33.0)

Per `CLAUDE.md`:

- `ai-literacy-superpowers/.claude-plugin/plugin.json` — `version` field
- `README.md` — Plugin version badge
- `CHANGELOG.md` — new top-level heading `## 0.33.0 — 2026-05-07` with entries grouped under `### Feature — Unified surface sync via /harness-sync`
- `.claude-plugin/marketplace.json` — `plugin_version` field

### Documentation cascade

| Target | Change |
| --- | --- |
| `docs/plugins/ai-literacy-superpowers/sync-harness.md` (new) | How-to page covering the three phases, the on-main vs on-branch distinction, refusal cases, example output |
| `docs/plugins/ai-literacy-superpowers/sync-conventions.md` | "See also" pointer to `/harness-sync` as the multi-surface entry point |
| `docs/plugins/ai-literacy-superpowers/generate-onboarding.md` | Same "See also" pattern |
| `docs/plugins/ai-literacy-superpowers/index.md` | New how-to in the "Setup and integration" section |
| `docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md` | Stage 5 (Propagate) gains a sentence noting `/harness-sync` |
| `docs/plugins/ai-literacy-superpowers/the-harness-lifecycle.md` | Renewal Years stage's "Tools at work" table picks up `/harness-sync` |
| `ai-literacy-superpowers/commands.md` (reference, if present) | New row in the commands table |

The principle: existing pages stay focused on their single-surface deep dive; the new page is the multi-surface entry. Existing commands are not deprecated.

---

## 9. Acceptance criteria

- [ ] `/harness-sync` command file added to `ai-literacy-superpowers/commands/`
- [ ] Plugin version bumped to v0.33.0 in all four locations
- [ ] CHANGELOG entry under new `## 0.33.0` heading with `### Feature — Unified surface sync via /harness-sync` group
- [ ] `docs/plugins/ai-literacy-superpowers/sync-harness.md` created and linked from `index.md`
- [ ] `sync-conventions.md` and `generate-onboarding.md` updated with "See also" pointers
- [ ] `the-harness-tuning-loop.md` and `the-harness-lifecycle.md` reference `/harness-sync` at the appropriate stages
- [ ] Drift scan reuses GC-rule detection logic (does not reimplement)
- [ ] Branch enforcement: refuses to apply on `main`; offers to create `chore/sync-surfaces-YYYY-MM-DD`
- [ ] Pre-commit guard rejects any staged path outside the allow-list
- [ ] `--check` flag runs scan only with no apply
- [ ] Idempotent — second consecutive run is a no-op
- [ ] Verification scan after apply; non-zero exit on any `still drifted (error)`
- [ ] PR created with `--label chore` at creation time
- [ ] Manual smoke test: run on this very project against the current `HARNESS.md`

---

## 10. Risk and rollback

- Adding the command does not remove the underlying commands. If `/harness-sync` has a bug, users fall back to `/convention-sync` and `/harness-onboarding` directly.
- The trust boundary is enforced by the pre-commit guard; if the guard is buggy, the worst case is a refusal that the user works around by running the underlying commands directly.
- Rollback is a single-commit revert of the command file plus the version bump (the docs cascade is additive and harmless if left in place).

---

## 11. Out of scope (and why)

- **`/harness-upgrade` integration** — Different mental model (pull from upstream, not push to surfaces). Conflating the two would dilute both. They remain separate commands.
- **`/extract-conventions` integration** — Pull-direction (tacit knowledge from team into HARNESS.md). Different surface boundary; not a propagation operation.
- **Automatic scheduled invocation** — Today's design is human-instigated only. The idempotency property leaves the door open for future automation if the team wants it, but enabling it would change the trust profile (no human-cognition gate at the propagation step) and is out of scope for v0.33.0.
- **HARNESS.md template update to mention `/harness-sync`** — Deferred to issue #256 to keep the main PR's review surface tight. The template propagation is a small, separate diff that benefits from its own review.

---

## 12. Deferred follow-ups (tracked)

- **Issue #256** — Add `/harness-sync` to the HARNESS.md template's command inventory so existing harnesses pick up the addition via `/harness-upgrade` after upgrading to v0.33.0+.
- **Future consideration (not yet an issue)** — If GC's `convention file sync` and `ONBOARDING.md staleness` rules' findings keep recurring across reflections, the tuning loop's regression-detection path may surface a constraint asking for stricter discipline (e.g., "always run `/harness-sync` after `/harness-constrain`"). That would be an organic outcome of the existing harness-gc loop, not a planned follow-up here.

---

## 13. Open questions

None — all design decisions resolved during brainstorming. Three explicit user choices anchored the design:

1. Drift scan presents the **full picture** (in-sync surfaces included), not drift-only.
2. The command **requires a label / branch prefix** because it produces commits.
3. The command name is **`/harness-sync`** (matches the `/harness-{init,upgrade,audit,onboarding}` family).

---

## 14. Implementation handoff

Once this spec is reviewed and approved by the user, the next step is to invoke the `writing-plans` skill to produce a detailed implementation plan that this spec scopes against. The plan will sequence the file additions, the version bump in four locations, the documentation cascade, and the manual smoke test. The plan will then drive the implementation work on this same `feat-harness-sync` branch, with subsequent commits adding the implementation against the spec committed as commit one.
