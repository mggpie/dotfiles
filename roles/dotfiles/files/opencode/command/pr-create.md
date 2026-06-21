---
description: Push the current branch and open a pull request with a structured description. Uses gh if installed, otherwise prints a compare URL. Never force-pushes shared history.
---

$ARGUMENTS

Open a PR for the current branch. No force pushes, no PRs that fail the gate.

## Steps

1. **Safety**: confirm you are NOT on the default branch (`main`/`master`).
   If you are, stop and ask to create a feature branch first
   (`git switch -c <type>/<short-name>`).
2. **Sync**: is `git status` clean and are there commits ahead of the base?
   If uncommitted changes remain, run `/commit` first.
3. **Final gate**: typecheck + lint + full test suite +
   `/opt/homebrew/bin/bash /opt/homebrew/bin/ubs --format=json .` (no criticals).
4. **Push**: `git push -u origin <branch>`.
   Never `--force`. Use `--force-with-lease` only if you understand the history
   and the branch is yours.
5. **Create the PR**:
   - If `gh` is installed: `gh pr create --title "<title>" --body "<body below>"`
     (or `gh pr create --fill` to derive from commits).
   - If `gh` is NOT installed: print the compare URL for the user to open:
     `https://<host>/<owner>/<repo>/compare/<base>...<branch>?expand=1`
     (derive host/owner/repo from `git remote get-url origin`).
6. **PR body structure**:
   - **Summary** — what & why, one short paragraph.
   - **Changes** — bullet list of the meaningful changes.
   - **Test plan** — how it was verified (tests run, UBS clean, manual checks).
   - **Risk / rollback** — blast radius + how to revert.

## Rules

- Never open a PR that fails the quality gate.
- Title follows Conventional Commit style; body is factual, no fluff.
- PR from a feature branch — don't push directly to a shared branch.
- `gh` is optional. Installing it (`brew install gh && gh auth login`) makes this
  fully automatic; without it you still get a ready-to-click compare URL.
