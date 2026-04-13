# Governance Debt Scoring

Score governance debt items by severity and blast radius to prioritise
remediation.

## Severity Scale

| Level | Meaning | Signal |
| --- | --- | --- |
| 1 — Minor | Wording gap — constraint is mostly accurate but language has drifted slightly from current practice | The team would agree the constraint is "close enough" |
| 2 — Moderate | Operational gap — constraint describes the right intent but verification does not match current process | The constraint passes audit but does not catch the risk it was designed for |
| 3 — Critical | Meaning failure — constraint language describes something materially different from what the team actually does or what the regulation actually requires | Compliance theatre — governance looks correct but is substantively wrong |

## Blast Radius Scale

| Level | Meaning | Signal |
| --- | --- | --- |
| 1 — Isolated | Only this constraint is affected | No other constraints reference the drifted term |
| 2 — Connected | 2-3 other constraints depend on the same term or assumption | Fixing this constraint requires reviewing the connected ones |
| 3 — Systemic | The drifted term is used across many constraints or is foundational to the governance framework | The four-debt cycle may be active — governance debt is reinforcing other debt forms |

## Scoring Matrix

| | Blast 1 (Isolated) | Blast 2 (Connected) | Blast 3 (Systemic) |
| --- | --- | --- | --- |
| Severity 1 (Minor) | 1 — Low | 2 — Low | 3 — Medium |
| Severity 2 (Moderate) | 2 — Low | 4 — Medium | 6 — High |
| Severity 3 (Critical) | 3 — Medium | 6 — High | 9 — Critical |

## Remediation Priority

| Score | Priority | Action |
| --- | --- | --- |
| 1-2 | Low | Address in next quarterly audit |
| 3-4 | Medium | Address this quarter |
| 6 | High | Address within two weeks |
| 9 | Critical | Address immediately — governance failure is active |
