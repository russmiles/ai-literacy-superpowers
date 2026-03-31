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

## Sync from Source

This plugin's reusable components originate from the
`ai-literacy-for-software-engineers` repo. When syncing changes,
use the `/sync-repos` command in that repo to identify what
needs updating, then apply changes via the PR workflow above.
