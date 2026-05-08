# Audit-driven `/harness-sync` and lifecycle docs simplification — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-08 |
| Status | Draft — pending user review |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | v0.35.0 (minor — `/harness-sync` behaviour change) |
| PR ceremony | `chore`-labelled — diaboli and choice-cartograph deliberately skipped per AGENTS.md STYLE on reflection-driven amendments and project-owner judgement |
| Related work | PR #257 (original /harness-sync), PR #259 (docs propagation constraint), PR #265 (MkDocs Material migration), PRs #263 + #266 (Diataxis reorg phases 1 + 2) |

---

## 1. Summary

Restructure `/harness-sync` so it runs `/harness-audit`'s detection logic internally, presents a single unified drift table covering all surfaces (push-direction control surfaces, audit findings, recurring reflection patterns), and applies fixes through the existing primitives. The two commands become two interfaces over a shared internal **audit-engine**: `/harness-audit` is read-only inspection, `/harness-sync` is read-then-fix.

`/harness-audit` stays callable as a standalone diagnostic command; its user-facing UX does not change. All other harness lifecycle commands (`/harness-init`, `/harness-status`, `/harness-health`, `/harness-constrain`, `/harness-gc`, `/harness-upgrade`, `/harness-onboarding`, `/convention-sync`) keep their current behaviour.

The lifecycle docs are simplified in the same PR to converge on a single canonical narrative: **detect drift, heal it; pull upstream when needed**. Three explanation pages get substantive rewrites; several how-to pages and the plugin landing page get touch-ups.

---

## 2. Why

### The accreted lifecycle

The plugin currently ships 11 lifecycle commands across 6 categories: setup (`/harness-init`), inspection (`/harness-status`, `/harness-health`, `/harness-audit`), authoring (`/harness-constrain`, `/harness-gc`), pull (`/harness-upgrade`), push (`/harness-sync`, `/convention-sync`, `/harness-onboarding`), plus `/harness-affordance`. The categories accreted over time as new propagation paths were added. The seam that this spec targets is between **detection** and **remediation**:

- `/harness-audit` finds drift everywhere (HARNESS.md vs reality, constraint enforcement levels, convention file sync, ONBOARDING staleness, snapshot age, template drift, recurring reflection patterns, …).
- `/harness-sync` fixes drift in only **two** of those surfaces (convention files via `/convention-sync`, ONBOARDING.md via `/harness-onboarding`).

A user wanting to bring the project into alignment with HARNESS.md must mentally map audit's findings to remediation commands and run each one separately. The mapping is implicit and easy to forget. The new `/harness-sync` makes the mapping explicit, presents the full picture, and applies the mechanical fixes in one pass.

### The targeted scope

This spec deliberately does not collapse the command count. Two reasons: (a) every existing command name is referenced from skills, GC rules, AGENTS.md, the docs site, the SessionStart hook nudges, and external user muscle memory; renaming or removing them is high-cost; (b) the conceptual simplification (everyday users use `/harness-sync`; experts can still use the underlying primitives) gets us most of the value at low cost. A more aggressive consolidation can be revisited later if this targeted change does not yield the perceived simplicity gain.

---

## 3. Architecture: shared engine, two interfaces

```text
audit-engine (internal)
  └── scans HARNESS.md vs reality across all surfaces
  └── returns a structured drift report

/harness-audit (existing command, unchanged user-facing)
  └── calls audit-engine
  └── prints report
  └── updates HARNESS.md Status section
  └── exits

/harness-sync (this PR's redesign)
  └── calls audit-engine
  └── presents unified drift table including ALL findings
  └── multi-select prompt for which to apply
  └── auto-fixes mechanical items via existing primitives
  └── prints suggested commands for manual items
  └── re-runs audit-engine to verify
  └── commits + ships (existing flow)
```

The audit-engine is a new internal layer. It is **not** a separate command. It is the shared logic that both user-facing commands invoke. In implementation terms it can live as a sub-skill, a reference document plus prompt convention, or a shared procedural section — the spec leaves the implementation form to the plan as long as the contract holds: same drift report shape regardless of caller.

---

## 4. The unified drift table

```text
Surface / Finding                              Status      Action on apply
─────────────────────────────────────────────  ──────────  ────────────────────────
.cursor/rules/                                 drifted     /convention-sync       [auto]
.github/copilot-instructions.md                in sync     —
.windsurf/rules/                               missing     /convention-sync       [auto]
ONBOARDING.md                                  drifted     /harness-onboarding    [auto]
Snapshot staleness (last: 2026-04-15)          drifted     /harness-health        [auto]
Template version (HARNESS: 0.31, plugin: 0.34) drifted     /harness-upgrade       [manual]
Constraint regression: ShellCheck unverified   drifted     /harness-constrain     [manual]
Reflection pattern: Output validation x3       candidate   /harness-constrain     [manual]
HARNESS.md Status section accuracy             drifted     /harness-audit         [auto]
CI / CD (constraint scope)                     managed     handled at runtime
─────────────────────────────────────────────────────────────────────────────────────
N surfaces tracked · X drifted · Y missing · Z in sync · W managed
```

### Vocabulary

- `drifted` — file or fact exists but does not match HARNESS.md / reality.
- `missing` — file expected but not present.
- `in sync` — matches HARNESS.md / reality.
- `managed` — handled at runtime by other layers (CI/CD); informational only.
- `candidate` — **new state** for findings audit surfaces that are not strict drift but warrant review (recurring reflection patterns, deferred constraints).

### Action column — `[auto]` vs `[manual]`

- `[auto]` items have a deterministic remediation that the project trusts to apply without user judgement. The auto-fix runs via the existing primitive when the user selects the row in the multi-select prompt. The trust-boundary pre-commit guard's allow-list is unchanged.
- `[manual]` items require user judgement (which constraint to add, whether enforcement should be promoted, whether a template upgrade is wanted). When selected, sync prints the suggested command and exits without applying it.

### What audit-engine surfaces

The drift report includes every check audit performs today. New rows added to the table relative to today's `/harness-sync`:

- **Snapshot staleness** — auto-fix via `/harness-health`.
- **Template version drift** — manual via `/harness-upgrade`.
- **Constraint regression** — manual via `/harness-constrain`.
- **Reflection pattern** (the GC rule's findings) — manual via `/harness-constrain`.
- **Status section accuracy** — auto-fix via `/harness-audit` (which updates HARNESS.md Status as a side-effect).

The full list lives in the existing audit logic; the spec does not enumerate further. Any future audit checks added via the audit-engine layer automatically appear in the sync table.

---

## 5. Interactive flow (deltas vs today)

```text
Phase 0: Branch enforcement              [unchanged]
Phase 1: Working-tree-clean check        [unchanged]
Phase 2: Run audit-engine                [NEW — replaces per-surface drift detection]
Phase 3: Build unified drift table       [EXPANDED — see § 4]
Phase 4: Multi-select prompt             [unchanged UX, more rows]
Phase 5: Apply selected items
         ├── [auto] items run via existing primitives  [unchanged]
         └── [manual] items print "Run: <command>"     [NEW]
Phase 6: Re-run audit-engine to verify   [REPLACES per-surface re-scan]
Phase 7: Trust-boundary pre-commit guard [unchanged]
Phase 8: Commit and ship                 [unchanged]
```

`--check` mode is unchanged: stops after Phase 3 with the drift table printed.

`/harness-sync` continues to refuse running on `main`. The branch creation prompt and the working-tree-clean check are unchanged. The trust-boundary guard's allow-list is unchanged: the only paths that get committed are the four push-direction surfaces (`.cursor/rules/**`, `.github/copilot-instructions.md`, `.windsurf/rules/**`, `ONBOARDING.md`). Manual items emit suggestions, never writes.

---

## 6. `/harness-audit` standalone behaviour

Unchanged. Still callable directly. Output format unchanged. Cadence reference in HARNESS.md Observability section ("Harness audit (/harness-audit): quarterly (90 days)") stays valid. The internal implementation calls audit-engine — but it would call the same logic anyway. No user-facing migration; no doc-link breakage; no GC-rule-name changes.

---

## 7. Docs simplification

Three pages get substantive rewrites; several get touch-ups. The aim is one canonical lifecycle narrative that all the docs converge on, removing the current overlap between *the-harness-lifecycle*, *the-harness-tuning-loop*, and *self-improving-harness*.

### Substantive rewrites

| Page | Action |
| --- | --- |
| `docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md` | **Rewrite as the canonical lifecycle narrative.** Use the simpler "detect drift → heal it; pull upstream when needed" frame. Position `/harness-sync` as the everyday entry point. Reference `/harness-audit` only as the inspection-only deep-dive. The current six-stage tuning-loop narrative moves to the-harness-tuning-loop. |
| `docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md` | **Trim and align.** Drop content that overlaps with the-harness-lifecycle. Refocus this page on the *signal capture → constraint promotion* sub-flow specifically: how reflections become candidate constraints, how `/harness-constrain` promotes them. No more end-to-end lifecycle narrative here. |
| `docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md` | **Trim and align.** Position relative to the canonical lifecycle. Keep the conceptual content about why the harness needs to self-improve; remove command-level walkthroughs that duplicate the how-to pages. |

### How-to rewrites

| Page | Action |
| --- | --- |
| `docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` | **Rewrite** to document the new audit-driven flow: the unified drift table, the `[auto]`/`[manual]` distinction, the multi-select prompt, the verification step. |
| `docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md` | **Update** to clarify audit is the inspection-only deep-dive; route everyday users to `/harness-sync`. Keep audit's how-to content for users who want a focused diagnostic without the action prompt. |

### Touch-ups

| Page | Action |
| --- | --- |
| `docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md` | Mention `/harness-sync` as the everyday command; demote `/harness-audit` to "diagnostic if you want one." |
| `docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md` | Same touch-up. |
| `docs/plugins/ai-literacy-superpowers/index.md` (plugin landing) | Reflect the simpler everyday flow in the Where-to-start table or intro paragraph. |
| `CLAUDE.md` (root) and `ai-literacy-superpowers/templates/CLAUDE.md` | Quarterly/Monthly Operations sections: replace ad-hoc lists of `/convention-sync` + `/harness-onboarding` invocations with `/harness-sync`. Keep the cadence anchors (`/governance-audit`, `/cost-capture`, `/assess`, `/harness-audit`). |
| `README.md` | Plugin description and command tables: `/harness-sync` description updated; `/harness-audit` clarified as diagnostic. |

### Out of scope for the docs pass

- No reorganising of harness skills (harness-engineering, garbage-collection, constraint-design, …). Skill bodies stay; only `docs/` and root convention text change.
- No restructuring of the four-quadrant Diataxis layout. Pages keep their current quadrants.
- No changes to ONBOARDING.md or the convention files (`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`). Those are derived; they regenerate via `/harness-sync` after this PR ships.
- No changes to AGENTS.md, REFLECTION_LOG.md, or HARNESS.md content beyond the small Status-section regen that audit performs.

---

## 8. Out of scope

Explicitly deferred so the spec does not quietly grow:

- **No reduction in command count.** Eleven lifecycle commands stay. Targeted simplification only.
- **No change to `/harness-audit`'s standalone UX.**
- **No change to `/convention-sync` or `/harness-onboarding`** as standalone commands.
- **No new GC rules.** The existing GC rules continue to fire on their schedules; their findings will appear in audit-engine's drift report and therefore in `/harness-sync`'s table.
- **No version/output-format changes** to the snapshot, audit report, ONBOARDING.md, or any constraint/GC entry shape.
- **No change to the trust-boundary pre-commit guard's allow-list.** The unified drift table includes additional rows but those rows either fix non-allow-listed paths via existing primitives (which have their own trust boundaries) or print manual suggestions without writing.
- **No HARNESS.md constraint additions or modifications.** The two existing PR-time constraints (`Docs site kept current`, `Docs propagation when shipping new commands`) cover the docs work already.
- **No reorganising of harness skills.** SKILL.md files stay as authored.
- **No changes to the marketplace listing's contract** (`marketplace.json` `version`).

---

## 9. Plan summary

Single PR (`chore/harness-sync-audit-driven`):

- New audit-engine layer (implementation form per the plan).
- `/harness-sync` rewritten to call audit-engine, build unified drift table, distinguish `[auto]` vs `[manual]`.
- `/harness-audit` refactored to also call audit-engine (no user-facing change).
- Three explanation page rewrites (the-harness-lifecycle, the-harness-tuning-loop, self-improving-harness).
- Two how-to page rewrites (sync-harness, run-a-harness-audit).
- Touch-ups across tutorials, plugin landing, CLAUDE.md (root + template), README.
- Plugin version bump 0.34.1 → 0.35.0 (minor — `/harness-sync` behaviour change).
- CHANGELOG entry, marketplace.json `plugin_version`, README badge + marketplace row.

### Spec-first / adjudication exemption

The PR uses the `chore` label. Per CLAUDE.md's "Spec-First Exemptions" table, that label clears the spec-first-commit-ordering, `PRs have adjudicated objections`, and `PRs have adjudicated choice stories` constraints. Per AGENTS.md STYLE on reflection-driven amendments, chore-label-for-behavioural-change is acceptable when the implementation is conservatively bounded (single PR), the version bump is honest, and the work has been brainstormed and specified — all four conditions hold here.

---

## 10. Verification

Before the PR opens:

1. `/harness-sync` (interactive): the unified drift table renders with `[auto]`/`[manual]` columns; multi-select prompt offers all rows; selecting an `[auto]` row runs the existing primitive; selecting a `[manual]` row prints the suggested command without writing.
2. `/harness-audit` (standalone): output unchanged from today's behaviour. Confirmed by running before and after on the same project state.
3. The audit-engine's drift report shape is the same regardless of caller (asserted in implementation; verifiable by side-by-side running).
4. `mkdocs build --strict` succeeds with the rewritten docs.
5. markdownlint clean across all touched files.
6. CI green: spec-first-check (chore exemption), version-check, markdownlint, Enforce PR constraints.

After merge:

7. Pages workflow rebuilds the docs site cleanly with the rewritten lifecycle pages.

---

## 11. Risks

- **Audit-engine extraction may surface latent inconsistencies** between `/harness-audit`'s current behaviour and what's documented. Mitigation: implementation should preserve existing `/harness-audit` output exactly; any divergence is a separate fix.
- **The unified drift table could overwhelm** users on large projects with many findings. Mitigation: the multi-select prompt's "Apply nothing" option remains the safe default; users can run `--check` to see the table without committing to action.
- **Doc rewrites could lose detail** that some readers depend on. Mitigation: substantive rewrites of three pages should preserve the conceptually-load-bearing content (the three loops, the role of compound learning, the self-improvement principle); only the *narrative arrangement* changes.
- **`[manual]` rows that appear repeatedly** could create alarm fatigue. Mitigation: those rows are exactly what `/harness-constrain` and `/harness-upgrade` are for; the user is being prompted to take action, which is the intended behaviour. If a particular finding is acceptable to leave, the user dispositions it via the existing constraint-or-skip mechanisms in those commands.
