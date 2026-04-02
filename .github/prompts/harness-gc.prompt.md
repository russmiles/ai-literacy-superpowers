---
name: harness-gc
description: Run garbage collection checks against the codebase
---

# Harness GC

Run garbage collection rules from HARNESS.md.

Read `#file:skills/garbage-collection/SKILL.md` for GC rule design.

1. Read all GC rules from HARNESS.md Garbage Collection section.

2. For each rule with enforcement configured, run the check:
   - Documentation freshness: scan for stale references
   - Convention drift: check LP preambles and CUPID naming
   - Dependency currency: run vulnerability scanner
   - Other rules: execute as described

3. Report findings per rule: what was found, severity, suggested fix.

4. Do not auto-fix unless the rule specifies auto-fix: true.
