---
name: literate-programming
description: Use when creating new source files, writing new functions or types, or significantly rewriting existing code — ensures code is structured for humans to read first, with narrative preambles, reasoning-based documentation, and presentation ordered by understanding rather than compiler convention
---

# Literate Programming

## Overview

Don Knuth's core insight: **code is written for humans to read, and only incidentally for machines to execute.** This skill applies a pragmatic version of that principle — not Knuth's web/tangle toolchain, but the discipline of writing code whose structure and documentation make the reasoning visible to the next reader.

Every file is a piece of writing, not just a collection of declarations.

---

## The Five Rules

### 1. Every file opens with a narrative preamble

The preamble answers three questions:

- **Why does this file exist?** What problem does it solve, and why is it the right place to solve it?
- **What are the key design decisions?** Not a list of functions — the choices that shaped the structure.
- **What does this file deliberately NOT do?** Explicit scope exclusions are as informative as inclusions.

The preamble belongs in the package/module comment block, before any imports. It is prose, not bullet points.

**Before (no preamble):**

```go
package cache

import (
    "sync"
    "time"
)

type Cache struct { ... }
```

**After (with preamble):**

```go
// Package cache provides a short-lived, in-process store for rendered page
// fragments. Its only job is to reduce redundant template execution on
// repeated requests for the same URL within a single deploy.
//
// We deliberately avoid distributed caching (Redis, Memcached) here. The
// fragments are cheap to recompute, the deploy cadence is high, and the
// operational burden of a networked cache is not justified at current traffic.
// If that changes, this package is the right place to swap the strategy.
//
// We do not attempt cache invalidation on content change — that problem
// belongs to the deployment pipeline, not the request path.
package cache
```

---

### 2. Documentation explains reasoning, not signatures

A comment that restates the function name or its parameter types adds no value. The code already shows WHAT. Documentation's job is to explain WHY — the design choice, the tradeoff, the constraint that shaped this particular approach.

**Before (restates the signature):**

```go
// getUserByID returns the user with the given ID from the database.
func getUserByID(id string) (*User, error) {
```

**After (explains reasoning):**

```go
// getUserByID loads from the read replica, not the primary. For the auth
// hot-path this is acceptable because user records change rarely and a
// replication lag of a few seconds is not observable by a human login flow.
// Write operations that need immediate consistency call the primary directly.
func getUserByID(id string) (*User, error) {
```

Apply the same standard to type definitions: explain why the type exists and what invariants it maintains, not just what its fields are.

---

### 3. Order of presentation follows logical understanding

Arrange code so that a reader encounters concepts in the order they need them to build understanding — not in the order the compiler requires. This usually means:

- **High-level orchestration before low-level detail.** The function that calls helpers should appear before the helpers, not after.
- **Domain model before mechanics.** The type that represents the problem should appear before the functions that manipulate it.
- **Purpose before implementation.** State what something is for before showing how it works.

In Go and Kotlin this sometimes means forward references — that is fine. Readability for the human outweighs convention.

---

### 4. Each file has one clearly stated concern

Name the file's single concern in the first sentence of the preamble. If you cannot state it in one sentence, the file has too many concerns and should be split.

A file's concern is not its list of contents ("this file contains the parser, the renderer, and the helper functions"). It is its intellectual role ("this file transforms a flat markdown string into a navigable hierarchy of sections").

---

### 5. Comments explain WHY, not WHAT

Inline comments are for explaining decisions, constraints, and non-obvious consequences — not for narrating code that can speak for itself.

| ❌ Describes WHAT | ✅ Explains WHY |
| --- | --- |
| `// increment counter` | `// counter is used by the rate limiter, not just for metrics` |
| `// check if user is nil` | `// nil user is valid here — unauthenticated requests are allowed` |
| `// loop over items` | `// process in reverse so removals don't shift the indices we haven't visited` |
| `// return error` | `// surface the parse error; callers need the line number to show a useful message` |

---

## Quick Reference

| Rule | Signal that it's missing |
| --- | --- |
| Narrative preamble | File opens directly with imports or a type declaration |
| Reasoning-based docs | Function comment could be generated from the signature alone |
| Logical order | Helper functions appear before the code that uses them |
| Single stated concern | Preamble lists contents rather than naming the file's role |
| WHY comments | Inline comment restates the next line in different words |

---

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "The function name is self-explanatory" | Names say WHAT. Documentation explains WHY the design is this way, not another way. |
| "I'll add documentation later" | Documentation written after implementation is biased toward describing what was built. LP documentation shapes what gets built. |
| "The preamble would be too long" | A preamble proportional to the decisions made is never too long. A file with no decisions worth naming should not exist. |
| "This is obvious" | Obvious to you now ≠ obvious to the next reader. Obvious things change; the reason they were obvious does not. |
| "I'll write a docstring" | A docstring that restates the signature satisfies a tool, not a reader. |
| "The code is the documentation" | The code shows the mechanism. LP documentation shows the reasoning. Both are needed. |

## Red Flags — Stop and Rewrite

- File opens with `import` or a type/function declaration, no preamble
- Any function comment that could be auto-generated from its signature
- Helper functions defined before the code that calls them
- A preamble that lists what the file contains rather than why it exists
- An inline comment that starts with "this" and restates the next line
