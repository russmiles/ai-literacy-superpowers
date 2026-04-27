---
spec: docs/superpowers/specs/2026-04-27-harness-affordance-discover.md
date: 2026-04-27
mode: code
diaboli_model: claude-opus-4-7
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "The MCP-without-permission cross-check searches base64-encoded entry blocks for plaintext permission prefixes, so the grep can never match a real permission and the warning logic is effectively broken."
    evidence: "scripts/harness-affordance-discover.sh stores entries as `<name>\\t<base64-of-block>`; the cross-check then runs `grep -q -F \"${pattern_prefix}\" \"$ENTRIES_FILE\"` looking for `mcp__<server>__` against a file whose body column is base64."
    disposition: accept
    disposition_rationale: "Critical bug confirmed. Fix by eliminating base64 encoding entirely: write one entry per file to a temp directory (named by the affordance name), and maintain a parallel plaintext permissions.txt for the cross-check. The grep then operates on real content. Also resolves O3, O4, O6 by removing the encoding round-trip and giving each entry a stable on-disk presence."
  - id: O2
    category: specification quality
    severity: high
    claim: "The implementation omits the `Notes` field from every emitted block, but the spec's output template defines `Notes` and the `Sources read` section explicitly requires a Notes flag for the `other → cli` case."
    evidence: "Spec output template defines `- **Notes**: <any warnings emitted by the scanner; otherwise omit>` and the mode-inference rules say `other → Mode: cli with a Notes flag`. The `emit_permission_affordance` block has no `Notes` line."
    disposition: accept
    disposition_rationale: "Spec deviation. Add a `Notes` field to the block as an optional line — emitted only when the scanner has something to say (the `other → cli` case, the WARN flag for MCP orphans, etc.). Block schema gains one conditional line; the `add` and `review` subcommands later can rely on a stable shape."
  - id: O3
    category: specification quality
    severity: high
    claim: "The spec mandates that an MCP server with no matching permission entry produces a draft affordance (with a Notes flag); the implementation only writes a top-of-file warning line and never emits an affordance entry for that server."
    evidence: "Spec says the cross-check should emit a draft affordance with a `WARN: no permission allowlist entry` Notes flag. The script writes to WARN_FILE only and never calls add_entry for the orphan server."
    disposition: accept
    disposition_rationale: "Spec deviation. After the refactor for O1, the orphan-MCP-server case calls `add_entry` like any other affordance, with `Notes: WARN: no permission allowlist entry in any settings.json`. The reviewer then sees the orphan as a row in the entry stream rather than as a separate warning paragraph."
  - id: O4
    category: implementation
    severity: high
    claim: "Disambiguation suffixes depend on the insertion order into ENTRIES_FILE, which mirrors the order of `permissions.allow` in the JSON source — reordering the allow-array silently swaps which collision-victim wins the unsuffixed name."
    evidence: "`unique_name` walks suffixes against entries already present in `ENTRIES_FILE`; entries enter in source-array order via `jq -r '.permissions.allow[]?'`. Spec claims re-runs produce stable identifiers without qualifying source-order dependency."
    disposition: accept
    disposition_rationale: "Sort the permission patterns lex-ascending before iteration so disambiguation is independent of source-array order. A user who reorders the allow array still gets the same suffix assignments. Combined with O1's one-file-per-entry refactor, the disambiguation logic becomes filename-based instead of grep-based, which is also faster and more obvious."
  - id: O5
    category: implementation
    severity: high
    claim: "The output sort is locale-dependent — `sort -t$'\\t' -k1,1` without `LC_ALL=C` produces different orderings on systems with different default locales, defeating the spec's cross-machine idempotency claim."
    evidence: "The script uses `sort -t$'\\t' -k1,1 \"$ENTRIES_FILE\"`. Spec promises diffable, idempotent runs; the script does not pin the collation locale."
    disposition: accept
    disposition_rationale: "One-line fix: use `LC_ALL=C sort` (and `LC_ALL=C ls -1` after the refactor) so collation is byte-ordered and identical across machines. Defends the cross-machine idempotency claim."
  - id: O6
    category: risk
    severity: medium
    claim: "The base64 encode/decode round-trip uses `base64 -d` for decoding, which is GNU coreutils convention; older or stripped-down BSD `base64` builds use `-D`, with no probe or fallback. On a system where `-d` is unsupported the decode silently produces no output and entries disappear."
    evidence: "Script invokes `printf '%s' \"$encoded\" | base64 -d`. The script header documents macOS and Linux as supported; no probe selects between `-d` and `-D`."
    disposition: accept
    disposition_rationale: "Resolved by O1's refactor: removing base64 entirely eliminates the portability concern. No probe needed, no fallback needed."
  - id: O7
    category: implementation
    severity: medium
    claim: "Hook script-name derivation strips `.sh` and `.py` extensions, but Bash-pattern derivation strips no extensions, so `Bash(./scripts/foo.sh)` becomes `foo.sh-cli` while a hook invoking the same script becomes `foo-stop` — inconsistent."
    evidence: "Hook path strips `.sh`/`.py` only; `derive_name` for Bash calls `basename` but never strips a suffix."
    disposition: accept
    disposition_rationale: "Extract a shared `strip_known_extensions` helper that both `derive_name` (for Bash patterns) and `emit_hook_affordance` (for hook script paths) call. Strip `.sh`, `.py`, `.js`, `.rb`, `.ts` — the common script extensions. A Bash permission for `Bash(./scripts/foo.sh)` and a hook invoking `foo.sh` will then both derive to `foo`."
  - id: O8
    category: implementation
    severity: medium
    claim: "Hook command parsing takes the first whitespace-delimited token as the script path. Shell wrappers (`bash -c '...'`, `python -m foo`) collapse to wrapper-named entries (`bash-stop`, `python-stop`) that convey nothing about what the hook does."
    evidence: "Script uses `script_basename=$(basename \"${hook_command%% *}\")`. The spec's example assumes script-style hook commands but does not constrain the input form."
    disposition: clarify
    disposition_rationale: "Real concern but the fix is non-trivial (parse `-c` arguments, recognise known wrappers like `bash`, `sh`, `python`, `node`). Defer to a follow-on improvement; for v0.28.0, accept the limitation. Spec will be updated to document that hook commands using shell wrappers produce wrapper-named affordances and recommend that hook configs invoke scripts directly when affordance-readability matters."
  - id: O9
    category: risk
    severity: medium
    claim: "`validate_json` runs against `.mcp.json` twice; if the file is edited between those calls and becomes malformed, the second call aborts the script via `set -e` after entries are accumulated but before the output file is written — silent data loss."
    evidence: "Script invokes `validate_json \"$MCP_JSON\"` at MCP server enumeration and again at the cross-check step. Output is written in a heredoc block that only runs after both checks complete."
    disposition: accept
    disposition_rationale: "Read `.mcp.json` once into a variable at the start of the script and use the cached parse for both the server enumeration and the cross-check. Eliminates the race window."
  - id: O10
    category: specification quality
    severity: low
    claim: "Behaviour on a malformed first source file is undocumented — the script aborts under `set -e` before other source files are processed, but the spec only specifies non-zero exit on malformed JSON without saying whether other sources should still be scanned."
    evidence: "Spec's Error Handling section says `exit non-zero so CI can catch` without addressing partial progress. Script aborts via `set -e` on first malformed source."
    disposition: accept
    disposition_rationale: "Document the all-or-nothing behaviour explicitly in the spec's Error Handling section: a malformed source file aborts the scanner before subsequent sources are processed. The implementation choice is reasonable (loud failure beats partial output of dubious provenance), but it should not be implicit."
---

# Adversarial Review — harness-affordance-discover (code mode)

Spec: `docs/superpowers/specs/2026-04-27-harness-affordance-discover.md`
Mode: code
Reviewer: advocatus-diaboli (Claude Opus 4.7)

## O1 — implementation — critical

### Claim

The MCP-without-permission cross-check is broken. It searches base64-encoded entry blocks for plaintext permission prefixes, which can never match.

### Evidence

`emit_permission_affordance` and `add_entry` store each entry as `<name>\t<base64-of-block>`. The cross-check then does `grep -q -F "${pattern_prefix}" "$ENTRIES_FILE"` looking for `mcp__<server>__`. Only the derived name (e.g. `honeycomb-mcp`) is plaintext on each line. The literal string `mcp__honeycomb__` is base64-encoded and so is invisible to a literal grep.

### Why this matters

The cross-check is the design's "asymmetric blocking case": permission-without-affordance is advisory, but affordance-without-permission is a governance hole that must be surfaced. Shipping a check that cannot actually detect this case — while the how-to claims it can — is worse than not shipping the check, because reviewers will trust the absence of warnings as evidence of correctness.

A correct check should grep against the original permission patterns held in plaintext (write a parallel `${WORK}/permissions.txt` capturing every raw pattern as it is read from settings, or invert the test by enumerating every `mcp__<server>__*` permission and confirming each derived server name is in the `.mcp.json` server list).

## O2 — specification quality — high

### Claim

The implementation does not emit a `Notes` field on any block, but the spec's output template defines `Notes` and the mode-inference rules require a Notes flag for the `other → cli` case.

### Evidence

Spec template has `- **Notes**: <any warnings emitted by the scanner; otherwise omit>`. Spec rules: "other → `Mode: cli` with a Notes flag". The `emit_permission_affordance` block has no Notes line and no path that emits one.

### Why this matters

(1) The "other" case (e.g. `WebFetch(*)`, `Read`, `Edit`) is silently mis-classified as ordinary `cli` with no flag — the human reviewer has no signal that the derivation guessed at `Mode: cli`. (2) Any caller relying on the spec's stated entry shape will have to handle two block shapes — one with Notes, one without — or be retrofitted later.

## O3 — specification quality — high

### Claim

For the MCP-server-without-permission case, the spec requires the scanner to emit a draft *affordance* with a Notes flag. The implementation emits only a top-of-file warning line and produces no affordance entry for the orphan server.

### Evidence

Spec: cross-check should "emit a draft affordance with a `WARN: no permission allowlist entry` Notes flag". The script only writes to `WARN_FILE` and never calls `add_entry` for the orphan.

### Why this matters

A reviewer scanning the affordance entries gets no row for the orphan server, so the natural promotion workflow never produces an affordance entry for the unauthorised server. The spec's design was to make the affordance entry itself the artefact reviewers act on. (Compounds with O1: even if the cross-check grep is fixed, the architectural choice to write to `WARN_FILE` instead of `add_entry` remains a deviation.)

## O4 — implementation — high

### Claim

Disambiguation suffixes depend on insertion order into `ENTRIES_FILE`, which mirrors the order of `permissions.allow` in the JSON source. Reordering the allow-array silently swaps which collision-victim wins the unsuffixed name; HARNESS.md entries already promoted under the previous order silently dangle.

### Evidence

`unique_name` walks suffixes only against entries already present in `ENTRIES_FILE`. Entries enter in source-array order via `jq -r '.permissions.allow[]?'`. Spec claims "re-runs produce stable identifiers" without qualifying that stability depends on source-array order being stable.

### Why this matters

A user who promotes `awk-cli` to HARNESS.md and later re-orders the allow array gets a HARNESS.md entry that now describes a different permission. There is no diff signal at the affordance-name level. A more robust derivation would suffix by content hash, by lexical order of the colliding pattern strings, or warn loudly when collisions occur.

## O5 — implementation — high

### Claim

The output sort is locale-dependent. `sort -t$'\t' -k1,1` without `LC_ALL=C` produces different orderings on systems whose default locales differ, defeating the spec's cross-machine idempotency claim.

### Evidence

`sort -t$'\t' -k1,1 "$ENTRIES_FILE"`. Spec promises "safe to diff successive runs"; the script does not pin the collation locale.

### Why this matters

CI runs the scanner in one locale; developers in another. Diffing CI output against local output produces spurious noise. The fix is one line — `LC_ALL=C sort ...`.

## O6 — risk — medium

### Claim

The base64 encode/decode round-trip uses `base64 -d` (GNU convention). BSD `base64` historically requires `-D`. On a system where the on-PATH `base64` does not accept `-d`, the decode silently produces empty output and entries disappear with no error.

### Evidence

`printf '%s' "$encoded" | base64 -d`. No probe selects between flags; `set -e` does not catch a `base64` that exits 0 with empty output.

### Why this matters

Modern macOS does accept `-d` (since circa 2014), but older or trimmed-down systems fail silently — counts in the heading would not match the entries below. An alternative that avoids the encoding entirely (one entry per file in a sorted directory, then `cat` in `ls -1` order) eliminates the portability concern.

## O7 — implementation — medium

### Claim

Hook script-name derivation strips `.sh` and `.py` extensions; Bash-pattern derivation strips no extensions. `Bash(./scripts/foo.sh)` becomes `foo.sh-cli` while a hook invoking the same script becomes `foo-stop` — inconsistent.

### Evidence

Hook path strips `.sh`/`.py` only; `derive_name` for Bash calls `basename` but never strips a suffix.

### Why this matters

Affordance entries are meant to be human-readable handles. Two entries describing the same underlying script under inconsistent names invites the reviewer to treat them as separate concerns. Fix is a one-line addition in `derive_name`.

## O8 — implementation — medium

### Claim

Hook command parsing takes the first whitespace-delimited token as the script path. Shell wrappers (`bash -c '...'`, `python -m foo`) collapse to wrapper-named entries (`bash-stop`, `python-stop`) that convey nothing about what the hook does.

### Evidence

`script_basename=$(basename "${hook_command%% *}")`. Spec's example assumes script-style hook commands but does not constrain the input form.

### Why this matters

`bash-stop` and `bash-stop-2` are not useful identifiers for governance. A more informative derivation would inspect the `-c` argument or the next non-flag token after a known wrapper, or fall back to a content hash.

## O9 — risk — medium

### Claim

`validate_json` runs against `.mcp.json` twice — once during MCP-server enumeration, again at the cross-check. If the file is edited between calls and becomes malformed, the second call aborts the script via `set -e` after entries are accumulated but before the output file is written. The user gets no output and no signal that work was lost.

### Evidence

Script invokes `validate_json "$MCP_JSON"` at MCP server enumeration and again at the cross-check step. Output is written in a heredoc block that only runs after the cross-check completes.

### Why this matters

Concurrent edits to `.mcp.json` are not exotic. The narrow window does occur, and "scan succeeded silently then failed silently" is poor UX for a tool positioned as safe to run on a schedule. Reading and validating each file once into a variable, or writing partial output to a `.partial` path that is moved into place at the end, would harden this.

## O10 — specification quality — low

### Claim

Behaviour on a malformed first source file is undocumented — the script aborts under `set -e` before other source files are processed, but the spec only specifies non-zero exit on malformed JSON without saying whether other sources should still be scanned.

### Evidence

Spec's Error Handling: "Malformed JSON → emit the file path and parse error to stderr, exit non-zero so CI can catch." Nothing about partial progress. Script aborts via `set -e` on first malformed source.

### Why this matters

The user's mental model from the spec is "exit non-zero on malformed JSON"; the implementation also implicitly enforces "and process nothing further." Either pin the choice in the spec, or relax the implementation to continue and accumulate parse errors.

## Explicitly not objecting to

- **`set -euo pipefail` choice**: strict mode is correct for this kind of scanner.
- **Use of `jq` as a hard dependency**: jq is widely available; the install-hint failure path is clean.
- **Tempdir cleanup via `trap 'rm -rf "$WORK"' EXIT`**: standard idiom; behaves correctly under exit and SIGINT/SIGTERM.
- **`derive_name` env-var-prefix handling**: the leading `KEY=value` strip handles real-world patterns and the regex is well-anchored.
- **Subshell-counter fix via `printf -v "$count_var"`**: the iteration-1 bug was fixed correctly.
- **Stub messages for `add` and `review` subcommands**: pointing the user at the design spec is the right interim contract.
- **`.claude/` gitignored output path**: aligns with project convention.
- **Splitting the parent command from the scanner script**: the decomposition matches the design spec's command-routing pattern and gives `add`/`review` clean addition paths later.
