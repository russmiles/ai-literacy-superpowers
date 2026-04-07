# Feed Learnings into Agent Context — Design Spec

## Problem

The plugin's agents (orchestrator, harness-enforcer, harness-gc)
operate without knowledge of past failures. REFLECTION_LOG.md captures
what went wrong, but no agent reads it. The same mistakes can recur
because agents have no institutional memory.

Auto-harness (neosigmaai/auto-harness) feeds `learnings.md` into every
iteration of its optimization loop. The HumanLayer blog describes this
as a core harness engineering principle: "anytime you find an agent
makes a mistake, you take the time to engineer a solution such that the
agent never makes that mistake again."

## Decision

Update agent definitions to read REFLECTION_LOG.md as context, so past
learnings inform current decisions. Each agent reads the most recent
entries relevant to its role.

## Artifacts

### 1. Update orchestrator agent — `agents/orchestrator.agent.md`

Add instruction:

> At the start of any pipeline run, read the 20 most recent entries
> in REFLECTION_LOG.md. Use the `Surprise` and `Improvement` fields
> to inform your approach. If a past reflection mentions a failure
> in the area you're about to work on, adjust your strategy to avoid
> repeating it — for example, by dispatching deterministic checks
> earlier in the pipeline, or by briefing subagents about known
> pitfalls.

### 2. Update harness-enforcer agent — `agents/harness-enforcer.agent.md`

Add instruction:

> Before running agent-based constraint checks, read the 10 most
> recent entries in REFLECTION_LOG.md. If any reflection describes
> a failure that an agent-based check should have caught, pay
> particular attention to that pattern in the current review.
> Past reflections are evidence of where agent review has been
> insufficient — use them to calibrate your scrutiny.

### 3. Update harness-gc agent — `agents/harness-gc.agent.md`

Add instruction:

> When running GC rules, read the 10 most recent entries in
> REFLECTION_LOG.md. Reflections that mention entropy, drift, or
> staleness are signals about where the codebase is degrading.
> Use these to inform what you look for beyond the declared GC
> rules — a reflection about documentation drift may indicate
> that the documentation freshness GC rule needs tighter criteria.

### 4. Update CLAUDE.md template — `templates/CLAUDE.md`

Add a section:

```markdown
## Learnings

REFLECTION_LOG.md contains past session learnings — surprises,
failures, and improvement proposals. Agents should read recent
entries before starting work to avoid repeating past mistakes.
```

### 5. Update CHANGELOG

## Design Considerations

### Context budget

REFLECTION_LOG.md will grow over time. Agents should read a bounded
number of recent entries to avoid context bloat:

| Agent | Entries to read | Rationale |
|-------|----------------|-----------|
| Orchestrator | Last 20 | Makes high-level pipeline decisions |
| Harness-enforcer | Last 10 | Focused on current review |
| Harness-gc | Last 10 | Focused on current GC run |

### Staleness

Old reflections become less relevant. Agents should weight recent
reflections more heavily. A reflection from 6+ months ago about a
tool that has since been promoted to deterministic is no longer
actionable — the constraint system handles it now.

### Relationship to AGENTS.md

AGENTS.md is for curated, permanent team knowledge (gotchas, arch
decisions). REFLECTION_LOG.md is for raw session-level observations.
Reflections that prove durable should be promoted to AGENTS.md by
a human. This spec does not change that — it just makes the raw
reflections available to agents as interim context.

## What Is NOT In Scope

- Automatic promotion of reflections to AGENTS.md — only humans
  curate that file
- Reading reflections from other projects
- Summarising or compressing reflections — agents read the raw entries
- Changing the reflection format (that's covered by issue #39)
