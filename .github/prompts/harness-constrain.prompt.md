---
name: harness-constrain
description: Add or promote a constraint in HARNESS.md
---

Add a new constraint or promote an existing one.

Read #file:skills/constraint-design/SKILL.md for constraint design
guidance.

1. Ask: add a new constraint or promote an existing one?

2. For new constraints: ask for the rule, determine enforcement type
   (deterministic/agent/unverified), tool, and scope (commit/pr/weekly).

3. For promotion: list unverified or agent-backed constraints that
   could be promoted. Check whether the required tool exists.

4. Update HARNESS.md with the new or promoted constraint.

5. Update the Status section counts.
