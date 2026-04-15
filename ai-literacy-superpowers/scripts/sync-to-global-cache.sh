#!/usr/bin/env bash
# Sync local plugin to the global Claude Code plugin cache.
#
# Reads the version from plugin.json and rsyncs the local
# ai-literacy-superpowers/ directory to the matching version slot
# in ~/.claude/plugins/cache/. Skips silently if nothing changed
# or if the cache directory structure doesn't exist.
#
# Intended as a Stop hook in settings.local.json so the global
# install stays current during development.
#
# Usage: bash sync-to-global-cache.sh [project-dir]

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${1:-.}}"
PLUGIN_DIR="${PROJECT_DIR}/ai-literacy-superpowers"
PLUGIN_JSON="${PLUGIN_DIR}/.claude-plugin/plugin.json"
CACHE_BASE="${HOME}/.claude/plugins/cache/ai-literacy-superpowers/ai-literacy-superpowers"

# Guard: plugin.json must exist
if [ ! -f "$PLUGIN_JSON" ]; then
  exit 0
fi

# Guard: cache base must exist (plugin is installed globally)
if [ ! -d "$CACHE_BASE" ]; then
  exit 0
fi

# Read version
version=$(sed -n 's/.*"version": "\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/p' "$PLUGIN_JSON" | head -1)
if [ -z "$version" ]; then
  exit 0
fi

TARGET="${CACHE_BASE}/${version}"

# Create version directory if this is a new version
mkdir -p "$TARGET"

# Sync — delete ensures removed files don't linger in cache
rsync -a --delete \
  --exclude '.git' \
  --exclude '.github' \
  "${PLUGIN_DIR}/" "${TARGET}/"

# Report what happened
printf '{"systemMessage": "Plugin v%s synced to global cache."}' "$version"

exit 0
