#!/usr/bin/env bash
# Markdownlint check — runs on PreToolUse for Write/Edit (command hook).
#
# Extracts the file path from the tool input. If the file is a .md file
# and markdownlint-cli2 is installed, runs the linter and warns on
# violations. Exits silently for non-markdown files or if the tool is
# not available.
#
# This script is advisory only — it never blocks. A non-zero exit from
# markdownlint produces a warning, not a gate.

set -euo pipefail

# Tool input is passed via stdin as JSON
input=$(cat)

# Extract file_path from the JSON input
file_path=$(echo "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

# If no file_path found, exit silently
if [ -z "$file_path" ]; then
  exit 0
fi

# Only check .md files
case "$file_path" in
  *.md) ;;
  *) exit 0 ;;
esac

# If the file does not exist yet (new file via Write), skip — markdownlint
# needs the file on disk to check it
if [ ! -f "$file_path" ]; then
  exit 0
fi

# If markdownlint-cli2 is not installed, exit silently
if ! command -v npx &>/dev/null; then
  exit 0
fi

# Run markdownlint on the specific file
output=$(npx --yes markdownlint-cli2 "$file_path" 2>&1) || {
  message="markdownlint found issues in ${file_path}:\n${output}"
  # Escape for JSON
  message=$(echo -e "$message" | sed 's/"/\\"/g' | tr '\n' ' ')
  printf '{"systemMessage": "%s"}' "$message"
}

exit 0
