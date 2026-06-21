# SaaS Patterns (universal)

Framework-agnostic patterns for building and maintaining a SaaS over the long term.
Load when implementing backend, billing, auth, or data work.

## Multitenancy

- Pick the isolation model deliberately: shared-schema + `tenant_id` (cheap, common),
  schema-per-tenant, or db-per-tenant (strong isolation, costly). Document the choice.
- For shared-schema: EVERY query is scoped by `tenant_id`. Enforce at a single
  layer (repository / row-level security), never ad hoc per query.
- Never trust a `tenant_id` from the client. Derive it from the authenticated session.
- Add a composite index leading with `tenant_id` on hot tables.

## Idempotency

- Any externally-triggered write (API POST, webhook, job retry) must be idempotent.
- Accept an `Idempotency-Key`; persist the first result keyed by it; return the
  stored result on replay. Expire keys after a bounded window.
- Background jobs: design for at-least-once delivery → make handlers idempotent,
  not "exactly once" (which doesn't exist in distributed systems).

## Webhooks (inbound, e.g. Stripe)

- Verify the signature BEFORE parsing the body. Reject on mismatch.
- Respond 2xx fast; do the real work async. Don't block the webhook on slow I/O.
- Handle out-of-order and duplicate events (use the event id for dedupe).
- Reconcile periodically against the source of truth — webhooks can be missed.

## Billing

- Treat the payment provider (e.g. Stripe) as the source of truth for subscription
  state; mirror it locally, reconcile via webhooks + a periodic sync.
- Never compute entitlements from client state. Gate features server-side on the
  mirrored subscription/plan.
- Handle: trial end, dunning/failed payment, proration, cancellation, refunds.
- Store money as integer minor units (cents). Never float.

## Auth & sessions

- Prefer short-lived access tokens + rotating refresh tokens. Revocation must work.
- Authorization ≠ authentication. Check BOTH on every protected resource (and check
  the resource belongs to the tenant/user — guard against IDOR).
- Rate-limit auth endpoints (login, reset, OTP) by IP + account.
- Hash passwords with a slow KDF (argon2/bcrypt). Never log secrets or tokens.

## Background jobs & queues

- Make jobs retryable + idempotent. Cap retries; route exhausted jobs to a DLQ.
- Keep jobs small and single-purpose. Pass ids, not large payloads.
- Make long jobs resumable via checkpoints; don't redo completed work on retry.

## Data & migrations

- Migrations are forward-only and reversible-in-practice (expand → migrate → contract).
- Never drop/rename a column in the same deploy that stops writing it. Two-phase it.
- Wrap multi-statement data changes in a transaction; ensure clean rollback.
- Backfills run in batches, off the hot path, idempotently.

## APIs

- Version from day one (`/v1`). Additive changes only within a version.
- Validate input at the boundary; reject unknown fields where it matters.
- Paginate list endpoints (cursor > offset for large/changing sets).
- Return stable error shapes with a machine-readable `code`.

## Observability

- Structured logs with `tenant_id` + `request_id`; never log PII/secrets.
- Emit metrics for the money paths (signups, payments, webhook lag, job failures).
- Alert on symptoms users feel (error rate, latency), not just host metrics.
