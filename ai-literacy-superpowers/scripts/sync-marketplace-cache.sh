#!/usr/bin/env bash
set -euo pipefail
# Pull the global marketplace cache when marketplace.json changes upstream.
#
# Claude Code keeps ~/.claude/plugins/marketplaces/ai-literacy-superpowers
# as a git clone of this repo. When a PR that touches marketplace.json is
# merged — whether the change is the listing version, the plugin_version
# pointer, or any other field — the clone is stale until someone pulls it.
# This script is invoked by a PostToolUse hook on `gh pr merge` and
# fast-forwards the clone whenever marketplace.json on origin/main differs
# from the cached copy.
#
# Silent no-op when: cache directory missing, not a git repo, offline,
# marketplace.json already matches origin/main, or cache has diverged
# from origin (fast-forward refused). The script never fails the hook —
# a failed sync is a diagnostic annoyance, not a reason to block work.
#
# Usage: bash sync-marketplace-cache.sh

CACHE="${HOME}/.claude/plugins/marketplaces/ai-literacy-superpowers"
MARKETPLACE=".claude-plugin/marketplace.json"

# Guard: cache must exist and be a git clone.
[ -d "${CACHE}/.git" ] || exit 0

# Fetch quietly; exit cleanly if offline or the remote is unreachable.
git -C "${CACHE}" fetch --quiet origin 2>/dev/null || exit 0

# Gate: pull only if marketplace.json on origin/main differs from HEAD.
# `diff --quiet` exits 0 when identical, 1 when different, 2+ on error.
if git -C "${CACHE}" diff --quiet HEAD "origin/main" -- "${MARKETPLACE}"; then
  exit 0
fi

parse_version() {
  # Extract the first top-level `"version": "X.Y.Z"` match — this is the
  # listing version (plugin_version and per-plugin versions appear later).
  sed -n 's/.*"version": "\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' | head -1
}

BEFORE_VER=$(parse_version < "${CACHE}/${MARKETPLACE}" || true)

# Fast-forward only — refuse to rewrite cache history if it has diverged.
git -C "${CACHE}" pull --ff-only --quiet origin main 2>/dev/null || exit 0

AFTER_VER=$(parse_version < "${CACHE}/${MARKETPLACE}" || true)

if [ -n "${BEFORE_VER}" ] && [ -n "${AFTER_VER}" ] && [ "${BEFORE_VER}" != "${AFTER_VER}" ]; then
  printf '{"systemMessage":"Marketplace cache synced: v%s \\u2192 v%s"}\n' \
    "${BEFORE_VER}" "${AFTER_VER}"
else
  printf '{"systemMessage":"Marketplace cache synced (marketplace.json updated)."}\n'
fi

exit 0
