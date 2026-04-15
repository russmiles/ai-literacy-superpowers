---
name: docker-scout-audit
description: Use when auditing Docker images in this project for CVEs, base image staleness, or remediation recommendations — covers all four TUI images (Go, Python, Kotlin, C#)
---

# Docker Scout Audit

## Overview

Docker Scout analyses an image's SBOM against the advisory database to surface CVEs and recommend base image updates. Images must be built locally before scanning — Scout analyses layers, not just the Dockerfile.

**Critical rule: Never assert that a base image version is "safe" from training knowledge. Tag aliases like `alpine:3.21` can float. Always run Scout to get the current state.**

---

## Project Images Quick Reference

Build each image before scanning:

```bash
# Go TUI (multi-stage: golang:1.26 → alpine:3.21)
docker build -t ai-literacy-go-tui go-tui/

# Python TUI (python:3.12-slim)
docker build -t ai-literacy-python-tui python-tui/

# Kotlin TUI (multi-stage: maven:3-eclipse-temurin-21 → eclipse-temurin:21-jre-alpine)
docker build -t ai-literacy-kotlin-tui tui/

# C# TUI (multi-stage: dotnet/sdk:8.0 → dotnet/runtime:8.0-alpine)
docker build -t ai-literacy-csharp-tui csharp-tui/
```

---

## Audit Commands

### Quick overview (start here)

```bash
docker scout quickview ai-literacy-go-tui
```

Prints a one-line summary: `5C  3H  6M  63L` (Critical / High / Medium / Low), plus base image refresh/update availability. Run this for all four images first to triage where to spend time.

### Actionable CVE list — fixable, high+ only

```bash
docker scout cves \
  --only-severity critical,high \
  --only-fixed \
  ai-literacy-go-tui
```

`--only-fixed` limits output to CVEs that have a known patch available, making the list immediately actionable. Drop `--only-fixed` to see the full picture including unfixable CVEs.

### CVEs introduced by your code layers (not the base image)

```bash
docker scout cves --ignore-base ai-literacy-python-tui
```

Useful for separating "base image hygiene" work (fix by updating FROM) from "our packages" work (fix by changing dependencies).

### Base image recommendations

```bash
docker scout recommendations ai-literacy-kotlin-tui
```

Shows whether a patch refresh of the same base tag or an update to a newer tag would eliminate CVEs, with a count of how many each option removes.

### Recommendations on hardened images

`docker scout recommendations` requires base image metadata embedded in the
image manifest. Hardened images (chiseled, distroless) may strip this metadata,
causing Scout to error: `image has no base image`. This is expected behaviour,
not a CVE. In CI, add `continue-on-error: true` to the recommendations step so
the job is not failed by this benign error:

```yaml
- name: Base image recommendations
  uses: docker/scout-action@...
  continue-on-error: true
  with:
    command: recommendations
    image: local://ai-literacy-csharp-tui
    exit-code: false
```

### Compare before/after a base image change

```bash
docker scout compare \
  --to ai-literacy-go-tui:new \
  ai-literacy-go-tui:old
```

Use this after updating a `FROM` line to quantify the security improvement before committing.

---

## Triage Workflow

```text
For each image:
  1. quickview         → is there anything worth fixing?
  2. recommendations   → can a base image bump fix most of it?
  3. cves --only-fixed --only-severity critical,high
                       → what must be fixed now?
  4. cves --ignore-base → anything in our own installed packages?
```

**Act on base image CVEs first** — a single `FROM alpine:3.21` bump often eliminates tens of vulnerabilities in one commit.

**For Alpine runtime stages:** `apk upgrade --no-cache` is more reliable than upgrading specific packages. A targeted `apk upgrade expat` can silently no-op if the fixed version isn't yet in the current Alpine repo index; a full upgrade applies whatever is available at build time. Add it as a chained step after `apk add`:

```dockerfile
RUN apk add --no-cache bash \
    && apk upgrade --no-cache
```

---

## Hardened Runtime Images

Where a hardened base image is available, prefer it over package upgrade patches.
A hardened image eliminates the OS-layer CVE surface rather than patching
individual packages one at a time.

| TUI | Previous base | Hardened base | Why |
| --- | --- | --- | --- |
| Go | `alpine:3.21` | `gcr.io/distroless/static:nonroot` | Static binary needs no shell, no libc, no package manager — minimal attack surface |
| C# | `dotnet/runtime:8.0-alpine` | `mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled` | Ubuntu Chiseled strips shell and package manager; bash not required on glibc images |
| Kotlin | `eclipse-temurin:21-jre-alpine` | (no drop-in yet) | Kotlin/Lanterna requires bash at runtime; stay with Alpine + full upgrade |
| Python | `python:3.12-slim` | (no distroless with interpreter yet) | Python apps need the interpreter; stay with slim + upgrade |

**Go distroless three-stage pattern:**

```dockerfile
FROM golang:1.26 AS build
# build and test as normal

FROM alpine:3.21 AS terminfo
RUN apk add --no-cache ncurses-terminfo

FROM gcr.io/distroless/static:nonroot AS runtime
COPY --from=terminfo /usr/share/terminfo /usr/share/terminfo
WORKDIR /app
COPY --from=build /app/framework-tui .
ENTRYPOINT ["./framework-tui"]
```

The terminfo stage copies only data files (not binaries) from Alpine into
distroless so that tcell can negotiate terminal colour capabilities at runtime.

**C# chiseled pattern:**

```dockerfile
FROM mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "FrameworkTui.dll"]
```

No `apk add bash` required — the bash dependency is Alpine-specific; chiseled
uses Ubuntu (glibc) where Terminal.Gui's curses initialisation works without a shell.

---

## Common Findings for This Project's Base Images

| Base image | Common CVE surface | Typical fix |
| --- | --- | --- |
| `gcr.io/distroless/static:nonroot` | Near-zero — no OS packages | Rebuild against updated distroless digest |
| `dotnet/runtime:8.0-jammy-chiseled` | Minimal — chiseled Ubuntu; .NET patched frequently | Monitor MSRC advisories; bump minor version |
| `python:3.12-slim` | Debian packages (openssl, libssl, glibc) | Bump to latest `-slim` digest |
| `eclipse-temurin:21-jre-alpine` | JVM Alpine — occasional alpine pkg CVEs | `apk upgrade --no-cache` in runtime stage |

---

## CI Integration

Add a Scout step after each Docker build job to block merges with critical CVEs:

```yaml
- name: Scan for critical/high CVEs
  run: |
    docker scout cves \
      --only-severity critical,high \
      --only-fixed \
      --exit-code \
      ai-literacy-go-tui
```

`--exit-code` returns `2` if any matching CVEs are found, failing the CI job. Pair with `--only-fixed` so builds are not blocked by CVEs with no available patch.

---

## Common False Positives

**Bundled development artefacts** — `COPY . .` in a Dockerfile copies the entire source tree, including local `.venv` directories, `node_modules`, or other dependency folders used only for development. These are scanned by Scout and their CVEs reported against the image even though they are unreachable at runtime. Always add a `.dockerignore` to exclude them:

```text
.venv
node_modules
.pytest_cache
__pycache__
*.pyc
```

If Scout reports CVEs in a package version that doesn't match what the image's package manager installed, check whether a bundled dev artefact is the real source.

---

## What Scout Cannot Catch

- **Zero-day CVEs** — no advisory entry exists yet; Scout has no data.
- **Semantic vulnerabilities** — a library doing the wrong thing correctly is invisible to CVE scanning.
- **Runtime configuration errors** — exposed ports, missing secrets rotation, overprivileged containers are out of scope.

For those, combine Scout with `docker scout policy` (Docker Business) or a separate runtime security tool.
