---
name: team-api
description: Use when the user wants to create or update a Team Topologies Team API document with AI literacy portfolio assessment data — generates a template Team API with literacy levels, discipline scores, shared gaps, and improvement plans, or updates an existing Team API with the latest assessment data
---

# Team API

Generate or update a Team Topologies Team API document enriched with
AI literacy portfolio assessment data. The Team API is a document
that describes a team's capabilities, communication preferences, and
service offerings — adding AI literacy data makes the team's
engineering maturity visible to the rest of the organisation.

This skill works in two modes:

- **Update mode**: reads an existing Team API document and adds or
  refreshes the AI literacy section using the latest portfolio
  assessment data
- **Template mode**: generates a new Team API document from the
  template in `references/team-api-template.md`, populated with
  portfolio assessment data

## Input

The skill needs:

- **Portfolio assessment file** — the most recent
  `assessments/*-portfolio-assessment.md`. If none exists, tell the
  user to run `/portfolio-assess` first.
- **Existing Team API file** (optional) — if the user provides a path
  to an existing Team API document, update it. If not, generate from
  the template.
- **Team directory** (optional) — where to write the output. Defaults
  to the current directory.

## Process

### Step 1: Find Portfolio Assessment Data

```bash
ls assessments/*-portfolio-assessment.md 2>/dev/null | sort | tail -1
```

If no file exists, stop and suggest running `/portfolio-assess`.

Read the most recent portfolio assessment and extract:

- Portfolio median level
- Assessment coverage percentage
- Repo detail table (each repo with level and discipline scores)
- Shared gaps
- Improvement plan (organisation-wide items)
- Next assessment date

### Step 2: Check for Existing Team API

Ask the user:

```text
Do you have an existing Team API document to update?

1. Yes — provide the file path
2. No — generate a new one from the template
```

### Step 3a: Update Existing Team API

If the user provides an existing file, read it and look for an
`## AI Literacy` or `## AI Engineering Maturity` section. If found,
replace it with fresh data. If not found, append the section before
the last section of the document (typically "Further Information" or
similar).

The AI Literacy section to insert:

```markdown
## AI Literacy

**Portfolio median level**: LN — Level Name
**Assessment coverage**: N% of repos fully assessed
**Last portfolio assessment**: YYYY-MM-DD
**Next assessment due**: YYYY-MM-DD

### Repo Levels

| Repo | Level | Confidence | Last Assessed |
| --- | --- | --- | --- |
| repo-name | LN | assessed/estimated | YYYY-MM-DD |

### Discipline Scores (assessed repos only)

| Repo | Context | Constraints | Guardrails |
| --- | --- | --- | --- |
| repo-name | N/5 | N/5 | N/5 |

### Active Shared Gaps

| Gap | Repos Affected | Recommended Action |
| --- | --- | --- |
| gap description | N/M | action |

### Current Improvement Focus

[Organisation-wide improvement items from the portfolio assessment,
presented as the team's current AI engineering priorities]
```

Preserve all other sections of the existing Team API untouched.

### Step 3b: Generate New Team API from Template

If no existing file, read `references/team-api-template.md` and
populate it with:

- Team name (ask the user)
- Team type (ask: stream-aligned, enabling, complicated-subsystem,
  or platform)
- The AI Literacy section populated from portfolio assessment data
- Placeholder sections for the user to fill in (communication
  preferences, service offerings, dependencies)

Write to the team directory as `team-api.md`.

### Step 4: Summary

Report what was done:

```text
Team API [created/updated]: path/to/team-api.md

  AI Literacy section: populated from portfolio assessment (YYYY-MM-DD)
  Portfolio median: LN
  Repos covered: N
  Shared gaps: N
  Next assessment: YYYY-MM-DD
```

## What Gets Pulled from Portfolio Assessment

| Portfolio field | Team API field |
| --- | --- |
| Portfolio median level | AI Literacy header |
| Assessment coverage | AI Literacy header |
| Repo detail table | Repo Levels table (simplified) |
| Discipline scores | Discipline Scores table |
| Shared gaps | Active Shared Gaps table |
| Organisation-wide improvements | Current Improvement Focus |
| Next assessment date | Next assessment due |

## What This Skill Does NOT Do

- Does not run `/portfolio-assess` — the data must already exist
- Does not modify the portfolio assessment — it reads, not writes
- Does not fill in non-AI sections of the Team API — those are the
  team's responsibility
- Does not enforce Team Topologies practices — it provides the
  document structure, the team decides how to use it
