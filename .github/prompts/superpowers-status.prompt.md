---
name: superpowers-status
description: Show the full habitat status — harness health, agent team, compound learning, model routing, CI coverage
---

# Superpowers Status

Broad habitat health check. No agents dispatched.

1. Check habitat files exist: CLAUDE.md, HARNESS.md, AGENTS.md,
   MODEL_ROUTING.md, REFLECTION_LOG.md

2. Read HARNESS.md Status section for enforcement ratio and drift

3. Count agents in agents/ directory (or .claude/agents/)

4. Count skills in skills/ directory (or .claude/skills/)

5. Check compound learning: REFLECTION_LOG.md entry count,
   AGENTS.md entry count

6. Check CI: list workflow files in .github/workflows/

7. Present summary with recommendations for any gaps
