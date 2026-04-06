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
