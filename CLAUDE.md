# ai-literacy-superpowers — Conventions

## Always Work on a Branch

Never commit directly to `main`. Create a branch for every change:

```bash
git checkout -b <short-descriptive-name>
```

## PR Workflow

1. Create a GitHub issue describing the task
2. Create a branch
3. Make changes, lint, commit
4. Push and create a PR
5. Wait for CI checks to pass
6. Merge only when green

## Commit Messages

Write concise commit messages describing what changed and why.
No postamble, trailer, or attribution lines.

## CHANGELOG

Before every PR, update `CHANGELOG.md`:

- Add a dated section at the top if today's date is not already present
- Group entries under a short theme heading
- One bullet per change: what changed and why it matters

## Semantic Versioning

The plugin follows [semver](https://semver.org/) while pre-1.0:

- **0.MINOR.0** — new skills, agents, commands, or behavioural changes
- **0.x.PATCH** — bug fixes, doc-only changes, count corrections

Version bumps are only required when files inside `ai-literacy-superpowers/`
change. Changes outside the plugin directory (articles, docs, observability,
root config) do not require a version bump.

When a PR touches `ai-literacy-superpowers/` files, check whether the
change warrants a bump:

1. Read the current version from `ai-literacy-superpowers/.claude-plugin/plugin.json`
2. If the change adds or removes a skill, agent, or command, or changes
   plugin behaviour, bump the minor version (e.g. 0.4.0 → 0.5.0)
3. If the change is a fix or doc update to plugin files only, bump the
   patch version (e.g. 0.4.0 → 0.4.1)
4. If the change is trivial (typo, whitespace, formatting-only fixes
   like adding code fence languages), no bump needed — add the
   `no-bump` label to the PR to skip the CI check
5. When bumping, update all three locations:
   - `ai-literacy-superpowers/.claude-plugin/plugin.json` (`"version"` field)
   - `README.md` (Plugin version badge)
   - `CHANGELOG.md` (version header on the current date section)

## Marketplace Versioning

The marketplace listing (`.claude-plugin/marketplace.json`) is versioned
independently from the plugin. It has two version fields:

- `version` — the listing version (the contract with the platform)
- `plugin_version` — pointer to the currently approved plugin release

**When to update `plugin_version`:**

After every plugin version bump, update `plugin_version` in
`.claude-plugin/marketplace.json` to match the new `plugin.json`
version. This is the common case — plugin code changes, listing
contract stays the same.

**When to bump `version` (listing version):**

Bump when the listing contract itself changes:

- Description, keywords, or owner metadata change
- Permissions or consent scope change
- A plugin entry is added or removed from the `plugins` array
- The `source` path changes

The listing version follows the same semver rules as the plugin while
pre-1.0. A listing-only change does not require a plugin version bump.

## Cross-Repo Spec-First Discipline

When work in this plugin is driven by a spec in another repo (typically
`ai-literacy-for-software-engineers`), the spec-first CI check cannot
see the spec. Two options:

1. **Copy the spec** into `docs/superpowers/specs/` as the first commit
   on the branch. This satisfies the spec-first gate and keeps a local
   record of what drove the change. Preferred for large feature work.

2. **Use the cross-repo exemption** — name the branch `cross-repo/...`
   or add the `cross-repo` label to the PR. The spec-first check will
   skip. Use this for sync-driven changes where the spec already exists
   upstream and copying it would be redundant.

In the PR description, always link to the upstream spec regardless of
which option you choose.

## Output Validation Checkpoints

Every command that produces structured output parsed by downstream
consumers must include a validation checkpoint step. The pattern:

1. Generate the output (agent dispatch or command logic)
2. Read the output back
3. Check structure against the format spec reference
4. Fix deviations in place (do not re-dispatch the agent)

Commands with checkpoints: `/harness-health`, `/assess`, `/reflect`,
`/cost-capture`, `/harness-constrain`, `/harness-init`,
`/superpowers-init`, `/governance-audit`, `/harness-onboarding`.

When adding a new command that writes structured markdown, add a
validation step following this pattern. Reference the format spec
rather than inlining field definitions.

## Sync from Source

This plugin's reusable components originate from the
`ai-literacy-for-software-engineers` repo. When syncing changes,
use the `/sync-repos` command in that repo to identify what
needs updating, then apply changes via the PR workflow above.

## Marketplace Cache Auto-Sync

Claude Code keeps a git clone of this repo at
`~/.claude/plugins/marketplaces/ai-literacy-superpowers/`. When a PR
that changes `.claude-plugin/marketplace.json` is merged, the clone is
stale until someone pulls it.

Two scripts handle cache freshness:

- `ai-literacy-superpowers/scripts/sync-to-global-cache.sh` — rsyncs
  plugin content into the versioned plugin cache (runs on every `Stop`)
- `ai-literacy-superpowers/scripts/sync-marketplace-cache.sh` — fast-
  forwards the marketplace clone whenever `marketplace.json` on
  `origin/main` differs from the cached copy (runs on `PostToolUse`
  matching `Bash(gh pr merge*)`; catches listing version,
  `plugin_version`, and per-plugin version bumps alike)

The hooks that invoke these scripts live in `.claude/settings.local.json`
(gitignored, per-machine). Collaborators who want the same behaviour
should copy those entries into their own local settings.
