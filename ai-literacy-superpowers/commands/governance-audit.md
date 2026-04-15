---
name: governance-audit
description: Run a deep governance investigation — semantic drift analysis, governance debt inventory, constraint falsifiability scoring, three-frame alignment checks, and governance health reporting
---

# /governance-audit

Full governance investigation. Dispatches the governance-auditor
agent for a deep analysis of governance constraints.

**Intended cadence:** quarterly (alongside `/assess` and
`/harness-audit`), or on demand when governance drift is suspected.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists, tell the user to run `/harness-init` first.

### 2. Check for Governance Constraints

Scan HARNESS.md for governance-related constraints (those with
governance language or a `Governance requirement` field). If none
are found, tell the user:

> No governance constraints found in HARNESS.md. Use
> `/governance-constrain` to add governance constraints before
> running an audit.

### 3. Create Output Directory

```bash
mkdir -p observability/governance
```

### 4. Dispatch the Governance-Auditor Agent

Dispatch the `governance-auditor` agent with this context:

- The path to HARNESS.md
- The path to the previous audit report (if one exists in
  `observability/governance/`)
- The current date for the report filename

The governance-auditor will:

1. Identify governance constraints
2. Score falsifiability
3. Detect semantic drift
4. Build governance debt inventory
5. Check three-frame alignment
6. Check for debt cycle reinforcement
7. Write the audit report to
   `observability/governance/audit-YYYY-MM-DD.md`
8. Output the governance metrics block

### 5. Validate the Governance Summary

**This step is mandatory.** After the governance-auditor writes the
report, read `observability/governance/audit-YYYY-MM-DD.md` and
verify the `## Governance Summary` section meets the Observatory
contract. Check each requirement:

1. **Heading**: Must be `## Governance Summary` (not `## Summary`
   or any variant). The Observatory parses this heading by exact
   regex match.

2. **Nine fields present**: The section must contain exactly these
   fields in this order, each on its own line as a bullet point:

   ```text
   - Total constraints: N
   - Falsifiable: N (with verification criteria)
   - Vague: N (lacking operational meaning)
   - Falsifiability ratio: N%
   - Semantic drift stage: N/5
   - Drift velocity: stable/increasing/decreasing
   - Governance debt items: N
   - Aggregate debt score: N (sum of severity x blast radius)
   - Frame alignment score: N%
   ```

3. **Value rules**:
   - Semantic drift stage must use 1-5 scale (1 = no drift), not 0
   - Falsifiability ratio and Frame alignment score must be
     percentages (`N%`), not fractions
   - Drift velocity must be one of: `stable`, `increasing`,
     `decreasing`
   - Aggregate debt score is 0 when no debt items exist
   - Frame alignment score = `(aligned / total) * 100`, rounded

If any check fails, fix the report in place:

- Rename `## Summary` to `## Governance Summary` if needed
- Add or reformat missing fields using data from the report body
  (constraint assessment, debt inventory, drift analysis sections)
- Rewrite values to match the required format

Do not re-dispatch the agent. Fix the output directly.

### 6. Update Harness Health Snapshot

If a harness health snapshot exists in `observability/snapshots/`,
update it with the governance metrics block from the audit report.

If no snapshot exists, create the governance metrics block in the
audit report and note that it should be included in the next
`/harness-health` run.

### 7. Present Results

Show the user:

- Overall governance health score
- Falsifiability ratio and breakdown
- Drift score and any constraints at Stage 3+
- Governance debt inventory (sorted by score)
- Three-frame alignment summary
- Any debt cycle reinforcement patterns

### 8. Recommend Actions

Based on audit findings, suggest next steps:

- Vague constraints that need operationalising (run
  `/governance-constrain` to rewrite)
- Drifted constraints that need updating
- Governance debt items prioritised by score
- Frame misalignment that needs resolution

### 9. Offer Dashboard Generation

Ask the user if they want to generate or update the governance
health dashboard:

> Run `/governance-health --dashboard` to generate an HTML dashboard
> with these results.

### 10. Commit

```bash
git add observability/governance/
git commit -m "Governance audit: [summary — e.g., 4 constraints, 0.75 falsifiability, 2 debt items]"
```
