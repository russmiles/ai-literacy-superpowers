---
name: harness-engineering
description: This skill should be used when the user asks about "harness engineering", "what is a harness", "harness framework", "AI code quality", "context engineering", "architectural constraints", "garbage collection for code", or wants to understand the conceptual foundation behind the harness-engineering plugin.
---

# Harness Engineering

A harness is the combined set of deterministic tooling and LLM-based
agents that keeps AI code generation trustworthy and maintainable at
scale. The concept originates from Birgitta Boeckeler's article
"Harness Engineering" (2026), which identifies three components that
together form a complete harness.

For the full article summary and four hypotheses, consult
`references/boeckeler-summary.md`.

## The Three Components

### Context Engineering

The knowledge an LLM needs to work effectively in a codebase. This
includes explicit documentation (conventions, constraints, stack
declarations) and implicit context (the code design itself). A
well-structured codebase is easier to harness than a sprawling one
because the structure communicates intent.

In this plugin, context engineering lives in HARNESS.md's **Context**
section — stack declaration, convention documentation, and any
project-specific knowledge that shapes how code should be written.

### Architectural Constraints

Rules that must be enforced — not suggestions, but hard boundaries.
Each constraint is backed by a **verification slot** that can be filled
by either a deterministic tool (linter, formatter, structural test) or
an agent-based review. The rest of the system does not care which backs
the slot — only whether the constraint passed.

In this plugin, constraints live in HARNESS.md's **Constraints** section
and are enforced at three timescales: advisory at edit time (hooks),
strict at merge time (CI), and investigative on schedule (audit).

### Garbage Collection

Periodic checks that fight entropy — the slow drift that neither
real-time hooks nor PR gates catch. Documentation goes stale,
conventions erode, dead code accumulates, dependencies fall behind.
Garbage collection agents run on a schedule to find and fix (or flag)
these issues.

In this plugin, GC rules live in HARNESS.md's **Garbage Collection**
section and are run by the `harness-gc` agent.

## The Living Harness

The central design principle of this plugin is that the harness is a
**living document** — HARNESS.md — that generates its own enforcement.
The document declares what should be true; the plugin's agents, hooks,
and CI check whether it is true; the auditor updates the document's
Status section to reflect reality.

This creates a self-referential feedback loop: the harness is harnessed
by its own document. When the Status section shows drift between
declared and actual enforcement, the team knows where to invest next.

## Progressive Hardening

Constraints follow a promotion ladder:

1. **Unverified** — declared intent, no automation yet
2. **Agent** — LLM-based review against the constraint's prose rule
3. **Deterministic** — tool-backed enforcement (linter, formatter, test)

Start by declaring what should be true. Automate when ready. The harness
improves over time without restructuring.

## Testing the Harness Itself

The harness teaches TDD for code. But the harness's own artifacts — skills, conventions, CLAUDE.md directives — are specifications that produce agent behaviour. A skill without behavioural tests is an unverified claim.

**Test-Driven Agentic Behaviours** (TDAB, after Antony Marcano, 2026) applies TDD to guidance files: write a test describing desired agent behaviour, run the agent, observe the gap, modify the guidance, verify the behaviour. Red-green-refactor for skills.

On the promotion ladder, a skill without behavioural tests is unverified. A skill with passing tests is agent-verified. If you would not ship code without tests, do not ship skills without them either.

## Implementation Patterns

Beneath the three components lies a layer of mechanical patterns that make the harness work in practice. Six patterns from production agent systems:

- **Tiered Memory** — always-loaded index, on-demand topic files, searchable archive
- **Dream Consolidation** — periodic pruning and reorganisation of compound learning memory
- **Progressive Context Compaction** — compression intensity increases with conversation age
- **Progressive Tool Expansion** — start agents with minimal tools, expand on demand
- **Command Risk Classification** — allow/ask/deny per tool, gated by reversibility and blast radius
- **Single-Purpose Tool Design** — typed inputs, constrained scope, individual permission surfaces

These are documented in detail in the framework (Theme 10, Appendices H, I, J).

## Enforcement Timing

Three concentric feedback loops:

| Loop | Trigger | Strictness | Purpose |
| --- | --- | --- | --- |
| Inner | PreToolUse hook | Advisory | Catch issues while context is fresh |
| Middle | CI on PR | Strict | Prevent violations reaching main |
| Outer | Scheduled GC + audit | Investigative | Fight slow entropy |

## Plugin Components

| Component | Count | Purpose |
| --- | --- | --- |
| Commands | 5 | User-facing harness lifecycle |
| Agents | 4 | Workers with bounded trust |
| Skills | 5 | Knowledge for agents and users |
| Hooks | 2 | Real-time enforcement wiring |
| Templates | 3 | Opinionated defaults |

For detailed guidance on each component, consult the relevant skill:
`context-engineering`, `constraint-design`, `garbage-collection`,
`verification-slots`.

## Additional Resources

### Reference Files

- **`references/boeckeler-summary.md`** — Full summary of the article,
  the three components, the four hypotheses, and related work
