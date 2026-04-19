---
name: diaboli
description: Run the adversarial spec reviewer on a spec file — produces or regenerates the objection record at docs/superpowers/objections/<spec-slug>.md; use after spec-writer completes or when a spec is substantively edited
---

# /diaboli \<spec-path\>

Run the advocatus-diaboli agent against a spec file and write the objection record.

## When to use

- Manually after `/spec-writer` completes, before presenting the plan
- When a spec is substantively edited after an objection record already exists
  (regenerates the record — old dispositions are lost; this is intentional)
- When the orchestrator is not in use and you want adversarial review on demand

## Process

### 1. Validate input

Confirm the spec file exists at the given path. If not, abort with:

```
Error: spec file not found at <path>. Pass a valid path under docs/superpowers/specs/.
```

### 2. Derive the slug

Strip the date prefix and `.md` extension from the filename.

Example: `docs/superpowers/specs/2026-04-19-advocatus-diaboli.md` → `advocatus-diaboli`

The output path will be `docs/superpowers/objections/<slug>.md`.

### 3. Dispatch the advocatus-diaboli agent

Pass the spec file path. The agent reads the spec and returns the full objection
record content. Do not pass any prior objection record — the agent reviews the
spec fresh.

### 4. Write the objection record

Write the agent's output to `docs/superpowers/objections/<slug>.md`.

If a file already exists at that path, overwrite it. Warn the user that any
prior dispositions are replaced and they will need to re-adjudicate.

### 5. Validation checkpoint

Read back `docs/superpowers/objections/<slug>.md` and verify:

1. YAML frontmatter is present and parseable (opens with `---`)
2. Required frontmatter fields present: `spec`, `date`, `diaboli_model`, `objections`
3. Each objection entry has: `id`, `category`, `severity`, `claim`, `evidence`,
   `disposition`, `disposition_rationale`
4. `disposition` value is `pending` for all entries (not pre-filled)
5. `disposition_rationale` value is `null` for all entries (not pre-filled)
6. Category values are one of: `premise`, `scope`, `implementation`, `risk`,
   `alternatives`, `specification quality`
7. Severity values are one of: `critical`, `high`, `medium`, `low`
8. Objection count is between 1 and 12 inclusive
9. Prose body contains one `## O<N>` section per objection
10. File ends with an `## Explicitly not objecting to` section containing
    at least three entries

If any check fails, fix the deviation in place. Do not re-dispatch the agent.

### 6. Present the record to the user

Show:

- Output path
- Number of objections (major / minor split)
- Category distribution
- A reminder: "Fill in `disposition` and `disposition_rationale` for each
  objection before proceeding. The plan-approval gate will not advance while
  any disposition is `pending`."

### 7. Suggest next steps

If this was invoked manually (not via orchestrator):

- Once all dispositions are filled, present the plan for approval
- Proceed to tdd-agent only after plan approval
