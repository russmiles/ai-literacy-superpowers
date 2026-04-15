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
