---
name: portfolio-dashboard
description: Use when the user wants to generate, update, or customise an HTML dashboard from portfolio assessment data — produces a self-contained HTML file with level distribution, repo table, shared gaps, improvement plan, and trend visualisation from multiple quarterly assessments
---

# Portfolio Dashboard

Generate a self-contained HTML dashboard from portfolio assessment
data. The dashboard visualises AI literacy levels across repos with
trend tracking from multiple quarterly assessments.

The output is a single HTML file with inline CSS and no external
dependencies. It opens in any browser, works offline, and can be
shared as an email attachment or Slack file.

## Input

The skill reads portfolio assessment files from the `assessments/`
directory in the current repo. It looks for files matching
`*-portfolio-assessment.md`.

If no portfolio assessment files exist, tell the user to run
`/portfolio-assess` first.

## Process

### Step 1: Find Assessment Files

```bash
ls assessments/*-portfolio-assessment.md 2>/dev/null | sort
```

Report what was found:

- **One file:** Dashboard will show current state, no trends
- **Two or more files:** Dashboard will include trend visualisation
- **No files:** Stop and suggest running `/portfolio-assess`

### Step 2: Parse Assessment Data

For each portfolio assessment file, extract:

- **Date** — from the filename (`YYYY-MM-DD`)
- **Summary** — repo count, assessed/estimated/not assessed counts
- **Level distribution** — count at each level (L0–L5), split by
  assessed vs estimated
- **Portfolio median level**
- **Weakest discipline** — name and average score
- **Repo table** — each repo with level, confidence, discipline
  scores, last assessed date
- **Shared gaps** — gaps affecting 3+ repos with recommended action
- **Improvement plan** — organisation-wide, cluster, individual items

For trend data (2+ files), also track per-repo level changes across
assessments to show trajectories (e.g. L1 → L2 → L3).

### Step 3: Generate the Dashboard

Produce a self-contained HTML file with these panels:

**1. Summary header.** Portfolio name (derived from the source
description in the most recent assessment), date, total repo count,
median level.

**2. Level distribution.** Colour-coded visualisation showing how
many repos are at each level. Use the standard level colours:

| Level | Colour | Hex |
| --- | --- | --- |
| L0 — Awareness | Grey | `#808080` |
| L1 — Prompting | Light blue | `#87CEEB` |
| L2 — Verification | Blue | `#4682B4` |
| L3 — Habitat Engineering | Teal | `#20B2AA` |
| L4 — Specification Architecture | Green | `#2E8B57` |
| L5 — Sovereign Engineering | Gold | `#DAA520` |

**3. Trends (if 2+ assessments).** Show how the portfolio has changed
over time:

- Median level trend line
- Number of repos at L3+ over time
- Assessment coverage (% of repos with full assessments) over time
- Per-repo level trajectories in the repo table

**4. Repo table.** Each repo as a row with:

- Repo name
- Current level (colour-coded cell)
- Confidence (assessed / estimated / not assessed)
- Discipline scores (context, constraints, guardrails) — or "—" for
  estimated/not assessed
- Last assessed date
- Level trajectory (if multiple assessments show change)

**5. Shared gaps.** Table of gaps affecting 3+ repos with repo count
and recommended action.

**6. Improvement plan.** Grouped by impact scope:

- Organisation-wide (50%+ of repos) — highest priority
- Cluster (2-4 repos)
- Individual

### Step 4: Write the File

Save to `assessments/portfolio-dashboard.html`.

If a previous dashboard exists, overwrite it — the dashboard is
regenerated from source data each time.

### Step 5: Report

```text
Dashboard generated: assessments/portfolio-dashboard.html

  Repos: N (N assessed, N estimated, N not assessed)
  Median level: LN
  Trend data: N quarterly assessments
  Shared gaps: N

Open with: open assessments/portfolio-dashboard.html
```

## Design Constraints

- **Self-contained:** All CSS must be inline or in a `<style>` block.
  No external stylesheets, no CDN links, no JavaScript libraries.
- **Readable without JavaScript:** The dashboard must be fully
  readable with JavaScript disabled. JavaScript may be used for
  progressive enhancement (sorting, collapsing sections) but is not
  required for the content to be visible.
- **Print-friendly:** The dashboard should render well when printed
  or saved as PDF.
- **No build step:** The HTML file is generated directly. No npm,
  no bundler, no static site generator.

## Customisation

After generating the initial dashboard, the user may ask for
refinements. Common requests:

- Filter to a subset of repos
- Add threshold highlighting (e.g. repos below L2 in red)
- Add a dark mode toggle
- Make tables sortable
- Collapse the improvement plan into an expandable section
- Add a "last updated" timestamp footer

Apply these as modifications to the existing file. Keep the
self-contained constraint — do not add external dependencies.
