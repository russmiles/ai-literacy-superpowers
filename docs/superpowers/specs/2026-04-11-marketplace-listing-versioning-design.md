# Marketplace Listing Versioning — Design

## Problem

The marketplace listing (`marketplace.json`) and the plugin
(`plugin.json`) are two independent versioned artifacts with different
lifecycles. The listing is a contract between the plugin and the
platform — it declares what the plugin is, what users consent to, and
what metadata the store presents. That contract can change independently
of the plugin software (e.g. permissions narrowed without a code
change).

Currently there are no rules governing when the listing version should
change, no explicit pointer from the listing to the approved plugin
version, and no enforcement to catch drift between the two.

## Schema Change

Add a `plugin_version` field to `marketplace.json` alongside the
existing `version` field:

- `version` — the listing version, bumped when listing metadata changes
- `plugin_version` — pointer to the currently approved plugin release

Both follow semver while pre-1.0.

### Before

```json
{
  "name": "ai-literacy-superpowers",
  "owner": { "name": "Russ Miles" },
  "plugins": [
    {
      "name": "ai-literacy-superpowers",
      "source": "./ai-literacy-superpowers",
      "description": "...",
      "version": "0.1.0"
    }
  ]
}
```

### After

```json
{
  "name": "ai-literacy-superpowers",
  "owner": { "name": "Russ Miles" },
  "version": "0.2.0",
  "plugin_version": "0.9.4",
  "plugins": [
    {
      "name": "ai-literacy-superpowers",
      "source": "./ai-literacy-superpowers",
      "description": "...",
      "version": "0.1.0"
    }
  ]
}
```

The top-level `version` and `plugin_version` are the authoritative
fields. The `plugins[].version` inside the array is the per-entry
listing version (kept for backward compatibility).

## Version Bump Rules

| What changed | Bump `version` (listing) | Update `plugin_version` |
| --- | --- | --- |
| Plugin code release | No | Yes |
| Description, keywords, owner | Yes | No (unless also releasing) |
| Permissions or consent scope | Yes | No |
| Plugin added/removed from array | Yes | No |
| Source path changes | Yes | No |

## Enforcement

### 1. CLAUDE.md convention

New section teaching agents the two-version model — when to bump each
field and where the fields live.

### 2. HARNESS.md constraint (deterministic, CI)

A CI check that `marketplace.json`'s `plugin_version` matches
`plugin.json`'s `version`. Fails the PR if they diverge. Added to the
existing `version-check.yml` workflow.

### 3. HARNESS.md GC rule (agent, weekly)

Periodic check that listing metadata (description, keywords) in
`marketplace.json` hasn't drifted from `plugin.json`. This catches
the slow divergence that CI gates don't cover.

## Files to Change

- `.claude-plugin/marketplace.json` — add `plugin_version`, promote
  `version` to top level
- `CLAUDE.md` — add marketplace versioning convention
- `HARNESS.md` — add constraint + GC rule, update status counts
- `.github/workflows/version-check.yml` — extend with marketplace
  sync check
- `CHANGELOG.md` — add entry
