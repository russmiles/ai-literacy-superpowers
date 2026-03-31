# AI Literacy Assessment Template

Use this template when generating the assessment document.

```markdown
# AI Literacy Assessment — {{TEAM_NAME}}

**Date**: {{YYYY-MM-DD}}
**Assessed by**: {{ASSESSOR}}
**Assessed level**: Level {{N}} — {{LEVEL_NAME}}

---

## Observable Evidence

### Repository Signals

| Signal | Found | Level indicator |
| --- | --- | --- |
| CI workflows | {{yes/no — list workflows}} | L2 |
| Test coverage enforcement | {{yes/no — threshold}} | L2 |
| Vulnerability scanning | {{yes/no — tools}} | L2 |
| Mutation testing | {{yes/no — tool and cadence}} | L2 |
| CLAUDE.md | {{yes/no — line count}} | L3 |
| HARNESS.md | {{yes/no — constraint count}} | L3 |
| AGENTS.md | {{yes/no — entry count}} | L3 |
| MODEL_ROUTING.md | {{yes/no}} | L3 |
| Custom skills | {{yes/no — count}} | L3 |
| Custom agents | {{yes/no — count}} | L3 |
| Custom commands | {{yes/no — count}} | L3 |
| Hooks configured | {{yes/no — count}} | L3 |
| REFLECTION_LOG.md | {{yes/no — entry count}} | L3 |
| Specifications directory | {{yes/no — spec count}} | L4 |
| Implementation plans | {{yes/no}} | L4 |
| Orchestrator with safety gates | {{yes/no}} | L4 |
| Plugin/platform tooling | {{yes/no}} | L5 |
| OTel configuration | {{yes/no}} | L5 |

### Evidence Summary

{{Brief narrative of what the repo scan revealed — what's strong,
what's present but thin, what's absent.}}

## Clarifying Responses

{{Summary of the team's answers to clarifying questions, noting
any differences between observable evidence and self-report.}}

## Level Assessment

### Primary Level: {{N}} — {{LEVEL_NAME}}

{{Rationale — why this level and not the one above or below.
Reference specific evidence.}}

### Discipline Maturity

| Discipline | Strength (1-5) | Evidence |
| --- | --- | --- |
| Context Engineering | {{1-5}} | {{What context artifacts exist and how current they are}} |
| Architectural Constraints | {{1-5}} | {{What enforcement exists — deterministic, agent, unverified}} |
| Guardrail Design | {{1-5}} | {{What feedback loops exist — tests, hooks, CI, mutation}} |

### The Weakest Discipline

{{Identify which discipline is the ceiling — the one holding
the team at this level rather than the next.}}

## Strengths

{{3-5 bullet points — what the team does well at their current
level. Be specific, reference evidence.}}

## Gaps

{{3-5 bullet points — what's missing for the next level.
Reference the framework's level descriptions.}}

## Recommendations

{{3-5 specific, actionable recommendations. Each should name:
what to do, why it matters, and which framework concept it
addresses. Order by impact.}}

## Next Assessment

Suggested re-assessment date: {{YYYY-MM-DD}} (quarterly)

Previous assessment: {{link to previous if exists, or "first assessment"}}
```
