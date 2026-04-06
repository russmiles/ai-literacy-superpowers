# Secrets Detection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add gitleaks-based secret detection to the harness as both a standalone skill and a default in harness-init.

**Architecture:** Five artifacts — a new skill file, updates to the HARNESS.md template, a new Stop-scope hook script, a hooks.json config update, and a harness-init command update. All files live under `ai-literacy-superpowers/`. No new agents, commands, or dependencies beyond gitleaks itself.

**Tech Stack:** Bash (hook script), Markdown (skill, template, command)

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `ai-literacy-superpowers/skills/secrets-detection/SKILL.md` | Standalone audit skill |
| Modify | `ai-literacy-superpowers/templates/HARNESS.md:53-59` | Promote constraint + add GC rule |
| Create | `ai-literacy-superpowers/hooks/scripts/secrets-check.sh` | Stop-scope advisory scan |
| Modify | `ai-literacy-superpowers/hooks/hooks.json:30-41` | Register new hook script |
| Modify | `ai-literacy-superpowers/commands/harness-init.md:49-58` | Gitleaks discovery during init |

---

### Task 1: Create the secrets-detection skill

**Files:**
- Create: `ai-literacy-superpowers/skills/secrets-detection/SKILL.md`

- [ ] **Step 1: Create the skill file**

Write `ai-literacy-superpowers/skills/secrets-detection/SKILL.md` with the following content. This follows the exact structure of the existing security skills (`dependency-vulnerability-audit`, `docker-scout-audit`, `github-actions-supply-chain`):

```markdown
---
name: secrets-detection
description: Use when auditing a project for secrets committed to source control, setting up gitleaks, or hardening the "No secrets in source" harness constraint — covers scanning, baselining, configuration, and CI integration
---

# Secrets Detection Audit

## Overview

Secrets in source code — API keys, tokens, passwords, private keys — are
one of the most common and most damaging security failures. A single
committed secret can grant an attacker access to production systems, and
git history means the secret persists even after the file is deleted.

Gitleaks is a SAST tool that scans git repositories for secrets using
regex and entropy-based detection. It catches common patterns (AWS keys,
GitHub tokens, private keys, connection strings) and supports custom
rules via `.gitleaks.toml`.

**Critical rule: Never assume a file is secret-free from visual
inspection. Run the scanner. Encoded, split, or templated secrets are
invisible to human review.**

---

## Audit Checklist

### For every project

- [ ] Gitleaks is installed and available on the path
- [ ] `gitleaks detect` runs cleanly against the current working directory
- [ ] Git history has been scanned (`gitleaks detect` without `--no-git`)
- [ ] A `.gitleaks.toml` exists if the project has known false positives
- [ ] Gitleaks runs in CI and fails the build on findings
- [ ] The HARNESS.md "No secrets in source" constraint is set to
      `deterministic` with gitleaks as the tool

---

## Installation

```bash
# macOS
brew install gitleaks

# Linux (Debian/Ubuntu)
# Download from https://github.com/gitleaks/gitleaks/releases
# Or use go install:
go install github.com/gitleaks/gitleaks/v8@latest

# Verify installation
gitleaks version
```

---

## Running the Audit

### Scan the working directory (no git history)

```bash
gitleaks detect --source . --no-banner --no-git --exit-code 1
```

`--no-git` scans only the current file state, not git history. Fast and
useful for commit-scope checks.

### Scan the full git history

```bash
gitleaks detect --source . --no-banner --exit-code 1
```

Without `--no-git`, gitleaks walks every commit in the repository. This
catches secrets that were committed and later deleted — they still exist
in history and are still exploitable.

### Scan only staged changes (pre-commit style)

```bash
gitleaks protect --source . --no-banner --staged --exit-code 1
```

`protect` mode scans uncommitted changes. Useful for pre-commit hooks.

### Generate a baseline for known false positives

```bash
gitleaks detect --source . --no-banner --report-path .gitleaks-baseline.json
```

Then on subsequent scans, exclude baseline findings:

```bash
gitleaks detect --source . --no-banner --baseline-path .gitleaks-baseline.json --exit-code 1
```

The baseline file should be committed to the repository. Review it
carefully — every entry is a finding you are explicitly accepting.

---

## Configuration

### `.gitleaks.toml` — custom rules and allowlists

Create a `.gitleaks.toml` in the project root to customise detection:

```toml
# Extend the default ruleset (don't replace it)
[extend]
useDefault = true

# Allowlist paths that contain test fixtures or example configs
[allowlist]
paths = [
  '''testdata/''',
  '''fixtures/''',
  '''.gitleaks-baseline.json''',
]

# Allowlist specific regex patterns (e.g. placeholder tokens in docs)
regexes = [
  '''EXAMPLE_KEY_[A-Z]+''',
  '''sk-test-[a-zA-Z0-9]+''',
]
```

### Common allowlist scenarios

| Scenario | Allowlist approach |
|----------|-------------------|
| Test fixtures with fake keys | `paths = ['''testdata/''']` |
| Documentation with placeholder tokens | `regexes = ['''EXAMPLE_.*''']` |
| Known false positive on a specific line | Add to `.gitleaks-baseline.json` via baseline scan |
| Encrypted secret files (e.g. SOPS) | `paths = ['''*.enc.yaml''']` |

**Never allowlist a real secret.** If the finding is a real key, rotate
it and remove it from history using `git filter-repo` or BFG Repo Cleaner.

---

## CI Integration

### GitHub Actions — using the official action (SHA-pinned)

```yaml
- name: Scan for secrets
  uses: gitleaks/gitleaks-action@ff98106e7d8ef52e496eb4e5a4ab46fc5970e459  # v2.3.8
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

The official action scans the PR diff by default, so it only flags new
secrets — not historical ones. For full-history scanning, add:

```yaml
  with:
    args: detect --source . --exit-code 1
```

**Note:** The SHA above follows the pinning guidance from the
`github-actions-supply-chain` skill. Always verify the SHA matches the
tagged release before using it. Check with:

```bash
gh api repos/gitleaks/gitleaks-action/git/ref/refs/tags/v2.3.8 --jq '.object.sha'
```

### Generic CI (any platform)

```bash
gitleaks detect --source . --no-banner --exit-code 1
```

Exit code `1` means findings were detected; the CI step fails.

---

## Harness Integration

### Promoting the constraint

In your project's `HARNESS.md`, update the "No secrets in source"
constraint:

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: deterministic
- **Tool**: gitleaks detect --source . --no-banner --exit-code 1
- **Scope**: commit
```

This promotion means:
- The **PreToolUse hook** (agent-based) still warns at write time
- The **Stop hook** runs gitleaks deterministically at session end
- The **CI gate** runs gitleaks and blocks merge on findings
- The **harness-enforcer** agent can invoke gitleaks directly

### Adding the GC rule

Add a garbage collection entry to catch scanner regression:

```markdown
### Secret scanner operational

- **What it checks**: Whether gitleaks is installed and the "No secrets
  in source" constraint is still enforced as deterministic
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: gitleaks --version && gitleaks detect --source . --no-banner --exit-code 1
- **Auto-fix**: false
```

---

## Report Format

After completing the audit, produce a findings table:

```markdown
## Secrets Detection Audit

| File | Finding | Severity | Fix |
| --- | --- | --- | --- |
| `.env.production` | AWS access key ID detected | Critical | Rotate key, remove file, add to `.gitignore` |
| `config/database.yml` | Database password in plaintext | High | Move to environment variable |
| `scripts/deploy.sh` | Hardcoded API token | High | Replace with `$API_TOKEN` env var |
| `docs/setup.md` | Example key matches real key pattern | Low | Replace with clearly fake placeholder |
```

Severity guide:

- **Critical** — real secret with production access (AWS keys, database
  credentials, private signing keys)
- **High** — real secret with limited access (API tokens, webhook
  secrets, service account keys)
- **Medium** — secret-like pattern that may be real (high-entropy
  strings, connection strings with credentials)
- **Low** — likely false positive but worth confirming (example keys,
  test fixtures, placeholder tokens)

---

## Remediating Found Secrets

Finding a secret is only half the job. The remediation steps:

1. **Rotate the secret immediately** — assume it has been compromised
2. **Remove from the current codebase** — delete or replace with env var
3. **Remove from git history** — use `git filter-repo` or BFG Repo Cleaner
4. **Add to `.gitignore`** — prevent the file from being re-committed
5. **Add a baseline entry** if the finding was a false positive
6. **Verify the fix** — re-run `gitleaks detect` and confirm clean

```bash
# Using BFG Repo Cleaner to remove a file from history:
bfg --delete-files .env.production
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Using git filter-repo to remove a specific string:
git filter-repo --invert-of --path .env.production
```

**Warning:** History rewriting is destructive and requires a force push.
Coordinate with your team before running these commands.

---

## What Gitleaks Cannot Catch

- **Encoded or encrypted secrets** — base64-encoded keys, secrets
  encrypted with SOPS or similar tools, secrets split across multiple
  lines or variables
- **Secrets in build artifacts** — compiled binaries, Docker image
  layers, generated configuration files not tracked by git
- **Runtime environment leaks** — secrets logged at runtime, exposed
  via error messages, or leaked through debug endpoints
- **Secrets with no known pattern** — custom tokens or internal keys
  that do not match any regex rule. Add custom rules to `.gitleaks.toml`
  for these.
- **Secrets in non-git-tracked files** — `--no-git` mode scans the
  working directory, but untracked files outside the project root are
  not scanned

For these gaps, combine gitleaks with runtime secret detection
(e.g. AWS Macie, HashiCorp Vault audit logs) and regular manual review.
```

- [ ] **Step 2: Verify the file was created**

Run: `ls -la ai-literacy-superpowers/skills/secrets-detection/SKILL.md`
Expected: file exists with non-zero size

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/skills/secrets-detection/SKILL.md
git commit -m "Add secrets-detection skill for gitleaks-based auditing"
```

---

### Task 2: Update the HARNESS.md template

**Files:**
- Modify: `ai-literacy-superpowers/templates/HARNESS.md:53-59` (constraint section)
- Modify: `ai-literacy-superpowers/templates/HARNESS.md:97-134` (GC section, add new rule)
- Modify: `ai-literacy-superpowers/templates/HARNESS.md:132` (status count)

- [ ] **Step 1: Promote the "No secrets in source" constraint**

In `ai-literacy-superpowers/templates/HARNESS.md`, replace lines 53-59:

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: commit
```

With:

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: deterministic
- **Tool**: gitleaks detect --source . --no-banner --exit-code 1
- **Scope**: commit
```

- [ ] **Step 2: Add the GC rule for scanner health**

In `ai-literacy-superpowers/templates/HARNESS.md`, after the existing "Command-prompt sync" GC entry (after line 124), add:

```markdown

### Secret scanner operational

- **What it checks**: Whether gitleaks is installed and the "No secrets
  in source" constraint is still enforced as deterministic (not regressed
  to unverified)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: gitleaks --version && gitleaks detect --source . --no-banner --exit-code 1
- **Auto-fix**: false
```

- [ ] **Step 3: Update the status section counts**

In `ai-literacy-superpowers/templates/HARNESS.md`, update the status section:

Replace:
```markdown
Constraints enforced: 0/3
Garbage collection active: 0/2
```

With:
```markdown
Constraints enforced: 1/3
Garbage collection active: 0/2
```

(One constraint — "No secrets in source" — is now deterministic by default.)

- [ ] **Step 4: Verify the changes**

Run: `grep -n "deterministic" ai-literacy-superpowers/templates/HARNESS.md`
Expected: should show the "No secrets in source" constraint and the "Secret scanner operational" GC rule both containing "deterministic"

Run: `grep -n "1/3" ai-literacy-superpowers/templates/HARNESS.md`
Expected: should show `Constraints enforced: 1/3`

- [ ] **Step 5: Commit**

```bash
git add ai-literacy-superpowers/templates/HARNESS.md
git commit -m "Promote 'No secrets in source' to deterministic with gitleaks in template"
```

---

### Task 3: Create the secrets-check.sh hook script

**Files:**
- Create: `ai-literacy-superpowers/hooks/scripts/secrets-check.sh`

- [ ] **Step 1: Create the hook script**

Write `ai-literacy-superpowers/hooks/scripts/secrets-check.sh` with the following content. This follows the exact pattern of `drift-check.sh` — advisory only, exits silently when not applicable:

```bash
#!/usr/bin/env bash
# Secrets check — runs at session end (Stop hook).
#
# If gitleaks is installed and HARNESS.md has a deterministic
# "No secrets in source" constraint, scans the working directory
# for committed secrets and warns if any are found.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# If gitleaks is not installed, exit silently
if ! command -v gitleaks &>/dev/null; then
  exit 0
fi

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

# If the "No secrets in source" constraint is not deterministic, exit
if ! grep -A2 "No secrets in source" "$HARNESS_FILE" | grep -q "deterministic"; then
  exit 0
fi

# Run gitleaks against the working directory (no git history, fast)
output=$(gitleaks detect --source "$PROJECT_DIR" --no-banner --no-git 2>&1) || {
  message="Gitleaks detected potential secrets in the working directory. Run 'gitleaks detect --source . --no-banner --no-git' to see details. Rotate any real secrets immediately."
  printf '{"systemMessage": "%s"}' "$(echo "$message" | sed 's/"/\\"/g')"
  exit 0
}

# Clean scan — exit silently
exit 0
```

- [ ] **Step 2: Make the script executable**

Run: `chmod +x ai-literacy-superpowers/hooks/scripts/secrets-check.sh`

- [ ] **Step 3: Verify the script is valid bash**

Run: `bash -n ai-literacy-superpowers/hooks/scripts/secrets-check.sh`
Expected: no output (no syntax errors)

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/hooks/scripts/secrets-check.sh
git commit -m "Add Stop-scope hook script for gitleaks secret scanning"
```

---

### Task 4: Update hooks.json to register the new script

**Files:**
- Modify: `ai-literacy-superpowers/hooks/hooks.json:30-41` (Stop hook array)

- [ ] **Step 1: Add the secrets-check hook entry**

In `ai-literacy-superpowers/hooks/hooks.json`, add the secrets-check entry to the Stop hooks array. The new entry goes after the existing `framework-change-prompt.sh` entry (line 38) and before the closing of the hooks array.

Replace:

```json
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/framework-change-prompt.sh",
            "timeout": 10
          }
```

With:

```json
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/framework-change-prompt.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/secrets-check.sh",
            "timeout": 15
          }
```

- [ ] **Step 2: Verify the JSON is valid**

Run: `python3 -m json.tool ai-literacy-superpowers/hooks/hooks.json > /dev/null`
Expected: no output (valid JSON)

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/hooks/hooks.json
git commit -m "Register secrets-check.sh in Stop hook array"
```

---

### Task 5: Update harness-init to offer gitleaks during setup

**Files:**
- Modify: `ai-literacy-superpowers/commands/harness-init.md:49-58` (constraints section)

- [ ] **Step 1: Update the "Ask About Constraints" section**

In `ai-literacy-superpowers/commands/harness-init.md`, replace the "Ask About Constraints" section (lines 49-59):

```markdown
### 4. Ask About Constraints

For each convention, ask whether the user wants it enforced. For each
that should be enforced:

- Check if a deterministic tool was discovered that could enforce it
- If yes, offer to configure it and set enforcement to `deterministic`
- If no, offer agent-based enforcement or leave as `unverified`

Ask about scope: should this check run at commit time (fast feedback),
PR time (strict gate), or weekly (periodic sweep)?
```

With:

```markdown
### 4. Ask About Constraints

For each convention, ask whether the user wants it enforced. For each
that should be enforced:

- Check if a deterministic tool was discovered that could enforce it
- If yes, offer to configure it and set enforcement to `deterministic`
- If no, offer agent-based enforcement or leave as `unverified`

Ask about scope: should this check run at commit time (fast feedback),
PR time (strict gate), or weekly (periodic sweep)?

#### Secret detection (default constraint)

The template includes a "No secrets in source" constraint. During setup:

1. Check whether `gitleaks` is available: `command -v gitleaks`
2. If **found**: inform the user that the constraint will be set to
   `deterministic` with gitleaks as the tool. Ask if they want to
   customise the configuration (e.g. add allowlist paths). Offer to
   run an initial scan: `gitleaks detect --source . --no-banner`
3. If **not found**: inform the user that the constraint will remain
   `unverified`. Suggest installation:
   - macOS: `brew install gitleaks`
   - Linux/Go: `go install github.com/gitleaks/gitleaks/v8@latest`
   - Then re-run `/harness-init` or use `/harness-constrain` to promote

Either way, tell the user what happened and allow them to override.
Read the `secrets-detection` skill from this plugin for full gitleaks
guidance if the user asks questions about configuration or scanning.
```

- [ ] **Step 2: Verify the change**

Run: `grep -n "gitleaks" ai-literacy-superpowers/commands/harness-init.md`
Expected: multiple matches showing the new section

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-init.md
git commit -m "Add gitleaks discovery to harness-init constraint setup"
```

---

### Task 6: Final verification

- [ ] **Step 1: Verify all five artifacts exist and are consistent**

Run each of these commands:

```bash
# Skill exists
ls ai-literacy-superpowers/skills/secrets-detection/SKILL.md

# Template has deterministic constraint
grep -A3 "No secrets in source" ai-literacy-superpowers/templates/HARNESS.md | head -5

# Template has GC rule
grep -A6 "Secret scanner operational" ai-literacy-superpowers/templates/HARNESS.md

# Hook script exists and is executable
ls -la ai-literacy-superpowers/hooks/scripts/secrets-check.sh

# Hook is registered in hooks.json
grep "secrets-check" ai-literacy-superpowers/hooks/hooks.json

# Harness-init references gitleaks
grep "gitleaks" ai-literacy-superpowers/commands/harness-init.md | head -3
```

All commands should return matching output.

- [ ] **Step 2: Verify hooks.json is valid JSON**

Run: `python3 -m json.tool ai-literacy-superpowers/hooks/hooks.json > /dev/null`
Expected: no output (valid JSON)

- [ ] **Step 3: Verify hook script has no syntax errors**

Run: `bash -n ai-literacy-superpowers/hooks/scripts/secrets-check.sh`
Expected: no output (no syntax errors)

- [ ] **Step 4: Review git log**

Run: `git log --oneline add-secrets-detection --not main`
Expected: 6 commits — design spec + 5 implementation commits
