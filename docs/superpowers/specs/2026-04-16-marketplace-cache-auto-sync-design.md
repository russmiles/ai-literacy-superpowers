# Marketplace Cache Auto-Sync — Design Spec

## Problem

Claude Code keeps the marketplace listing for this plugin as a git
clone at `~/.claude/plugins/marketplaces/ai-literacy-superpowers/`.
When a PR that changes `.claude-plugin/marketplace.json` is merged,
that clone is stale until a human (or another tool) runs `git pull`
against it. Stale clones serve the old `source` path, the old
`plugin_version`, and the old listing metadata — all invisible
failures that surface only when users try to install or update the
plugin on a fresh machine.

The existing `sync-to-global-cache.sh` handles the other half of the
cache (`~/.claude/plugins/cache/ai-literacy-superpowers/<version>/`),
but it only syncs plugin *content* from the local working tree — it
does nothing for the marketplace clone.

## Decision

Add a companion script, `sync-marketplace-cache.sh`, invoked by a
`PostToolUse` hook that matches `Bash(gh pr merge*)`. When a merge
happens through the Claude Code CLI, the hook fires, the script
fetches `origin`, compares the listing version in the clone's
`marketplace.json` to the one on `origin/main`, and fast-forwards
the clone if they differ.

Three properties are non-negotiable:

1. **Silent no-op when state is unusual.** Missing cache directory,
   offline, non-fast-forward state, or already-current versions all
   exit 0 without output. A failed sync is a diagnostic annoyance,
   never a reason to block the parent hook chain or the user's work.
2. **Version-gated pull.** The script compares the top-level
   `version` field (listing version) between cache and
   `origin/main`. It only pulls when they differ. This matches the
   user's request ("when the marketplace version changes") and
   avoids pulling on every merge.
3. **Fast-forward only.** If the cache has diverged from
   `origin/main` (unexpected), the script refuses to rewrite its
   history and exits silently. The user investigates manually.

## Scope

In scope:

- `ai-literacy-superpowers/scripts/sync-marketplace-cache.sh`
  (committed in the plugin directory so anyone installing the
  plugin has the script available)
- Hook wiring in `.claude/settings.local.json` (gitignored, per-
  machine) so the author's setup invokes it automatically
- Documentation in `CLAUDE.md` so collaborators know how to opt in

Out of scope for this spec:

- A `SessionStart` hook to catch PRs merged through the GitHub web
  UI (belt-and-braces; deferrable follow-up)
- Project-level settings.json enforcement (would require confirming
  the hook is safe for all collaborators regardless of their plugin
  install state)
- Telemetry or metrics on how often the sync fires

## Consequences

- One more script to maintain; mirrored structure to the existing
  sync-to-global-cache script limits the cost.
- The rule only fires for CLI-driven merges. Web-UI merges remain
  the user's manual responsibility until a SessionStart companion
  hook lands.
- The cache pull depends on network availability at merge time; the
  script silently skips when offline, so the cache stays at the
  pre-merge state until the next successful run.
