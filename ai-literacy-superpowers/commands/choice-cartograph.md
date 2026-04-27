---
name: choice-cartograph
description: Run the Choice Cartographer (decision-archaeology agent) on a spec — produces the choice-story record at docs/superpowers/stories/<slug>.md; use after spec-mode /diaboli dispositions are resolved, before plan approval
---

# /choice-cartograph \<spec-path\>

Run the choice-cartographer agent against a spec file and write the
structured choice-story record. Use after spec-mode `/diaboli`
dispositions are resolved and before plan approval.

This release is spec-mode only — there is no `--mode` flag. Code-mode
behaviour is tracked under issue #209 and will introduce the flag
alongside its actual implementation.

## When to use

- Manually after `/diaboli` (spec mode) dispositions are filled, before
  presenting the plan for approval
- When a spec is substantively edited after a choice-story record
  already exists (regenerates the record — old dispositions are lost;
  this is intentional, mirroring the diaboli pattern)
- When the orchestrator is not in use and you want decision archaeology
  on demand

## Process

### 1. Validate input

Confirm the spec file exists at the given path. If not, abort with:

```text
Error: spec file not found at <path>. Pass a valid path under docs/superpowers/specs/.
```

### 2. Derive the slug

Strip the date prefix and `.md` extension from the filename.

Example: `docs/superpowers/specs/2026-04-27-choice-cartographer.md` →
slug `choice-cartographer`.

Output path: `docs/superpowers/stories/<slug>.md`

### 3. Dispatch the choice-cartographer agent

Pass the spec file path. The agent reads the spec (and the matching
diaboli objection record at
`docs/superpowers/objections/<slug>.md` if it exists) and returns the
full choice-story record content. Do not pass any prior choice-story
record — the agent reviews fresh.

### 4. Write the choice-story record

Write the agent's output to `docs/superpowers/stories/<slug>.md`.

If a file already exists at that path, overwrite it. Warn the user that
any prior dispositions are replaced and they will need to re-adjudicate.

### 5. Validation checkpoint

Read back the written file and verify:

1. YAML frontmatter is present and parseable (opens with `---`).
2. Required frontmatter fields present: `spec`, `date`, `mode`,
   `cartographer_model`, `stories`.
3. `mode` value is `spec`.
4. Each story entry has: `id`, `lens`, `title`, `disposition`,
   `disposition_rationale`.
5. `disposition` value is `pending` for all entries (not pre-filled).
6. `disposition_rationale` value is `null` for all entries (not
   pre-filled).
7. `lens` values are drawn from the six-lens set: `forces`,
   `alternatives`, `defaults`, `patterns`, `consequences`, `coherence`.
8. Story count is between 1 and 15 inclusive. Surface a warning if the
   count is ≥ 13 (signal that the spec may need rewriting before
   annotation).
9. Prose body contains one `## Story #N` section per frontmatter entry,
   numbered consecutively from 1.
10. **Cross-reference resolution — objection IDs.** For every story,
    every `O\d+` token in the `Refs` field must correspond to an
    existing entry in `docs/superpowers/objections/<slug>.md`. If the
    objections record does not exist or the referenced ID is not
    present, this is a validation error.
11. **Cross-reference resolution — story IDs.** For every story, every
    `#\d+` token in the `Refs` field must satisfy
    `N < current_story_id`. Self-references and forward references are
    validation errors.

If any check fails, fix the deviation in place. Do not re-dispatch the
agent. The selectivity cap (15) is enforced inside the agent's
reasoning protocol, so the validator never refuses to write.

### 6. Present the record to the user

Show:

- Output path
- Number of stories
- Lens distribution
- Cross-reference summary (count of resolved objection IDs and
  story IDs)
- A reminder: "Edit `docs/superpowers/stories/<slug>.md` to set each
  story's `disposition` to one of `accepted | revisit | promoted` and
  write a `disposition_rationale`. The plan-approval gate is soft — it
  will surface a `cartograph_pending_count` field but allow
  progression. The merge-time HARNESS constraint **PRs have
  adjudicated choice stories** is the forcing function — PR merge is
  blocked while any story is `pending`."

### 7. Suggest next steps

If invoked manually (not via orchestrator):

- Once dispositions are filled, present the plan for approval; proceed
  to tdd-agent only after plan approval.
- The merge-time gate enforces dispositions at PR time, but resolving
  them at plan-approval time is cheaper for compound learning — the
  context is fresh.
