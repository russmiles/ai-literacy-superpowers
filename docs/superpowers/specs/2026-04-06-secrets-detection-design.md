# Secrets Detection for the Harness — Design Spec

## Problem

The HARNESS.md template declares a "No secrets in source" constraint but leaves
it as `unverified` with no tooling. Every project that runs `/harness-init`
gets a constraint that exists on paper but catches nothing. Secrets in source
are one of the most common and most damaging security failures — this should
be enforced by default, not aspirational.

## Decision

Add gitleaks as the default deterministic enforcement tool for secret detection.
Deliver it as both a standalone skill (for manual audits) and a wired-in default
during harness-init (for automatic setup).

## Approach: Gitleaks-Only

Gitleaks is the de facto standard for git secret scanning. It is already named
as the example secret scanner in the verification-slots reference doc. Keeping
the skill focused on one tool (rather than being tool-agnostic) follows the
pattern established by `dependency-vulnerability-audit` (govulncheck, OWASP)
and `docker-scout-audit` (Docker Scout).

## Artifacts

### 1. Skill — `secrets-detection/SKILL.md`

New skill at `ai-literacy-superpowers/skills/secrets-detection/SKILL.md`.

Structure (matching existing security skills):

1. **Overview** — why secrets in source are dangerous, what gitleaks does
2. **Audit Checklist** — is gitleaks installed? `.gitleaks.toml` configured?
   in CI? git history clean?
3. **Running the Audit** — commands for scanning working directory, scanning
   git history, creating a baseline for known false positives
4. **Configuration** — `.gitleaks.toml`: allowlists for test fixtures,
   custom rules
5. **CI Integration** — GitHub Actions step using `gitleaks/gitleaks-action`
   with SHA pinning (per our own supply chain skill)
6. **Harness Integration** — how to promote the "No secrets in source"
   constraint from `unverified` to `deterministic`
7. **Report Format** — findings table: `File | Finding | Severity | Fix`
8. **What gitleaks cannot catch** — encoded secrets, secrets in build
   artifacts, runtime env leaks

### 2. Template Update — `templates/HARNESS.md`

Promote the "No secrets in source" constraint to deterministic by default:

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: deterministic
- **Tool**: gitleaks detect --source . --no-banner --exit-code 1
- **Scope**: commit
```

Add a GC rule for scanner health:

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

### 3. Hook Script — `hooks/scripts/secrets-check.sh`

New Stop-scope hook script. Advisory only — does not block.

Behaviour:

- Checks if `gitleaks` is on the path (exits silently if not)
- Checks if HARNESS.md has a `deterministic` "No secrets in source"
  constraint (exits if not)
- Runs `gitleaks detect --source . --no-banner --no-git --exit-code 1`
- If findings: prints warning summary with file paths
- If clean: exits silently

### 4. Hooks Config — `hooks/hooks.json`

Add `secrets-check.sh` to the existing Stop hook array:

```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/secrets-check.sh",
  "timeout": 15
}
```

### 5. Harness-Init Update — `commands/harness-init.md`

Update the harness-init command to guide the discoverer to:

- Check whether `gitleaks` is available on the path
- If found: promote the constraint to `deterministic` by default
- If not found: keep `unverified`, suggest installation
- Inform the user either way; allow override

## Enforcement Timescales

| Timescale | Mechanism | Strictness |
| ----------- | ----------- | ------------ |
| Commit (PreToolUse) | Existing agent-based prompt hook reads HARNESS.md constraints | Advisory |
| Session end (Stop) | `secrets-check.sh` runs gitleaks on working directory | Advisory |
| PR (CI) | `gitleaks/gitleaks-action` in GitHub Actions | Blocking |
| Weekly (GC) | Scanner health check — tool installed, constraint not regressed | Investigative |

## What Is NOT In Scope

- Supporting multiple scanner backends (trufflehog, detect-secrets) — YAGNI
- New agents — existing harness-enforcer and harness-gc handle this
- New commands — the skill is invoked directly; harness-init is updated
- Pre-commit git hooks (outside Claude Code) — that is the user's choice;
  the skill can recommend it but does not install it
