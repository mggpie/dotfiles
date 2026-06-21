# Security Checklist (OWASP-oriented, universal)

Use during review (the `demon` agent leans on this) and before shipping anything
that touches input, auth, money, or data.

## Input & injection

- [ ] All external input validated/sanitized at the boundary (body, query, headers, params).
- [ ] Parameterized queries / prepared statements only — no string-built SQL.
- [ ] No shell-string interpolation; pass argv arrays, never `sh -c "<user input>"`.
- [ ] Output encoded for its sink (HTML, SQL, shell, JSON, log) to prevent injection/XSS.
- [ ] File paths/uploads validated; no path traversal (`../`), enforced type + size limits.

## AuthN / AuthZ

- [ ] Every protected route checks authentication AND authorization.
- [ ] Object-level checks: the resource belongs to the requesting user/tenant (no IDOR).
- [ ] No privilege escalation via mass-assignment (role/owner not settable by client).
- [ ] Sessions/tokens: short-lived, rotated, revocable; logout actually invalidates.
- [ ] Sensitive actions re-verify identity (step-up auth) where appropriate.

## Secrets & data

- [ ] No secrets in code, logs, error messages, or client bundles.
- [ ] Secrets from env/secret-manager; `.env` not committed.
- [ ] PII minimized, encrypted at rest where required; TLS in transit.
- [ ] Passwords hashed with a slow KDF (argon2/bcrypt), never reversible encryption.

## SSRF / external calls

- [ ] User-supplied URLs are not fetched without an allowlist + scheme/host checks.
- [ ] Outbound requests have timeouts; failures handled, not swallowed.
- [ ] Untrusted data is never deserialized into executable types.

## Rate limiting & abuse

- [ ] Auth + expensive endpoints rate-limited (per IP + per account).
- [ ] Pagination/bulk endpoints have hard caps; no unbounded queries.
- [ ] Webhook signatures verified before processing.

## Concurrency & integrity

- [ ] Writes are idempotent where retried; no double-charge / double-submit.
- [ ] Multi-step state changes are transactional with clean rollback.
- [ ] No race conditions around `await` on shared/global state.

## Errors & logging

- [ ] Errors don't leak stack traces, queries, or internal paths to clients.
- [ ] Logs are structured, scrubbed of secrets/PII, and include a request id.
- [ ] Failure paths tested (timeout, partial response, dependency down).

## Dependencies

- [ ] No known-vulnerable dependencies (audit). Pin + review transitive risk.
- [ ] No unmaintained/typo-squatted packages pulled in.

> Reviewer rule: every flagged issue needs a concrete trigger (repro) and the
> shortest correct fix. Prioritize critical/high over style nits.
