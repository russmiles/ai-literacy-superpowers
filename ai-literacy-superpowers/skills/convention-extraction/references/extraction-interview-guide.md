# Extraction Interview Guide

This reference provides the full structured interview protocol for
convention extraction, with example answers and a worked example
showing how a single extraction session produces CLAUDE.md entries,
HARNESS.md constraints, and skill definition content.

## Interview Protocol

### Setting

Conduct the extraction in one of two settings:

- **Mob session** (recommended for teams of 5+): All senior engineers
  in a room (or call). One facilitator asks the questions. Disagreements
  are surfaced and resolved in real-time. This is the highest-value
  format because it forces alignment.

- **One-on-one interviews** (for distributed teams or sensitive topics):
  Interview each senior separately, then compare answers. Divergences
  become discussion topics for the full team.

### Duration

Allow 60-90 minutes for a full extraction. The first question often
takes longest as the team calibrates on the format.

### The Questions

#### Question 1: Architectural non-negotiables

**Ask:** "What architectural decisions should never be left to
individual judgment?"

**Follow-ups:**

- "What happens when someone violates this?"
- "Is this written down anywhere today?"
- "Would a new team member know this on day one?"

**Example answers:**

- "All database access goes through the repository layer, never direct
  SQL in handlers" → HARNESS.md constraint (deterministic, testable)
- "Services communicate via events, never direct HTTP calls between
  services" → HARNESS.md constraint (structural, agent-verifiable)
- "No new dependencies without team discussion" → CLAUDE.md convention
  (process, not mechanically enforceable)

#### Question 2: Frequent AI corrections

**Ask:** "Which conventions are corrected most often in AI-generated
code?"

**Follow-ups:**

- "How do you correct it — comment, rewrite, or reject?"
- "Could you describe what correct code looks like?"
- "Would a linter catch this?"

**Example answers:**

- "AI always generates Java-style getters instead of Kotlin properties"
  → CLAUDE.md convention: "Use Kotlin properties, not Java-style
  getters"
- "AI puts error handling at the wrong layer" → CLAUDE.md convention:
  "Errors are handled at the boundary layer, not in domain logic"
- "AI doesn't follow our naming convention for test files" → CLAUDE.md
  convention: "Test files are named `*_test.go`, test functions start
  with `Test` followed by the function name and scenario"

#### Question 3: Security instincts

**Ask:** "Which security checks are applied instinctively?"

**Follow-ups:**

- "What would you flag if you saw it in a review?"
- "Is this based on a past incident?"
- "Could a tool check this automatically?"

**Example answers:**

- "All user input is validated at the API boundary" → HARNESS.md
  constraint (must-follow, agent-verifiable)
- "No secrets in source, even in test fixtures" → HARNESS.md constraint
  (deterministic, tool-checkable)
- "Auth tokens are never logged, even at debug level" → HARNESS.md
  constraint (agent-verifiable with grep)

#### Question 4: Review rejections

**Ask:** "What triggers an immediate rejection in review?"

**Follow-ups:**

- "How often does this actually happen?"
- "Is this a hard rule or a judgment call?"
- "Would you reject a PR from a senior for the same thing?"

**Example answers:**

- "No tests for new behaviour" → HARNESS.md constraint (deterministic,
  CI-enforceable)
- "Magic numbers without explanation" → CLAUDE.md convention
  (should-follow)
- "Functions longer than 40 lines" → CLAUDE.md convention (should-follow
  with threshold)

#### Question 5: Refactoring philosophy

**Ask:** "What separates a clean refactoring from an over-engineered
one?"

**Follow-ups:**

- "Can you give an example of each?"
- "At what point does abstraction become harmful?"
- "How do you decide whether to extract a function?"

**Example answers:**

- "Three similar lines is better than a premature abstraction" →
  CLAUDE.md convention (nice-to-have philosophy)
- "Don't add interfaces until you have two implementations" → CLAUDE.md
  convention (should-follow)
- "Refactoring should make the next change easier, not all possible
  changes easier" → Skill reference material (philosophy)

## Mapping Table

| Answer type | Priority | Artefact | Location | Enforcement |
| ------------ | ---------- | ---------- | ---------- | ------------- |
| Hard boundary (always wrong) | Must-follow | Constraint | HARNESS.md | Deterministic or agent |
| Strong expectation | Should-follow | Convention | CLAUDE.md | Advisory (hooks) |
| Preference | Nice-to-have | Style guide | CLAUDE.md or skill | None (guidance only) |
| "It depends" | Not encodable | Backlog item | Nowhere yet | Needs decomposition |
| Disagreement surfaced | Discussion needed | Meeting topic | Team discussion | Resolve before encoding |

## Worked Example

A team building a Go REST API runs the extraction. Here is a condensed
result from one session:

**CLAUDE.md additions (3 conventions):**

```markdown
## Conventions (from extraction 2026-04-01)

- **Error handling**: Errors are wrapped with context at each layer
  using `fmt.Errorf("operation: %w", err)`. Never swallow errors.
  Never log and return — do one or the other.
- **Naming**: HTTP handlers are named `handleVerbNoun` (e.g.
  `handleCreateUser`). Repository methods are named `VerbNoun` (e.g.
  `FindUserByEmail`).
- **Testing**: Table-driven tests for any function with more than two
  meaningful input combinations. Test names describe the scenario, not
  the function: `TestFindUser_ReturnsNilWhenNotFound`.
```

**HARNESS.md additions (2 constraints):**

```markdown
### No direct SQL outside repository layer

- **Rule**: All database queries must go through repository types.
  Handlers and services must not import the database package.
- **Enforcement**: deterministic
- **Tool**: Go import analysis (custom linter rule)
- **Scope**: pr

### Input validation at API boundary

- **Rule**: All user-supplied input is validated in the handler before
  reaching service or domain code.
- **Enforcement**: agent
- **Tool**: harness-enforcer
- **Scope**: pr
```

**Skill content (refactoring philosophy — captured for code reviewer):**

The team agreed: "Three similar lines is better than a premature
abstraction. Don't extract a function until you have three call sites
or the extracted function has a clear domain name."

This became a note in the code-reviewer agent's instructions.

## Sizing Heuristic

| Team size | Recommendation |
| ----------- | --------------- |
| 1-5 | Informal — conventions emerge through pairing. Formal extraction optional. |
| 6-15 | Recommended — tacit knowledge starts to diverge. One extraction session per quarter. |
| 15+ | Essential — without extraction, AI output will vary significantly by prompter. Monthly review of encoded conventions. |
