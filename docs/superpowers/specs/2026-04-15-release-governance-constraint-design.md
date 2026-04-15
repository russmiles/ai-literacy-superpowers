# Release Governance Constraint

## Problem

Published plugin versions have no governance enforcement ensuring
traceability. A version can be bumped in `plugin.json` without a
corresponding changelog entry (partially addressed by the existing
version-check CI workflow) or a git tag. Without tags, there is no
immutable pointer to the code that shipped for a given version.

## Approach

Add a governance constraint to HARNESS.md encoding the requirement:

> Every published plugin version must have a corresponding changelog
> entry and a git tag.

### What already exists

The `version-check.yml` CI workflow already verifies that the
`plugin.json` version matches the top `CHANGELOG.md` heading at PR
time. This covers the changelog side of the constraint.

### What needs adding

1. **Auto-tagger workflow** — a new GitHub Actions workflow that
   creates a `vX.Y.Z` git tag on push to main when the `plugin.json`
   version differs from the latest existing tag.

2. **GC rule with auto-fix** — a new garbage collection rule in
   HARNESS.md that periodically verifies every version in the
   changelog has a corresponding git tag, and auto-creates missing
   tags.

3. **Governance constraint in HARNESS.md** — the formal constraint
   with governance template fields (operational meaning, evidence,
   failure action, three-frame alignment).

### Three-frame alignment

- **Engineering**: PR blocked if changelog heading doesn't match
  version; CI auto-tags on merge; GC catches missed tags.
- **Compliance**: Git tag history and changelog provide audit trail.
  Missing tags are auto-remediated and logged.
- **AI system**: Deterministic checks at PR time (existing) and
  post-merge (new auto-tagger). GC rule is deterministic with
  auto-fix.

All three frames aligned — confirmed during `/governance-constrain`
guided workflow.

## Expected Outcome

- HARNESS.md gains its first governance constraint
- New `.github/workflows/auto-tag.yml` workflow
- New GC rule "Release tag completeness" in HARNESS.md
- HARNESS.md Status updated (12/12 constraints, 3/8 GC active)
- Minor version bump (governance constraint is behavioural)
