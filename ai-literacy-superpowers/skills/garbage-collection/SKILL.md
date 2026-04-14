---
name: garbage-collection
description: This skill should be used when the user asks about "garbage collection rules", "entropy fighting", "documentation staleness", "dead code detection", "convention drift", "periodic checks", "auto-fix rules", or needs guidance on the Garbage Collection section of HARNESS.md.
---

# Garbage Collection

Garbage collection in a harness context means periodic checks that fight
entropy — the slow drift that neither real-time hooks nor PR gates
catch. Documentation goes stale, conventions erode, dead code
accumulates, dependencies fall behind.

This is Boeckeler's third harness component: agents that run
periodically to find inconsistencies and violations, actively fighting
decay.

## Anatomy of a GC Rule

Every GC rule in HARNESS.md has five fields:

- **What it checks** — the specific entropy being detected
- **Frequency** — `daily`, `weekly`, or `manual`
- **Enforcement** — `deterministic` or `agent`
- **Tool** — what runs the check
- **Auto-fix** — `true` (GC agent fixes it) or `false` (create an
  issue instead)

## Choosing Frequency

| Frequency | Use for |
| --- | --- |
| daily | Fast checks with high entropy rate (style drift in active codebases) |
| weekly | Most GC rules — documentation, dependencies, dead code |
| manual | Exploratory checks not yet calibrated for automation |

Start with weekly for most rules. Only move to daily if the entropy
rate justifies the cost.

## The Auto-Fix Decision

Auto-fix is safe when the fix is deterministic, local, verifiable, and
reversible. It is not safe when the fix requires judgement, has ripple
effects, cannot be verified, or is destructive.

For the full safety rubric and detailed examples, consult
`references/gc-catalogue.md`.

**When auto-fix is true**: The `harness-gc` agent applies the fix
directly (with user confirmation in interactive mode) and commits the
result.

**When auto-fix is false**: The agent creates a GitHub issue describing
the finding, with file:line references and a suggested fix.

## Common GC Categories

| Category | Examples | Typical frequency |
| --- | --- | --- |
| Documentation entropy | Stale references, outdated versions | weekly |
| Convention drift | Naming violations, style drift | weekly |
| Dead code | Orphaned files, unused exports | weekly |
| Dependency entropy | Known CVEs, major version lag | weekly |
| Harness entropy | Missing tools, broken hooks | weekly |
| Architectural fitness | Layer violations, coupling trends, complexity hotspots | weekly |
| Learning-driven | Reflection regression detection, assessment gap analysis | weekly |
| Memory entropy | Stale reflections, duplicate entries, contradicted memory | weekly |

For a full catalogue of GC patterns with HARNESS.md entry examples,
consult `references/gc-catalogue.md`.

## Designing a New GC Rule

1. Identify the entropy: what drifts over time in this codebase?
2. Describe the check: what would a reviewer look for?
3. Choose frequency: how fast does this entropy accumulate?
4. Decide enforcement: can a deterministic tool check this, or does it
   need agent reasoning?
5. Apply the auto-fix rubric: is automated correction safe?
6. Add the rule to HARNESS.md's Garbage Collection section

## Architectural Fitness Functions

Fitness functions are GC rules that measure architectural properties
rather than fighting entropy in individual files. Where documentation
staleness or dead code checks look at the state of specific files,
fitness functions assess system-wide properties: layer boundaries,
coupling trends, complexity hotspots.

The concept comes from Ford, Parsons, Kua & Sadalage's *Building
Evolutionary Architectures*. Architecture degrades through accumulated
small violations that no single constraint catches. Fitness functions
detect the accumulation on a weekly cadence.

For the full framework, tool catalogue, and guidance on writing fitness
function GC rules, consult the dedicated skill at
`../fitness-functions/SKILL.md`.

## Learning-Driven GC

Most GC rules scan code or configuration for entropy — stale docs,
dead code, drifting conventions. Learning-driven GC rules take a
different input: compound learning artifacts such as reflections and
assessments. Instead of asking "has the code drifted?", they ask
"has the team learned something that the harness hasn't absorbed yet?"

This category exists because the harness should grow from experience.
When REFLECTION_LOG.md records the same type of surprise repeatedly,
that pattern is a missing constraint. A learning-driven GC rule
detects the gap and proposes the constraint — closing the loop between
compound learning and harness evolution.

### Reflection-driven regression detection

The primary example of learning-driven GC. This rule reads
REFLECTION_LOG.md, groups surprises by theme, and flags any theme
appearing in 2+ entries that is not already covered by a HARNESS.md
constraint. When an uncovered pattern is found, the GC agent creates
a GitHub issue proposing a new constraint with evidence (reflection
dates and quotes), suggested enforcement type, and suggested scope.

See the HARNESS.md template for the rule entry and
`references/gc-catalogue.md` for the full catalogue entry.

### Memory entropy (Dream Consolidation)

Compound learning artifacts accumulate their own entropy. REFLECTION_LOG.md grows with duplicates. AGENTS.md collects entries that contradict later experience. Convention files drift from the codebase they describe. Memory that is never pruned becomes noise — the agent loads context that contradicts current practice or references reversed decisions.

**Dream Consolidation** (from the framework's Appendix J) addresses this at two timescales:

- **Session-end**: check new reflections for duplicates or contradictions with existing entries. Merge duplicates. Flag contradictions for human resolution. Update the Tier 1 memory index if new topics were added.
- **Periodic deep consolidation** (weekly or quarterly): review the full memory corpus. Prune entries superseded by code changes. Promote recurring patterns into durable conventions. Archive reflections older than two quarters that have not been promoted.

A memory entropy GC rule in HARNESS.md:

- **What it checks**: Whether REFLECTION_LOG.md or AGENTS.md contain duplicate, contradicted, or stale entries
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false (contradictions require human judgment)

## Additional Resources

### Reference Files

- **`references/gc-catalogue.md`** — Complete catalogue of common GC
  patterns with HARNESS.md entry examples, detection approaches, and
  the auto-fix safety rubric
- **`../fitness-functions/SKILL.md`** — Architectural fitness functions
  skill with framework, tool catalogue, and GC rule mapping guidance
- **`../fitness-functions/references/fitness-catalogue.md`** — Concrete
  HARNESS.md GC rule entries for each fitness function type
