# Convention Patterns

## What Makes a Convention Enforceable

A convention is enforceable when a reviewer (human or LLM) can
objectively determine whether code follows it. The test: could two
independent reviewers agree on whether this convention is met, without
discussing it?

## Well-Written Conventions

### Naming

**Enforceable:** "All exported Go functions use PascalCase. All
unexported functions use camelCase. Acronyms are treated as single
words: `HttpServer`, not `HTTPServer`."

**Why it works:** Objective rule, no judgement calls, a linter can
check it deterministically.

### Error Handling

**Enforceable:** "Every function that returns an error must either
handle the error with a specific recovery action or wrap it with
`fmt.Errorf` adding context before returning it to the caller. Bare
`return err` without wrapping is not permitted."

**Why it works:** A reviewer can check each error return site. An
agent can scan for bare `return err` patterns.

### File Structure

**Enforceable:** "Each package contains at most one file per public
type. The file is named after the type in snake_case. Test files are
co-located and named `<type>_test.go`."

**Why it works:** Objective, verifiable by listing files in a
directory. A deterministic script could check this.

### Documentation

**Enforceable:** "Every exported function has a doc comment. The
first sentence of the comment states what the function returns or
does, not how it does it. Comments that restate the function
signature (e.g., 'GetUser gets a user') are treated as missing."

**Why it works:** Presence is deterministic. Quality rule ("not
restating the signature") requires agent review but is specific
enough to be consistent.

## Poorly-Written Conventions (Anti-Patterns)

### Vague Quality Statements

**Unenforceable:** "Write clean code."

**Why it fails:** "Clean" is subjective. Two reviewers will disagree.
No tool can check it. An LLM will interpret it differently each time.

### Unmeasurable Aspirations

**Unenforceable:** "Functions should be short."

**Why it fails:** "Short" is undefined. Is 20 lines short? 50? Fix
by specifying: "Functions should not exceed 40 lines excluding blank
lines and comments."

### Style Preferences Without Rules

**Unenforceable:** "Use meaningful variable names."

**Why it fails:** "Meaningful" is a judgement call. Fix by specifying
concrete patterns: "Variable names must be at least 3 characters
except for loop indices (`i`, `j`, `k`) and error values (`err`)."

### Implementation Instructions Disguised as Conventions

**Unenforceable:** "Use dependency injection."

**Why it fails:** This prescribes a technique, not a testable
property. Fix by describing the observable outcome: "No function
constructs its own dependencies. All external dependencies are
received as parameters or struct fields."

## The Enforceability Spectrum

| Level | Example | Checker |
| --- | --- | --- |
| Fully deterministic | "Tabs, not spaces" | Linter |
| Mostly deterministic | "Max 40 lines per function" | Linter + edge cases |
| Agent-checkable | "Doc comments explain why, not what" | LLM review |
| Aspirational | "Code should be readable" | Not enforceable — rewrite |

## Converting Aspirational to Enforceable

Start with the aspiration. Ask: "What would I see in code that follows
this?" Write the observable properties as the convention.

**Aspiration:** "Code should be well-tested."
**Observable:** "Every public function has at least one test. Every
error path has a test that triggers it. Test coverage for each package
is above 80% as reported by the coverage tool."
