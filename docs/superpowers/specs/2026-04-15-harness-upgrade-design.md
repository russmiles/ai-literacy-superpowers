---
diaboli: exempt-pre-existing
---

# Harness Upgrade — Design Spec

## Problem

When the plugin ships a new template version with additional
constraints, GC rules, sections, or commented-out optional blocks,
existing users who already ran `/harness-init` have no way to discover
or adopt the new content. Their HARNESS.md stays frozen at the version
it was generated from. There is no upgrade path.

## Goals

1. Let users pull new template content into their existing HARNESS.md
   without losing customisations.
2. Push a signal when the plugin upgrades so users know new content is
   available.
3. Consolidate the two diverged template files into a single source of
   truth.

## Non-Goals

- Automatic migration of existing content (rewording constraints,
  restructuring sections).
- Per-item version tracking.
- Rollback support beyond manual editing.

## Design

### Template Consolidation (prerequisite)

Delete `templates/HARNESS.md` (root copy). The single canonical
template lives at `ai-literacy-superpowers/templates/HARNESS.md`
(the plugin package path). `harness-init` already reads
`${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`, which resolves to the
plugin package — no command change needed.

Add a `<!-- template-version: X.Y.Z -->` comment to the template on
its own line, immediately after the closing `-->` of the intro comment
block. When `harness-init` generates a HARNESS.md, it writes this
marker with the current plugin version.

### `/harness-upgrade` Command (pull mechanism)

A new command at `ai-literacy-superpowers/commands/harness-upgrade.md`.

#### Process

1. **Read both files** — the user's `HARNESS.md` and
   `${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.

2. **Extract the template-version marker** from the user's HARNESS.md.
   If missing (pre-upgrade HARNESS.md), treat as version `0.0.0` —
   everything in the template is potentially new.

3. **Structural diff** — compare by parsing both files into named
   items:
   - **Constraints**: each `### Constraint name` block under
     `## Constraints`, including commented-out blocks identified by
     `<!-- Uncomment if...` patterns.
   - **GC rules**: each `### Rule name` block under
     `## Garbage Collection`, including commented-out blocks.
   - **Sections**: top-level `## Section` headings (e.g.
     `## Observability` — a section present in the template but absent
     from the user's file).

4. **Categorise findings** into three buckets:
   - **New items**: present in template, absent from user's HARNESS.md
     (matched by heading name).
   - **Updated items**: present in both but template content differs.
     Only applies to items the user has not customised — if the user
     has uncommented and edited a block, or modified an active
     constraint, the user's version takes precedence and the item is
     not flagged. Comparison is limited to items that still match the
     template's original text (commented or active).
   - **Removed items**: present in user's file but removed from
     template. Advisory only: "this item was removed from the
     template, you may want to review whether it's still relevant."

5. **Present menu** — show each finding with:
   - What it is (constraint, GC rule, section).
   - Whether it's active or commented-out (optional).
   - A one-line description of what it does.
   - Options: **accept** (add to HARNESS.md), **skip** (don't add),
     **customise** (add but let the user edit it first).

6. **Apply changes** — for accepted items:
   - New constraints: append to `## Constraints` section, before the
     `---` separator.
   - New GC rules: append to `## Garbage Collection` section, before
     the `---` separator.
   - New sections: insert at the position matching the template's
     section order.
   - Commented-out blocks: insert as commented, preserving the
     `<!-- Uncomment if... -->` wrapper.

7. **Update the template-version marker** in the user's HARNESS.md to
   the current plugin version.

8. **Write dismissal file** — write the current plugin version to
   `.claude/.harness-upgrade-dismissed`. This silences the
   SessionStart hook until the next plugin upgrade. The file must be
   gitignored.

9. **Report** — summarise what was added, what was skipped, and
   suggest next steps (e.g. "Run `/harness-audit` to verify the new
   constraints").

#### Skipped items

When the user skips an item, the command does not persist a skip list.
The structural diff will surface it again the next time the user runs
`/harness-upgrade` after a further plugin upgrade. This is intentional
— preferences change, and the menu is lightweight enough that re-seeing
a skipped item is not burdensome. The version marker update means the
push mechanisms go silent between upgrades.

### SessionStart Hook (immediate push)

A new hook script `hooks/scripts/template-currency-check.sh` registered
as a SessionStart event in `hooks/hooks.json`.

#### Logic

1. Check `HARNESS.md` exists at project root. If not, exit silently.
2. Extract `template-version` from `HARNESS.md` (grep for the comment
   marker).
3. Extract the current plugin version from
   `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.
4. If they match, exit silently.
5. If they differ, check for a dismissal marker file at
   `.claude/.harness-upgrade-dismissed`. If it exists and contains the
   current plugin version, exit silently — the user has already seen
   this nudge for this version.
6. If no dismissal or dismissal is for an older version, emit:

   ```json
   {"systemMessage": "Plugin template has been updated (your harness: vX.Y.Z, plugin: vA.B.C). Run /harness-upgrade to see what's new."}
   ```

The hook is advisory only — it never blocks. It uses the JSON
`systemMessage` format consistent with all other plugin hooks.

### GC Rule (persistent push)

A new GC rule added to the template's `## Garbage Collection` section:

```markdown
### Template currency

- **What it checks**: Whether the HARNESS.md template-version marker
  matches the installed plugin version, indicating new template content
  is available that hasn't been reviewed
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: compare template-version comment in HARNESS.md against
  plugin.json version
- **Auto-fix**: false
```

The GC rule ignores the dismissal marker — it reports the version
mismatch regardless. The distinction from the SessionStart hook:

- **SessionStart**: fires once per plugin upgrade, can be dismissed.
  Purpose: immediate awareness.
- **GC rule**: fires weekly regardless of dismissal. Purpose:
  persistent reminder that the user has un-reviewed template content.

The GC finding shows up in `/harness-gc` output and in health snapshots
under "GC findings", giving it visibility in the observability loop.

### Template Version Lifecycle

**On `harness-init` (first run):**

- Generates HARNESS.md from template.
- Writes `<!-- template-version: X.Y.Z -->` using the current plugin
  version.
- No dismissal file exists yet.

**On plugin upgrade (user gets new version):**

- Template may have new content.
- Plugin version in `plugin.json` advances.
- User's HARNESS.md still has the old `template-version`.
- Next session: SessionStart hook detects mismatch, emits nudge.
- Next GC run: Template currency rule reports the mismatch.

**On `/harness-upgrade`:**

- Diffs user's HARNESS.md against current template.
- User accepts/skips items via menu.
- Updates `template-version` marker to current plugin version.
- Writes dismissal file with current version.
- SessionStart hook goes silent until next plugin upgrade.
- GC rule goes silent until next plugin upgrade.

**On `/harness-init` re-run (existing HARNESS.md):**

- Preserves existing sections as before.
- Also updates `template-version` marker to current plugin version
  (since the user is actively working with init, they are choosing
  what to configure).

**Edge case — no template-version marker (pre-existing HARNESS.md):**

- `/harness-upgrade` treats it as `0.0.0` — everything in the
  template is potentially new.
- SessionStart hook treats missing marker as a mismatch.
- First `/harness-upgrade` run adds the marker.

## Components

| Component | Type | Path |
| --- | --- | --- |
| `/harness-upgrade` command | command | `commands/harness-upgrade.md` |
| Template currency check | hook script | `hooks/scripts/template-currency-check.sh` |
| SessionStart hook registration | hook config | `hooks/hooks.json` (new SessionStart entry) |
| Template currency GC rule | template content | `templates/HARNESS.md` (new GC rule) |
| Template version marker | template content | `templates/HARNESS.md` (new comment line) |
| Template consolidation | file deletion | delete root `templates/HARNESS.md` |

## Dependencies

- Template consolidation must happen before the command can be built
  (single template assumption).
- The `harness-init` command must be updated to write the
  `template-version` marker.
- `.gitignore` must include `.claude/.harness-upgrade-dismissed`.

## Version Impact

This adds a new command, a new hook script, and modifies the template.
Per semver conventions: **minor version bump** (new command = new
capability).
