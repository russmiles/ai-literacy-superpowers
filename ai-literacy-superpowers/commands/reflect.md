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

1. Append the entry to `REFLECTION_LOG.md` (after the last existing
   entry, preserving the `---` separator)

1. Do NOT modify `AGENTS.md` — only humans edit that file. If the
   reflection contains a proposal, note it and let the human decide.

1. Commit the updated REFLECTION_LOG.md:

   ```bash
   git add REFLECTION_LOG.md
   git commit -m "Add reflection: [one-line summary of the task]"
   ```
