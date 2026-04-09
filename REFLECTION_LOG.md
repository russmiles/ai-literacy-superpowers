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
