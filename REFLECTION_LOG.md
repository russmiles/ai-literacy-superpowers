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
