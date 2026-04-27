# Choice-story validation checks

Reference for the validation checkpoint applied to choice-story records
at `docs/superpowers/stories/<spec-slug>.md`. Both `/choice-cartograph`
and the orchestrator's step 5 import this list as the single source of
truth — do not inline these checks into the command or the orchestrator.
Reference the file by path.

When a check fails, apply the **fix-recipe** in place. Do not re-dispatch
the agent. The selectivity cap (15 stories) is enforced inside the
agent's reasoning protocol, so the validator never receives a
cap-overshoot in normal operation.

## Frontmatter checks

### F1. YAML frontmatter parseable

The file must open with `---`, contain valid YAML up to a closing `---`,
and the closing line must be reachable.

**Fix-recipe:** none. If the frontmatter is unparseable, fail loudly
with the YAML error message. This is an agent-output contract break —
do not silently mutate.

### F2. Required frontmatter fields present

The frontmatter must have all of: `spec`, `date`, `mode`,
`cartographer_model`, `stories`.

**Fix-recipe:** if any required scalar field is missing (`spec`,
`date`, `mode`, `cartographer_model`), fail loudly. If `stories` is
missing or empty, fail loudly. These are agent-output contract breaks.

### F3. `mode` is `spec`

This release is spec-mode only.

**Fix-recipe:** if the value is anything other than `spec`, fail loudly
with the unexpected value. Do not silently overwrite — surface the
contract break.

### F4. Each story has the required fields

Every entry in the `stories` array must have: `id`, `lens`, `title`,
`disposition`, `disposition_rationale`.

**Fix-recipe:** if any field is missing, insert the field with the
default value (`disposition: pending`, `disposition_rationale: null`,
`title: <untitled>`, `lens: []`). Do not invent `id` — fail loudly if
`id` is missing.

### F5. `disposition: pending` for all entries

The agent always writes `disposition: pending`. The validator confirms
the agent did not pre-fill.

**Fix-recipe:** if any entry has a non-`pending` value, overwrite with
`pending`. The agent-output contract is "pending only".

### F6. `disposition_rationale: null` for all entries

The agent always writes `disposition_rationale: null`.

**Fix-recipe:** if any entry has a non-`null` value, overwrite with
`null`. Agent-output contract.

### F7. Lens values drawn from the six-lens set

`lens` is a list whose values must each be one of: `forces`,
`alternatives`, `defaults`, `patterns`, `consequences`, `coherence`.

**Fix-recipe:** drop any non-allowed lens value from the list. If the
resulting list is empty, fail loudly with the original invalid lens
values for context.

### F8. Story count between 1 and 15 inclusive (warning at ≥ 13)

The agent's reasoning protocol caps at 15. The validator confirms.

**Fix-recipe:** if count is 0, fail loudly (the agent should have
emitted at least one story). If count is > 15, fail loudly — this is a
contract break by the agent (the cap is in the agent, not the
validator). Do not silently truncate. Surface the count to the user
and recommend re-running with explicit instructions to apply the
selectivity protocol. Warn (do not fail) at counts ≥ 13.

## Prose-body checks

### P1. One `## Story #N` section per frontmatter entry, numbered consecutively from 1

Every story in the frontmatter must have a corresponding prose section
heading `## Story #N — <title>` where N starts at 1 and increments by 1.

**Fix-recipe:** if a heading is missing for a frontmatter entry, drop
the frontmatter entry (the agent's prose body is the canonical record
of what was reasoned about; an unresolvable heading suggests the entry
was a leftover). If a heading exists without a frontmatter entry, drop
the heading section.

### P2. Each story's prose body contains a `**Refs:**` line

The skill mandates the field be present even when empty (`—`). The
validator enforces presence.

**Fix-recipe:** if a `**Refs:**` line is missing from a story's prose,
insert `**Refs:** —` immediately after the `**Lens:**` line.

## Cross-reference resolution

### CR1. Locate the `Refs` field

For each story, find the `Refs` value by scanning the prose body within
the bounds of the story's `## Story #N — ...` heading and the next
heading (or end of file). Apply this regex on each line:

```regex
^\*\*Refs:\*\*\s+(.+)$
```

The first match within the story's bounds is the `Refs` value. Trim
whitespace. If the value is `—` (em-dash), the field is empty — no
cross-references to resolve.

Whole-file scans for `O\d+` or `#\d+` tokens are forbidden. Only the
captured `Refs` value is parsed for cross-references. Tokens appearing
elsewhere in story prose (Context, Forces, Consequences, Notes) are
not cross-references and must not be validated.

### CR2. Cross-reference resolution — objection IDs

For every `O\d+` token in any story's `Refs` value, the token must
correspond to an `id: O\d+` entry in the YAML frontmatter `objections`
array of `docs/superpowers/objections/<spec-slug>.md`.

The lookup is **YAML-frontmatter-only** in the target file. Headings in
the prose body of the objections record (e.g. `## O3 — premise — high`)
are *not* the source of truth — they are derived from the YAML. A
`Refs` value containing `O17` resolves only if the YAML `objections`
array of the matching record contains an entry with `id: O17`.

**Fix-recipe:** if an `O\d+` token does not resolve, replace the token
with `—` in the `Refs` line. If the resulting `Refs` value is empty
after replacement, write `—` as the entire value. Continue checking
the remaining tokens.

### CR3. Cross-reference resolution — story IDs

For every `#\d+` token in any story's `Refs` value, the token's number
must satisfy `N < current_story_id`. No forward references. No
self-references.

**Fix-recipe:** if a `#\d+` token does not satisfy the constraint,
replace the token with `—` in the `Refs` line. If the resulting `Refs`
value is empty after replacement, write `—` as the entire value.

## Validation-failure behaviour

The validator is **fix-in-place** by codified pattern. It does not
re-dispatch the agent. It does not refuse to write. It applies the
fix-recipes above and surfaces a summary of what was fixed.

A check whose fix-recipe is "fail loudly" is a contract break — the
agent's output violates the agreed format in a way that cannot be
silently repaired. In those cases, the validator surfaces the error to
the user and does not write the file. The user can investigate, fix
the agent's prompt, and re-run.

The cap-overshoot case (F8 with count > 15) is the most common contract
break in practice and the one the user will see if the agent's
selectivity protocol fails. Surfacing rather than truncating is the
right behaviour because it preserves the agent's full output for the
user to inspect, rather than silently dropping content.
