---
name: portfolio-assess
description: Assess AI literacy across multiple repositories — aggregate assessments into a portfolio view with level distribution, shared gaps, and prioritised improvements
---

# /portfolio-assess

Aggregate AI literacy assessments across multiple repositories into
an organisational portfolio view.

Read the `portfolio-assessment` skill before proceeding — it contains
the discovery modes, aggregation logic, pattern identification, and
portfolio improvement plan generation.

## Flags

```text
/portfolio-assess [flags]

  --local <path>        Scan local directories for repos
  --org <name>          Discover repos in a GitHub org
  --topic <tag>         Filter repos by GitHub topic tag
  --no-scan-unassessed  Skip lightweight scan for repos without assessments
```

At least one of `--local`, `--org`, or `--topic` is required. Flags
can be combined.

## Process

### 1. Parse Flags

Extract the discovery mode(s) from the user's input. If no flags are
provided, ask the user how to discover repos:

```text
How should I find the repos to assess?

1. Local directories — provide a path (e.g. ~/code/myorg/)
2. GitHub organisation — provide an org name
3. GitHub topic tag — provide a tag to search for
```

### 2. Discover Repos

**Local mode:** Scan the given path for subdirectories with `.git`.

**GitHub org mode:**

```bash
gh repo list <org> --json name,url,topics --limit 200
```

**GitHub topic mode:**

```bash
gh repo list <org> --topic <tag> --json name,url,topics --limit 200
```

or without `--org`:

```bash
gh search repos --topic <tag> --json fullName,url --limit 200
```

Deduplicate if multiple modes are combined. Report the discovery
results.

### 3. Gather Assessments

For each repo, follow the gathering logic from the skill:

- Read existing assessment documents (most recent by date)
- Run lightweight scan for unassessed repos (unless `--no-scan-unassessed`)
- Report progress as each repo is processed

### 4. Aggregate and Analyse

Compute level distribution, median, weakest discipline average.
Identify shared gaps (3+ repos), outliers, and stale assessments.

### 5. Generate Improvement Plan

Map shared gaps to plugin commands/skills using the
`literacy-improvements` mapping. Group by impact scope:
organisation-wide, cluster, individual.

### 6. Record

Write the portfolio assessment to
`assessments/YYYY-MM-DD-portfolio-assessment.md` using the template
from the skill's references.

### 7. Summary

Print a summary:

```text
Portfolio assessment complete.

  Repos: N total (N assessed, N estimated, N not assessed)
  Median level: LN
  Shared gaps: N (affecting 3+ repos)
  Stale assessments: N (older than 90 days)
  Organisation-wide improvements: N
  Document: assessments/YYYY-MM-DD-portfolio-assessment.md
```
