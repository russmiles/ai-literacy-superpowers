# Compound Learning

<!-- This file is the project's persistent memory across AI sessions.
     It accumulates patterns, gotchas, and decisions so that each session
     builds on what previous sessions learned — rather than rediscovering
     the same things from scratch.

     IMPORTANT: This file is often generated or updated by LLM agents.
     Review new entries with the same scepticism you would apply to any
     generated content. Entries should reflect observed reality in the
     codebase, not aspirational conventions. An entry in GOTCHAS that
     does not reflect an actual problem that was actually solved is noise
     that increases the cognitive cost of every future session. -->

## STYLE

<!-- Patterns and idioms that work well in this codebase.
     Each entry: what to do, and why it works here. -->

- All hook scripts are advisory only — they warn but never block.
  Output uses JSON `systemMessage` format so Claude Code surfaces
  the message without interrupting the session flow.

## GOTCHAS

<!-- Traps, surprises, and non-obvious constraints. Entries
     accumulate as the pipeline discovers them.
     Each entry: what the trap is, and how to avoid it. -->

- When adding a new deterministic constraint (like ShellCheck),
  always run a test pass against the full codebase before promoting
  — including files created earlier in the same session. ShellCheck
  found 4 issues in scripts that had passed both implementer and
  spec compliance review. Deterministic tools catch what LLM review
  misses. (Source: REFLECTION_LOG 2026-04-06)

- Worktree-isolated subagents lose Bash permissions — the `.claude/
  settings.local.json` allow-list does not propagate to worktree
  paths. Use regular background agents on separate branches instead,
  but expect branch cross-contamination when multiple agents share
  the same repo. Plan for cherry-pick cleanup when dispatching
  parallel implementation agents without worktrees.
  (Source: REFLECTION_LOG 2026-04-07)

- Background subagents may lack Write/Edit permissions even when the
  parent context has them. For write-heavy tasks (e.g. generating
  full documentation pages), either use foreground agents so the user
  can approve tool calls, or have the parent extract content from
  subagent output and do the writes itself. The subagent output logs
  at `/private/tmp/claude-*/tasks/<agent-id>.output` contain the
  drafted content even when writes were denied.
  (Source: REFLECTION_LOG 2026-04-11)

- Before proposing a new CI workflow, grep `.github/workflows/` for
  related checks. This project already has version-check.yml,
  lint-markdown.yml, harness.yml, gc.yml, and pages.yml. Proposing
  a duplicate wastes a branch cycle and erodes trust.
  (Source: REFLECTION_LOG 2026-04-11)

- This project's harness is self-referential — the plugin defines
  the harness framework, and its own HARNESS.md uses that framework.
  Changes to template files (`templates/HARNESS.md`) do not
  automatically propagate to the project's root `HARNESS.md`. The
  command-prompt sync and plugin manifest currency GC rules are
  critical here to catch drift. (Source: REFLECTION_LOG 2026-04-06)

## ARCH_DECISIONS

<!-- Key architectural decisions and the reasoning behind them.
     Each entry: what was decided, why, and what the alternatives were. -->

- Decision: hook scripts never block, only warn. Reason: this is a
  plugin used across diverse projects — blocking hooks could break
  workflows the plugin authors cannot predict. Advisory messages let
  users decide how to act. Alternative considered: configurable
  blocking (rejected — complexity not justified for the advisory
  value these hooks provide).

- Decision: health snapshots are generated artifacts committed
  directly to main. Reason: they do not affect behaviour and
  gating them on PR review would add friction to the observability
  cadence. Alternative considered: PR workflow for snapshots
  (rejected — would discourage frequent snapshot generation).

- Decision: every command that produces structured output parsed by
  downstream consumers must include a validation checkpoint step.
  The pattern is: generate, read back, check against format spec,
  fix in place. Reason: agents consistently drift from format specs
  under cognitive load — the governance-auditor ignored its own
  9-field format spec, /harness-health generated deprecated YAML
  blocks. Reference templates set intent but do not guarantee
  compliance. The checkpoint is the verification layer, analogous
  to type checking in compiled code. Alternative considered:
  relying on agent instructions alone (rejected — proven unreliable
  across 8 commands). Alternative considered: hook-based validation
  (rejected — hooks are advisory-only with 30-second timeouts, too
  limited for format verification). (Source: REFLECTION_LOG 2026-04-15)

## TEST_STRATEGY

<!-- How tests are structured in this project. Helps agents write consistent
     tests without reading every test file from scratch. -->

- This project has no application code or test suite. Content is
  validated by markdownlint (CI), ShellCheck, bash -n syntax checks,
  and gitleaks secret scanning. All validation is deterministic and
  runs in the harness CI workflow.

## DESIGN_DECISIONS

<!-- Interface contracts, data shapes, and design choices that are stable and
     that agents should not second-guess without good reason. -->

- Plugin components follow strict naming: skills use `SKILL.md`
  inside `skills/<name>/`, agents use `<name>.agent.md`, commands
  use `<name>.md`, hook scripts use `<name>.sh` (kebab-case). All
  names are lowercase kebab-case except `SKILL.md`.
