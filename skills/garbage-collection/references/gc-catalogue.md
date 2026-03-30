# Garbage Collection Rule Catalogue

A reference of common GC patterns, organised by the kind of entropy
they fight. Each pattern includes what to check, recommended frequency,
whether auto-fix is safe, and an example HARNESS.md entry.

## Documentation Entropy

### Stale References

**What it checks**: README, HARNESS.md, and doc comments that reference
files, functions, classes, or CLI flags that no longer exist.

**Frequency**: weekly

**Auto-fix**: false — stale references usually indicate a design change
that needs human judgement about what the correct new reference is.

**Detection approach**: Extract references (file paths, function names)
from documentation. Grep the codebase for each. Flag any that return
zero matches.

### Outdated Version Numbers

**What it checks**: Version numbers in README badges, documentation,
or configuration that do not match the actual installed version.

**Frequency**: weekly

**Auto-fix**: true — if the correct version can be determined from
package files (go.mod, pom.xml, package.json), the GC agent can update
the documentation.

## Convention Drift

### Naming Violations

**What it checks**: Source files where naming patterns have drifted from
declared conventions (e.g., new files using camelCase when the convention
says snake_case).

**Frequency**: weekly

**Auto-fix**: false — renaming has ripple effects.

### Style Drift

**What it checks**: Files that were committed without passing the
formatter, perhaps because the pre-commit hook was bypassed.

**Frequency**: weekly

**Auto-fix**: true — run the formatter and commit the result.

## Dead Code

### Orphaned Files

**What it checks**: Source files that are not imported, included, or
referenced by any other file. Configuration files that are not
referenced by any build or CI script.

**Frequency**: weekly

**Auto-fix**: false — orphaned files may be intentionally standalone.
Create an issue instead.

### Unused Exports

**What it checks**: Exported functions, types, or constants that are
not imported anywhere in the codebase.

**Frequency**: weekly

**Auto-fix**: false — removing exports is a breaking change for
consumers outside the repo. Create an issue.

## Dependency Entropy

### Known Vulnerabilities

**What it checks**: Dependencies with known CVEs, using the language
ecosystem's vulnerability database.

**Frequency**: weekly

**Auto-fix**: false — dependency upgrades can break things. Create
an issue with the CVE details.

### Major Version Lag

**What it checks**: Dependencies that are more than one major version
behind the latest release.

**Frequency**: weekly

**Auto-fix**: false — major version bumps often have breaking changes.

## Harness Entropy

### Constraint Tool Existence

**What it checks**: Deterministic constraints that reference tools not
installed in the project or CI.

**Frequency**: weekly

**Auto-fix**: false — the `harness-auditor` handles this, but the GC
agent can run the same check independently.

### Hook Script Validity

**What it checks**: Hook scripts referenced in hooks.json that do not
exist, are not executable, or fail a dry-run.

**Frequency**: weekly

**Auto-fix**: false — broken hooks need investigation.

## The Auto-Fix Safety Rubric

Auto-fix is safe when:

1. The fix is deterministic — same input always produces same output
2. The fix is local — changes only the affected file, no ripple effects
3. The fix is verifiable — a test or check confirms the fix is correct
4. The fix is reversible — a git revert undoes it cleanly

Auto-fix is not safe when:

1. The fix requires judgement — multiple valid corrections exist
2. The fix has ripple effects — renaming, removing exports, changing APIs
3. The fix cannot be verified — no test covers the changed behaviour
4. The fix is destructive — deleting files, removing functionality
