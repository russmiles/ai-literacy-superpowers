---
title: Update the Plugin
layout: default
parent: How-to Guides
nav_order: 27
---

# Update the Plugin

Keep the plugin and marketplace listing current when new versions are
released.

---

## Prerequisites

- The plugin is already installed (see [Installation](../../README.md#installation))
- For marketplace updates: you maintain a marketplace that includes
  this plugin

---

## 1. Check for a new version

Compare your installed version against the latest release:

```bash
claude plugin list
```

Look for `ai-literacy-superpowers` in the output. The version shown is
what you have locally. Check the
[CHANGELOG](../../CHANGELOG.md) or the
[releases page](https://github.com/Habitat-Thinking/ai-literacy-superpowers/releases)
for the latest version.

---

## 2. Update the installed plugin

Pull the latest version into your local environment:

```bash
# Claude Code
claude plugin update ai-literacy-superpowers
```

```bash
# Copilot CLI
/plugin update ai-literacy-superpowers
```

This fetches the newest plugin code — skills, agents, hooks, commands,
and templates. Your project files (CLAUDE.md, HARNESS.md, etc.) are
not overwritten; only the plugin itself is updated.

---

## 3. Review what changed

After updating, check the changelog for anything that affects your
workflow:

```bash
# In Claude Code, read the changelog
cat node_modules/.claude/plugins/ai-literacy-superpowers/CHANGELOG.md
```

Or check the [CHANGELOG](../../CHANGELOG.md) on GitHub. Pay attention
to:

- **New skills or agents** that you may want to use
- **Changed hooks** that may alter advisory behaviour
- **Version bumps** that indicate breaking changes (minor bumps in
  pre-1.0 may include behavioural changes)

---

## 4. Update the marketplace listing (maintainers only)

If you maintain a marketplace that includes this plugin, refresh the
index so the new version is discoverable:

```bash
claude plugin marketplace update Habitat-Thinking/ai-literacy-superpowers
```

This pulls the latest `plugin.json` metadata — version, description,
keywords — into the marketplace index. It does not update installations
for users who already have the plugin; they must run
`claude plugin update` themselves.

---

## 5. Verify the update

Confirm the new version is active:

```bash
claude plugin list
```

Then run a quick health check to make sure everything loads:

```text
/superpowers-status
```

If the status command reports missing components, try removing and
reinstalling the plugin:

```bash
claude plugin uninstall ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

---

## What you have now

Your plugin is at the latest version. All skills, agents, hooks, and
commands reflect the newest release. If you maintain a marketplace, it
now advertises the current version to other users.

## Next steps

- [Check harness health](run-a-harness-audit.md) after major version
  updates
- [Review the CHANGELOG](../../CHANGELOG.md) for migration notes
- [Run an assessment](run-an-assessment.md) to see if new skills
  unlock higher literacy levels
