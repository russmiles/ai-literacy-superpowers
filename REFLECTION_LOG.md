# Reflection Log

<!-- Each entry is appended by integration-agent at the end of a pipeline run.
     Entries capture what was surprising, what went wrong, and what should be
     proposed for addition to AGENTS.md.

     Do NOT modify AGENTS.md directly from this log — only propose. Humans
     curate AGENTS.md. The value of this log is that it provides the raw
     material for curation, not that it auto-populates memory.

     Entry format:

     ---

     - **Date**: YYYY-MM-DD
     - **Agent**: integration-agent
     - **Task**: [one-sentence summary]
     - **Surprise**: [anything unexpected during the pipeline run]
     - **Proposal**: [pattern or gotcha to consider for AGENTS.md, or "none"]
     - **Improvement**: [what would make the pipeline smoother next time]
     - **Signal**: [context | instruction | workflow | failure | none]
     - **Constraint**: [proposed constraint, or "none"]
     - **Session metadata**:
       - Duration: [estimated session duration, e.g. "45 min" or "unknown"]
       - Model tiers used: [e.g. "capable (30%), standard (70%)" or "unknown"]
       - Pipeline stages completed: [e.g. "5/5" or list of agents, or "unknown"]
       - Agent delegation: [full pipeline | partial | manual | unknown]

     Session metadata fields are best-effort. Use "unknown" for any
     value that cannot be determined. Entries written before 2026-04-14
     predate session metadata — treat missing fields as "unknown".

     Signal types classify where the learning should route:
       context     → HARNESS.md Context section (priming gaps)
       instruction → Skills or shared commands (prompt improvements)
       workflow    → AGENTS.md (process patterns)
       failure     → Constraints via /harness-constrain (preventable errors)
       none        → No routing needed (routine work)

     Entries written before 2026-04-08 predate the Signal field.
     Treat missing Signal fields as "none" when computing metrics.

     -->

---

- **Date**: 2026-04-06
- **Agent**: orchestrator (opus)
- **Task**: Added gitleaks secret detection skill and harness integration, then initialized the project's own harness with 6 constraints and promoted ShellCheck to deterministic
- **Surprise**: ShellCheck found 4 issues in existing scripts including `secrets-check.sh` which had just been created and passed both implementer and spec compliance review — the unused variable (`output`) and sed-vs-parameter-expansion patterns were invisible to the subagent reviewers because the spec review checked structure and behaviour, not shell idioms
- **Proposal**: When adding a new deterministic constraint (like ShellCheck), always run a test pass against the full codebase before promoting — including files created earlier in the same session. Consider adding ShellCheck to the default harness template alongside gitleaks so new projects get it from the start.
- **Improvement**: The spec reviewer subagent should be briefed to run ShellCheck (or equivalent linters) as part of its verification when reviewing shell scripts, rather than only checking structural requirements against the spec. Deterministic tools catch what LLM review misses.

---

- **Date**: 2026-04-06
- **Agent**: orchestrator (opus)
- **Task**: Initialized the project's own harness (HARNESS.md, CI workflow, badges) and generated the baseline health snapshot
- **Surprise**: 5 out of 6 constraints reached deterministic enforcement on first init — far higher than typical projects. This is because the plugin's "code" is markdown and bash, where lightweight tools (markdownlint, gitleaks, bash -n, grep, shellcheck) cover nearly everything. Projects with application code would start with more unverified or agent-level constraints.
- **Proposal**: Future agents should know that this project's harness is self-referential — the plugin defines the harness framework, and its own HARNESS.md uses that framework. Changes to template files (templates/HARNESS.md) do not automatically propagate to the project's root HARNESS.md. The command-prompt sync GC rule and plugin manifest currency GC rule are particularly important here to catch drift between the plugin's own docs and its shipped templates.
- **Improvement**: The health snapshot was committed directly to main because it's a generated artifact. Consider whether snapshot commits should go through PRs for consistency, or whether direct-to-main is the right pattern for observability artifacts that don't affect behaviour.

---

- **Date**: 2026-04-07
- **Agent**: orchestrator (opus)
- **Task**: Researched harness engineering patterns on GitHub, designed and implemented three Tier 1 features in parallel: auto-enforcer GitHub Action, convention sync across AI tools, and architectural fitness functions for the GC system
- **Surprise**: Worktree-isolated subagents consistently failed on Bash permissions — the isolation mechanism did not carry tool permissions through to the child agent. Non-worktree background agents worked but cross-contaminated branches (convention-sync commits landed on the fitness-functions branch), requiring manual cherry-picking to untangle. The worktree permission issue is a platform-level problem worth investigating — worktrees are the intended isolation mechanism for parallel agents, but if they can't run git commands, they're useless for implementation work.
- **Proposal**: Future agents should know: (1) worktree isolation for subagents is currently unreliable for implementation tasks that need Bash/git — use regular background agents on separate branches instead, but expect branch cross-contamination when multiple agents share the same repo; (2) when dispatching parallel implementation agents without worktrees, each agent should be given explicit instructions to verify it's on the correct branch before committing, and the orchestrator should plan for cherry-pick cleanup; (3) the three Tier 1 features (auto-enforcer, convention-sync, fitness-functions) each modify `templates/HARNESS.md` — merging them in sequence will cause conflicts on the later PRs, so always rebase the last one after merging the first two.
- **Improvement**: Investigate why worktree-isolated agents lose Bash permissions. This may be a Claude Code plugin permission scoping issue — the `.claude/settings.local.json` allow-list may not propagate to worktree paths. If fixable, worktrees would be the clean solution for parallel implementation. If not, the dispatching-parallel-agents skill should document the "branch cross-contamination" risk and recommend the cherry-pick cleanup pattern as standard practice.

---

- **Date**: 2026-04-08
- **Agent**: claude-opus-4-6 (interactive)
- **Task**: Closed gaps in all three harness feedback loops and updated docs to reflect the improvements (PRs #76–#77)
- **Surprise**: Nothing unexpected — the work went smoothly as planned
- **Proposal**: Future agents should know that the three harness feedback loops (enforcement, observation, garbage collection) are tightly coupled — changing one loop's behaviour or output format can affect the other two. When modifying any single loop, check the interfaces between all three before considering the work complete.
- **Improvement**: none

---

- **Date**: 2026-04-08
- **Agent**: claude-opus-4-6 (interactive + haiku/sonnet subagents)
- **Task**: Integrated Boeckeler's Feedback Flywheel concepts — added signal classification to reflections, vocabulary mapping to docs, and Session Quality metrics to snapshot format (PR #81)
- **Surprise**: Nothing unexpected — the subagent pipeline executed cleanly across 7 tasks with spec compliance review on each
- **Proposal**: Future agents should know: (1) reflection template changes must propagate to all consumers — the /reflect command, the integration agent, REFLECTION_LOG.md header comment, and the self-improving-harness docs page all carry copies of the template; (2) the explanation pages cross-reference each other heavily — changes to one concept page (e.g. compound-learning.md) may require updates to self-improving-harness.md, three-enforcement-loops.md, and others that reference the same structures
- **Improvement**: none
- **Signal**: workflow
- **Constraint**: none

---

- **Date**: 2026-04-09
- **Agent**: claude-opus-4-6 (interactive + haiku/sonnet subagents)
- **Task**: Major session — org transfer to Habitat-Thinking, feedback flywheel signal classification, model sovereignty skill, Article 07 (The Assessment Practice), literacy-improvements skill bridging assessment to action, portfolio-assessment skill for multi-repo aggregation, semver workflow convention. Plugin went from v0.1.0 to v0.6.0 across PRs #79–#90.
- **Surprise**: The three-layer assessment stack (assess → literacy-improvements → portfolio-assess) emerged iteratively from conversation rather than being designed upfront. Each layer naturally read the output of the layer below — the improvement mapping reads assessment gaps, the portfolio reads individual assessments and the improvement mapping. The architecture was coherent despite being discovered incrementally.
- **Proposal**: Future agents should know: (1) the assessment system is now three layers deep — single-repo assessment, improvement planning, and portfolio aggregation — and changes to the assessment document format affect all three layers; (2) iterative design conversations that start with "does X do Y?" and evolve through "what about Z?" can produce coherent multi-layer architectures if each layer reads the output of the layer below rather than inventing its own data model; (3) when adding new skills or commands, update the improvement-mapping.md reference if the new capability closes a gap at any literacy level
- **Improvement**: The version bump workflow (CLAUDE.md convention) worked well — every PR checked whether a bump was needed. Could be automated further with a CI check that compares plugin.json version to the latest git tag.
- **Signal**: workflow
- **Constraint**: none

---

- **Date**: 2026-04-10
- **Agent**: claude-opus-4-6 (interactive + sonnet subagents)
- **Task**: Continued session — portfolio dashboard skill, team-api skill, agent-harness-enabled topic tagging, portfolio assessment of Habitat-Thinking org, HTML dashboard generation, 23 how-to guides for all skills, 6 tutorials covering the full journey. Plugin went from v0.6.0 to v0.8.2 across PRs #91–#98.
- **Surprise**: Three parallel subagents each writing 7 how-to guides (21 total) all produced zero markdownlint errors and consistent style on first attempt. The briefing format — style reference file, skill file to read first, explicit constraints (line count, frontmatter format, no commit) — was sufficient for reliable parallel content generation at scale without review loops.
- **Proposal**: Future agents should know: (1) parallel subagent dispatch for bulk documentation works reliably when each subagent gets a style reference file to read, the source skill files to read before writing, and explicit structural constraints (line count, frontmatter format); (2) the docs site now has complete Diataxis coverage — 6 tutorials, 23 how-tos, reference pages, and 14 explanation pages — changes to skills should check whether the corresponding how-to needs updating; (3) the portfolio dashboard skill generates self-contained HTML that can be committed to the repo, which creates an interesting pattern: AI-generated artifacts that are versioned alongside the data they visualise
- **Improvement**: The how-to generation could be even faster with a template file that subagents read instead of inferring style from an example. A `docs/how-to/_template.md` with the exact structure (frontmatter, intro line, numbered steps, code blocks pattern) would remove the style inference step.
- **Signal**: workflow
- **Constraint**: none

---

- **Date**: 2026-04-10
- **Agent**: assessor (via /assess)
- **Task**: First full AI literacy assessment of ai-literacy-superpowers
- **Surprise**: The project assessed at L5 on first assessment. The strongest signal was self-referential: the plugin originates the assessment framework it was assessed with, which makes the L5 "platform-level tooling" criterion trivially met. The interesting gap is that MODEL_ROUTING.md — a template this plugin ships — was missing from the plugin's own project. The cobbler's children.
- **Proposal**: Future agents should know: the plugin's own project should always have every artifact it templates for others. If the plugin ships a MODEL_ROUTING.md template, the project root should have a MODEL_ROUTING.md. Check for this during harness audits.
- **Improvement**: The assessment could detect "template-but-not-applied" gaps automatically — scan templates/ and check whether corresponding files exist at the project root.
- **Signal**: context
- **Constraint**: none

---

- **Date**: 2026-04-11
- **Agent**: claude-opus-4-6 (interactive + background subagents)
- **Task**: Completed all documentation gaps — three reference page stubs (commands, agents, templates), wired Article 08 into docs nav, added Human Pace how-to guide, fixed stale design spec counts, bumped to v0.9.4
- **Surprise**: Background subagents drafted all three reference pages but couldn't write files due to permission denials — had to extract content from their output logs and write from the parent context. Also, the version consistency CI check I suggested adding at the end already existed at `.github/workflows/version-check.yml`.
- **Proposal**: Future agents should know: (1) background subagents may lack Write/Edit permissions — use foreground agents for write-heavy tasks, or have the parent do the final writes; (2) before proposing new CI checks, grep `.github/workflows/` for related workflows to avoid duplicating existing enforcement; (3) the docs site now has zero "Coming Soon" stubs — all reference pages (skills, commands, agents, hooks, templates, harness-md-format) are complete
- **Improvement**: Grep for existing CI workflows before suggesting new ones. For parallel doc writing, foreground agents with approved permissions would avoid the extract-and-rewrite overhead.
- **Signal**: workflow
- **Constraint**: none

---

- **Date**: 2026-04-14
- **Agent**: claude-opus-4-6 (main conversation)
- **Task**: Added Tier 1 and Tier 2 Observatory metrics to harness health snapshots — YAML metrics block, regression detection, feedback loop tracking, session metadata in reflections, governance YAML standardisation, and configurable snapshot cadence
- **Surprise**: The files referenced in the spec existed in two locations — some at the repo root (e.g. `skills/`, `hooks/`, `templates/`) and others nested under `ai-literacy-superpowers/` (e.g. `ai-literacy-superpowers/commands/`, `ai-literacy-superpowers/agents/`). The spec used root-relative paths for all files, which required discovery to find the actual locations.
- **Proposal**: GOTCHA: Plugin files are split between the repo root and the `ai-literacy-superpowers/` subdirectory. Root-level `skills/`, `hooks/`, `templates/` are the plugin's own development files. Files under `ai-literacy-superpowers/` are the packaged plugin that gets distributed. When a spec references a file path, check both locations.
- **Improvement**: Specs that reference files across both locations should use explicit prefixes (`root:` vs `plugin:`) or full paths to avoid ambiguity. Alternatively, a file map in the spec preamble would save discovery time.
- **Signal**: context
- **Constraint**: none
- **Session metadata**:
  - Duration: unknown
  - Model tiers used: unknown
  - Pipeline stages completed: manual implementation (no orchestrator pipeline)
  - Agent delegation: manual

---

- **Date**: 2026-04-14
- **Agent**: claude-opus-4-6 (main conversation + harness-gc subagent)
- **Task**: Ran /harness-health and /harness-gc (first full run of all 7 GC rules), fixed marketplace.json drift, created issues for remaining findings (PR #120)
- **Surprise**: Three things: (1) The health badge script matches substrings — "Trend alerts: none" triggered the "alert" detector, producing a false "Degraded" status. Worked around by rephrasing to "Trend concerns: none". (2) First full GC run found 4/7 rules with findings (11 command-prompt sync issues, marketplace version stuck at 0.1.0 since creation), confirming the "silent" GC effectiveness flag was masking real entropy. (3) Re-running a failed GitHub Actions workflow reuses the original event payload — adding a label after the first run and re-triggering does not pick up the new label. A fresh push is needed to trigger a new workflow run with current label state.
- **Proposal**: Future agents should know: (1) the badge script in `scripts/update-health-badge.sh` uses substring matching on the Meta section — avoid words like "alert", "stalled", "silent", "overdue" in field names when the value is negative (e.g. use "Trend concerns: none" not "Trend alerts: none"); (2) running /harness-gc is essential to move health from "Attention" to "Healthy" — the 5 agent-scoped GC rules only execute on explicit invocation, not via CI; (3) when adding labels to exempt a PR from CI checks, push a new commit (even empty) rather than re-running the failed workflow, because GitHub Actions re-runs reuse the original event payload
- **Improvement**: The badge script should read the YAML metrics block (`observatory_metrics.observability.health`) instead of parsing the markdown Meta section with substring matching — this would eliminate the false-positive class entirely. Filed as a mental note for next plugin development session.
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~30 min
  - Model tiers used: capable (harness-gc subagent), most-capable (main conversation)
  - Pipeline stages completed: harness-health, harness-gc, fix, PR, merge, reflect
  - Agent delegation: partial (subagent for GC, manual for fixes and PR)

---

- **Date**: 2026-04-14
- **Agent**: claude-opus-4-6 (main conversation)
- **Task**: Diagnosed and fixed intermittent YAML block omission in harness-health snapshots by restructuring command spec instructions
- **Surprise**: The bug was not in code but in prompt architecture. The YAML block instruction was a single trailing sentence inside the content-heaviest step of the command spec. When previous snapshots existed (adding cognitive load from trend computation and template bias from reading old snapshots that predate the YAML spec), the model would treat its job as done after writing the last markdown section. The same instruction design principles that prevent bugs in code — single responsibility, explicit contracts, verification steps — apply directly to prompt-based command specs.
- **Proposal**: GOTCHA: Command specs that instruct the model to generate multi-part output (e.g. markdown sections + YAML block) must give each part its own numbered step. Trailing instructions inside content-heavy steps are unreliable — the model loses them under cognitive load. Mandatory outputs should be marked **bold mandatory**, contrasted with conditional outputs, and include a self-verification checkpoint ("confirm the file ends with X before proceeding"). This applies to all command specs in the plugin, not just harness-health.
- **Improvement**: Audit other command specs for "trailing instruction" patterns where a required output is appended as an afterthought inside a step that already produces substantial content. The snapshot-format reference should also lead with the mandatory/conditional distinction for each section.
- **Signal**: instruction
- **Constraint**: none
- **Session metadata**:
  - Duration: ~15 min
  - Model tiers used: most-capable (main conversation), standard (Explore subagent)
  - Pipeline stages completed: manual investigation, fix, reflect
  - Agent delegation: manual

---

- **Date**: 2026-04-15
- **Agent**: claude-opus-4-6 (main conversation + governance-auditor subagent + Explore subagent)
- **Task**: Observatory signal verification (72 signals across 5 sources), Governance Summary validation checkpoint, harness health snapshot regeneration
- **Surprise**: The governance-auditor agent consistently ignored its own `## Governance Summary` format spec despite having detailed instructions (lines 92-144 of the agent file). The instructions were correct but the agent produced a loose `## Summary` section with missing fields every time — including when dispatched with explicit context about the required format. A subagent also hallucinated "23 GC rules" when there were 13 — a clean factual error on a countable quantity. Separately, the /harness-health command still generated the deprecated YAML `observatory_metrics` block (removed in v0.16.0) because the command spec did not explicitly forbid it.
- **Proposal**: GOTCHA: Agent format specs for machine-readable output (regex-parsed headings, structured field lists) need three layers of defence: (1) clear instructions in the agent file, (2) a self-check instruction telling the agent to verify its own output before returning, (3) a validation checkpoint in the dispatching command that fixes the output in place. Instructions alone are not sufficient — agents drift from structured output formats under cognitive load, especially when the report body requires substantial analysis.
- **Improvement**: The Observatory signal verification checklist should be a reusable skill or command (`/observatory-verify`) rather than a one-off prompt. It produced high-value findings (6 PARTIAL, 7 MISSING across 72 signals) and the structured table format made gaps immediately actionable.
- **Signal**: failure
- **Constraint**: none (fix already in place as command checkpoint in step 5 of /governance-audit)
- **Session metadata**:
  - Duration: ~45 min
  - Model tiers used: most-capable (main conversation, ~70%), standard (Explore subagent, ~10%), capable (governance-auditor subagent, ~20%)
  - Pipeline stages completed: harness-health, governance-audit, signal verification, fix, 3 PRs (#142-#144), reflect
  - Agent delegation: partial (subagents for governance audit and exploration, manual for verification and fixes)

---

- **Date**: 2026-04-15
- **Agent**: claude-opus-4-6 (main conversation + 7 haiku subagents)
- **Task**: Added output validation checkpoints to 7 commands following the governance-audit pattern, via brainstorming, spec, plan, and subagent-driven implementation. Plugin 0.19.3 to 0.19.4.
- **Surprise**: Two things: (1) The subagent-driven implementation was remarkably clean — 7 haiku-model agents dispatched in two parallel batches completed all mechanical edits with zero errors and zero review loops. The plan file in the first commit tripped the spec-first CI check (same friction as PR #143), requiring a `chore` label. (2) More fundamentally, the need for output validation checkpoints at all was surprising — commands, skills, and agents already reference detailed format templates and specs, yet agents consistently drift from those templates under cognitive load. Reference templates set intent but do not guarantee compliance. The gap between "the spec says X" and "the output actually contains X" is real and requires an explicit verification step, the same way compiled code passes a type checker even though the programmer intended correct types.
- **Proposal**: STYLE: When using subagent-driven development for mechanical edits (insert markdown section, renumber headings), haiku-model agents are sufficient and reliable. The key is a self-contained prompt with the exact content to insert and explicit renumbering instructions. No judgment calls = no need for a capable model. This scales well — 7 parallel agents completed in ~50 seconds wall time. ARCH_DECISION: Reference templates are necessary but not sufficient for structured output compliance. Every command that produces machine-readable output parsed by downstream consumers needs an explicit validation checkpoint between generation and commit — the same way a compiler enforces types even though the programmer wrote the code with correct types in mind.
- **Improvement**: Spec and plan should be committed separately (spec first, plan second) to satisfy the spec-first CI check without needing a label workaround. Future plans should note this in their Task 1.
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~60 min
  - Model tiers used: most-capable (main conversation, brainstorming, coordination, ~50%), capable (Explore subagent for audit, ~10%), haiku (7 implementation subagents, ~40%)
  - Pipeline stages completed: brainstorming, spec, plan, subagent-driven implementation (7 tasks), version bump, PR, reflect
  - Agent delegation: partial (subagents for implementation, manual for design and coordination)

---

- **Date**: 2026-04-15
- **Agent**: claude-opus-4-6 (main conversation + haiku/Explore subagents)
- **Task**: Full session: harness health, governance audit, Observatory signal verification, output validation checkpoints for 8 commands, convention sync, GC workflow expansion, README/docs audit and remediation, and /harness-onboarding command. Plugin v0.19.2 to v0.20.0 across PRs #142-#157.
- **Surprise**: The plugin had strong generation capabilities but weak verification — nothing checked that structured output matched its spec. This manifested at every layer: governance-auditor ignoring its format spec, /harness-health generating deprecated YAML, docs site with a "Coming Soon" stub for the HARNESS.md format reference, README counts drifting from reality. Verification was treated as optional rather than structural. Once the checkpoint pattern was established (PR #144), it propagated to 7 more commands with haiku subagents in under a minute — the pattern was simple, the gap was recognising it was needed.
- **Proposal**: ARCH_DECISION: Every command that produces structured output parsed by downstream consumers must include a validation checkpoint step. This is not optional — it is the verification layer that makes the generation layer trustworthy. The pattern is: generate, read back, check against format spec, fix in place. Reference templates set intent; checkpoints guarantee compliance. Implemented across 8 commands; apply to any new command that generates parseable output.
- **Improvement**: A standing `/observatory-verify` command that runs the 72-signal checklist on demand would make signal contract auditing reusable. The one-off prompt found 13 gaps (6 PARTIAL, 7 MISSING) that drove most of the session's work — making it a command would let any session start with "what signals are we missing?"
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~3 hours
  - Model tiers used: most-capable (main conversation, ~55%), haiku (implementation subagents, ~25%), capable (Explore/governance subagents, ~20%)
  - Pipeline stages completed: harness-health, governance-audit, signal verification, brainstorming, spec, plan, subagent-driven implementation, convention-sync, docs audit, docs remediation, issue creation, /harness-onboarding feature, 16 PRs (#142-#157), 3 reflects
  - Agent delegation: partial (subagents for implementation, exploration, and governance audit; manual for design, verification, and coordination)

---

- **Date**: 2026-04-16
- **Agent**: claude-opus-4-6 (main conversation + Explore subagent)
- **Task**: Codified validation checkpoint architectural decision (3-place: AGENTS.md + HARNESS.md + CLAUDE.md), built /harness-onboarding command (issue #37), built /observatory-verify command with 82-signal checklist. Plugin v0.20.0 to v0.21.0 across PRs #157-#159.
- **Surprise**: The reflection-to-implementation loop ran in real time. Both /harness-onboarding and /observatory-verify originated directly from the previous reflection's Proposal and Improvement fields. The architectural decision codification also came from a reflection. Three consecutive reflections each produced actionable work implemented in the same session — compound learning with minutes of latency, not days. This only worked because each proposal was self-contained (single command or constraint).
- **Proposal**: STYLE: When a reflection's Proposal or Improvement field describes something actionable and self-contained, explore implementing it in the same session while context is warm. This works when the work is a single skill/command/constraint — larger proposals should still go through spec-first planning. The three-place codification pattern (AGENTS.md decision + HARNESS.md constraint + CLAUDE.md convention) should be documented as a how-to guide for future agents — it's a reusable process for turning architectural decisions into discoverable, enforceable, and primed conventions.
- **Improvement**: none
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~45 min
  - Model tiers used: most-capable (main conversation, ~80%), capable (Explore subagent, ~20%)
  - Pipeline stages completed: architectural decision codification, /harness-onboarding feature (spec, skill, command, template, GC rule), /observatory-verify feature (spec, command, signal checklist reference), 3 PRs (#157-#159), reflect
  - Agent delegation: partial (Explore subagent for research, manual for implementation and design)

---

- **Date**: 2026-04-16
- **Agent**: claude-opus-4-7 (main conversation, no subagents)
- **Task**: Fixed marketplace.json `source` path (listing 0.2.1 → 0.2.2, PR #164) and added a `PostToolUse` hook on `Bash(gh pr merge*)` that fast-forwards `~/.claude/plugins/marketplaces/ai-literacy-superpowers` whenever marketplace.json on origin/main differs from the cached copy (plugin 0.21.0 → 0.22.0, PR #166). Hook fired successfully on both merges within the same session — validating the design end-to-end.
- **Surprise**: Three things. (1) The `PostToolUse` hook installed mid-session via `.claude/settings.local.json` **fired on the very next `gh pr merge`** in the same session, because the settings watcher was already watching that file when the session started. Hooks added to pre-existing settings files do not require a restart to activate — an important detail for any workflow that wires up automation and wants to validate it immediately. (2) The initial narrow trigger design ("listing version changed") would have silently skipped PR #166's own merge, because #166 bumped only `plugin_version`, not listing `version`. Broadening the gate to file-diff on marketplace.json was validated in production — the hook fired and synced the cache exactly because of that decision. When users say "when X changes," interrogate whether X means the field they named or the state that field represents. (3) The cache at `~/.claude/plugins/marketplaces/<name>/` is a full git clone (with `.git/`, working tree, remote tracking `origin/main`) — not a read-only snapshot. Treating it as a live git repo unlocks simple, reliable diff/pull operations; anything fancier (hash-of-file, API polling) would have been overengineering.
- **Proposal**: CONTEXT: Document the two-cache architecture explicitly in HARNESS.md or CLAUDE.md — `~/.claude/plugins/cache/<name>/<version>/` holds versioned plugin content (rsync'd locally by the existing `Stop` hook) and `~/.claude/plugins/marketplaces/<name>/` is a git clone that Claude Code reads to resolve `source`. Future agents touching plugin releases need this mental model; discovering it ad hoc cost time. STYLE: Shell scripts must place `set -euo pipefail` within the first 15 lines (the "Enforce PR constraints" check counts literally). Header comments longer than ~12 lines push strict mode past the cutoff — put the directive immediately after the shebang as an invariant, not next to the code it affects.
- **Improvement**: The CHANGELOG version-consistency CI parser does a positional parse of the first token after `##`, not a regex. A date-only heading (`## 2026-04-16`) silently extracts `2026` and fails the check with a cryptic mismatch. Either the parser should be hardened (accept either a semver or skip non-semver headings) or CLAUDE.md should call out the heading format as a hard requirement alongside the existing "add a dated section" guidance. Also: `.claude/settings.local.json` is gitignored, so "workflow rules" captured in hooks there are *personal* — committing the **script** in the plugin dir while leaving the **hook wiring** in local settings is the right split, but CLAUDE.md should state the opt-in pattern explicitly (done in this PR's documentation update).
- **Signal**: context
- **Constraint**: none
- **Session metadata**:
  - Duration: ~60 min
  - Model tiers used: most-capable (main conversation, 100%; no subagents dispatched)
  - Pipeline stages completed: source fix (spec-first exempt via `chore` label), issue, branch, CI iteration, merge; spec-first design doc, hook script, settings wiring, CLAUDE.md rule, plugin bump, PR, rebase after first merge, broadening tweak, merge; 2 PRs (#164, #166), reflect
  - Agent delegation: manual (direct implementation; no orchestrator/spec-writer/tdd-agent invoked)

---

- **Date**: 2026-04-18
- **Agent**: claude-opus-4-7 (main conversation, no subagents)
- **Task**: Added docs/tutorials/first-time-tour.md — a single-route walk through all 21 plugin capabilities in the order most useful on a first run, organised into eight phases with the sequencing rationale made explicit. PR #173, merged to main. No plugin version bump (docs-only).
- **Surprise**: The version-consistency CI failure that bit me today was explicitly documented in the 2026-04-16 reflection's Improvement field — "date-only heading silently extracts '2026' and fails with a cryptic mismatch; CLAUDE.md should call out the heading format." I hit the exact same bug two days later because REFLECTION_LOG.md Improvements are not load-bearing — they are captured but not routed anywhere that influences future sessions. The compound-learning loop has generation (we reflect) and storage (log grows) but no *retrieval* — future agents do not read the log for warnings before touching the relevant surface. This is a gap between "we captured the signal" and "the signal changed behaviour next time."
- **Proposal**: CONTEXT: Update CLAUDE.md "CHANGELOG" section to state the hard invariant enforced by CI: "Every top-level `## ...` heading MUST begin with a semver version (e.g. `## 0.22.0 — YYYY-MM-DD`). For docs-only changes that do not bump the plugin version, append entries under the most recent version's heading — do not create a dated-only top-level heading." This is the fix the previous reflection recommended; it is still unactioned. WORKFLOW: When a session's Surprise field describes a failure mode, consider running `/harness-constrain` or editing CLAUDE.md in the same session rather than leaving the fix implicit in the log. The prior reflection shows that "improvements" left to propagate organically do not propagate.
- **Improvement**: Reflections need a retrieval hook, not just a write hook. Candidate: a SessionStart-phase GC rule that scans recent REFLECTION_LOG.md Improvement fields for keywords matching the files/commands touched in the current session, and surfaces them as warnings before the work starts. The current architecture treats REFLECTION_LOG.md as a write-only audit trail; to close the learning loop it needs to be read at the right moments.
- **Signal**: failure
- **Constraint**: none
- **Session metadata**:
  - Duration: ~45 min
  - Model tiers used: most-capable (main conversation, 100%; no subagents dispatched)
  - Pipeline stages completed: manual tutorial draft, commit, push, PR, 2 CI failures (spec-first, version-consistency), fix-up commit, label add (chore), merge; no orchestrator pipeline used
  - Agent delegation: manual
