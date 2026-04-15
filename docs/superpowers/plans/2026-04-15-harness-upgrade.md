# Harness Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let existing users discover and adopt new template content when the plugin upgrades, via a pull command (`/harness-upgrade`) and two push mechanisms (SessionStart hook + GC rule).

**Architecture:** A new command performs a structural diff between the user's HARNESS.md and the plugin's canonical template, presenting new items in an accept/skip menu. A SessionStart hook provides immediate awareness on plugin upgrade, with a dismissal file to silence it. A weekly GC rule provides persistent reminders. A `template-version` marker in generated HARNESS.md files tracks currency.

**Tech Stack:** Markdown (command spec), Bash (hook script), JSON (hooks.json config)

**Spec:** `docs/superpowers/specs/2026-04-15-harness-upgrade-design.md`

---

### Task 1: Consolidate template files

Remove the duplicate root-level template. The canonical template lives
at `ai-literacy-superpowers/templates/HARNESS.md`.

**Files:**
- Delete: `templates/HARNESS.md`
- Modify: `ai-literacy-superpowers/templates/HARNESS.md` (add version marker)

- [ ] **Step 1: Add template-version marker to canonical template**

Add the marker line immediately after the closing `-->` of the intro
comment block in `ai-literacy-superpowers/templates/HARNESS.md`.

Insert this line after line 12 (`https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html -->`):

```markdown
<!-- template-version: 0.18.0 -->
```

Note: we use the upcoming version (0.18.0) since this work adds a new
command — the version bump happens in a later task.

- [ ] **Step 2: Delete the root template**

```bash
git rm templates/HARNESS.md
```

- [ ] **Step 3: Verify harness-init still references the correct path**

Read `ai-literacy-superpowers/commands/harness-init.md` and confirm
step 7 references `${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`. This
resolves to `ai-literacy-superpowers/templates/HARNESS.md` at runtime.
No change needed — just verify.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "Consolidate template files into single canonical copy

Delete root templates/HARNESS.md. The plugin package copy at
ai-literacy-superpowers/templates/HARNESS.md is now the single
source of truth. Add template-version marker for upgrade tracking."
```

---

### Task 2: Add template-version marker to harness-init

Update the harness-init command to write the `template-version` marker
when generating or re-running HARNESS.md.

**Files:**
- Modify: `ai-literacy-superpowers/commands/harness-init.md`

- [ ] **Step 1: Update step 7 (Generate HARNESS.md) in harness-init**

In `ai-literacy-superpowers/commands/harness-init.md`, find the
"### 7. Generate HARNESS.md" section. Add a paragraph at the end of
the section, before `### 8. Generate CI Configuration`:

```markdown
**Template version marker (both first run and re-run):**

After writing HARNESS.md, ensure it contains a `<!-- template-version: X.Y.Z -->`
comment on its own line immediately after the intro comment block,
where X.Y.Z is the current plugin version read from
`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. If the marker
already exists, update it to the current version. If it does not
exist, insert it after the line containing
`https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html -->`.
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Update harness-init to write template-version marker

Both first run and re-run now write or update the template-version
comment in generated HARNESS.md files, enabling upgrade tracking."
```

---

### Task 3: Create the template-currency-check hook script

The SessionStart hook that detects version mismatch and nudges the
user.

**Files:**
- Create: `hooks/scripts/template-currency-check.sh`

- [ ] **Step 1: Write the hook script**

Create `hooks/scripts/template-currency-check.sh`:

```bash
#!/usr/bin/env bash
# Template currency check — runs at session start (SessionStart hook).
#
# Compares the template-version marker in the project's HARNESS.md
# against the current plugin version. If they differ and the user
# hasn't dismissed the nudge for this version, emits a system message
# suggesting /harness-upgrade.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"
PLUGIN_JSON="${CLAUDE_PLUGIN_ROOT:-.}/.claude-plugin/plugin.json"
DISMISSED_FILE="${PROJECT_DIR}/.claude/.harness-upgrade-dismissed"

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

# If plugin.json is not readable, skip silently
if [ ! -f "$PLUGIN_JSON" ]; then
  exit 0
fi

# Extract template-version from HARNESS.md
harness_version=$(sed -n 's/.*<!-- template-version: \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' "$HARNESS_FILE" | head -1)

# If no marker exists, treat as needing upgrade
if [ -z "$harness_version" ]; then
  harness_version="0.0.0"
fi

# Extract plugin version from plugin.json
plugin_version=$(sed -n 's/.*"version": "\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/p' "$PLUGIN_JSON" | head -1)
if [ -z "$plugin_version" ]; then
  exit 0
fi

# If versions match, nothing to do
if [ "$harness_version" = "$plugin_version" ]; then
  exit 0
fi

# Check for dismissal file
if [ -f "$DISMISSED_FILE" ]; then
  dismissed_version=$(cat "$DISMISSED_FILE" 2>/dev/null || echo "")
  if [ "$dismissed_version" = "$plugin_version" ]; then
    exit 0
  fi
fi

# Versions differ and not dismissed — nudge the user
printf '{"systemMessage": "Plugin template has been updated (your harness: v%s, plugin: v%s). Run /harness-upgrade to see what'"'"'s new."}' "$harness_version" "$plugin_version"

exit 0
```

- [ ] **Step 2: Make the script executable**

```bash
chmod +x hooks/scripts/template-currency-check.sh
```

- [ ] **Step 3: Verify syntax**

```bash
bash -n hooks/scripts/template-currency-check.sh
```

Expected: no output (clean parse).

- [ ] **Step 4: Verify shellcheck**

```bash
shellcheck hooks/scripts/template-currency-check.sh
```

Expected: no errors.

- [ ] **Step 5: Verify strict mode is present**

```bash
head -15 hooks/scripts/template-currency-check.sh | grep -q "set -euo pipefail" && echo "PASS" || echo "FAIL"
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add hooks/scripts/template-currency-check.sh
git commit -m "Add template currency check hook script

SessionStart hook that compares HARNESS.md template-version marker
against plugin version and nudges user to run /harness-upgrade when
they differ. Advisory only, respects dismissal file."
```

---

### Task 4: Register the SessionStart hook

Add the new script to hooks.json as a SessionStart event.

**Files:**
- Modify: `hooks/hooks.json`

- [ ] **Step 1: Add SessionStart entry to hooks.json**

The current hooks.json has `PreToolUse` and `Stop` entries. Add a new
`SessionStart` entry. The full updated file:

```json
{
  "description": "Harness engineering hooks: constraint gate (PreToolUse) warns on violations, drift check (Stop) nudges when HARNESS.md may be stale, template currency (SessionStart) nudges on plugin upgrade",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if HARNESS.md exists in the project root. If it does, read the Constraints section and identify any constraints with scope 'commit'. For each commit-scoped constraint, evaluate whether the file being written or edited would violate it. If violations are found, return a warning describing each violation with the constraint name. Do not block — only warn. If no HARNESS.md exists or no commit-scoped constraints apply, return nothing.",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/drift-check.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/snapshot-staleness-check.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/template-currency-check.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Validate JSON syntax**

```bash
python3 -c "import json; json.load(open('hooks/hooks.json'))" && echo "VALID" || echo "INVALID"
```

Expected: VALID.

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "Register template currency check as SessionStart hook

Nudges user on session start when HARNESS.md template-version
is behind the installed plugin version."
```

---

### Task 5: Add Template currency GC rule to template

Add the GC rule to the canonical template so new and upgrading users
get the persistent push mechanism.

**Files:**
- Modify: `ai-literacy-superpowers/templates/HARNESS.md`

- [ ] **Step 1: Add the GC rule**

In `ai-literacy-superpowers/templates/HARNESS.md`, add the following
block at the end of the `## Garbage Collection` section, before the
`---` separator that closes GC (before the `<!-- Uncomment if
governance...` comment block or the closing `---`). Insert it after the
last active GC rule (currently "Reflection-driven regression
detection"):

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

- [ ] **Step 2: Verify markdownlint**

```bash
npx markdownlint-cli2 "ai-literacy-superpowers/templates/HARNESS.md"
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "Add template currency GC rule to template

Weekly check that compares HARNESS.md template-version marker against
plugin version. Persistent push complement to the SessionStart hook."
```

---

### Task 6: Create the `/harness-upgrade` command

The core pull mechanism — a command spec that performs the structural
diff and presents the accept/skip menu.

**Files:**
- Create: `ai-literacy-superpowers/commands/harness-upgrade.md`

- [ ] **Step 1: Write the command spec**

Create `ai-literacy-superpowers/commands/harness-upgrade.md`:

```markdown
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
```

- [ ] **Step 2: Verify frontmatter has name and description**

```bash
head -5 ai-literacy-superpowers/commands/harness-upgrade.md
```

Expected: YAML frontmatter with `name: harness-upgrade` and
`description:` fields.

- [ ] **Step 3: Verify markdownlint**

```bash
npx markdownlint-cli2 "ai-literacy-superpowers/commands/harness-upgrade.md"
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-upgrade.md
git commit -m "Add /harness-upgrade command

Structural diff between user's HARNESS.md and plugin template.
Presents new constraints, GC rules, sections, and optional blocks
in an accept/skip menu. Updates template-version marker and writes
dismissal file on completion."
```

---

### Task 7: Add .gitignore entry for dismissal file

Ensure the dismissal marker is not committed to the repository.

**Files:**
- Create: `.gitignore` (project root — does not currently exist)

- [ ] **Step 1: Create .gitignore**

```
# Harness upgrade dismissal marker — local session state, not committed
.claude/.harness-upgrade-dismissed
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "Add .gitignore for harness upgrade dismissal marker"
```

---

### Task 8: Update plugin version, CHANGELOG, and README

This work adds a new command, a new hook script, and a new GC rule
in the template — that's a minor version bump.

**Files:**
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `CHANGELOG.md`
- Modify: `README.md`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Read current versions**

```bash
grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json
grep 'plugin_version' .claude-plugin/marketplace.json
head -5 CHANGELOG.md
```

Current version: 0.17.1. New version: 0.18.0.

- [ ] **Step 2: Bump plugin.json version**

In `ai-literacy-superpowers/.claude-plugin/plugin.json`, change:

```json
"version": "0.18.0",
```

- [ ] **Step 3: Bump marketplace.json plugin_version**

In `.claude-plugin/marketplace.json`, update `plugin_version` to
`0.18.0`.

- [ ] **Step 4: Update README badge**

In `README.md`, update the plugin version badge to `v0.18.0` and
update the Commands badge count (currently 18, now 19 with
harness-upgrade).

- [ ] **Step 5: Add CHANGELOG entry**

Add a new section at the top of `CHANGELOG.md`:

```markdown
## 0.18.0 — 2026-04-15

### Template adoption

- Add `/harness-upgrade` command — structural diff between user's
  HARNESS.md and plugin template, with accept/skip menu for new
  constraints, GC rules, sections, and optional blocks
- Add SessionStart hook for template currency — nudges user when
  plugin template has been updated since their harness was generated
- Add Template currency GC rule to template — weekly persistent
  reminder for un-reviewed template content
- Add `template-version` marker to generated HARNESS.md files for
  upgrade tracking
- Consolidate two diverged template files into single canonical copy
  at `ai-literacy-superpowers/templates/HARNESS.md`
```

- [ ] **Step 6: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json \
       .claude-plugin/marketplace.json \
       README.md \
       CHANGELOG.md
git commit -m "Bump to 0.18.0 — add /harness-upgrade and template adoption

New command, SessionStart hook, and GC rule for template currency.
Consolidate template files. Update badges and changelog."
```

---

### Task 9: Update project's own HARNESS.md

The project's own HARNESS.md should get the template-version marker
and the new GC rule, since this plugin eats its own dog food.

**Files:**
- Modify: `HARNESS.md`

- [ ] **Step 1: Add template-version marker**

Insert `<!-- template-version: 0.18.0 -->` after line 12 (the closing
`-->` of the intro comment block) in `HARNESS.md`.

- [ ] **Step 2: Add Template currency GC rule**

Add the GC rule to `HARNESS.md`'s Garbage Collection section. Insert
after the last existing GC rule ("Release tag completeness") and
before the `---` separator:

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

- [ ] **Step 3: Update the Status section**

Update the GC count in the Status section. Currently:

```
Garbage collection active: 3/8
```

Change to:

```
Garbage collection active: 3/9
```

(The new rule is declared but not yet automated in CI.)

- [ ] **Step 4: Verify markdownlint**

```bash
npx markdownlint-cli2 "HARNESS.md"
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add HARNESS.md
git commit -m "Add template-version marker and currency GC rule to project harness

Eat our own dog food: the plugin's own HARNESS.md now tracks template
currency the same way user projects will."
```
