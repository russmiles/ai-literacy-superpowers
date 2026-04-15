# Marketplace Listing Versioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Treat the marketplace listing as an independently versioned artifact with its own lifecycle, enforced by convention, CI, and GC.

**Architecture:** Add `plugin_version` pointer to `marketplace.json`, add conventions to CLAUDE.md, add a deterministic CI constraint and an agent GC rule to HARNESS.md, extend the existing version-check workflow.

**Tech Stack:** JSON, Markdown, Bash (CI workflow), YAML (GitHub Actions)

---

## Task 1: Update marketplace.json schema

**Files:**

- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Add top-level version and plugin_version fields**

Edit `.claude-plugin/marketplace.json` to add the two top-level fields.
The `version` becomes `0.2.0` (bumped from the implicit 0.1.0 because
the schema itself is changing). The `plugin_version` points to the
current plugin release.

```json
{
  "name": "ai-literacy-superpowers",
  "owner": {
    "name": "Russ Miles"
  },
  "version": "0.2.0",
  "plugin_version": "0.9.4",
  "plugins": [
    {
      "name": "ai-literacy-superpowers",
      "source": "./ai-literacy-superpowers",
      "description": "AI Literacy framework development workflow — harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops",
      "version": "0.1.0"
    }
  ]
}
```

- [ ] **Step 2: Verify JSON is valid**

Run: `python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"`
Expected: no output (success)

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Add top-level version and plugin_version to marketplace.json"
```

---

## Task 2: Add marketplace versioning convention to CLAUDE.md

**Files:**

- Modify: `CLAUDE.md`

- [ ] **Step 1: Add Marketplace Versioning section after Semantic Versioning**

Add a new section after the existing "Semantic Versioning" section:

```markdown
## Marketplace Versioning

The marketplace listing (`.claude-plugin/marketplace.json`) is versioned
independently from the plugin. It has two version fields:

- `version` — the listing version (the contract with the platform)
- `plugin_version` — pointer to the currently approved plugin release

**When to update `plugin_version`:**

After every plugin version bump, update `plugin_version` in
`.claude-plugin/marketplace.json` to match the new `plugin.json`
version. This is the common case — plugin code changes, listing
contract stays the same.

**When to bump `version` (listing version):**

Bump when the listing contract itself changes:

- Description, keywords, or owner metadata change
- Permissions or consent scope change
- A plugin entry is added or removed from the `plugins` array
- The `source` path changes

The listing version follows the same semver rules as the plugin while
pre-1.0. A listing-only change does not require a plugin version bump.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "Add marketplace versioning convention to CLAUDE.md"
```

---

## Task 3: Add marketplace sync constraint to HARNESS.md

**Files:**

- Modify: `HARNESS.md`

- [ ] **Step 1: Add constraint after Version consistency**

Add a new constraint section after the existing "Version consistency"
constraint:

```markdown
### Marketplace plugin version sync

- **Rule**: `marketplace.json` top-level `plugin_version` must match
  `plugin.json` `version`. When the plugin version is bumped, the
  marketplace pointer must be updated in the same PR.
- **Enforcement**: deterministic
- **Tool**: .github/workflows/version-check.yml
- **Scope**: pr
```

- [ ] **Step 2: Update the Status section**

Update the constraint count from `8/8` to `9/9`:

```markdown
Constraints enforced: 9/9
```

- [ ] **Step 3: Commit**

```bash
git add HARNESS.md
git commit -m "Add marketplace plugin version sync constraint to HARNESS.md"
```

---

## Task 4: Add marketplace metadata drift GC rule to HARNESS.md

**Files:**

- Modify: `HARNESS.md`

- [ ] **Step 1: Add GC rule after Plugin manifest currency**

Add a new GC rule section after the existing "Plugin manifest currency"
rule:

```markdown
### Marketplace listing drift

- **What it checks**: Whether the description and keywords in
  `marketplace.json` have drifted from `plugin.json` — the listing
  should reflect what the plugin actually declares
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
```

- [ ] **Step 2: Update GC active count in Status section**

Update from `2/6` to `2/7` (the new rule is agent-enforced, not yet
wired into CI):

```markdown
Garbage collection active: 2/7
```

- [ ] **Step 3: Commit**

```bash
git add HARNESS.md
git commit -m "Add marketplace listing drift GC rule to HARNESS.md"
```

---

## Task 5: Extend version-check.yml with marketplace sync check

**Files:**

- Modify: `.github/workflows/version-check.yml`

- [ ] **Step 1: Add marketplace version extraction to the Extract versions step**

Append these lines to the `Extract versions from all locations` step,
after the `LATEST_TAG` block:

```bash
# marketplace.json plugin_version
MARKETPLACE_PLUGIN_VERSION=$(python3 -c "
import json, sys
with open('.claude-plugin/marketplace.json') as f:
    data = json.load(f)
print(data.get('plugin_version', ''))
")
echo "marketplace_plugin=$MARKETPLACE_PLUGIN_VERSION" >> "$GITHUB_OUTPUT"
echo "marketplace:   $MARKETPLACE_PLUGIN_VERSION"
```

- [ ] **Step 2: Add marketplace sync check step**

Add a new step after "Check all three locations match":

```yaml
      - name: Check marketplace plugin_version matches plugin.json
        run: |
          PLUGIN="${{ steps.versions.outputs.plugin }}"
          MARKETPLACE="${{ steps.versions.outputs.marketplace_plugin }}"

          if [ -z "$MARKETPLACE" ]; then
            echo "::error::marketplace.json missing plugin_version field"
            exit 1
          fi

          if [ "$PLUGIN" != "$MARKETPLACE" ]; then
            echo "::error::Version mismatch: plugin.json ($PLUGIN) != marketplace.json plugin_version ($MARKETPLACE)"
            echo ""
            echo "When bumping the plugin version, also update plugin_version in:"
            echo "  - .claude-plugin/marketplace.json"
            exit 1
          fi

          echo "Marketplace plugin_version in sync: $MARKETPLACE"
```

- [ ] **Step 3: Verify workflow syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/version-check.yml'))"`
Expected: no output (success)

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/version-check.yml
git commit -m "Extend version-check workflow with marketplace plugin_version sync"
```

---

## Task 6: Update CHANGELOG, bump version, update badges

**Files:**

- Modify: `CHANGELOG.md`
- Modify: `README.md`
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Bump plugin version to 0.10.0**

This adds a constraint (behavioural change to CI), which warrants a
minor version bump.

Update `ai-literacy-superpowers/.claude-plugin/plugin.json` version to
`0.10.0`.

Update `.claude-plugin/marketplace.json` `plugin_version` to `0.10.0`.

- [ ] **Step 2: Add CHANGELOG entry**

Add a new section at the top of CHANGELOG.md:

```markdown
## 0.10.0 — 2026-04-11

### Independent Marketplace Listing Versioning

- Add `plugin_version` field to `marketplace.json` — the listing now
  explicitly declares which plugin release it approves
- Add marketplace versioning convention to CLAUDE.md — agents know
  when to bump listing version vs update plugin pointer
- Add marketplace plugin version sync constraint to HARNESS.md —
  CI blocks PRs where `plugin_version` diverges from `plugin.json`
- Add marketplace listing drift GC rule to HARNESS.md — weekly
  check that listing metadata hasn't drifted from plugin metadata
- Extend `version-check.yml` to enforce marketplace sync on every PR
```

- [ ] **Step 3: Update README badges**

Update Plugin version badge from `v0.9.4` to `v0.10.0`.

Update Harness badge from `8%2F8` to `9%2F9`.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md README.md \
  ai-literacy-superpowers/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json
git commit -m "Bump plugin to 0.10.0 for marketplace listing versioning"
```

---

## Task 7: Final verification

- [ ] **Step 1: Run markdownlint**

Run: `npx markdownlint-cli2 "CLAUDE.md" "HARNESS.md" "CHANGELOG.md" "README.md"`
Expected: no errors

- [ ] **Step 2: Validate JSON files**

Run: `python3 -c "import json; json.load(open('ai-literacy-superpowers/.claude-plugin/plugin.json')); json.load(open('.claude-plugin/marketplace.json')); print('OK')"`
Expected: `OK`

- [ ] **Step 3: Validate workflow YAML**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/version-check.yml')); print('OK')"`
Expected: `OK`

- [ ] **Step 4: Verify version consistency across all locations**

```bash
grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json
grep 'Plugin-v' README.md | head -1
grep -m1 '^## [0-9]' CHANGELOG.md
grep '"plugin_version"' .claude-plugin/marketplace.json
```

All four should show `0.10.0`.

- [ ] **Step 5: Push and create PR**

```bash
git push -u origin marketplace-listing-versioning
gh pr create --title "Add independent marketplace listing versioning" --body "..."
```

- [ ] **Step 6: Wait for CI and merge**

```bash
gh pr checks <number> --watch
gh pr merge <number> --merge
```
