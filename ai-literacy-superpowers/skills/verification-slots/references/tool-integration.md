# Tool Integration Reference

## The Verification Slot Contract

Every verification slot — deterministic or agent-based — follows the
same interface:

**Input:**

- Constraint definition (rule text, enforcement type, tool name)
- Scope (commit, pr, weekly, manual)
- File set (list of files to check, or "all")

**Output:**

- Result: `pass` or `fail`
- Findings: list of `{file, line, message}` objects (empty if pass)

## Wrapping Common Deterministic Tools

### Linters

**Tool**: ESLint, golangci-lint, pylint, ktlint

**Integration**: Run the tool with machine-readable output, parse
findings into the slot format.

### Formatters

**Tool**: Prettier, gofmt, black, ktfmt

**Integration**: Run in check mode (exit non-zero if changes needed).

### Type Checkers

**Tool**: TypeScript compiler, mypy, go vet

**Integration**: Run in check mode, parse errors.

### Secret Scanners

**Tool**: gitleaks, trufflehog, detect-secrets

**Integration**: Run against changed files, fail on findings.

### Structural Test Frameworks

**Tool**: ArchUnit (JVM), go-cleanarch, dependency-cruiser (JS)

**Integration**: Run as part of test suite, fail on violations.

### Custom Scripts

For constraints with no off-the-shelf tool, write a bash script that
follows the slot contract: exit 0 for pass, non-zero for fail, output
findings as structured text.

## Agent-Based Verification

When no deterministic tool exists, the `harness-enforcer` agent reads
the constraint's rule text and reviews code against it. The agent
produces the same output format: pass/fail with findings.

**How the enforcer decides:**

1. Read the constraint's `enforcement` field
2. If `deterministic`: execute the `tool` command, interpret exit code
   and output
3. If `agent`: read the `rule` text, review the file set against it,
   produce findings
4. If `deterministic + agent`: run both, merge findings

## Registering a New Tool

To add a new deterministic tool to an existing constraint:

1. Install the tool in the project (package.json, go.mod, etc.)
2. Verify it works locally: run the command and check output
3. Update the constraint in HARNESS.md:
   - Change `enforcement` from `agent` or `unverified` to
     `deterministic`
   - Set `tool` to the exact command
4. Run `/harness-audit` to verify the tool works in the harness context
5. If using CI, add the tool step to the CI template

The harness-enforcer agent will now execute this tool instead of
performing an agent-based review for this constraint.
