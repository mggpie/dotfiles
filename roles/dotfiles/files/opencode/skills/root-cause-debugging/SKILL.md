---
name: root-cause-debugging
description: Systematically debug a failing test, error, crash, or wrong output by reproducing, isolating, forming hypotheses, and fixing the root cause instead of the symptom. Use when something is broken, flaky, or behaving unexpectedly and the cause is not obvious.
license: MIT
metadata:
  audience: workers
  area: debugging
---

## What I do

Turn "it's broken" into a verified root-cause fix, without guess-and-check churn.

## Method

1. **Reproduce deterministically.** Find the smallest, repeatable trigger. If it's
   flaky, make it reliable first (control time, seed RNG, force ordering, run in a
   loop). You cannot fix what you cannot reproduce.
2. **Read the actual error.** Full message + stack trace, top frame in YOUR code.
   Don't skim. The answer is often literally in the message.
3. **Isolate.** Bisect the surface: comment out halves, `git bisect` across commits,
   binary-search the input. Shrink until the failing surface is tiny.
4. **Form a hypothesis, then test ONE thing.** "If X is the cause, then changing Y
   produces Z." Change one variable at a time. Revert changes that don't help —
   don't pile up speculative edits.
5. **Confirm the mechanism.** Before fixing, be able to explain WHY it breaks
   (the exact line + the wrong value/state). If you can't explain it, you haven't
   found the root cause — you found a coincidence.
6. **Fix the cause, not the symptom.**
   - Symptom fix: `if (x) x.y` to dodge a null.
   - Root fix: figure out why `x` is null and prevent it (or handle it correctly
     at the boundary, with intent).
7. **Prove it.** Add a test that fails before the fix and passes after. Re-run the
   reproduction. Check nothing adjacent regressed.

## Common AI-generated bug classes (check these first)

- **Missing `await`** → fire-and-forget promise, silent failure, race.
- **Null/undefined deref** on an optimistic happy-path chain.
- **Off-by-one / boundary** (empty, first, last, zero, negative).
- **`==` vs `===`, NaN comparisons, `parseInt` without radix.**
- **State mutated during iteration / shared mutable state across `await`.**
- **Wrong scope/closure** capturing a loop variable.
- **Resource never released** (listener, timer, handle, connection).

## Anti-patterns

- ❌ Changing many things at once → you won't know what fixed it (or broke more).
- ❌ "Add a try/catch and move on" → hides the cause, creates the next bug.
- ❌ Trusting a fix you can't explain → it'll come back.
- ❌ Deleting/weakening the failing test to make CI green.

## Leverage past sessions

Before deep-diving, check whether this was solved before:
`cass search "<error signature>" --robot --limit 5` (cross-agent history), and
`hivemind_find(query="<symptom>")` (this swarm's memory). Store the root cause
when you find it so the next agent inherits it.
