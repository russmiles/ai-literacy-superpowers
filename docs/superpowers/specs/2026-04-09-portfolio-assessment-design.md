# Portfolio Assessment — Design

**Date:** 2026-04-09
**Status:** Approved

---

## Context

The `/assess` command evaluates a single repo's AI literacy level. The
`literacy-improvements` skill bridges assessment gaps to actionable
commands. Neither operates across repositories.

Organisations with multiple repos need a portfolio view: which repos
are at which level, where are the shared gaps, and what improvements
would lift the most repos at once. This spec adds a
`portfolio-assessment` skill and `/portfolio-assess` command that
aggregate individual assessments into an organisational picture.

---

## Discovery Modes

The command supports three entry points for discovering repos.

### Local mode

```text
/portfolio-assess --local ~/code/myorg/
```

Scan directories under the given path for repos containing
`assessments/*.md` files. Each subdirectory with a `.git` directory
is treated as a repo.

### GitHub org mode

```text
/portfolio-assess --org Habitat-Thinking
```

Use `gh repo list Habitat-Thinking --json name,url,topics --limit 200`
to discover all repos in the org.

### GitHub topic mode

```text
/portfolio-assess --topic ai-literacy
/portfolio-assess --org Habitat-Thinking --topic harness
```

Filter repos by topic tag. When combined with `--org`, scopes the
topic search to that org. When used alone, searches across all repos
accessible to the authenticated user.

### Combined flags

Flags can be combined:

```text
/portfolio-assess --org Habitat-Thinking --topic harness
/portfolio-assess --local ~/code/myorg/ --org Habitat-Thinking
```

When both `--local` and `--org` are provided, local repos take
precedence (avoid re-fetching what's already cloned).

---

## Handling Unassessed Repos

When a discovered repo has no `assessments/` directory or no
assessment files, the command has two modes controlled by a flag.

### `--scan-unassessed` (default: on)

Run a lightweight evidence-only scan. This uses the same observable
evidence signals from the `ai-literacy-assessment` skill's Phase 1,
but with important differences:

- **No clarifying questions** — cannot ask them across many repos
- **No assessment document generated** in the target repo
- **Estimated level** with lower confidence — flagged as "(estimated)"
  in the portfolio view
- **No immediate adjustments or improvements** — read-only

For GitHub repos, use the GitHub API to check for key files before
cloning:

```text
gh api repos/<owner>/<repo>/contents/CLAUDE.md
gh api repos/<owner>/<repo>/contents/HARNESS.md
gh api repos/<owner>/<repo>/contents/.github/workflows
gh api repos/<owner>/<repo>/contents/specs
```

If the API check is sufficient to estimate a level, skip the clone.
Only clone to a temp directory when deeper inspection is needed (e.g.
counting HARNESS.md constraints, reading CI workflow contents).

Clean up temp clones after scanning.

### `--no-scan-unassessed`

Report the repo as "not yet assessed" in the portfolio view. No
scanning, no estimation. Fastest mode for large portfolios where
you only want to see already-assessed repos.

---

## Evidence-Only Scan Logic

The lightweight scan checks for the same signals as the full
assessment, grouped by level:

### L2 signals (Verification)

| Signal | API check | Clone needed? |
| --- | --- | --- |
| CI workflows exist | `contents/.github/workflows` | No |
| Test step in CI | Read workflow file content | Yes (or API contents) |
| Vulnerability scanning in CI | Read workflow file content | Yes (or API contents) |
| Linting in CI | Read workflow file content | Yes (or API contents) |

### L3 signals (Habitat Engineering)

| Signal | API check | Clone needed? |
| --- | --- | --- |
| CLAUDE.md exists | `contents/CLAUDE.md` | No |
| HARNESS.md exists | `contents/HARNESS.md` | No |
| HARNESS.md has enforced constraints | Read file content | Yes (or API contents) |
| AGENTS.md exists | `contents/AGENTS.md` | No |
| REFLECTION_LOG.md exists | `contents/REFLECTION_LOG.md` | No |
| Custom skills | `contents/.claude/skills` | No |
| Hooks configured | `contents/.claude/hooks` or hooks.json | No |

### L4 signals (Specification Architecture)

| Signal | API check | Clone needed? |
| --- | --- | --- |
| Specs directory | `contents/specs` | No |
| Orchestrator agent | `contents/.claude/agents` | No |

### L5 signals (Sovereign Engineering)

| Signal | API check | Clone needed? |
| --- | --- | --- |
| Plugin manifest | `contents/.claude-plugin/plugin.json` | No |
| OTel configuration | Search for telemetry config | Yes |

The estimated level uses the same heuristic as the full assessment:
highest level where evidence exists across all three disciplines
(context, constraints, guardrails). The weakest discipline is the
ceiling.

---

## Portfolio View

The skill produces a structured portfolio assessment document.

### Header

```text
Portfolio Assessment — YYYY-MM-DD
Source: [description of discovery — org name, topic, local path]

Repos discovered: N
Repos assessed (full): N
Repos estimated (lightweight scan): N
Repos not yet assessed: N
Repos not accessible: N
```

### Level Distribution

```text
Level distribution:
  L0: N | L1: N | L2: N | L3: N | L4: N | L5: N
  Estimated: L0: N | L1: N | L2: N | L3: N | L4: N | L5: N

Portfolio median level: LN.N
Weakest discipline across portfolio: [name] (avg N.N/5)
```

### Repo Table

```text
| Repo | Level | Confidence | Context | Constraints | Guardrails | Last assessed |
| --- | --- | --- | --- | --- | --- | --- |
| api-gateway | L3 | assessed | 4 | 3 | 3 | 2026-04-01 |
| billing-service | L2 | assessed | 2 | 3 | 1 | 2026-03-15 |
| new-service | L1 | estimated | — | — | — | never |
| legacy-auth | — | not assessed | — | — | — | never |
```

The Confidence column has three values:
- **assessed** — full assessment document exists
- **estimated** — lightweight scan only, no clarifying questions
- **not assessed** — no scan performed (`--no-scan-unassessed`)

For estimated repos, discipline scores are shown as "—" since the
lightweight scan does not produce discipline-level ratings.

### Cross-Repo Patterns

```text
## Shared Gaps

Gaps appearing in 3+ repos:

| Gap | Repos affected | Level | Recommended action |
| --- | --- | --- | --- |
| No reflections | 5/8 | L3 | Establish org-wide reflection cadence |
| No CI constraint enforcement | 4/8 | L3 | Deploy auto-enforcer template |
| No secret scanning | 3/8 | L2 | Roll out gitleaks via shared CI template |

## Outliers

Above median:
- api-gateway (L4) — only repo with specs and agent pipeline

Below median:
- legacy-auth (L1) — no CI, no conventions, assessment overdue

## Stale Assessments

Repos with assessments older than 90 days:
- billing-service (last: 2026-01-15, 84 days ago)
```

### Portfolio Improvement Plan

Using the same `literacy-improvements` mapping, identify improvements
grouped by impact scope:

```text
## Portfolio Improvement Plan

### Organisation-wide (50%+ of repos)

| Gap | Repos | Action | Impact |
| --- | --- | --- | --- |
| No reflections | 5/8 | Establish /reflect cadence + template | Lifts 5 repos toward L3 |
| No CI enforcement | 4/8 | Deploy auto-enforcer CI template | Lifts 4 repos toward L3 |

### Cluster (2-4 repos)

| Gap | Repos | Action |
| --- | --- | --- |
| No secret scanning | billing, new-service, legacy-auth | Roll out secrets-detection skill |

### Individual

| Repo | Gap | Action |
| --- | --- | --- |
| api-gateway | No fitness functions | fitness-functions skill |
```

Organisation-wide improvements get highest priority because one action
lifts multiple repos. Cluster improvements are next. Individual gaps
defer to each repo's own improvement plan.

---

## Skill Structure

**Location:** `ai-literacy-superpowers/skills/portfolio-assessment/SKILL.md`

### Process

**Step 1: Discover repos.** Based on the provided flags (local, org,
topic), build a list of repos to assess. Report what was found.

**Step 2: Gather assessments.** For each repo:
- Check for `assessments/*.md` — if found, read the most recent one
  and parse level, discipline scores, gaps
- If no assessment and `--scan-unassessed` is on, run the lightweight
  evidence-only scan and estimate a level
- If no assessment and `--no-scan-unassessed`, mark as "not assessed"

**Step 3: Aggregate.** Compute level distribution, median, weakest
discipline average.

**Step 4: Identify patterns.** Find shared gaps (3+ repos), outliers
(significantly above/below median), stale assessments (90+ days).

**Step 5: Generate portfolio improvement plan.** Map shared gaps to
plugin commands/skills using the `literacy-improvements` mapping.
Group by impact scope (org-wide, cluster, individual).

**Step 6: Present and record.** Display the portfolio view. Write
the document to `assessments/YYYY-MM-DD-portfolio-assessment.md` in
the current working directory.

---

## Command Structure

**Location:** `ai-literacy-superpowers/commands/portfolio-assess.md`

The command accepts flags and invokes the skill:

```text
/portfolio-assess [flags]

Flags:
  --local <path>        Scan local directories for repos
  --org <name>          Discover repos in a GitHub org
  --topic <tag>         Filter repos by GitHub topic tag
  --no-scan-unassessed  Skip lightweight scan for repos without assessments
```

At least one of `--local`, `--org`, or `--topic` is required.

---

## Files to Create

1. `ai-literacy-superpowers/skills/portfolio-assessment/SKILL.md` —
   the skill with full process
2. `ai-literacy-superpowers/skills/portfolio-assessment/references/portfolio-template.md` —
   output template for the portfolio document
3. `ai-literacy-superpowers/skills/portfolio-assessment/references/lightweight-scan.md` —
   reference for the evidence-only scan signals and API checks
4. `ai-literacy-superpowers/commands/portfolio-assess.md` — the command

## Files to Update

5. `README.md` — skills count 20 → 21, add portfolio-assessment to
   skills table; commands count 13 → 14, add /portfolio-assess to
   commands table; version badge 0.5.0 → 0.6.0
6. `ai-literacy-superpowers/.claude-plugin/plugin.json` — version
   0.5.0 → 0.6.0
7. `docs/index.md` — skills count 20 → 21, commands count 13 → 14
8. `docs/reference/skills.md` — add portfolio-assessment entry, count
   20 → 21
9. `docs/reference/commands.md` — update count 13 → 14 (stub page)
10. `docs/tutorials/getting-started.md` — skills count 20 → 21,
    commands count 13 → 14 in install output
11. `CHANGELOG.md` — entry for v0.6.0

## Out of Scope

- Running full `/assess` remotely in individual repos
- Modifying individual repos from the portfolio assessment
- Automated scheduling of portfolio assessments
- Dashboard UI (the output is a markdown document)
- Cross-repo improvement execution (the plan identifies actions but
  does not dispatch them across repos)
