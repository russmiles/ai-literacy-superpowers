---
name: extract-conventions
description: Run a guided convention extraction session — surfaces tacit team knowledge through structured questions
---

Guide a convention extraction session. Read
#file:skills/convention-extraction/SKILL.md first.

1. Verify CLAUDE.md and HARNESS.md exist (suggest /superpowers-init if not)

2. Ask five extraction questions, one at a time:
   - What architectural decisions should never be left to individual judgment?
   - Which conventions are corrected most often in AI-generated code?
   - Which security checks are applied instinctively?
   - What triggers an immediate rejection in review?
   - What separates a clean refactoring from an over-engineered one?

3. After each answer, categorise as:
   - **Constraint** (must-follow) → HARNESS.md
   - **Convention** (should-follow) → CLAUDE.md
   - **Style preference** (nice-to-have) → CLAUDE.md
   - **Not encodable yet** → needs decomposition

4. Present all proposed additions organised by priority tier

5. Append to CLAUDE.md and/or HARNESS.md with confirmation (never overwrite)

6. Suggest: run /harness-audit to verify enforceability
