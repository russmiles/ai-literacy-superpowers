---
name: model-card
description: Research and author Mitchell-extended model cards. /model-card create <name> for one-card hybrid review-before-commit flow; /model-card seed for bulk-populate from the shipped frontier seed list.
---

# /model-card \<subcommand\> [args]

Subcommands:

- `create <model-name> [--provider X] [--out path]`
- `seed [--force]`

Future subcommands tracked as issues:

- `/model-card list` — issue #233
- `/model-card compare <a> <b>` — issue #234
- `/model-card refresh <name>` — issue #235

## Subcommand: `create`

### Usage

```text
/model-card create <model-name> [--provider X] [--out path]
```

### Flow

1. **Parse args**
   - `model-name` (required, positional)
   - `--provider` (optional hint; if absent, agent infers)
   - `--out` (optional library directory override; cards still land beneath
     it as `<provider>/<model-name>.md`)

2. **Resolve target path**
   - Default: `~/.claude/model-cards/<provider>/<model-name>.md`
   - If `MODEL_CARDS_DIR` env var is set, use it as the library root
   - If `--out` flag is passed, use it as the library root (highest priority)
   - The provider sub-directory and `<model-name>.md` filename always apply
     beneath whatever library root was resolved

3. **Check for existing card at target path**
   - If present, ask the user: `overwrite / skip / load-existing-as-base`
   - On `skip`, abort the flow with no file change
   - On `load-existing-as-base`, pass the existing card content to the agent
     as starting context

4. **Dispatch the `model-card-researcher` agent**
   - Pass the model name and provider hint
   - Agent returns either:
     - A full markdown card content string, OR
     - A `REFUSED:` string indicating the model-existence check failed

5. **Handle REFUSED**
   - If the agent's output starts with `REFUSED:`, surface the refusal
     reason to the user verbatim and abort the flow with no file written.

6. **Show review summary**
   - Sources used per section (tier breakdown — counts of `[T1.x]`,
     `[T2.x]`, `[T3.x]`, `[T4.x]` citations)
   - Sections that came up thin — list of section numbers (1-10) where
     "Not publicly available" appears at section level
   - Top 3 most-cited claims by raw citation count, with their source URLs
   - Estimated token cost of the research (rough — sum of fetched-content
     sizes at ~4 chars/token approximation)

7. **Ask for disposition**
   - `accept` — write the card to target path, confirm with full path
   - `edit` — open the draft in `$EDITOR` (or `vi` if unset), then re-prompt
     with the edited content
   - `re-run-section <N>` — re-dispatch the agent with a section-specific
     prompt focusing on template section number N (1-10); replace just that
     section in the draft, then re-prompt
   - `abort` — discard the draft, no file written

8. **On accept**
   - `mkdir -p $(dirname target_path)`
   - Write the card content to `target_path`
   - Print: `Card written: <full_path>`

### Specification picks (from spec O9 disposition)

- `--out path` — directory override; card filename and provider sub-dir
  still apply beneath
- Provider name resolution — agent-inferred; if ambiguous, command prompts
  user during step 6 to confirm provider sub-directory before write
- `re-run-section <N>` — N is the template section number 1-10
- "Top 3 most-cited claims" — raw citation count per claim

## Subcommand: `seed`

### Usage

```text
/model-card seed [--force]
```

### Flow

1. **Read seed list**
   - Source: `${CLAUDE_PLUGIN_ROOT}/seed/frontier-models.json`
   - Format: `[{"name": "...", "provider": "..."}, ...]`

2. **Show user the list and total count**

3. **Ask once for confirmation**
   - `Research <N> cards into <library-root>? [y/N]`
   - On `y`, proceed
   - On any other input, abort

4. **For each model in list (sequential)**
   - Resolve target path (as in `create` step 2)
   - If card exists at target path AND `--force` is not set, skip with
     one-line message
   - Dispatch `model-card-researcher`
   - If REFUSED, log skip with reason (one line); continue to next model
   - Else write card to target path; log creation (one line)

5. **Print summary**
   - Created: N
   - Skipped (existed): N
   - Skipped (refused): N
   - Failed (other): N

### Note on resumability

`seed` is idempotent for the common-case "ran partially, want to retry" — the
existence check at step 4 skips already-written cards. To re-research existing
cards, use `--force` (overwrites) or run `/model-card create <name>` per model
(interactive review).

If failure modes prove common in real use, `--resume` and `--retry-failed`
flags can be added in a v0.1.x patch without spec rework.
