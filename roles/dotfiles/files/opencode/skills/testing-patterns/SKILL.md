---
name: testing-patterns
description: Add tests to existing or untested code, break dependencies to get code under test, write characterization tests for legacy/unknown behavior, choose unit vs integration vs e2e, and structure assertions. Use when writing or improving tests, getting gnarly code under test, or deciding what to test.
license: MIT
metadata:
  audience: workers
  area: testing
---

## What I do

Help get code under test and keep tests meaningful — especially the hard case:
existing code with no tests.

## Getting untested code under test (Feathers)

1. **Characterization test first.** Before changing legacy code, pin its CURRENT
   behavior with a test (even if that behavior is weird). Assert what it actually
   does, then refactor safely against that net.
2. **Find seams.** A seam is a place to change behavior without editing in place:
   - Inject a collaborator (pass the dependency in instead of `new`-ing it).
   - Extract + override (pull the awkward call into a method, override in a test subclass).
   - Wrap the function and swap the wrapper.
3. **Break dependencies** to remove the reason code "can't be tested":
   - Hard-coded clock → inject a time provider.
   - Network/DB/filesystem → inject a client/interface, fake it in tests.
   - Global/singleton → pass it in, reset between tests.
   - Hidden randomness → inject a seedable RNG.

## What to test (priority for a SaaS)

- **Behavior, not implementation.** Test the observable contract; don't assert on
  private internals (those break on every refactor).
- **The money/security paths first**: auth/authz, billing/webhooks, data writes,
  tenant isolation. A bug here is an incident.
- **Edge & failure cases**: null/empty/zero/huge, timeouts, partial failures,
  duplicate/retry (idempotency), concurrent writes.

## Test shape

- **One behavior per test.** Prefer one logical assertion; name the test after the
  behavior (`rejects_login_when_account_locked`), not the method.
- **Arrange–Act–Assert.** Keep setup obvious; no logic in tests.
- **Deterministic.** No real clock, network, or sleep. Fake time and I/O. A flaky
  test is worse than no test.
- **Layer deliberately**: unit (logic, fast, many) → integration (DB/queue/contract,
  fewer) → e2e (critical user flows only, fewest). Don't e2e what a unit test covers.

## Red → Green → Refactor (for new behavior / bug fixes)

For a bug fix: write a failing test that reproduces it FIRST, then fix. The test
proves the fix and prevents regression. For a feature: a failing test clarifies the
contract before you implement it. This is a strong default, not dogma — skip it
only when the test would be pure ceremony.

## When NOT to over-test

- Don't test the framework, the language, or trivial getters.
- Don't assert on log strings or exact error messages that aren't a contract.
- Don't mock what you own and can use for real cheaply (prefer real over mock).
