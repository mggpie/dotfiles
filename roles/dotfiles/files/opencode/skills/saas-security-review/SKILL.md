---
name: saas-security-review
description: Deep security review of SaaS changes touching authentication, authorization, sessions, OAuth, billing/payments, Stripe webhooks, multitenancy, rate limiting, or database writes. Use when writing or reviewing auth/billing/db code, or when the reviewer/demon needs an OWASP-oriented playbook for security-critical paths.
license: MIT
metadata:
  audience: reviewers
  area: security
---

## What I do

A focused, exploit-minded review playbook for the paths where a SaaS bug becomes
an incident: auth, money, and tenant data. Each item is **attack → check → fix**.
Prioritize critical/high; show a concrete trigger, not a vague worry.

## 1. Authentication

- **Attack**: forged/replayed token, algorithm confusion (`alg: none`), missing
  signature verification, long-lived tokens that can't be revoked.
  **Check**: signature verified with the right key; issuer + audience bound;
  expiry enforced; refresh tokens rotate and old ones are invalidated.
  **Fix**: verify before trust; short access TTL + rotating refresh; server-side
  revocation list / token version.
- **Attack**: credential stuffing, brute force on login/reset/OTP.
  **Check**: rate limit per IP **and** per account; lockout/backoff; generic
  error messages (don't reveal which factor was wrong).
  **Fix**: slow KDF (argon2/bcrypt), rate limit, constant-time compare for
  tokens/secrets.

## 2. Authorization (the #1 SaaS bug class)

- **Attack — IDOR / BOLA**: change an id in the URL/body and access another
  tenant's or user's object.
  **Check**: EVERY data access is scoped to the authenticated principal +
  tenant. There is no endpoint that trusts a client-supplied `tenant_id`/`user_id`
  for ownership.
  **Fix**: derive tenant/user from the session; enforce ownership at a single
  layer (repository / row-level security), not ad hoc per handler.
- **Attack — privilege escalation via mass assignment**: client sets `role`,
  `is_admin`, `owner_id`, `tenant_id` through a bulk update.
  **Check**: write DTOs allow-list fields; sensitive fields are never client-settable.
  **Fix**: explicit field allow-list on writes; reject unknown fields where it matters.
- **Attack — function-level auth bypass**: admin/internal route reachable without
  the right role.
  **Check**: every protected route checks authN **and** authZ (role/permission).

## 3. Multitenancy & data isolation

- **Attack**: a missing `WHERE tenant_id = ?` leaks or cross-writes data.
  **Check**: tenant scoping is enforced centrally (RLS or a guarded repository),
  not remembered by each query author. Background jobs and admin tools are scoped too.
  **Fix**: row-level security or a single data layer that injects the tenant
  filter; tests that prove tenant A can't read/write tenant B.

## 4. Billing / payments (Stripe et al.)

- **Attack — forged webhook**: attacker POSTs a fake `payment_succeeded` to
  unlock paid features.
  **Check**: webhook signature verified BEFORE parsing the body; events deduped
  by event id; entitlements computed server-side from the provider's truth, never
  from client state.
  **Fix**: verify signature, dedupe, reconcile periodically against the provider.
- **Attack — replay / double-processing**: same event/job runs twice → double
  credit or double charge.
  **Check**: handlers are idempotent (idempotency key or event-id ledger).
- **Attack — money math**: floats, rounding, negative quantities, currency mixups.
  **Check**: integer minor units; quantities validated ≥ 0; currency explicit.
- **Check edge states**: trial end, failed payment/dunning, proration,
  cancellation, refund, plan downgrade — each gated correctly.

## 5. Injection & input (OWASP)

- **SQL/NoSQL**: parameterized queries only; no string-built queries with request data.
- **Command**: argv arrays, never `sh -c "<user input>"`.
- **SSRF**: user-supplied URLs only fetched against an allow-list + scheme/host checks.
- **Deserialization**: never deserialize untrusted input into executable types.
- **XSS** (if any HTML/templating): output encoded for its sink; no raw `innerHTML`
  with user data; templating auto-escape on.

## 6. Secrets, transport, logging

- No secrets in code, logs, error responses, or client bundles; from env/secret manager.
- TLS in transit; sensitive data encrypted at rest where required.
- Errors returned to clients don't leak stack traces, queries, or internal paths.
- Logs scrubbed of secrets/PII; include a request id for tracing.

## 7. Concurrency & integrity

- Retried writes are idempotent (no double-submit/double-charge).
- Multi-step state changes are transactional with clean rollback.
- No race conditions around `await` on shared/global state.

## Output

```json
{
  "verdict": "approved|needs_changes|blocked",
  "findings": [
    {
      "severity": "critical|high|medium|low",
      "area": "authn|authz|tenancy|billing|injection|secrets|concurrency",
      "file": "src/...",
      "line": 0,
      "attack": "concrete exploit / trigger",
      "fix": "shortest correct fix"
    }
  ],
  "summary": "one line"
}
```

Any critical/high in authz, tenancy, or billing → **blocked** until fixed.
Cross-check with `@knowledge/security-checklist.md` (the always-on list) and run
UBS on the changed files for the mechanical pass.
