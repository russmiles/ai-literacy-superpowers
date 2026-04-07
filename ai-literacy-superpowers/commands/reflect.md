---
name: reflect
description: Capture a reflection after completing work — what was surprising, what should future agents know, what could improve
---

# /reflect

Capture a post-task reflection and append it to REFLECTION_LOG.md.

## Process

1. Ask the user (or review the current session context) for:
   - What was just worked on (one sentence)
   - What was surprising or unexpected
   - What should future agents know about this area of the codebase

1. Format the entry:

   ```text
   ---

   - **Date**: [today's date in YYYY-MM-DD]
   - **Agent**: [you / the agent that did the work]
   - **Task**: [what was done]
   - **Surprise**: [what was unexpected]
   - **Proposal**: [what to add to AGENTS.md, or "none"]
   - **Improvement**: [what would make the process better]
   ```

1. **Auto-constraint proposal** — review the Surprise and Improvement
   fields of the entry you just formatted:

   - If either field describes a preventable failure (e.g. a lint error
     that slipped through, a wrong branch, a missing check, a tool that
     should have caught something), offer to draft a constraint.
   - Propose the constraint to the user with:
     - **Rule**: one-sentence description of what the constraint enforces
     - **Enforcement**: `deterministic` or `agent`
     - **Tool**: the command or tool that checks it (if known)
     - **Scope**: when it runs (e.g. `commit`, `pr`, `session-end`)
   - If the user **accepts**, invoke `/harness-constrain` with the
     proposed rule, enforcement type, tool, and scope. Record the
     constraint in the reflection entry:
     `- **Constraint**: [short description] ([enforcement type])`
   - If the user **declines**, record:
     `- **Constraint**: none`
   - If neither field describes a preventable failure, skip this step
     and record:
     `- **Constraint**: none`

1. Append the entry to `REFLECTION_LOG.md` (after the last existing
   entry, preserving the `---` separator)

1. Do NOT modify `AGENTS.md` — only humans edit that file. If the
   reflection contains a proposal, note it and let the human decide.

1. Commit the updated REFLECTION_LOG.md:

   ```bash
   git add REFLECTION_LOG.md
   git commit -m "Add reflection: [one-line summary of the task]"
   ```
