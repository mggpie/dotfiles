---
description: Evaluator-optimizer loop — refine a change until it passes the adversary and a quality bar.
---

$ARGUMENTS

Loop: implement → evaluate → fix, until the quality bar is met or max rounds hit.

Define the bar up front: tests green, `demon` finds no critical/high holes,
typecheck clean.

Each round:
1. Spawn a worker to implement/fix:
   `Task(subagent_type="<role>", prompt="<task + last round's findings>")`.
2. Evaluate hard:
   - `swarm_evaluation_prompt(...)` for a structured rubric, AND
   - `Task(subagent_type="demon", prompt="Break the change in <files>")`.
3. If critical/high holes remain → feed them into the next round's worker prompt.
4. Stop when no critical/high holes AND tests pass, OR after 3 rounds (then escalate).

Record the winning approach:
`hivemind_store(information="<what worked>", tags="iterate,<area>")`.

Coordinator orchestrates only — workers implement, demon evaluates.
