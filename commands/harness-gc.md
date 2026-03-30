---
name: harness-gc
description: Manage and run garbage collection rules — add new periodic checks or run existing ones on demand
---

# /harness-gc

Manage and run garbage collection rules from HARNESS.md.

Read the `garbage-collection` skill from this plugin before proceeding.

## Modes

This command operates in two modes based on what the user asks:

### Mode 1: Add a GC Rule

If the user wants to add a new garbage collection check:

1. Ask what entropy they want to detect
2. Help them describe the check using the GC catalogue from the
   `garbage-collection` skill's references
3. Choose frequency (daily, weekly, manual)
4. Choose enforcement (deterministic tool or agent)
5. Apply the auto-fix safety rubric: is automated correction safe?
6. Add the rule to HARNESS.md's Garbage Collection section
7. Commit the update

### Mode 2: Run GC Checks

If the user wants to run garbage collection (or no specific mode is
requested):

1. Read HARNESS.md's Garbage Collection section
2. Dispatch the `harness-gc` agent to run all active rules
3. Present the results
4. For auto-fixable findings, ask whether to apply fixes
5. For non-fixable findings, offer to create GitHub issues
