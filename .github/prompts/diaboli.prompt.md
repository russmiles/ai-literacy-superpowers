---
name: diaboli
description: Run the adversarial spec reviewer on a spec file — produces or regenerates the objection record at docs/superpowers/objections/<spec-slug>.md; use after spec-writer completes or when a spec is substantively edited
---

# Diaboli

Run the advocatus-diaboli adversarial reviewer against a spec file.

## Usage

```
/diaboli docs/superpowers/specs/<date>-<name>.md
```

## Steps

1. Confirm the spec file exists at the path provided
2. Derive the slug: strip the date prefix and `.md` extension from the filename
3. Read the spec file in full
4. Read `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` for the
   charter, six categories, severity definitions, and output format
5. Generate objection record content following the skill's output format:
   - YAML frontmatter with all objections (`disposition: pending`, `disposition_rationale: null`)
   - Prose sections per objection (`## O<N> — <category> — <severity>`)
   - Closing "Explicitly not objecting to" section (at least three entries)
6. Write to `docs/superpowers/objections/<slug>.md` (overwrite if exists)
7. Validate the written file: check frontmatter structure, field presence,
   pending dispositions, category/severity enum values, objection count (1–12),
   prose sections, closing section
8. Fix any validation failures in place
9. Report: output path, objection count (major/minor), category distribution
10. Remind the user to fill in dispositions before the plan-approval gate
