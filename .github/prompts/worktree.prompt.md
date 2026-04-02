---
name: worktree
description: Manage git worktrees for parallel agent isolation — spin up, merge back, or clean up
---

Manage git worktrees for parallel development. Three sub-commands:

**spin** — Create a new worktree:
1. Create a branch: `git checkout -b <name>`
2. Create worktree: `git worktree add ../<project>-<name> <name>`
3. Report the worktree path

**merge** — Merge a worktree back:
1. Switch to the base branch in the main worktree
2. Merge the feature branch
3. Delete the feature branch
4. Remove the worktree: `git worktree remove <path>`

**clean** — Remove a worktree without merging:
1. Switch to main in the main worktree
2. Remove worktree: `git worktree remove <path>`
3. Delete the branch: `git branch -D <name>`
