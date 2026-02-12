# AI Assistant Context

## Architecture

- Single Ansible role (`roles/dotfiles`) managing a Void Linux (glibc) workstation.
- Sway on Wayland, Fish shell, PipeWire audio, runit init.
- Nix overlay for packages not in Void repos.
- Vault-encrypted secrets in `secrets.yml` (bose MAC, SSH keys, GH token).
- `.vault_pass` and `.become_pass` files required for deployment — never committed.

## Rules

### Code style
- All code and comments in English. Comment like a senior engineer — explain *why*, not *what*.
- No AI-sounding prose ("Let's", "Sure!", "Here's", "I'll go ahead and..."). Just do the work.

### Deployment
- After any change: `git add -A && git commit && git push && deploy <tags>`.
- The `deploy` fish function handles `ansible-playbook` with vault + become.
- Always verify changes actually work after deploying. Don't assume.
- Never deploy `firefox` or `vscode` tags unprompted — those configs include local state (logins, synced settings) that diverges from the repo version intentionally.

### Templating strategy
- Don't template entire config files for a few variables. Instead, export values as env vars in `fish/conf.d/env.fish` (already a Jinja2 template) and reference `$VAR` in configs.
- Only `env.fish` should be a template. Everything else is a static file deployed via `copy`.

### Variable management
- Don't over-abstract. This is a single-host setup — YAGNI.
- Hardcoded values in fish functions are fine when the value is used in one place.
- `defaults/main.yml` is for values that genuinely vary per host or are reused across multiple task files.

### Testing
- Molecule + Testinfra with Docker (Void Linux image).
- Many tags are skipped in molecule (hardware, GUI, runit) — see `molecule.yml` skip-tags.
- Tests must only verify what molecule actually converges.
- Molecule runs on PRs and manual dispatch only, not on every push. Lint + dry-run runs on every push.

### Tags
- Every task must have a tag matching its filename (e.g., `fish.yml` → `tags: [fish]`).
- Use `notest` tag for tasks that can't run in Docker (hardware, runit services).
- `tags: [always]` only on vault include and cache update.

### Idempotency
- `env.fish` is excluded from the `conf.d/` copy glob and rendered separately via `template`.
- Never use `shell`/`command` without `changed_when` or a `creates`/`when` guard.
- `update_cache: false` on all `xbps` tasks — cache is updated once in `main.yml`.
