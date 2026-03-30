---
name: superpowers-status
description: Show the complete health of the project's AI Literacy habitat — harness enforcement, agent team, compound learning, model routing, and CI status
---

# /superpowers-status

Display a health dashboard for the project's AI Literacy habitat. Run this any
time to verify that the framework is correctly configured and that compound
learning is accumulating as expected.

## What this command checks

Work through each section below in order. For each check, report status as
one of: OK, WARNING, or MISSING. Collect all results and print the full
dashboard at the end — do not stop early if a check fails.

### Section 1: Habitat files

Check that the core habitat files exist:

| File | Expected location | Status |
|------|------------------|--------|
| CLAUDE.md | project root | OK / MISSING |
| AGENTS.md | project root | OK / MISSING |
| MODEL_ROUTING.md | project root | OK / MISSING |
| REFLECTION_LOG.md | project root | OK / MISSING |

For each file that exists, check that it is non-empty and contains the
expected section headings (STYLE, GOTCHAS, ARCH_DECISIONS for AGENTS.md;
agent routing table for MODEL_ROUTING.md).

### Section 2: Harness health

Check for the presence and validity of the harness:

- Does `.claude/settings.json` exist?
- Are hooks configured? Check for the drift-check hook or equivalent.
- Does `.claude/HARNESS.md` exist and describe the harness?
- Are the hook scripts executable?

Use the harness-engineering skill to evaluate what is found.

### Section 3: Agent team

Check that the agent team is present and consistent:

- List all `.claude/agents/*.md` files
- For each agent, confirm it has frontmatter with `name`, `description`,
  and `tools` fields
- Confirm the orchestrator, spec-writer, tdd-agent, code-reviewer, and
  integration-agent are all present

Report any agents that are present in `.claude/agents/` but not referenced
in MODEL_ROUTING.md (potential routing gap).

### Section 4: Compound learning

Evaluate the state of AGENTS.md:

- When was it last modified? (`git log -1 --format="%ar" AGENTS.md`)
- How many entries are in GOTCHAS?
- How many entries are in ARCH_DECISIONS?
- How many reflection entries are in REFLECTION_LOG.md?
- Is the content growing (healthy) or static (potentially stale)?

Report: "Compound learning is active" if AGENTS.md or REFLECTION_LOG.md has
been modified in the last 30 days. Report "WARNING: no recent updates" if
neither has been touched in over 30 days.

### Section 5: Model routing

Check MODEL_ROUTING.md:

- Does it contain a routing table?
- Does it reference all agents present in `.claude/agents/`?
- Are token budget guidelines present?

### Section 6: CI status

Check for CI configuration:

- Does `.github/workflows/` contain any AI Literacy workflow files?
- Is `scripts/ai-literacy-check.sh` present and executable?
- If on a branch with an open PR, show the PR check status:
  `gh pr checks --json name,status,conclusion 2>/dev/null || echo "No open PR"`

## Output format

Print the dashboard as a structured report:

```
AI Literacy Habitat Status
==========================

Habitat files    [OK / WARNING / MISSING]
Harness          [OK / WARNING / MISSING]
Agent team       [OK / WARNING / MISSING]
Compound learning [OK / WARNING / MISSING]
Model routing    [OK / WARNING / MISSING]
CI               [OK / WARNING / MISSING]

--- Details ---

[Section-by-section findings, flagging anything that is WARNING or MISSING]

--- Recommendations ---

[Prioritised list of actions to reach full green, if any]
```

If all sections are OK, end with: "Habitat is healthy. All checks passed."
