---
diaboli: exempt-pre-existing
---

# Executable Spec Integration — Design Proposal (Tier 2)

## Problem

The plugin has a `spec-writer` agent and `writing-plans` skill, but
the connection between specs and verification is informal. A spec
describes what should be built; tests verify it was built correctly.
But there is no harness-level mechanism ensuring that generated code
passes the spec's tests before other constraint checks run.

Birgitta Boeckeler's article names functional verification as a
"missing piece" in AI harnesses — the gap between "the code looks
right" (constraint checks) and "the code does the right thing"
(spec conformance).

## Proposal

A constraint pattern (documented in the `constraint-design` skill)
that makes specs load-bearing: when a spec file exists with executable
tests, generated code must pass those tests before the harness-enforcer
runs other constraints.

### Artifacts

1. **Update to `constraint-design` skill** — add an "Executable Spec
   Constraint" section covering:
   - The pattern: a constraint whose tool command is "run the spec's
     tests"
   - HARNESS.md entry format:

```markdown
### Spec conformance

- **Rule**: All code changes covered by a spec in `docs/superpowers/specs/`
  must pass the spec's associated test suite before merge
- **Enforcement**: deterministic
- **Tool**: <project test runner command>
- **Scope**: pr
```

- How to link specs to tests (naming convention: spec at
     `specs/YYYY-MM-DD-feature-design.md` → tests at
     `tests/feature/` or `tests/feature_test.go`)
- The distinction: this constraint runs the test suite, not the
     spec itself. The spec is the human-readable requirement; the
     tests are the executable verification.

1. **Update to `writing-plans` skill** — add guidance that every
   implementation plan should declare where its tests live, so the
   spec conformance constraint knows what to run.

2. **Update to TDD agent** — reinforce that specs produce tests first,
   and those tests are the executable contract that the spec
   conformance constraint will verify.

### How It Works in the Enforcement Loop

| Timescale | What happens |
| ----------- | ------------- |
| Edit (PreToolUse) | Agent warns if changes touch spec-covered code without tests passing |
| PR (CI) | Test suite runs as a deterministic constraint — blocks merge on failure |
| PR (auto-enforcer) | Agent reviews whether the implementation matches the spec's intent |

The deterministic test gate catches "code doesn't work." The agent
review catches "code works but doesn't match what was specified." Both
are needed — this is the `deterministic + agent` enforcement pattern.

### Connection to BDD/Cucumber

For teams using BDD, the executable spec pattern is natural — Gherkin
scenarios ARE the spec AND the test. The constraint design skill should
note this as the gold standard: when the spec is the test, there is
zero drift between intent and verification.

For teams not using BDD, the naming convention approach (spec file →
test directory) is the pragmatic alternative.

## Status

Ready for implementation. This is primarily a documentation/guidance
change — updating existing skills to articulate a pattern, not building
new tools. The constraint itself is just a test suite runner, which
every project already has.
