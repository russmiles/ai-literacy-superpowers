---
name: harness-status
description: Show current harness health — enforcement ratio, drift, and garbage collection state
---

Quick read of harness health. No agents dispatched.

1. Read HARNESS.md Status section for: last audit date, enforcement
   ratio, GC coverage, drift status.

2. Count constraints by type: deterministic, agent, unverified.

3. Count GC rules by status: active vs inactive.

4. Present summary with next step suggestions:
   - /harness-constrain to add or promote constraints
   - /harness-audit for full verification
   - /harness-gc to run garbage collection
