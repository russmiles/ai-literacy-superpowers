#!/usr/bin/env bash
# Discovery scanner for /harness-affordance discover.
#
# Reads project-level config (.claude/settings.json,
# .claude/settings.local.json, .mcp.json) and emits a draft
# affordance inventory to .claude/affordance-discovery-<date>.md.
#
# The scanner emits machine-derivable fields only (Mode, Trigger
# for hooks, Permission). Human-owned governance fields (Identity,
# Audit trail, Notes) are left as TODO placeholders for the human
# to fill in via /harness-affordance add or by hand.
#
# Output file is gitignored (.claude/ is in .gitignore by project
# convention) so drafts never accidentally land in version control.
#
# Idempotent: running twice produces the same output modulo the
# date in the heading. Entries are sorted alphabetically by
# derived name. No timestamps inside entries.
#
# Requires: jq (for JSON parsing)
#
# Usage: bash harness-affordance-discover.sh [project-dir]
#        Default project-dir is $CLAUDE_PROJECT_DIR or "."

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${1:-.}}"
PROJECT_DIR="${PROJECT_DIR%/}"  # Strip trailing slash

# Prerequisite: jq
if ! command -v jq >/dev/null 2>&1; then
  cat >&2 <<'EOF'
ERROR: jq is required for /harness-affordance discover.
Install via:
  macOS:  brew install jq
  Linux:  apt install jq   (Debian/Ubuntu)
          dnf install jq   (Fedora/RHEL)
EOF
  exit 1
fi

SETTINGS_BASE="${PROJECT_DIR}/.claude/settings.json"
SETTINGS_LOCAL="${PROJECT_DIR}/.claude/settings.local.json"
MCP_JSON="${PROJECT_DIR}/.mcp.json"

# Guard: at least one source must exist
if [ ! -f "$SETTINGS_BASE" ] && [ ! -f "$SETTINGS_LOCAL" ] && [ ! -f "$MCP_JSON" ]; then
  echo "No project config found at ${PROJECT_DIR}/.claude/ or ${PROJECT_DIR}/.mcp.json — nothing to discover." >&2
  exit 0
fi

DATE=$(date +%Y-%m-%d)
OUT_DIR="${PROJECT_DIR}/.claude"
OUT_FILE="${OUT_DIR}/affordance-discovery-${DATE}.md"

mkdir -p "$OUT_DIR"

# Temp working files for accumulating entries before sorting.
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
ENTRIES_FILE="${WORK}/entries.txt"  # Lines: <name>\t<markdown-block-base64>
WARN_FILE="${WORK}/warnings.txt"
: > "$ENTRIES_FILE"
: > "$WARN_FILE"

# Counters
COUNT_CLI=0
COUNT_LOCAL_MCP=0
COUNT_CENTRAL_MCP=0
COUNT_HOOK=0
COUNT_SETTINGS_BASE=0
COUNT_SETTINGS_LOCAL=0
COUNT_MCP_SERVERS=0

# --- Helpers ----------------------------------------------------------------

# Validate JSON; emit parse error on stderr and return 1 on failure.
validate_json() {
  local file="$1"
  if ! jq -e . "$file" >/dev/null 2>&1; then
    echo "ERROR: malformed JSON at ${file}" >&2
    jq . "$file" 2>&1 | head -5 >&2 || true
    return 1
  fi
  return 0
}

# Derive an affordance name from a permission pattern.
# Examples:
#   Bash(gh *)            -> gh-cli
#   Bash(git *)           -> git-cli
#   Bash(npx *)           -> npx-cli
#   Bash(echo)            -> echo-cli
#   Bash(echo *)          -> echo-cli
#   mcp__honeycomb__*     -> honeycomb-mcp
#   mcp__honeycomb__query -> honeycomb-mcp-query
#   WebFetch(*)           -> webfetch-cli
derive_name() {
  local pattern="$1"
  # Bash(...)
  if [[ "$pattern" =~ ^Bash\((.+)\)$ ]]; then
    local inner="${BASH_REMATCH[1]}"
    # Skip leading env-var assignments (KEY=value or KEY="value")
    while [[ "$inner" =~ ^[A-Z_][A-Z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; do
      inner="${BASH_REMATCH[1]}"
    done
    # Take first whitespace-delimited token
    local cmd="${inner%% *}"
    # Strip trailing wildcards, colons, and slashes
    cmd="${cmd%\*}"
    cmd="${cmd%:}"
    cmd="${cmd%/}"
    # Pull out the basename (handles paths like /usr/bin/foo or $HOME/bin/foo)
    cmd=$(basename "$cmd")
    # Final scrub: strip remaining colons and lowercase
    cmd="${cmd//:/}"
    echo "${cmd}-cli" | tr '[:upper:]' '[:lower:]'
    return
  fi
  # mcp__server__method or mcp__server__*
  if [[ "$pattern" =~ ^mcp__([A-Za-z0-9_-]+)__(.+)$ ]]; then
    local server="${BASH_REMATCH[1]}"
    local method="${BASH_REMATCH[2]}"
    if [ "$method" = "*" ]; then
      echo "${server}-mcp" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
    else
      echo "${server}-mcp-${method}" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
    fi
    return
  fi
  # Other tool patterns like WebFetch(*), Read, Edit, etc.
  if [[ "$pattern" =~ ^([A-Za-z][A-Za-z0-9]*)(\(.*\))?$ ]]; then
    local tool="${BASH_REMATCH[1]}"
    echo "${tool}-cli" | tr '[:upper:]' '[:lower:]'
    return
  fi
  # Fallback: lowercase, replace non-alphanumeric with hyphen, collapse
  echo "$pattern" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

# Infer Mode from a permission pattern and the MCP servers list.
# $1 = pattern, $2 = comma-separated list of central-mcp server names.
infer_mode() {
  local pattern="$1"
  local central_servers="$2"
  if [[ "$pattern" =~ ^mcp__([A-Za-z0-9_-]+)__ ]]; then
    local server="${BASH_REMATCH[1]}"
    if [[ ",${central_servers}," == *",${server},"* ]]; then
      echo "central-mcp"
    else
      echo "local-mcp"
    fi
    return
  fi
  echo "cli"
}

# Resolve a candidate name to a unique one by appending a numeric
# suffix if needed. Echoes the resolved name. Reads ENTRIES_FILE
# (does not modify).
unique_name() {
  local candidate="$1"
  local final="$candidate"
  local suffix=1
  while grep -q -F "${final}"$'\t' "$ENTRIES_FILE" 2>/dev/null; do
    suffix=$((suffix + 1))
    final="${candidate}-${suffix}"
  done
  echo "$final"
}

# Add an entry to the working file. The block must already use the
# final (disambiguated) name in its heading — pass it through
# unique_name() before building the block.
# $1 = final name, $2 = markdown block.
add_entry() {
  local name="$1"
  local block="$2"
  printf '%s\t%s\n' "$name" "$(printf '%s' "$block" | base64 | tr -d '\n')" >> "$ENTRIES_FILE"
}

# Emit one cli/mcp affordance from a permission pattern.
# $1 = pattern, $2 = source-file label, $3 = central servers list.
emit_permission_affordance() {
  local pattern="$1"
  local source_label="$2"
  local central_servers="$3"

  local candidate mode name
  candidate=$(derive_name "$pattern")
  name=$(unique_name "$candidate")
  mode=$(infer_mode "$pattern" "$central_servers")

  case "$mode" in
    cli)         COUNT_CLI=$((COUNT_CLI + 1)) ;;
    local-mcp)   COUNT_LOCAL_MCP=$((COUNT_LOCAL_MCP + 1)) ;;
    central-mcp) COUNT_CENTRAL_MCP=$((COUNT_CENTRAL_MCP + 1)) ;;
  esac

  local block
  block=$(cat <<EOF
### ${name}

- **Mode**: ${mode}
- **Identity**: TODO
- **Audit trail**: TODO
- **Permission**: \`${pattern}\` (declared in ${source_label})
- **Last reviewed**: TODO (run \`/harness-affordance review\` once Identity and Audit trail are filled in)
EOF
)
  add_entry "$name" "$block"
}

# Emit one hook affordance.
# $1 = trigger event, $2 = matcher (or empty), $3 = command, $4 = source label.
emit_hook_affordance() {
  local trigger="$1"
  local matcher="$2"
  local hook_command="$3"
  local source_label="$4"

  # Derive a candidate name from the script basename + trigger.
  local script_basename
  script_basename=$(basename "${hook_command%% *}")
  script_basename="${script_basename%.sh}"
  script_basename="${script_basename%.py}"
  local trigger_lower
  trigger_lower=$(echo "$trigger" | tr '[:upper:]' '[:lower:]')
  local candidate="${script_basename}-${trigger_lower}"
  candidate=$(echo "$candidate" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
  local name
  name=$(unique_name "$candidate")

  COUNT_HOOK=$((COUNT_HOOK + 1))

  local matcher_clause=""
  if [ -n "$matcher" ] && [ "$matcher" != "null" ]; then
    matcher_clause=" matching \`${matcher}\`"
  fi

  local block
  block=$(cat <<EOF
### ${name}

- **Mode**: hook
- **Trigger**: ${trigger}
- **Identity**: TODO
- **Audit trail**: TODO
- **Permission**: \`hooks.${trigger}\`${matcher_clause} entry in ${source_label} invoking \`${hook_command}\`
- **Last reviewed**: TODO (run \`/harness-affordance review\` once Identity and Audit trail are filled in)
EOF
)
  add_entry "$name" "$block"
}

# --- Read MCP servers (used to infer central-mcp vs local-mcp) -------------

CENTRAL_SERVERS=""
if [ -f "$MCP_JSON" ]; then
  if validate_json "$MCP_JSON"; then
    # Servers with a `url` field (typically https://) are central; others local.
    while IFS= read -r server; do
      [ -z "$server" ] && continue
      COUNT_MCP_SERVERS=$((COUNT_MCP_SERVERS + 1))
      has_url=$(jq -r --arg s "$server" '.mcpServers[$s].url // empty' "$MCP_JSON")
      if [ -n "$has_url" ]; then
        CENTRAL_SERVERS="${CENTRAL_SERVERS},${server}"
      fi
    done < <(jq -r '.mcpServers // {} | keys[]' "$MCP_JSON")
    CENTRAL_SERVERS="${CENTRAL_SERVERS#,}"
  fi
fi

# --- Read permission entries from settings files ----------------------------

# Reads permissions and emits affordances. Updates global counters
# directly. Must NOT be invoked via $(...) — that runs the function in a
# subshell and the global updates are lost.
# $1 = file, $2 = label, $3 = name of global var to set with entry count.
read_permissions_from() {
  local file="$1"
  local label="$2"
  local count_var="$3"
  [ -f "$file" ] || return 0
  validate_json "$file" || return 1
  local count=0
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    emit_permission_affordance "$pattern" "$label" "$CENTRAL_SERVERS"
    count=$((count + 1))
  done < <(jq -r '.permissions.allow[]? // empty' "$file")
  printf -v "$count_var" '%d' "$count"
}

if [ -f "$SETTINGS_BASE" ]; then
  read_permissions_from "$SETTINGS_BASE" ".claude/settings.json" COUNT_SETTINGS_BASE
fi

if [ -f "$SETTINGS_LOCAL" ]; then
  read_permissions_from "$SETTINGS_LOCAL" ".claude/settings.local.json" COUNT_SETTINGS_LOCAL
fi

# --- Read hook entries from settings files ----------------------------------

read_hooks_from() {
  local file="$1"
  local label="$2"
  [ -f "$file" ] || return 0
  validate_json "$file" || return 1
  # hooks.<event>[].matcher  hooks.<event>[].hooks[].command
  while IFS=$'\t' read -r event matcher hook_command; do
    [ -z "$event" ] && continue
    [ -z "$hook_command" ] && continue
    emit_hook_affordance "$event" "$matcher" "$hook_command" "$label"
  done < <(jq -r '
    .hooks // {} | to_entries[] |
    .key as $event |
    .value[]? |
    (.matcher // "") as $matcher |
    (.hooks // [])[]? |
    [$event, $matcher, .command // ""] | @tsv
  ' "$file")
}

if [ -f "$SETTINGS_BASE" ]; then
  read_hooks_from "$SETTINGS_BASE" ".claude/settings.json"
fi

if [ -f "$SETTINGS_LOCAL" ]; then
  read_hooks_from "$SETTINGS_LOCAL" ".claude/settings.local.json"
fi

# --- Cross-check: MCP servers with no matching permission allowlist entry ---

if [ -f "$MCP_JSON" ] && validate_json "$MCP_JSON"; then
  while IFS= read -r server; do
    [ -z "$server" ] && continue
    # Have we emitted any affordance whose permission matches mcp__<server>__*?
    pattern_prefix="mcp__${server}__"
    if ! grep -q -F "${pattern_prefix}" "$ENTRIES_FILE"; then
      echo "WARN: MCP server '${server}' is declared in .mcp.json but has no matching permission entry (mcp__${server}__*) in any settings file." >> "$WARN_FILE"
    fi
  done < <(jq -r '.mcpServers // {} | keys[]' "$MCP_JSON")
fi

# --- Compose the output file ------------------------------------------------

{
  echo "# Affordance Discovery — ${DATE}"
  echo ""
  echo "Draft affordance inventory generated from project config."
  echo "Review each entry, fill in the human-owned fields"
  echo "(**Identity**, **Audit trail**, optional **Notes**), then"
  echo "copy approved entries into \`HARNESS.md\` under \`## Affordances\`."
  echo ""
  echo "Source files scanned:"
  if [ -f "$SETTINGS_BASE" ]; then
    echo "- \`.claude/settings.json\` (${COUNT_SETTINGS_BASE} permission entries)"
  fi
  if [ -f "$SETTINGS_LOCAL" ]; then
    echo "- \`.claude/settings.local.json\` (${COUNT_SETTINGS_LOCAL} permission entries)"
  fi
  if [ -f "$MCP_JSON" ]; then
    echo "- \`.mcp.json\` (${COUNT_MCP_SERVERS} MCP servers)"
  fi
  echo ""
  echo "Counts by mode: cli=${COUNT_CLI}, local-mcp=${COUNT_LOCAL_MCP}, central-mcp=${COUNT_CENTRAL_MCP}, hook=${COUNT_HOOK}"
  echo ""

  if [ -s "$WARN_FILE" ]; then
    echo "## Warnings"
    echo ""
    while IFS= read -r warn; do
      echo "- ${warn}"
    done < "$WARN_FILE"
    echo ""
  fi

  echo "---"
  echo ""

  # Emit entries sorted alphabetically by derived name.
  if [ -s "$ENTRIES_FILE" ]; then
    sort -t$'\t' -k1,1 "$ENTRIES_FILE" | while IFS=$'\t' read -r name encoded; do
      printf '%s' "$encoded" | base64 -d
      echo ""
      echo ""
    done
  else
    echo "_No affordances discovered. Either no permission, hook, or MCP server is declared in the scanned files, or the files are empty._"
  fi
} > "$OUT_FILE"

# --- Report -----------------------------------------------------------------

echo "Wrote draft affordance inventory to: ${OUT_FILE}"
echo "  cli:         ${COUNT_CLI}"
echo "  local-mcp:   ${COUNT_LOCAL_MCP}"
echo "  central-mcp: ${COUNT_CENTRAL_MCP}"
echo "  hook:        ${COUNT_HOOK}"
if [ -s "$WARN_FILE" ]; then
  echo ""
  echo "Warnings:"
  while IFS= read -r warn; do
    echo "  ${warn}"
  done < "$WARN_FILE"
fi
