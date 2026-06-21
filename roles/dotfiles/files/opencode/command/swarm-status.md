---
description: Show the current swarm's epic, subtasks, reservations, and inbox. Read-only.
---

Report the live state of the running swarm. Do not spawn workers or edit anything.

1. `swarm_status()` — epic + subtask lifecycle (created / spawned / in_progress / completed / closed).
2. `swarmmail_inbox()` — pending messages from workers (blockers, questions).
3. `swarmmail_health()` — active file reservations and any conflicts.
4. `hive_ready()` — subtasks unblocked and ready to spawn next.

Summarize as: **Epic → per-subtask status → blockers → what's ready next.**
