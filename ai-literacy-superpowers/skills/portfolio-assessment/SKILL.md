---
name: portfolio-assessment
description: Use when assessing AI literacy across multiple repositories — aggregates individual assessments into a portfolio view with level distribution, shared gaps, outliers, and a prioritised improvement plan grouped by organisational impact. Discovers repos from local paths, GitHub orgs, or topic tags.
---

# Portfolio Assessment

Aggregate AI literacy assessments across multiple repositories into
an organisational portfolio view. Identifies shared gaps, outliers,
and stale assessments, then generates an improvement plan grouped by
impact scope (organisation-wide, cluster, individual).

This skill reads existing assessment documents from individual repos.
It does not run `/assess` remotely — each repo must be assessed
individually first, or the lightweight scan estimates a level from
observable evidence.

## Discovery Modes

The skill discovers repos through three entry points, which can be
combined.

### Local mode (`--local <path>`)

Scan directories under the given path. Each subdirectory with a
`.git` directory is treated as a repo. Check each for an
`assessments/` directory.

### GitHub org mode (`--org <name>`)

Use the GitHub CLI to list repos:

```bash
gh repo list <name> --json name,url,topics --limit 200
```

### GitHub topic mode (`--topic <tag>`)

Filter by topic tag. When combined with `--org`, scopes to that org:

```bash
gh repo list <name> --topic <tag> --json name,url,topics --limit 200
```

When used alone, searches repos accessible to the authenticated user:

```bash
gh search repos --topic <tag> --json fullName,url --limit 200
```

### Combining modes

When both `--local` and GitHub modes are provided, local repos take
precedence — avoid re-fetching what is already cloned. Deduplicate
by repo name.

## Process

### Step 1: Discover Repos

Based on the provided flags, build a list of repos. Report what was
found:

```text
Discovered N repos:
  Local: N (from ~/code/myorg/)
  GitHub org: N (from Habitat-Thinking)
  Total after deduplication: N
```

If no repos are found, stop and report.

### Step 2: Gather Assessments

For each repo, determine its assessment status:

**Has assessment:** Read the most recent `assessments/*.md` file
(sorted by filename date). Parse:

- Assessed level (from the `**Assessed level**` line)
- Discipline scores (from the Discipline Maturity table)
- Gaps (from the Gaps section)
- Last assessment date (from the filename or `**Date**` line)
- Improvement plan status (from the Improvement Plan section, if present)

**No assessment, scan enabled (`--scan-unassessed`, the default):**
Run the lightweight evidence-only scan. See
`references/lightweight-scan.md` for the signal list and API checks.
Produce an estimated level with lower confidence. No discipline scores
are generated — the scan only determines level, not per-discipline
ratings.

**No assessment, scan disabled (`--no-scan-unassessed`):**
Mark as "not assessed." Include in the portfolio view with no level.

Report progress as repos are processed:

```text
Gathering assessments...
  api-gateway: L3 (assessed 2026-04-01)
  billing-service: L2 (assessed 2026-03-15)
  new-service: L1 (estimated — no prior assessment)
  legacy-auth: not assessed (--no-scan-unassessed)
```

### Step 3: Aggregate

Compute portfolio-level metrics:

- **Level distribution** — count of repos at each level, split by
  assessed vs estimated
- **Portfolio median level** — median of all levels (assessed and
  estimated)
- **Weakest discipline** — average of each discipline score across
  assessed repos (estimated repos excluded since they lack discipline
  scores)
- **Assessment coverage** — percentage of repos with full assessments

### Step 4: Identify Patterns

**Shared gaps:** Gaps that appear in 3 or more repos. These indicate
organisational problems, not repo-specific issues. Read the Gaps
section from each assessed repo's assessment document. For estimated
repos, infer gaps from missing evidence signals.

**Outliers:** Repos significantly above or below the portfolio median.

- Above: success stories — what are they doing that others aren't?
- Below: struggling repos — may need targeted attention

**Stale assessments:** Repos where the most recent assessment is
older than 90 days. These need re-assessment before their data
should drive decisions.

### Step 5: Generate Portfolio Improvement Plan

Using the `literacy-improvements` skill's
`references/improvement-mapping.md`, map shared gaps to plugin
commands and skills. Group by impact scope:

**Organisation-wide (50%+ of repos):** One action lifts many repos.
These get highest priority. Typical actions: deploy shared CI
templates, establish org-wide cadences, create shared skill libraries.

**Cluster (2-4 repos):** Targeted skill-sharing between related repos.
Typical actions: roll out a specific tool, share a constraint pattern.

**Individual:** Unique to one repo. Defer to that repo's own
`literacy-improvements` plan.

Present the plan with estimated impact (how many repos each action
lifts and toward which level).

### Step 6: Present and Record

Display the full portfolio view to the user.

Write the document to `assessments/YYYY-MM-DD-portfolio-assessment.md`
in the current working directory (typically the portfolio or platform
repo). Use the template from `references/portfolio-template.md`.

## What This Skill Does NOT Do

- Run full `/assess` remotely in individual repos
- Modify individual repos (read-only across repos)
- Execute improvements across repos (identifies actions but does not
  dispatch them)
- Require all repos to use this plugin (reads the standard assessment
  document format)
