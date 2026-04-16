#!/usr/bin/env bash
# Pull the global marketplace cache when marketplace.json changes upstream.
#
# Claude Code keeps ~/.claude/plugins/marketplaces/ai-literacy-superpowers
# as a git clone of this repo. When a PR that touches the top-level
# marketplace version is merged, that clone is stale until someone pulls.
# This script is invoked by a PostToolUse hook on `gh pr merge` and
# fast-forwards the clone if the listing version on origin/main differs
# from the cached one.
#
# Silent no-op when: cache directory missing, not a git repo, offline,
# cache has local/ahead state that blocks fast-forward. The script never
# fails the hook — a failed sync is a diagnostic annoyance, not a reason
# to block further work.
#
# Usage: bash sync-marketplace-cache.sh

set -euo pipefail

CACHE="${HOME}/.claude/plugins/marketplaces/ai-literacy-superpowers"

# Guard: cache must exist and be a git clone.
[ -d "${CACHE}/.git" ] || exit 0

# Fetch quietly; exit cleanly if offline or the remote is unreachable.
git -C "${CACHE}" fetch --quiet origin 2>/dev/null || exit 0

MARKETPLACE=".claude-plugin/marketplace.json"
parse_version() {
  # Extract the first top-level `"version": "X.Y.Z"` match — this is the
  # listing version (plugin_version and per-plugin versions appear later).
  sed -n 's/.*"version": "\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' | head -1
}

CACHE_VER=$(parse_version < "${CACHE}/${MARKETPLACE}" || true)
REMOTE_VER=$(git -C "${CACHE}" show "origin/main:${MARKETPLACE}" 2>/dev/null | parse_version || true)

# Nothing to do if we can't read both, or versions already match.
[ -n "${CACHE_VER}" ] && [ -n "${REMOTE_VER}" ] || exit 0
[ "${CACHE_VER}" != "${REMOTE_VER}" ] || exit 0

# Fast-forward only — refuse to rewrite cache history if it has diverged.
if git -C "${CACHE}" pull --ff-only --quiet origin main 2>/dev/null; then
  printf '{"systemMessage":"Marketplace cache synced: v%s \\u2192 v%s"}\n' \
    "${CACHE_VER}" "${REMOTE_VER}"
fi

exit 0
