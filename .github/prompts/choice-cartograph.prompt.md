---
name: choice-cartograph
description: Run the Choice Cartographer (decision-archaeology agent) on a spec — produces the choice-story record at docs/superpowers/stories/<slug>.md; use after spec-mode /diaboli dispositions are resolved, before plan approval
---

# Choice Cartograph

Run the choice-cartographer agent against a spec file. Spec mode only in
this release; code mode is tracked under issue #209.

## Usage

```text
/choice-cartograph docs/superpowers/specs/<date>-<name>.md
```

Single positional argument. No `--mode` flag yet — the flag will be
added alongside the actual code-mode implementation.

## Steps

1. Confirm the spec file exists at the path provided
2. Derive the slug: strip the date prefix and `.md` extension from the
   filename
3. Determine output path: `docs/superpowers/stories/<slug>.md`
4. Read the spec file in full
5. Read the matching diaboli objection record at
   `docs/superpowers/objections/<slug>.md` if it exists (used for
   Routing-Rule application and `Refs` cross-references)
6. Read
   `ai-literacy-superpowers/skills/choice-cartographer/SKILL.md` for the
   charter, the six lenses, the routing rule, the selectivity protocol,
   the cross-reference contract, and the output format
7. Generate choice-story record content following the skill's output
   format:
   - YAML frontmatter with `mode: spec`, `cartographer_model`, all
     stories (`disposition: pending`, `disposition_rationale: null`)
   - Prose sections per story (`## Story #N — <title>`)
8. Write to `docs/superpowers/stories/<slug>.md` (overwrite if exists)
9. Validate the written file: check frontmatter structure including
   `mode: spec`, field presence, pending dispositions, lens enum values,
   story count (1–15, warning at ≥ 13), prose sections, cross-reference
   resolution for both `O\d+` and `#\d+` tokens in `Refs` fields
10. Fix any validation failures in place — never re-dispatch the agent;
    the selectivity cap is enforced inside the agent so the validator
    never refuses to write
11. Report: output path, story count, lens distribution, count of
    resolved cross-references
12. Remind the user to set each story's `disposition` to one of
    `accepted | revisit | promoted` and write a
    `disposition_rationale`. The plan-approval gate is soft (will
    surface `cartograph_pending_count` and continue); the merge-time
    HARNESS constraint **PRs have adjudicated choice stories** blocks
    PR merge while any story is `pending`.
