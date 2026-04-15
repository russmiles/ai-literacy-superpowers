<!-- Generated from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md.
     Do not edit directly — regenerate with /harness-onboarding. -->

# Welcome to {{PROJECT_NAME}}

{{One paragraph: what this project is, why it matters, and what a new
contributor should expect.}}

---

## Tech Stack

{{From HARNESS.md Context > Stack. List each technology with a brief
note on how it's used in this project.}}

---

## How We Write Code

{{From HARNESS.md Context > Conventions. Transform the terse bullet
format into readable prose — explain not just the rule but why the
team follows it.}}

---

## What's Enforced

{{From HARNESS.md Constraints. Group by when they fire:}}

### At commit time

{{Constraints with Scope: commit — these warn while you edit.}}

### At PR time

{{Constraints with Scope: pr — these block merges.}}

### On schedule

{{Constraints with Scope: weekly or monthly — these run periodically.}}

---

## Common Pitfalls

{{From AGENTS.md GOTCHAS + recent REFLECTION_LOG entries with Signal:
context or workflow. Present as practical warnings with "what happened"
and "how to avoid it".}}

---

## Architecture Decisions

{{From AGENTS.md ARCH_DECISIONS. Each entry: what was decided, why,
and what the alternatives were. These are choices the team has made —
don't second-guess them without good reason.}}

---

## How We Test

{{From AGENTS.md TEST_STRATEGY. Explain how quality is assured in this
project — what tools run, what they check, where to find test configs.}}

---

## How the Harness Works

{{Brief explanation of the three enforcement loops and how they protect
the codebase:}}

- **Advisory loop** — hooks that warn during editing (never block)
- **Strict loop** — CI gates that block merges
- **Investigative loop** — scheduled GC rules that catch slow drift

{{Mention the observability cadence: how often audits, assessments,
reflections, and cost captures run.}}

---

## Your First PR Checklist

{{Synthesised from Constraints and Conventions into a practical
pre-flight list. Include only commit-scoped and PR-scoped items
that a contributor would need to check before pushing.}}

---

## Where to Learn More

{{Links to key project files and documentation:}}

- [HARNESS.md](HARNESS.md) — the full constraint and convention reference
- [AGENTS.md](AGENTS.md) — accumulated team knowledge and gotchas
- [REFLECTION_LOG.md](REFLECTION_LOG.md) — session-by-session learnings
