---
name: worktree
description: Manage git worktrees for parallel agent isolation — spin up a new worktree, merge it back, or clean it up
---

# /worktree

Manage git worktrees for parallel agent work. Three modes:

## /worktree spin [name]

Create an isolated worktree and branch for agent work.

1. Create a new branch from current HEAD:

   ```bash
   git branch [name]
   ```

1. Create a worktree at `../ai-literacy-worktrees/[name]`:

   ```bash
   git worktree add ../ai-literacy-worktrees/[name] [name]
   ```

1. Report: "Worktree created at `../ai-literacy-worktrees/[name]` on
   branch `[name]`. Agent can work there without affecting the main
   working directory."

## /worktree merge [name]

Merge a completed worktree's branch back.

1. Ensure we are on the originating branch (usually main or a feature
   branch):

   ```bash
   git checkout [originating-branch]
   ```

1. Merge the worktree's branch:

   ```bash
   git merge [name]
   ```

1. If there are conflicts, report them and stop — the user resolves
   manually.

1. If clean, report: "Branch `[name]` merged successfully."

## /worktree clean [name]

Remove a worktree after its branch has been merged.

1. Remove the git worktree:

   ```bash
   git worktree remove ../ai-literacy-worktrees/[name]
   ```

1. Delete the branch if it has been merged:

   ```bash
   git branch -d [name]
   ```

1. Prune worktree references:

   ```bash
   git worktree prune
   ```

1. Report: "Worktree `[name]` removed and branch deleted."

## Notes

- Always use `../ai-literacy-worktrees/` as the worktree parent
  directory to keep worktrees outside the main repo
- Each worktree gets its own branch — agents working in different
  worktrees cannot interfere with each other
- The `spin → work → merge → clean` lifecycle mirrors Osmani's
  `agent-spin`, `agent-merge`, `agent-clean` pattern
