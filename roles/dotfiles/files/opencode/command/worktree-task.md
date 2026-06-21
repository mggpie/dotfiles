---
description: Run a task in an isolated git worktree so workers never collide on the working tree.
---

$ARGUMENTS

Use for risky or parallel work that should stay off the main working tree until verified.

1. `swarm_worktree_create(...)` — new branch + isolated worktree for this task.
2. `swarmmail_init` inside the worktree path.
3. Spawn the worker(s) scoped to that worktree; they reserve + implement there.
4. Review gate: `swarm_review` → `demon` → `swarm_review_feedback`.
5. Verify with `saas-shipper` (typecheck + lint + tests) INSIDE the worktree.
6. On green: `swarm_worktree_merge(...)` then `swarm_worktree_cleanup(...)`.
   On red: leave it for inspection, or `swarm_worktree_cleanup` to discard.

Never merge a worktree that failed review or verification.
