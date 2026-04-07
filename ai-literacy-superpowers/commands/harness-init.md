---
name: harness-init
description: Set up a living harness for this project — discover the stack, define conventions, generate HARNESS.md with enforcement
---

# /harness-init

Set up a living harness for this project. This is the guided on-ramp
that produces a working HARNESS.md from a conversation.

Read the `harness-engineering` and `context-engineering` skills from
this plugin before proceeding. They provide the conceptual framework
and convention-writing guidance needed for this conversation.

## Process

### 1. Discover

Dispatch the `harness-discoverer` agent to scan the project. Wait for
its discovery report before proceeding.

### 2. Present Findings

Show the user what was discovered:

- Tech stack and versions
- Existing linters, formatters, and CI checks
- Any existing convention documentation (CLAUDE.md, CONTRIBUTING.md)
- Pre-commit hooks already in place

Frame this as: "Here's what your project already has. Let's build on
it."

### 3. Ask About Conventions

Ask the user about their conventions, one topic at a time. Use the
discovery report to make informed suggestions. Cover:

- **Naming**: What casing and patterns does the team use?
- **File structure**: How are files organised? One type per file?
- **Error handling**: How should errors be handled and propagated?
- **Documentation**: What must have doc comments? What should comments
  explain?

For each topic, offer concrete options based on what the discoverer
found. Use the convention patterns from the `context-engineering` skill
to ensure conventions are enforceable.

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

### 5. Ask About Garbage Collection

Ask whether the user wants periodic checks for:

- Documentation freshness
- Dependency currency
- Convention drift
- Dead code

For each, set frequency and auto-fix preference.

### 6. Generate HARNESS.md

Read the template from `${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.
Replace all placeholder values with discovered facts and user responses.
Write the result to `HARNESS.md` at the project root.

### 7. Generate CI Configuration

If GitHub Actions was detected (or the user confirms it), read the
template from `${CLAUDE_PLUGIN_ROOT}/templates/ci-github-actions.yml`.
Add deterministic tool steps for each PR-scoped deterministic
constraint. Write to `.github/workflows/harness.yml`.

If no CI was detected, offer the generic script from
`${CLAUDE_PLUGIN_ROOT}/templates/ci-generic.sh`.

#### Auto-enforcer for agent PR constraints

After generating `harness.yml`, check whether the HARNESS.md being
produced contains any agent-scoped PR constraints. If it does:

1. Inform the user: "Your harness includes agent-based PR constraints.
   These cannot run in the standard CI workflow — they require the
   auto-enforcer action."
2. Offer to copy `${CLAUDE_PLUGIN_ROOT}/templates/ci-auto-enforcer.yml`
   to `.github/workflows/auto-enforcer.yml` as part of the init commit
3. Remind the user to add the `ANTHROPIC_API_KEY` secret to their
   repository before the first PR: Settings > Secrets and variables >
   Actions > New repository secret
4. Read the `auto-enforcer-action` skill from this plugin for full
   setup guidance if the user asks questions

If no agent PR constraints exist, skip this offer silently.

### 8. Add README Badge

Add the harness badge to the project's README.md. Use the badge update
script at `${CLAUDE_PLUGIN_ROOT}/scripts/update-badge.sh` or insert
manually:

```text
[![Harness](https://img.shields.io/badge/Harness-0%2FN_enforced-808080?style=flat-square)](HARNESS.md)
```

### 9. Commit

Stage and commit all generated files:

- HARNESS.md
- CI workflow (if generated)
- README.md (badge update)

Commit message: "Initialize project harness with HARNESS.md"

### 10. Summary

Tell the user:

- How many constraints were declared and how many are enforced
- What to do next: `/harness-constrain` to add more rules,
  `/harness-status` to check health, `/harness-audit` to verify
  enforcement
