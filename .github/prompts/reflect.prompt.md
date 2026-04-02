---
name: reflect
description: Capture a reflection after completing work — what was surprising, what should future agents know, what could improve
---

Capture a post-task reflection and append it to REFLECTION_LOG.md.

1. Ask for or review the session context:
   - What was just worked on (one sentence)
   - What was surprising or unexpected
   - What should future agents know about this area

2. Format the entry:

   ```text
   ---

   - **Date**: [today's date YYYY-MM-DD]
   - **Agent**: [agent that did the work]
   - **Task**: [what was done]
   - **Surprise**: [what was unexpected]
   - **Proposal**: [what to add to AGENTS.md, or "none"]
   - **Improvement**: [what would make the process better]
   ```

3. Append to `REFLECTION_LOG.md` after the last entry

4. Do NOT modify `AGENTS.md` — only humans edit that file

5. Commit: `git add REFLECTION_LOG.md && git commit -m "Add reflection: [summary]"`

Reference: #file:skills/convention-extraction/SKILL.md for extraction context
