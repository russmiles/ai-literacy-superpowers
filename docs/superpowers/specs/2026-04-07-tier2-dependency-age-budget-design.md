---
diaboli: exempt-pre-existing
---

# Dependency Age Budget (libyear) — Design Proposal (Tier 2)

## Problem

Dependency checks currently cover CVEs (`govulncheck`, OWASP
Dependency-Check) and major version lag. But they miss *aggregate
staleness* — the total age of all dependencies as a single number.

The libyear metric (sum of years each direct dependency is behind
latest) gives a clear, trending measure of dependency health. A project
with 2 libyears is reasonably current; a project with 15 libyears has
significant staleness risk even if no individual dependency has a CVE.

## Proposal

Add libyear as a complementary metric to the `dependency-vulnerability-audit`
skill, and add a GC rule for weekly tracking with a configurable
threshold.

### Artifacts

1. **Update to `dependency-vulnerability-audit` skill** — add a
   "Dependency Age" section covering:
   - What libyear measures and why it matters beyond CVE scanning
   - Commands per ecosystem:
     - npm: `npx libyear`
     - Ruby: `bundle exec libyear-bundler`
     - Python: `pip list --outdated` (manual calculation)
     - Go: `go list -m -u all` (manual calculation from update availability)
   - How to read the output and set a threshold
   - Recommended budget: <10 libyears for small projects, <20 for large

2. **GC rule entry** for HARNESS.md:

```markdown
### Dependency age budget

- **What it checks**: Whether the total dependency age (libyear score)
  exceeds the project's declared threshold or has increased since the
  last snapshot
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx libyear (or ecosystem equivalent)
- **Auto-fix**: false
```

1. **Health snapshot integration** — add a libyear metric to the
   snapshot format so it trends over time alongside enforcement ratio
   and mutation kill rate.

### Interpretation

The GC agent flags when:

- Total libyears exceed the declared threshold
- Total libyears increased week-over-week (staleness is accumulating)
- A single dependency accounts for >3 libyears (concentrated risk)

## Status

Ready for implementation. Requires a project with npm/Ruby/Python
dependencies to be useful — not applicable to this plugin itself.
