---
name: harness-audit
description: Run a full meta-verification of the harness — check whether HARNESS.md matches reality
---

Full meta-verification of the harness.

1. Check HARNESS.md exists (suggest /harness-init if not)

2. Scan the project for tools, CI, hooks — compare against declared
   constraints

3. Verify each constraint: does the declared tool exist? Is CI
   configured? Are hooks wired?

4. Detect drift: declared-but-missing and present-but-undeclared
   enforcement

5. Run meta-observability checks from
   #file:skills/harness-observability/references/meta-observability-checks.md

6. Update HARNESS.md Status section with audit date and counts

7. Update README badge via `scripts/update-health-badge.sh`

8. Present results and recommend actions
