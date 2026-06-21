---
description: Run explicit independent tasks in parallel as cheap workers.
---

$ARGUMENTS

Run the listed tasks concurrently. Use when YOU already know the split (no
decomposition needed) and the tasks touch disjoint files.

1. `swarmmail_init(project_path="$PWD", task_description="Parallel: <summary>")`
2. Confirm the tasks touch NON-overlapping files. If they overlap → run them
   sequentially instead.
3. Spawn all workers in a SINGLE message:
   ```
   Task(subagent_type="<role>", prompt="<task 1 + file list>")
   Task(subagent_type="<role>", prompt="<task 2 + file list>")
   ```
4. As each returns, run the review gate
   (`swarm_review` → `demon` → `swarm_review_feedback`).
5. `saas-shipper` for final verify, then `hive_sync()`.

Coordinator never implements. Workers reserve their own files.
