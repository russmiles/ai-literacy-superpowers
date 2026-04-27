#!/usr/bin/env bash
# Discovery scanner for /harness-affordance discover.
#
# Reads project-level config (.claude/settings.json,
# .claude/settings.local.json, .mcp.json) and emits a draft
# affordance inventory to .claude/affordance-discovery-<date>.md.
#
# The scanner emits machine-derivable fields only (Mode, Trigger
# for hooks, Permission, Notes). Human-owned governance fields
# (Identity, Audit trail) are left as TODO placeholders for the
# human to fill in via /harness-affordance add or by hand.
#
# Output file is gitignored (.claude/affordance-discovery-*.md is
# in the project .gitignore) so drafts never accidentally land in
# version control.
#
# Idempotency: running twice on identical input produces output that
# differs only in the date in the heading. Permission patterns are
# sorted lex-ascending before processing so disambiguation suffixes
# do not depend on JSON allow-array order. Final entries are
# concatenated in `LC_ALL=C ls -1` order from a temp directory of
# per-entry files (no base64 encoding round-trip).
#
# Error handling: a malformed source file aborts the scanner via
# `set -e` before subsequent sources are processed. This is
# documented in the spec's Error Handling section as deliberate —
# loud failure beats partial output of dubious provenance.
#
# Limitation: hook commands that use shell wrappers (`bash -c '...'`,
# `python -m foo`, etc.) currently derive to wrapper-named entries
# (`bash-stop`, `python-stop`). Configure hooks to invoke scripts
# directly when affordance-readability matters. A future
# improvement will recognise common wrappers and parse their
# arguments.
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

# Working directory: one file per entry, named "<derived-name>.md".
# Final output concatenates these in `LC_ALL=C ls -1` order.
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
ENTRIES_DIR="${WORK}/entries"
mkdir -p "$ENTRIES_DIR"

# Counters
COUNT_CLI=0
COUNT_LOCAL_MCP=0
COUNT_CENTRAL_MCP=0
COUNT_HOOK=0
COUNT_SETTINGS_BASE=0
COUNT_SETTINGS_LOCAL=0
COUNT_MCP_SERVERS=0
COUNT_ORPHAN_MCP=0

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

# Strip known script extensions. Used by both Bash-pattern and
# hook-script name derivation so a `Bash(./scripts/foo.sh)` permission
# and a hook invoking `foo.sh` derive to the same root name.
strip_known_extensions() {
  local name="$1"
  name="${name%.sh}"
  name="${name%.py}"
  name="${name%.js}"
  name="${name%.rb}"
  name="${name%.ts}"
  echo "$name"
}

# Derive an affordance name from a permission pattern.
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
    # Strip known script extensions for symmetry with hook entries
    cmd=$(strip_known_extensions "$cmd")
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

# Infer Mode from a permission pattern.
# $1 = pattern, $2 = comma-separated list of central-mcp server names.
# Echoes the mode AND a "needs-notes" flag (1 if mode was guessed; 0 if known).
infer_mode() {
  local pattern="$1"
  local central_servers="$2"
  if [[ "$pattern" =~ ^Bash\( ]]; then
    echo "cli 0"
    return
  fi
  if [[ "$pattern" =~ ^mcp__([A-Za-z0-9_-]+)__ ]]; then
    local server="${BASH_REMATCH[1]}"
    if [[ ",${central_servers}," == *",${server},"* ]]; then
      echo "central-mcp 0"
    else
      echo "local-mcp 0"
    fi
    return
  fi
  # `other` case per spec: Mode: cli with a Notes flag.
  echo "cli 1"
}

# Resolve a candidate name to a unique one by appending a numeric
# suffix if needed. Reads the entries dir for existing files.
unique_name() {
  local candidate="$1"
  local final="$candidate"
  local suffix=1
  while [ -e "${ENTRIES_DIR}/${final}" ]; do
    suffix=$((suffix + 1))
    final="${candidate}-${suffix}"
  done
  echo "$final"
}

# Emit one cli/mcp affordance from a permission pattern.
# $1 = pattern, $2 = source-file label, $3 = central servers list.
emit_permission_affordance() {
  local pattern="$1"
  local source_label="$2"
  local central_servers="$3"

  local candidate name mode_with_flag mode needs_notes
  candidate=$(derive_name "$pattern")
  name=$(unique_name "$candidate")
  mode_with_flag=$(infer_mode "$pattern" "$central_servers")
  mode="${mode_with_flag% *}"
  needs_notes="${mode_with_flag##* }"

  case "$mode" in
    cli)         COUNT_CLI=$((COUNT_CLI + 1)) ;;
    local-mcp)   COUNT_LOCAL_MCP=$((COUNT_LOCAL_MCP + 1)) ;;
    central-mcp) COUNT_CENTRAL_MCP=$((COUNT_CENTRAL_MCP + 1)) ;;
  esac

  {
    echo "### ${name}"
    echo ""
    echo "- **Mode**: ${mode}"
    echo "- **Identity**: TODO"
    echo "- **Audit trail**: TODO"
    echo "- **Permission**: \`${pattern}\` (declared in ${source_label})"
    echo "- **Last reviewed**: TODO (run \`/harness-affordance review\` once Identity and Audit trail are filled in)"
    if [ "$needs_notes" = "1" ]; then
      echo "- **Notes**: Mode \`cli\` was inferred for an unrecognised pattern shape; reviewer should verify the actual transport before promoting"
    fi
  } > "${ENTRIES_DIR}/${name}"
}

# Emit an MCP-orphan affordance — for an MCP server declared in
# .mcp.json with no matching mcp__<server>__* permission entry.
# Per spec: emit a draft affordance with a WARN Notes flag.
emit_mcp_orphan_affordance() {
  local server="$1"
  local central_servers="$2"

  local candidate name mode
  candidate=$(echo "${server}-mcp" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
  name=$(unique_name "$candidate")
  if [[ ",${central_servers}," == *",${server},"* ]]; then
    mode="central-mcp"
    COUNT_CENTRAL_MCP=$((COUNT_CENTRAL_MCP + 1))
  else
    mode="local-mcp"
    COUNT_LOCAL_MCP=$((COUNT_LOCAL_MCP + 1))
  fi
  COUNT_ORPHAN_MCP=$((COUNT_ORPHAN_MCP + 1))

  {
    echo "### ${name}"
    echo ""
    echo "- **Mode**: ${mode}"
    echo "- **Identity**: TODO"
    echo "- **Audit trail**: TODO"
    echo "- **Permission**: _none — the agent cannot actually invoke this MCP server until a permission allowlist entry is added_"
    echo "- **Last reviewed**: TODO (run \`/harness-affordance review\` once Identity, Audit trail, and Permission are addressed)"
    echo "- **Notes**: WARN: MCP server \`${server}\` declared in .mcp.json but no \`mcp__${server}__*\` permission entry in any settings.json. Either add a permission to grant the agent access, or remove the server declaration."
  } > "${ENTRIES_DIR}/${name}"
}

# Emit one hook affordance.
# $1 = trigger, $2 = matcher, $3 = command, $4 = source label.
emit_hook_affordance() {
  local trigger="$1"
  local matcher="$2"
  local hook_command="$3"
  local source_label="$4"

  # Derive a candidate name from the script basename + trigger.
  # Note: shell wrappers (bash -c '...', python -m foo) produce
  # wrapper-named entries (bash-<event>, python-<event>); see header.
  local script_basename
  script_basename=$(basename "${hook_command%% *}")
  script_basename=$(strip_known_extensions "$script_basename")
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

  {
    echo "### ${name}"
    echo ""
    echo "- **Mode**: hook"
    echo "- **Trigger**: ${trigger}"
    echo "- **Identity**: TODO"
    echo "- **Audit trail**: TODO"
    echo "- **Permission**: \`hooks.${trigger}\`${matcher_clause} entry in ${source_label} invoking \`${hook_command}\`"
    echo "- **Last reviewed**: TODO (run \`/harness-affordance review\` once Identity and Audit trail are filled in)"
  } > "${ENTRIES_DIR}/${name}"
}

# --- Read MCP servers (used to infer central-mcp vs local-mcp) -------------
# Cache the parsed MCP_JSON content so we only validate/parse it once.

CENTRAL_SERVERS=""
MCP_SERVERS=""  # newline-separated server names
if [ -f "$MCP_JSON" ]; then
  if validate_json "$MCP_JSON"; then
    MCP_SERVERS=$(jq -r '.mcpServers // {} | keys[]' "$MCP_JSON")
    while IFS= read -r server; do
      [ -z "$server" ] && continue
      COUNT_MCP_SERVERS=$((COUNT_MCP_SERVERS + 1))
      has_url=$(jq -r --arg s "$server" '.mcpServers[$s].url // empty' "$MCP_JSON")
      if [ -n "$has_url" ]; then
        CENTRAL_SERVERS="${CENTRAL_SERVERS},${server}"
      fi
    done <<< "$MCP_SERVERS"
    CENTRAL_SERVERS="${CENTRAL_SERVERS#,}"
  fi
fi

# --- Read permission entries from settings files ----------------------------
# Patterns are accumulated in a tempfile, then sorted lex-ascending so
# disambiguation does not depend on source-array order.

PATTERNS_FILE="${WORK}/patterns.tsv"
: > "$PATTERNS_FILE"

read_permissions_into_file() {
  local file="$1"
  local label="$2"
  local count_var="$3"
  [ -f "$file" ] || return 0
  validate_json "$file" || return 1
  local count=0
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    printf '%s\t%s\n' "$pattern" "$label" >> "$PATTERNS_FILE"
    count=$((count + 1))
  done < <(jq -r '.permissions.allow[]? // empty' "$file")
  printf -v "$count_var" '%d' "$count"
}

if [ -f "$SETTINGS_BASE" ]; then
  read_permissions_into_file "$SETTINGS_BASE" ".claude/settings.json" COUNT_SETTINGS_BASE
fi
if [ -f "$SETTINGS_LOCAL" ]; then
  read_permissions_into_file "$SETTINGS_LOCAL" ".claude/settings.local.json" COUNT_SETTINGS_LOCAL
fi

# Sort patterns lex-ascending so disambiguation suffixes are
# independent of source-array order.
if [ -s "$PATTERNS_FILE" ]; then
  LC_ALL=C sort -t$'\t' -k1,1 "$PATTERNS_FILE" -o "$PATTERNS_FILE"
  while IFS=$'\t' read -r pattern label; do
    emit_permission_affordance "$pattern" "$label" "$CENTRAL_SERVERS"
  done < "$PATTERNS_FILE"
fi

# --- Read hook entries from settings files ----------------------------------

read_hooks_from() {
  local file="$1"
  local label="$2"
  [ -f "$file" ] || return 0
  validate_json "$file" || return 1
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
# Operates on plaintext PATTERNS_FILE rather than encoded entry blocks.

if [ -n "$MCP_SERVERS" ]; then
  while IFS= read -r server; do
    [ -z "$server" ] && continue
    pattern_prefix="mcp__${server}__"
    if ! grep -q -F "${pattern_prefix}" "$PATTERNS_FILE" 2>/dev/null; then
      emit_mcp_orphan_affordance "$server" "$CENTRAL_SERVERS"
    fi
  done <<< "$MCP_SERVERS"
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
    echo "- \`.mcp.json\` (${COUNT_MCP_SERVERS} MCP servers"
    if [ "$COUNT_ORPHAN_MCP" -gt 0 ]; then
      echo -n "  "
      echo "; ${COUNT_ORPHAN_MCP} without matching permission entries — see entries flagged WARN below)"
    else
      echo "  )"
    fi
  fi
  echo ""
  echo "Counts by mode: cli=${COUNT_CLI}, local-mcp=${COUNT_LOCAL_MCP}, central-mcp=${COUNT_CENTRAL_MCP}, hook=${COUNT_HOOK}"
  echo ""
  echo "---"
  echo ""

  # Emit entries in LC_ALL=C-sorted basename order. Sorting by basename
  # (not full path) ensures `awk-cli` precedes `awk-cli-2` — full-path
  # sort would put `awk-cli-2.md` before `awk-cli.md` because `-` < `.`
  # in ASCII. Names are constrained by derive_name to lowercase
  # alphanumeric + hyphens, so `ls -1` is safe here.
  # shellcheck disable=SC2012
  if [ -n "$(LC_ALL=C ls -1 "$ENTRIES_DIR" 2>/dev/null)" ]; then
    # shellcheck disable=SC2012
    LC_ALL=C ls -1 "$ENTRIES_DIR" | while IFS= read -r entry_file; do
      cat "${ENTRIES_DIR}/${entry_file}"
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
if [ "$COUNT_ORPHAN_MCP" -gt 0 ]; then
  echo ""
  echo "Note: ${COUNT_ORPHAN_MCP} MCP server(s) declared in .mcp.json have no matching permission entry; see WARN-flagged entries in the output."
fi
