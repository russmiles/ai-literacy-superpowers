---
name: context-engineering
description: This skill should be used when the user asks about "writing conventions", "codebase context", "HARNESS.md context section", "convention documentation", "how to write enforceable rules", or needs guidance on the Context section of HARNESS.md.
---

# Context Engineering

Context engineering is the practice of curating the knowledge an LLM
needs to work effectively in a codebase. Good context makes the
difference between an LLM that follows project conventions and one that
generates plausible but inconsistent code.

Birgitta Boeckeler's key insight: the code design itself is a huge part
of the context. Well-structured code communicates intent; the harness
documentation makes that intent explicit and enforceable.

## The Context Section of HARNESS.md

The Context section serves three audiences simultaneously:

1. **New team members** read it to understand the project's stack and
   conventions
2. **LLM agents** read it as structured input when reviewing code or
   generating enforcement
3. **The plugin** reads it to understand what tools might be appropriate
   for enforcement

### Stack Declaration

Declare the factual baseline: languages, build system, test framework,
container strategy. Keep this section factual — no aspirations, just
what is true today. The `harness-discoverer` agent populates this
during `/harness-init`.

### Conventions

Conventions are the core of context engineering. Each convention must be
**concrete enough that a reviewer could objectively say whether code
follows it**. The test: could two independent reviewers agree without
discussing it?

For detailed examples of well-written vs poorly-written conventions,
consult `references/convention-patterns.md`.

## Writing Effective Conventions

### The Enforceability Test

Before adding a convention, ask:

1. Can I describe what code that follows this convention looks like?
2. Can I describe what code that violates it looks like?
3. Could a tool or agent check this without ambiguity?

If the answer to any question is no, the convention needs rewriting.

### From Aspiration to Enforcement

Start with what the team values. Ask: "What would I see in code that
follows this?" Write the observable properties as the convention.

| Aspiration | Observable convention |
| --- | --- |
| "Write clean code" | Not enforceable — decompose further |
| "Keep functions short" | "Functions must not exceed 40 lines" |
| "Use meaningful names" | "Variables must be 3+ characters except `i`, `j`, `k`, `err`" |
| "Handle errors properly" | "Every returned error must be wrapped with context" |

### Convention Categories

Organise conventions by what they govern:

- **Naming** — casing, length, domain vocabulary
- **File structure** — one type per file, co-located tests, package boundaries
- **Error handling** — wrapping, recovery, logging
- **Documentation** — what must have doc comments, what the first sentence must contain
- **Dependencies** — injection patterns, banned packages, version policies
- **Testing** — coverage thresholds, test naming, fixture patterns

### What Not to Put in Conventions

- Implementation instructions ("use dependency injection") — describe
  the observable outcome instead
- Tool configuration — that belongs in the tool's config file
- Aspirational quality statements — decompose into observable properties
- Temporary rules — use constraint scope and GC rules instead

## Keeping Context Fresh

Context rots. The `harness-gc` agent checks for documentation freshness
as a garbage collection rule. Symptoms of stale context:

- Conventions reference functions, files, or patterns that no longer
  exist
- Stack declaration lists a framework version that has been upgraded
- Naming conventions describe a style the codebase has drifted from

The `/harness-audit` command detects some of these automatically by
cross-referencing HARNESS.md against the project's actual state.

## Additional Resources

### Reference Files

- **`references/convention-patterns.md`** — Detailed examples of
  enforceable vs unenforceable conventions, the enforceability spectrum,
  and techniques for converting aspirations to observable rules
