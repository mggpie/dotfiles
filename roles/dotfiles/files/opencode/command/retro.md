---
description: Close out a swarm — record outcomes, surface learnings and anti-patterns, sync.
---

Run after a swarm to feed the learning loop and leave the repo clean.

1. **Outcomes**: ensure each subtask recorded `swarm_complete` /
   `swarm_record_outcome` (fast+success promotes a pattern; slow+errors flags it).
2. **Surface what the system learned**:
   - `swarm_get_pattern_insights()` — promoted vs deprecated patterns.
   - `swarm_get_strategy_insights()` — strategy success rates in this repo.
   - `swarm_get_file_insights(files=[...])` — hot / risky files.
3. **Persist durable lessons**:
   `hivemind_store(information="<decision / gotcha / root cause>", tags="retro,<area>")`.
4. **Anti-patterns**: call out anything auto-inverted (>60% failure → AVOID).
5. `hive_sync()` then confirm a clean `git status`.

Output: **what shipped → what we learned → anti-patterns to avoid → follow-ups.**
