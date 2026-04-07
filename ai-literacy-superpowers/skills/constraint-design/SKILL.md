---
name: constraint-design
description: This skill should be used when the user asks to "add a constraint", "design a constraint", "write a harness rule", "choose enforcement type", "promote a constraint", "configure a verification slot", or needs guidance on the Constraints section of HARNESS.md.
---

# Constraint Design

A constraint is a rule that must be enforced — not a suggestion, but a
hard boundary. In the harness framework, each constraint occupies a
**verification slot** that can be filled by either a deterministic tool
or an agent-based review. The system does not care which backs the slot;
only whether the constraint passed.

## Anatomy of a Constraint

Every constraint in HARNESS.md has four fields:

- **Rule** — what must be true, written precisely enough for objective
  verification
- **Enforcement** — `deterministic`, `agent`, or `unverified`
- **Tool** — which tool or agent checks this (or "none yet")
- **Scope** — when the check runs: `commit`, `pr`, `weekly`, `manual`

## Writing a Verifiable Rule

The rule field is the most important. Apply the same enforceability test
used for conventions:

1. Describe what compliant code looks like
2. Describe what violating code looks like
3. Confirm a reviewer (human or agent) could check this without
   ambiguity

Consult the `context-engineering` skill's convention patterns for
detailed examples.

## Choosing Enforcement Type

| Question | If yes | If no |
| --- | --- | --- |
| Does a deterministic tool exist for this? | Use deterministic | Continue |
| Is the rule precise enough for consistent LLM review? | Use agent | Use unverified |
| Is the team ready to set up tooling? | Use deterministic | Start with agent |

Start with unverified if unsure. Promote when ready.

For the full promotion lifecycle (unverified to agent to deterministic),
consult `references/promotion-ladder.md`.

## Choosing Scope

| Scope | When it runs | Use for |
| --- | --- | --- |
| `commit` | PreToolUse hook (advisory) | Fast checks — formatting, naming |
| `pr` | CI pipeline (strict) | Thorough checks — tests pass, no secrets |
| `weekly` | Scheduled run | Slow checks — dependency audit, structural tests |
| `manual` | `/harness-audit` only | Exploratory — new rules being calibrated |

Start with `pr` scope for most constraints. Move to `commit` only for
fast checks that benefit from immediate feedback. Use `weekly` for
checks that are too slow or expensive for every PR.

## The Verification Slot Interface

The `harness-enforcer` agent uses a uniform contract:

**Input:** constraint definition + scope + file set
**Output:** pass/fail + findings list (file:line references)

This means the enforcer does not care whether it shells out to `eslint`
or reads code against a prose rule — the interface is the same. Promote
a constraint from agent to deterministic by changing the enforcement
field in HARNESS.md; no other changes needed.

For technical details on integrating custom tools into verification
slots, consult the `verification-slots` skill.

## Common Constraint Patterns

### Formatting / Style

- **Rule**: All source files pass the configured formatter
- **Typical enforcement**: Deterministic (prettier, gofmt, black)
- **Typical scope**: commit

### Secret Detection

- **Rule**: No API keys, tokens, or passwords in source files
- **Typical enforcement**: Deterministic (gitleaks, trufflehog)
- **Typical scope**: commit

### Test Suite

- **Rule**: All tests pass with zero failures
- **Typical enforcement**: Deterministic (test runner)
- **Typical scope**: pr

### Documentation Quality

- **Rule**: Doc comments explain reasoning, not signatures
- **Typical enforcement**: Agent (nuanced quality check)
- **Typical scope**: pr

### Architectural Boundaries

- **Rule**: Package X does not import package Y
- **Typical enforcement**: Deterministic (ArchUnit, go-cleanarch) or agent
- **Typical scope**: pr

### Executable Spec Conformance

A spec describes what should be built; tests verify it was built correctly.
The executable spec constraint bridges the two: it is a constraint whose
tool command runs the spec's associated test suite. The spec itself is
never executed — the tests are the executable verification.

- **Rule**: All code changes covered by a spec must pass the spec's
  associated test suite before merge
- **Typical enforcement**: Deterministic (project test runner)
- **Typical scope**: pr

**HARNESS.md entry example:**

```markdown
### Spec conformance

- **Rule**: All code changes covered by a spec in `docs/specs/`
  must pass the spec's associated test suite before merge
- **Enforcement**: deterministic
- **Tool**: <project test runner command>
- **Scope**: pr
```

**Linking specs to tests (naming convention):**

Spec files map to test directories or files by name. A spec at
`specs/YYYY-MM-DD-feature-design.md` corresponds to tests at
`tests/feature/` or `tests/feature_test.go`. The constraint runner
uses this convention to determine which tests to execute when
spec-covered code changes.

**The `deterministic + agent` enforcement pattern:**

A single constraint type is not enough. Deterministic tests catch
"code doesn't work" — functional failures that a test runner can
detect mechanically. Agent review catches "code works but doesn't
match what was specified" — intent drift that requires reading the
spec and judging alignment. Both are needed for full spec conformance:

| Layer | What it catches | Enforcement |
| --- | --- | --- |
| Test suite | Functional failures | Deterministic |
| Agent review | Intent drift from spec | Agent |

**Connection to BDD/Cucumber:**

For teams using BDD, the executable spec pattern is the gold standard.
Gherkin scenarios ARE the spec AND the test — there is zero drift
between intent and verification because they are the same artifact.
For teams not using BDD, the naming convention approach (spec file to
test directory) is the pragmatic alternative. Either way, the harness
constraint runs tests, not specs.

## Additional Resources

### Reference Files

- **`references/promotion-ladder.md`** — Complete lifecycle of a
  constraint from unverified through agent to deterministic, including
  partial promotion, demotion, and decision signals
