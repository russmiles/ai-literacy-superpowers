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

Before every PR, check whether the change warrants a version bump:

1. Read the current version from `ai-literacy-superpowers/.claude-plugin/plugin.json`
2. If the change adds or removes a skill, agent, or command, or changes
   plugin behaviour, bump the minor version (e.g. 0.4.0 → 0.5.0)
3. If the change is a fix or doc update only, bump the patch version
   (e.g. 0.4.0 → 0.4.1)
4. If the change is trivial (typo, whitespace, internal spec/plan), no bump needed
5. When bumping, update all three locations:
   - `ai-literacy-superpowers/.claude-plugin/plugin.json` (`"version"` field)
   - `README.md` (Plugin version badge)
   - `CHANGELOG.md` (version header on the current date section)

## Sync from Source

This plugin's reusable components originate from the
`ai-literacy-for-software-engineers` repo. When syncing changes,
use the `/sync-repos` command in that repo to identify what
needs updating, then apply changes via the PR workflow above.
