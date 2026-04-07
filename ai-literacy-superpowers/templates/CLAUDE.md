# Project Conventions

<!-- INSTRUCTIONS: Replace every placeholder marked with <!-- ... --> with
     project-specific content. Delete placeholder comments once filled in.
     Keep this file focused and high-signal — every rule here costs a token
     budget on every call. Remove rules that do not apply. -->

## Literate Programming

All code written in this project follows Don Knuth's literate programming principles.
The full skill is at `.claude/skills/literate-programming/SKILL.md`.

When creating a new source file or significantly rewriting an existing one, read
`.claude/skills/literate-programming/SKILL.md` and apply it before writing any code.

The five rules in brief:

1. Every file opens with a narrative preamble — why it exists, key design decisions,
   what it deliberately does NOT do
2. Documentation explains reasoning, not signatures — WHY the design is this way,
   not what the function returns
3. Order of presentation follows logical understanding — orchestration before detail,
   concept before mechanism
4. Each file has one clearly stated concern — named in the first sentence of the preamble
5. Inline comments explain WHY, not WHAT — the code already shows what happens

## CUPID Code Review

When reviewing or refactoring code, apply the CUPID lens documented at
`.claude/skills/cupid-code-review/SKILL.md`.

The five properties in brief:

1. **Composable** — can it be used independently without hidden dependencies?
2. **Unix philosophy** — does it do one thing completely and well?
3. **Predictable** — does it behave as its name suggests, with no hidden side effects?
4. **Idiomatic** — does it follow the grain of the language and project conventions?
5. **Domain-based** — do its names come from the problem domain, not the technical implementation?

## Workflow

### Spec-First Change Discipline

Any change to application behaviour must flow through the spec before touching
implementation code:

1. Update the spec — add or revise user stories, acceptance scenarios, and FRs
2. Update the implementation plan — reflect new or changed FRs
3. Write failing tests from the spec — confirm red before writing implementation
4. Update the implementation — until failing tests turn green
5. Refactor — clean up while keeping all tests green

### Test-Driven Development

Follow red-green-refactor strictly:

1. RED — write a failing test that describes the desired behaviour
2. GREEN — write the minimal production code needed to make the test pass
3. REFACTOR — clean up while keeping all tests green

No production code without a failing test first.

### Branch Discipline

Never commit directly to `main`. At the start of any task:

1. Create a GitHub issue describing the task
2. Create a branch: `git checkout -b <short-descriptive-name>`
   (lowercase, hyphen-separated, e.g. `add-search`, `fix-renderer-wrapping`)

### Commit Messages

Write concise commit messages that describe what changed and why. No postamble,
no attribution lines. The message ends when the description ends.

### CHANGELOG

Before every PR, update CHANGELOG.md:

- Add a dated section at the top if today's date is not already present
- Group entries under a short theme heading
- One bullet per change: what changed and why it matters

### PR Health Check

After every push and PR creation:

1. Run `gh pr checks <number> --watch`
2. If any check fails, fetch the log: `gh run view <run-id> --log-failed`
3. Fix every error, then commit (never amend) and push
4. Repeat until all checks are green

<!-- LANGUAGE-SPECIFIC CONVENTIONS -->
<!-- Add the commands for your project's language(s) below. Examples: -->

## Build and Test

<!-- Replace with actual commands for this project -->

```bash
# Build
# <fill in build command>

# Test
# <fill in test command>

# Lint
# <fill in lint command>

# Format
# <fill in format command>
```

<!-- PROJECT-SPECIFIC CONSTRAINTS -->
<!-- Add constraints specific to this project below.
     Each constraint should answer: what is the rule, and why does it exist?
     Remove this section if there are no project-specific constraints. -->

## Learnings

REFLECTION_LOG.md contains past session learnings — surprises,
failures, and improvement proposals. Agents should read recent
entries before starting work to avoid repeating past mistakes.

## Project Constraints

<!-- Example:
- All database queries must go through the repository layer — direct DB access
  from handlers bypasses the audit log middleware.
- API responses must use the envelope format {data, error, meta} — clients
  depend on this structure for error handling.
-->
