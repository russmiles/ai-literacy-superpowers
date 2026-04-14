---
name: harness-constrain
description: Add a new constraint to HARNESS.md or promote an existing one from unverified to agent or deterministic
---

# /harness-constrain

Add or modify a single constraint interactively.

Read the `constraint-design` and `verification-slots` skills from this
plugin before proceeding. They provide the design framework and
technical reference for constraints.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists, tell the user to run `/harness-init` first.

### 2. Ask What Rule to Enforce

Ask the user what rule they want to add or modify. If they describe
something vague, help them refine it using the enforceability test
from the `constraint-design` skill.

### 3. Check for Existing Constraints

Read HARNESS.md's Constraints section. If a similar constraint already
exists, offer to modify it (e.g., promote from unverified to enforced)
instead of adding a duplicate.

### 4. Find Deterministic Tools

Dispatch the `harness-discoverer` agent to check whether a deterministic
tool exists in the project that could enforce this constraint. Also
check common tools for the project's stack that could be installed.

### 5. Choose Enforcement

Present options:

- **Deterministic** (if a tool was found): configure the tool
- **Agent**: the harness-enforcer will review code against the rule
- **Unverified**: declare intent, automate later

### 6. Choose Scope

Ask when the check should run:

- `commit` — advisory warning during editing (fast checks only)
- `pr` — strict CI gate (most constraints)
- `weekly` — periodic sweep (slow or expensive checks)
- `manual` — on-demand via `/harness-audit`

### 7. Test Run

Dispatch the `harness-enforcer` agent to run a test verification of
the new constraint against the current codebase. Show the user what
would pass or fail.

### 8. Update HARNESS.md

Add the new constraint (or update the existing one) in HARNESS.md's
Constraints section. Follow the standard format:

```text
### [Constraint name]
- **Rule**: [precise, enforceable rule text]
- **Enforcement**: [deterministic | agent | unverified]
- **Tool**: [tool command or "harness-enforcer" or "none yet"]
- **Scope**: [commit | pr | weekly | manual]
```

### 9. Update CI (if deterministic + PR scope)

If the constraint is deterministic and PR-scoped, add the tool step
to the CI workflow file.

### 10. Emit Observatory Event

Append the appropriate event to `observability/events.jsonl` (create
the file if it does not exist):

- New constraint: `constraint.added` with name and tier
- Promoted constraint: `constraint.promoted` with name, old tier, new tier
- Removed constraint: `constraint.removed` with name and reason

Event logging is best-effort — if writing fails, continue normally.

### 11. Commit

Commit the updated HARNESS.md (and CI file if changed).
