# Compound Learning

<!-- This file is the project's persistent memory across AI sessions.
     It accumulates patterns, gotchas, and decisions so that each session
     builds on what previous sessions learned — rather than rediscovering
     the same things from scratch.

     IMPORTANT: This file is often generated or updated by LLM agents.
     Review new entries with the same scepticism you would apply to any
     generated content. Entries should reflect observed reality in the
     codebase, not aspirational conventions. An entry in GOTCHAS that
     does not reflect an actual problem that was actually solved is noise
     that increases the cognitive cost of every future session. -->

## STYLE

<!-- Patterns and idioms that work well in this codebase.
     Each entry: what to do, and why it works here. -->

<!-- Example:
- Prefer early returns over nested conditionals in handlers — the codebase
  uses flat control flow throughout and deep nesting has caused review
  friction on every PR that introduced it.
-->

## GOTCHAS

<!-- Traps, surprises, and non-obvious constraints. Initially empty — entries
     accumulate as the pipeline discovers them.
     Each entry: what the trap is, and how to avoid it. -->

<!-- Example:
- Do not call `db.Close()` in request handlers — the connection pool is
  shared across the process lifetime. Closing it in a handler shuts down
  all subsequent requests. This caused a production incident in March 2026.
-->

## ARCH_DECISIONS

<!-- Key architectural decisions and the reasoning behind them.
     Each entry: what was decided, why, and what the alternatives were. -->

<!-- Example:
- Decision: use event sourcing for order state rather than a status column.
  Reason: audit requirements demand a complete history. A status column
  discards intermediate states. Alternatives considered: audit log table
  (rejected — dual-write consistency risk), soft deletes (rejected — does
  not capture partial fulfilment events).
-->

## TEST_STRATEGY

<!-- How tests are structured in this project. Helps agents write consistent
     tests without reading every test file from scratch. -->

<!-- Example:
- Unit tests live alongside source files as _test.go (Go) or *Spec.kt (Kotlin)
- Integration tests are in tests/integration/ and require a running database
- Use table-driven tests for anything with more than three input variations
- Mock at the interface boundary, not the concrete type
-->

## DESIGN_DECISIONS

<!-- Interface contracts, data shapes, and design choices that are stable and
     that agents should not second-guess without good reason. -->

<!-- Example:
- All public API endpoints accept and return JSON with the envelope shape:
  { "data": ..., "error": null | { "code": string, "message": string } }
  Changing this shape would break the mobile clients.
-->
