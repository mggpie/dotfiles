---
description: Adversarial review of the current diff — correctness pass + demon break attempt. Read-only.
---

$ARGUMENTS

Review uncommitted / changed work without modifying it.

1. Identify the diff: `git status` + `git diff` (structure only).
2. **Automated bug scan (UBS)** on the changed files:
   `/bin/bash /home/me/.nix-profile/bin/ubs --format=json <files>`
   (parse `.totals.critical` / `.totals.warning`).
3. **Correctness pass**:
   `Task(subagent_type="saas-reviewer", prompt="Review <files>: bugs, regressions, security, missing tests")`.
4. **Adversarial pass**:
   `Task(subagent_type="demon", prompt="Try to BREAK <files>. Holes with repro + fix")`
   (or `swarm_adversarial_review(<files>)`).
5. Merge all three into a single verdict: **approved | needs_changes | blocked**,
   critical/high first, each with a concrete repro and the shortest fix.

Read-only. You report; a worker fixes.
