# Project Conventions

## Literate Programming

All code follows Don Knuth's literate programming principles. The full
guide is in `skills/literate-programming/SKILL.md`.

1. Every file opens with a narrative preamble — why it exists, key
   design decisions, what it deliberately does NOT do
2. Documentation explains reasoning (WHY), not signatures (WHAT)
3. Presentation follows logical understanding — orchestration before
   detail
4. Each file has one clearly stated concern
5. Inline comments explain WHY, not WHAT

## CUPID Code Review

All reviews apply the CUPID lens from
`skills/cupid-code-review/SKILL.md`:

1. **Composable** — usable independently without hidden dependencies
2. **Unix philosophy** — does one thing completely and well
3. **Predictable** — behaves as its name suggests
4. **Idiomatic** — follows the language and project conventions
5. **Domain-based** — names from the problem domain, not implementation

## Conventional Comments

All review feedback uses Conventional Comments
(conventionalcomments.org) labels:

- Labels: `praise`, `issue`, `suggestion`, `nitpick`, `question`,
  `thought`, `todo`, `chore`, `note`
- Decorations: `(blocking)`, `(non-blocking)`, `(if-minor)`
- Every review includes at least one `praise:` comment
- Every `issue:` paired with a `suggestion:` when possible

## Workflow

- **Spec-first**: changes flow through specs before implementation
- **TDD**: red-green-refactor strictly, no code without a failing test
- **Branch discipline**: never commit to main, create an issue first
- **Commit messages**: concise, what and why, no postamble
- **CHANGELOG**: update before every PR
- **PR health check**: watch CI, fix failures, don't declare done
  until green
