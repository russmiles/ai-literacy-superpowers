# Lightweight Scan Reference

The lightweight scan estimates a repo's AI literacy level from
observable evidence without running a full assessment. No clarifying
questions are asked and no assessment document is generated in the
target repo.

## When Used

- By the `portfolio-assessment` skill when `--scan-unassessed` is
  enabled (the default) and a discovered repo has no existing
  assessment

## Approach

1. **API-first**: Check for key files via the GitHub API before
   cloning. Many signals can be detected from file existence alone.
2. **Clone only when needed**: If API checks are insufficient to
   determine a level (e.g. need to read HARNESS.md content to count
   enforced constraints), clone to a temp directory.
3. **Clean up**: Remove temp clones after scanning.

## Signals by Level

### L2 — Verification

| Signal | How to check | Clone needed? |
| --- | --- | --- |
| CI workflows exist | `gh api repos/<owner>/<repo>/contents/.github/workflows` | No |
| Test step in CI workflow | Read workflow YAML for `test`, `pytest`, `jest`, `go test` | Yes (or API file contents) |
| Vulnerability scanning in CI | Read workflow YAML for `govulncheck`, `npm audit`, `owasp`, `scout` | Yes (or API file contents) |
| Linting in CI | Read workflow YAML for `lint`, `eslint`, `markdownlint`, `shellcheck` | Yes (or API file contents) |

### L3 — Habitat Engineering

| Signal | How to check | Clone needed? |
| --- | --- | --- |
| CLAUDE.md exists | `gh api repos/<owner>/<repo>/contents/CLAUDE.md` | No |
| HARNESS.md exists | `gh api repos/<owner>/<repo>/contents/HARNESS.md` | No |
| HARNESS.md has enforced constraints | Read HARNESS.md, count constraints with `deterministic` or `agent` enforcement | Yes (or API file contents) |
| AGENTS.md exists with entries | `gh api repos/<owner>/<repo>/contents/AGENTS.md` — check size > 0 | No (size check) |
| REFLECTION_LOG.md exists with entries | `gh api repos/<owner>/<repo>/contents/REFLECTION_LOG.md` — check size > minimal | No (size check) |
| Custom skills | `gh api repos/<owner>/<repo>/contents/.claude/skills` | No |
| Custom agents | `gh api repos/<owner>/<repo>/contents/.claude/agents` | No |
| Custom commands | `gh api repos/<owner>/<repo>/contents/.claude/commands` | No |
| Hooks configured | `gh api repos/<owner>/<repo>/contents/.claude/hooks` or hooks.json | No |

### L4 — Specification Architecture

| Signal | How to check | Clone needed? |
| --- | --- | --- |
| Specs directory exists | `gh api repos/<owner>/<repo>/contents/specs` | No |
| Implementation plans exist | Check for `plan*.md` files in specs or docs | No |
| Orchestrator agent | `gh api repos/<owner>/<repo>/contents/.claude/agents` — check for orchestrator | No |

### L5 — Sovereign Engineering

| Signal | How to check | Clone needed? |
| --- | --- | --- |
| Plugin manifest | `gh api repos/<owner>/<repo>/contents/.claude-plugin/plugin.json` | No |
| OTel configuration | Search for `otel`, `telemetry` in config files | Yes |
| Cross-team templates | Check for `templates/` directory | No |

## Scoring

Apply the same heuristic as the full assessment:

- The estimated level is the **highest level where evidence exists
  across all three disciplines** (context engineering, architectural
  constraints, guardrail design)
- The weakest discipline is the ceiling
- Without clarifying questions, some signals are ambiguous — when in
  doubt, score conservatively (lower level)

## Limitations

- **No discipline scores**: The lightweight scan produces a level
  estimate but not per-discipline ratings (1-5). These require the
  full assessment's clarifying questions.
- **No gaps list**: Gaps are inferred from missing signals rather than
  explicitly identified through conversation.
- **Conservative estimates**: Without human input, the scan may
  underestimate teams that have strong practices not reflected in
  files (e.g. verbal conventions, external tooling).
- **API rate limits**: Scanning many repos via the GitHub API may hit
  rate limits. The skill should check `gh api rate_limit` before
  starting and warn if remaining requests are low.

## Output

The lightweight scan returns a simple result per repo:

```text
{
  repo: "owner/name",
  estimated_level: 2,
  confidence: "estimated",
  signals_found: ["ci_workflows", "test_in_ci", "linting_in_ci", "claude_md"],
  signals_missing: ["harness_md_enforced", "reflections", "agents_md"],
  clone_needed: false
}
```

This result is consumed by the portfolio-assessment skill's
aggregation step.
