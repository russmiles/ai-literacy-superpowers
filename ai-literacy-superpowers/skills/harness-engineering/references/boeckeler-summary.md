# Harness Engineering — Source Material

## Origin

Birgitta Boeckeler, "Harness Engineering," *Exploring Gen AI*,
martinfowler.com, 17 February 2026.

<https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html>

## Definition

A harness is the combined set of deterministic tooling (linters,
structural tests, pre-commit hooks, architectural constraints) and
LLM-based agents (context engineering, periodic garbage collection,
knowledge base curation) that keeps AI code generation trustworthy
and maintainable at scale.

## The Three Components

### 1. Context Engineering

A continuously enhanced knowledge base embedded in the codebase, plus
agent access to dynamic context such as observability data and browser
navigation. The code design itself is a significant part of the context
— well-structured code is easier to harness than sprawling code.

### 2. Architectural Constraints

Monitored not only by LLM-based agents but also by deterministic custom
linters and structural tests. These are hard, enforceable rules, not
suggestions. Keeping data structures stable and defining and enforcing
module boundaries are the primary focus areas.

### 3. Garbage Collection

Agents that run periodically to find inconsistencies in documentation or
violations of architectural constraints, actively fighting entropy and
decay. The process is iterative: when the agent struggles, treat it as a
signal — identify what is missing and feed it back into the repository.

## Key Insight

Building a real harness is much more work than maintaining a collection
of Markdown rules files. The deterministic parts (custom linters,
structural tests) are where much of the real rigour lives. Rigor does
not disappear when AI writes the code — it relocates from typing code to
designing the systems that generate and verify code.

## The Four Hypotheses

### 1. Harnesses as Future Service Templates

Teams pick from a set of harnesses for common application topologies —
analogous to golden path service templates but containing custom linters,
structural tests, basic context documentation, and additional context
providers.

### 2. Constrained Runtimes Enable More AI Autonomy

Increasing trust and reliability requires constraining the solution
space: specific architectural patterns, enforced boundaries, standardised
structures. Trade "generate anything" flexibility for prompts, rules,
and harnesses full of technical specifics.

### 3. Convergence on Fewer Tech Stacks

AI might push toward fewer tech stacks because teams may choose stacks
with good harnesses available and prioritise "AI-friendliness."

### 4. Pre-AI vs Post-AI Application Maintenance

New applications built with a harness in mind can fully benefit.
Existing applications need harness retrofitting, which may or may not
be worth the effort.

## The Missing Piece

Boeckeler notes that the measures described focus on long-term internal
quality and maintainability, but verification of functionality and
behaviour — confirming the software actually does what it is supposed to
do — is absent from the discussion.

## Related Work

- Mitchell Hashimoto, "AI Harness" — possible origin of the term
- Chad Fowler, "Relocating Rigor" — rigor moves from writing code to
  designing control systems
