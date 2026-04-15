# Auto-Enforcer GitHub Action — Design Spec

## Problem

The plugin enforces harness constraints across three loops:

- **Inner** (PreToolUse hooks) — advisory, runs while editing in Claude Code
- **Middle** (CI on PR) — currently only deterministic tool checks in `.github/workflows/harness.yml`
- **Outer** (scheduled audit) — investigative, runs on demand via `/harness-audit`

The middle loop is incomplete. The existing CI template runs deterministic tool
commands for PR-scoped constraints, but agent-based constraints (e.g. "All
frontmatter has name and description") require a human to manually invoke
`/harness-audit`. Teams using PR-Agent or CodeRabbit get automatic AI-powered
PR review as a first-class CI step. The harness middle loop should too.

The result is a gap: agent constraints exist in HARNESS.md, are checked
interactively by the inner loop, but are silently skipped at PR time unless
someone remembers to audit manually.

## Decision

Add an Auto-Enforcer GitHub Action that runs all PR-scoped constraints — both
deterministic and agent-based — automatically on every pull request. Deliver it
as a new skill for setup guidance, a CI workflow template for drop-in adoption,
and an update to `harness-init` that offers the workflow during CI configuration.

## Approach

Agent-based constraints in CI must be handled differently from the full Claude
Code runtime. The action uses the Claude API directly (via a simple script) to
evaluate each agent constraint against the PR diff. This is lightweight, portable,
and does not require Claude Code installed in CI.

A key design split governs strictness:

- **Deterministic constraint failures are blocking** — exit non-zero, block the
  merge. These checks are reliable and repeatable; a failure means something
  real is wrong.
- **Agent constraint findings are advisory** — posted as a PR comment, not
  blocking. AI judgements can vary and should not stop merges on their own. The
  value is visibility, not gatekeeping.

The workflow is data-driven: it reads constraint definitions from HARNESS.md at
runtime rather than hardcoding rules. Adding or modifying constraints in
HARNESS.md automatically changes what the action checks, with no workflow edits
needed.

## Artifacts

### 1. Skill — `auto-enforcer-action/SKILL.md`

New skill at `ai-literacy-superpowers/skills/auto-enforcer-action/SKILL.md`.

Structure:

1. **Overview** — what the action does, how it completes the middle enforcement
   loop, the advisory-vs-blocking split and why it is designed that way
2. **Prerequisites** — `ANTHROPIC_API_KEY` stored as a GitHub Actions secret;
   HARNESS.md present at the project root with at least one PR-scoped constraint
3. **What Gets Checked**
   - Deterministic PR constraints: each tool command is run against the checked-out
     code; findings are collected per constraint
   - Agent PR constraints: the constraint rule text plus the PR diff (changed
     files) is sent to Claude API; the response is parsed for findings
4. **Installing the Workflow** — copy `templates/ci-auto-enforcer.yml` to
   `.github/workflows/auto-enforcer.yml`; set the `ANTHROPIC_API_KEY` secret in
   repository settings; configure inclusions/exclusions if needed
5. **Configuration Options**
   - `include-constraints`: list of constraint names to run (default: all PR-scoped)
   - `exclude-constraints`: list of constraint names to skip
   - `agent-model`: Claude model to use for agent checks (default: `claude-opus-4-5`)
   - `comment-mode`: `always` (post comment even if no findings) or `findings-only`
     (post only when agent findings exist)
6. **Permissions** — workflow requires `contents: read` and `pull-requests: write`
   (for posting PR comments); no other permissions needed
7. **Reading the Output** — what the PR comment looks like (structured markdown
   table with constraint name, type, status, and findings); how to distinguish
   deterministic failures (job fails) from agent advisories (comment only)
8. **Interaction with Existing CI** — the auto-enforcer supplements but does not
   replace the existing `harness.yml`; they run independently; avoid running the
   same deterministic constraint in both workflows to reduce noise
9. **Limitations** — agent findings reflect the model's judgement on the diff, not
   a full repo scan; the action does not run GC rules (those are scheduled, not
   PR-scoped); large diffs may exceed context limits

### 2. CI Template — `templates/ci-auto-enforcer.yml`

New GitHub Actions workflow template at
`ai-literacy-superpowers/templates/ci-auto-enforcer.yml`.

Trigger: `pull_request` (opened, synchronize, reopened).

Permissions block at the top:

```yaml
permissions:
  contents: read
  pull-requests: write
```

Steps:

1. **Checkout** — `actions/checkout@<SHA>` with `fetch-depth: 0` to get the
   full diff against the base branch
2. **Parse PR-scoped constraints** — shell script reads HARNESS.md, extracts all
   constraints with `scope: pr`, separates them into deterministic and agent lists
3. **Run deterministic constraints** — for each deterministic constraint, execute
   the tool command; collect exit code and any stdout findings; if any exit
   non-zero, mark the job for failure but continue to collect all results
4. **Run agent constraints** — for each agent constraint, build a prompt containing
   the constraint rule text and the `git diff origin/<base>...HEAD` output; call
   the Claude API using the `ANTHROPIC_API_KEY` secret; parse the response for
   structured findings
5. **Post PR comment** — compose a markdown comment with a summary table:

   | Constraint | Type | Status | Findings |
   | ------------ | ------ | -------- | ---------- |
   | No secrets in source | deterministic | PASS | — |
   | All frontmatter complete | agent | ADVISORY | 2 files missing description |

   Post via `gh pr comment` (uses `GITHUB_TOKEN`). Use `comment-mode` config to
   decide whether to post when no findings exist.
6. **Exit** — exit non-zero if any deterministic constraint failed; agent findings
   do not affect exit code.

Key implementation notes:

- SHA-pin all third-party actions throughout (per the `github-actions-supply-chain`
  skill); use trusted actions only (actions/checkout, actions/setup-node if needed)
- The HARNESS.md parser must handle the documented constraint block format; it
  does not need to support every possible markdown variation — only the format
  produced by `harness-init` and `harness-constrain`
- Agent API calls use the Messages API directly via `curl` to avoid any runtime
  dependency beyond standard shell tools; no SDK install needed
- The `git diff` passed to the agent is bounded: if the diff exceeds 50 KB, pass
  only the list of changed files and their summaries rather than full patch text

### 3. Harness-Init Update — `commands/harness-init.md`

Update step 7 (Generate CI Configuration) of the `harness-init` command.

After generating `harness.yml` for deterministic constraints, check whether the
HARNESS.md being produced contains any agent-scoped PR constraints. If it does:

- Inform the user: "Your harness includes agent-based PR constraints. These cannot
  run in the standard CI workflow — they require the auto-enforcer action."
- Offer to copy `templates/ci-auto-enforcer.yml` to
  `.github/workflows/auto-enforcer.yml` as part of the init commit
- Remind the user to add the `ANTHROPIC_API_KEY` secret to their repository before
  the first PR: Settings → Secrets and variables → Actions → New repository secret
- Read the `auto-enforcer-action` skill from this plugin for full setup guidance
  if the user asks questions

If no agent PR constraints exist, skip this offer silently.

## Enforcement Timescales

| Timescale | Mechanism | Constraint Types | Strictness |
| ----------- | ----------- | ----------------- | ------------ |
| Edit (PreToolUse) | Agent-based prompt hook reads HARNESS.md constraints | All scopes (advisory) | Advisory |
| PR (CI) — deterministic | `harness.yml` runs tool commands for deterministic PR constraints | Deterministic only | Blocking |
| PR (CI) — agent | `auto-enforcer.yml` calls Claude API for agent PR constraints | Agent only | Advisory (comment) |
| PR (CI) — combined | `auto-enforcer.yml` runs both deterministic and agent PR constraints | Both | Blocking (det.) + Advisory (agent) |
| Weekly (GC) | `/harness-gc` runs scheduled rules | GC-scoped | Investigative |

The auto-enforcer completes the middle loop: every PR-scoped constraint in
HARNESS.md — regardless of enforcement type — is now checked automatically on
every pull request.

## What Is NOT In Scope

- Modifying the `harness-enforcer` or `harness-gc` agents — this is purely a
  new delivery mechanism for existing constraint logic
- Adding new constraint types or enforcement kinds — the action uses what is
  already in HARNESS.md
- Running GC rules in CI — GC rules are periodic/investigative by design; running
  them on every PR would be slow and noisy
- Installing a full Claude Code runtime in CI — the action uses the Claude API
  directly for agent checks; lighter, more portable, no CLI install needed
- Making agent findings blocking — AI judgement should not gate merges; findings
  are advisory comments that inform the author and reviewer
- Supporting CI platforms other than GitHub Actions in this iteration — a generic
  shell equivalent can be a follow-on
