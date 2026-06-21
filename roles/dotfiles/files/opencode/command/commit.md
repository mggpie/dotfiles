---
description: Stage changes, run the quality gate, and create a clean Conventional Commit. Never commits secrets or with --no-verify.
---

$ARGUMENTS

Create a well-formed commit for the current changes. Verify BEFORE committing.

## Steps

1. **Inspect**: `git status`, `git diff`, `git diff --staged`. Understand what
   changed and why before writing anything.
2. **Group**: if the diff mixes unrelated concerns, make separate commits — one
   logical change per commit.
3. **Quality gate** (must pass before committing):
   - Typecheck + lint + the relevant tests.
   - Bug scan the changed files:
     `/opt/homebrew/bin/bash /opt/homebrew/bin/ubs --format=json <files>`
     — any `.totals.critical` blocks the commit.
   - Confirm NO secrets / `.env` / API keys / tokens are staged.
4. **Stage intentionally**: `git add <specific paths>`. Avoid blanket `git add -A`
   unless you've reviewed every change it would include.
5. **Message — Conventional Commits**:
   ```
   <type>(<scope>): <imperative summary ≤ 72 chars>

   <body: WHAT changed and WHY — not how. Wrap ~72 cols.>

   <footer: BREAKING CHANGE: ... / Refs #123 — if any>
   ```
   Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`.
6. **Commit.** Never use `--no-verify` (it bypasses hooks). Never force.

## Rules

- One logical change per commit. No "misc fixes" dumps.
- If the gate fails: fix it or report — do NOT commit broken code.
- Don't commit generated files, secrets, or leftover debug logging.
- Subject line is imperative mood ("add", not "added"/"adds").
