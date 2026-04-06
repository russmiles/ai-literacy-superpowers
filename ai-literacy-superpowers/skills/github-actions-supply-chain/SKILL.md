---
name: github-actions-supply-chain
description: Use when reviewing GitHub Actions workflow files for security issues, hardening CI pipelines, or assessing supply chain risk in a repository that uses GitHub Actions
---

# GitHub Actions Supply Chain Assessment

## Overview

GitHub Actions workflows run arbitrary code with access to repository secrets and a `GITHUB_TOKEN`. A compromised or repointed action is indistinguishable from a legitimate one — the attack lands silently in your CI logs. This skill provides a structured checklist for assessing and hardening Actions supply chain risk.

**Never rely on your knowledge of whether an action version is "safe". Run the checklist.**

---

## Assessment Checklist

Work through every workflow file in `.github/workflows/`. For each file:

- [ ] Every `uses:` reference is pinned to a full 40-character commit SHA
- [ ] Third-party actions (outside the `actions/` and `github/` namespaces) are identified and risk-rated
- [ ] A top-level or job-level `permissions:` block is present and minimally scoped
- [ ] No `pull_request_target` trigger is used with `actions/checkout` of the PR head (fork poisoning risk)
- [ ] No user-controlled input flows unsanitised into `run:` shell commands (script injection)
- [ ] A `dependabot.yml` (or Renovate config) exists to keep pinned SHAs current

---

## SHA Pinning

### Why tags are unsafe

A mutable tag (`@v4`) can be silently repointed to a different commit by anyone with push access to that repository — including an attacker who has compromised the maintainer's account. The `tj-actions/changed-files` incident (March 2025) demonstrated this at scale: a compromised action exfiltrated secrets from thousands of repositories before the tag was corrected.

### How to find the SHA for an action version

```bash
# Using the GitHub CLI — replace owner, repo, and tag as needed
gh api repos/actions/checkout/git/ref/refs/tags/v4 --jq '.object.sha'

# If the tag points to a tag object rather than a commit, dereference it:
gh api repos/actions/checkout/git/tags/<sha-from-above> --jq '.object.sha'
```

Alternatively, browse to `https://github.com/<owner>/<repo>/releases/tag/<version>` and copy the full commit SHA from the "Assets" section or the commit link.

### Pinned reference format

```yaml
# Before (mutable tag):
uses: actions/checkout@v4

# After (pinned SHA with tag as comment):
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

Always leave the tag as a comment so humans can understand what version is pinned.

### First-party vs third-party risk

| Action namespace | Risk level | Rationale |
| --- | --- | --- |
| `actions/*` | Medium | GitHub-owned; GitHub employee accounts can be compromised |
| `github/*` | Medium | Same as above |
| Any other owner | High | No privileged relationship; pin and verify provenance |

---

## Permissions Scoping

Without an explicit `permissions:` block, a workflow inherits the repository's default token permissions — which may include write access to contents, pull requests, or packages.

### Minimal read-only workflow (most CI workflows)

```yaml
permissions:
  contents: read
```

### Workflow that needs to post PR comments

```yaml
permissions:
  contents: read
  pull-requests: write
```

### Workflow that uploads release artifacts

```yaml
permissions:
  contents: write
```

Apply the `permissions:` block at the **job level** when different jobs need different scopes. Apply at the **workflow level** when all jobs share the same minimal scope.

---

## Dependabot for Actions

A `dependabot.yml` file tells GitHub to open PRs when pinned action SHAs fall behind the latest release. Without this, pinned SHAs become stale and fall behind security patches.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      actions:
        patterns:
          - "*"
```

Add a separate `package-ecosystem` entry for each language's dependency manager (`gomod`, `maven`, etc.) as needed.

---

## Report Format

After completing the checklist, produce a findings table:

```markdown
## Supply Chain Assessment — .github/workflows/

| File | Finding | Severity | Fix |
| --- | --- | --- | --- |
| lint.yml | `DavidAnson/markdownlint-cli2-action@v16` not SHA-pinned | High | Pin to commit SHA |
| go-tests.yml | No `permissions:` block | Medium | Add `permissions: contents: read` |
| All files | No dependabot.yml for actions | Medium | Add `.github/dependabot.yml` |
```

Severity guide:

- **High** — third-party action not SHA-pinned; `pull_request_target` misuse; script injection
- **Medium** — first-party action not SHA-pinned; no `permissions:` block; no dependabot
- **Low** — informational (e.g. runner version, minor hygiene)

---

## Common Mistakes

- **Pinning the tag object SHA instead of the commit SHA** — some tags point to tag objects, not commits. Always dereference to the underlying commit SHA.
- **Pinning without a comment** — a bare SHA is unreadable. Always comment the human-readable version alongside.
- **Pinning but not enabling Dependabot** — a pinned SHA that never updates is worse than a mutable tag once a CVE lands in the pinned version.
- **Scoping permissions at workflow level when jobs have different needs** — use job-level `permissions:` for finer control.
