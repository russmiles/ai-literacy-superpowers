---
diaboli: exempt-pre-existing
---

# Build an AI Literacy Portfolio Dashboard — How-To Design

**Date:** 2026-04-09
**Status:** Approved
**Type:** How-to guide for docs site

---

## Context

The portfolio assessment skill produces a markdown document with level
distribution, repo detail, shared gaps, and improvement plans. This
how-to teaches readers to generate a self-contained HTML dashboard
from that data using Claude Code, supporting trend visualisation from
multiple quarterly assessments.

## Design

**File:** `docs/how-to/build-portfolio-dashboard.md`
**Style:** Practical how-to matching existing guides (numbered steps,
code blocks, direct tone)

### Sections

1. **Prerequisites** — run `/portfolio-assess` if needed, three
   discovery mode examples, note on multiple files for trends
2. **Generate the Dashboard** — prompt to give Claude Code, reads all
   portfolio assessment files, produces self-contained HTML with
   summary, level distribution, trends, repo table with trajectories,
   shared gaps, improvement plan
3. **Customise** — follow-up prompts for filtering, thresholds, dark
   mode, sortable tables
4. **Share** — open locally, commit, GitHub Pages, email/Slack
5. **Keep It Current** — quarterly regeneration workflow

### Key design decisions

- Dashboard is self-contained HTML (inline CSS, no deps) so it works
  offline and can be shared as a single file
- Trends require 2+ portfolio assessment files — single file omits
  the trend section
- The reader uses Claude Code to generate the HTML, not a build tool
- Customisation is via follow-up prompts, not manual editing
