---
name: harness-upgrade
description: Discover and adopt new template content after a plugin upgrade — diffs your HARNESS.md against the current template and presents new items for review
---

# /harness-upgrade

Discover new constraints, GC rules, sections, and optional blocks that
have been added to the plugin's HARNESS.md template since your harness
was last generated or upgraded. Present each new item for review and
selectively adopt what you want.

## Process

### 1. Check Prerequisites

Verify HARNESS.md exists at the project root. If not, tell the user:
"No HARNESS.md found. Run /harness-init to create one."

Read the plugin version from
`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.

Read the template-version marker from the user's HARNESS.md. If
missing, treat as version `0.0.0`.

If versions match, tell the user: "Your harness is up to date with
the current template (vX.Y.Z). Nothing to upgrade." Then skip to
step 6 (write dismissal and update marker).

### 2. Read and Parse Both Files

Read the user's `HARNESS.md` and the plugin's template at
`${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.

Parse each file into named items:

- **Constraints**: each `### Heading` block under `## Constraints`.
  Include commented-out blocks — identify them by
  `<!-- Uncomment if...` patterns. Extract the heading name from
  inside the comment.
- **GC rules**: each `### Heading` block under
  `## Garbage Collection`. Include commented-out blocks using the
  same pattern.
- **Sections**: top-level `## Heading` entries. Compare which
  sections exist in each file.

Match items by heading name (case-insensitive, trimmed).

### 3. Categorise Findings

Sort items into three buckets:

**New items** — present in the template, absent from the user's
HARNESS.md. These are the primary upgrade targets.

**Updated items** — present in both files, but the template content
differs. Only flag items the user has not customised: if the user's
version still matches a previously generated template version (i.e.
the text is identical to what the template shipped when they last
ran init or upgrade), flag it. If the user has edited the item, skip
it — the user's version takes precedence.

**Removed items** — present in the user's HARNESS.md but absent from
the current template. Advisory only.

If no findings in any bucket, tell the user: "Your harness already
contains all current template content." Then skip to step 6.

### 4. Present Menu

Show the user each finding, grouped by bucket.

**For new items**, present each one with:

- What it is: constraint, GC rule, or section
- Whether it's active or commented-out (optional content)
- A one-line summary of what it does (from the Rule or What it checks
  field)
- Options: **accept**, **skip**, or **customise**

Ask the user to choose for each item. If there are many items, present
them in a numbered list and allow batch responses (e.g. "accept all"
or "accept 1, 3, 5, skip 2, 4").

**For updated items**, show the diff between the user's version and
the template version. Options: **accept update**, **keep mine**.

**For removed items**, list them as advisory: "These items exist in
your harness but have been removed from the template. You may want
to review whether they're still relevant." No action required.

### 5. Apply Changes

For each accepted item:

- **New constraints**: append to the `## Constraints` section, before
  the `---` separator that closes the section.
- **New GC rules**: append to the `## Garbage Collection` section,
  before the `---` separator that closes the section.
- **New sections**: insert at the position matching the template's
  section order (e.g. `## Observability` goes between
  `## Garbage Collection` and `## Status`).
- **Commented-out blocks**: insert as commented, preserving the
  `<!-- Uncomment if... -->` wrapper.
- **Updated items**: replace the user's version with the template
  version.

Preserve all existing content that was not part of the upgrade.

### 6. Update Markers

Update the `<!-- template-version: X.Y.Z -->` comment in HARNESS.md
to the current plugin version. If the marker does not exist, insert
it after the line containing
`https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html -->`.

Write the current plugin version to
`.claude/.harness-upgrade-dismissed` (create the `.claude/` directory
if it does not exist). This silences the SessionStart hook until the
next plugin upgrade.

### 7. Report

Summarise what happened:

- Items accepted (with names)
- Items skipped
- Removed items flagged for review (if any)
- Template version updated from X.Y.Z to A.B.C

Suggest next steps:

- "Run /harness-audit to verify the new constraints"
- "Run /harness-init to configure any new sections"
- If constraints were added: "New constraints start as the template
  declares them. Use /harness-constrain to adjust enforcement level
  or scope."
