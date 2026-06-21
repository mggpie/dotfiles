# AI Assistant Context

## Architecture

- Single Ansible role (`roles/dotfiles`) managing a Void Linux (glibc) workstation.
- Sway on Wayland, Fish shell, PipeWire audio, runit init.
- Nix overlay for packages not in Void repos.
- Vault-encrypted secrets in `secrets.yml` (bose MAC, SSH keys, GH token).
- `.vault_pass` and `.become_pass` files required for deployment - never committed.
- `roles/dotfiles/files/` holds all managed config files in one place. Most map to `~/.config/` (e.g. `files/fish/config.fish` -> `~/.config/fish/config.fish`) but some target other locations (e.g. `files/ssh/config` -> `~/.ssh/config`, `files/tlp/tlp.conf` -> `/etc/tlp.conf`).
- Task files live in `roles/dotfiles/tasks/`, one per application (e.g. `fish.yml`, `sway.yml`).

## Rules

### Code style
- All code and comments in English. Comment like a senior engineer - explain *why*, not *what*.
- No AI-sounding prose ("Let's", "Sure!", "Here's", "I'll go ahead and..."). Just do the work.
- **No fancy Unicode.** Use plain `-` (hyphen-minus), not em dashes, en dashes, or arrows. `->` not `→`.
- **Commit messages:** lowercase, imperative, no period, no prefix. Say what changed, not the category. Good: `fix env.fish idempotency, template instead of copy`. Bad: `fix: resolve idempotency issues in environment configuration`. Never use conventional commit prefixes (`feat:`, `fix:`, `docs:`, etc.).

### General workflow
- **Verify, don't guess.** When unsure about system values (app_id, paths, command output), check first with appropriate tools (swaymsg, ls, grep). Don't assume or iterate - get it right on first try.
- **Find root causes.** If a timing/ordering issue exists, fix the mechanism (use polling), not the symptom (adjust sleep values).
- **Deploy after changes.** After editing files, commit/push/deploy without being asked unless user explicitly says not to.

### Code style
- All code and comments in English. Comment like a senior engineer - explain *why*, not *what*.
- No AI-sounding prose ("Let's", "Sure!", "Here's", "I'll go ahead and..."). Just do the work.
- **No fancy Unicode.** Use plain `-` (hyphen-minus), not em dashes, en dashes, or arrows. `->` not `→`.
- **Commit messages:** lowercase, imperative, no period, no prefix. Say what changed, not the category. Good: `fix env.fish idempotency, template instead of copy`. Bad: `fix: resolve idempotency issues in environment configuration`. Never use conventional commit prefixes (`feat:`, `fix:`, `docs:`, etc.).

### Deployment
- After any change: `git add -A && git commit && git push && deploy <tags>`.
- The `deploy` fish function commits, pushes, and runs `ansible-playbook` with the given tags.
- Vault and become passwords are configured in `ansible.cfg` (pointing to `.vault_pass` and `.become_pass` files). Every deploy must include `--vault-password-file` and `--become-password-file` - some tasks require root or decrypted secrets to function.
- Always verify changes actually work after deploying. Don't assume.
- Never deploy `firefox` or `vscode` tags unprompted - those configs include local state (logins, synced settings) that diverges from the repo version intentionally.
- **Package installation:** Can install manually (xbps-install/nix-env) for quick testing, but must add to ansible task file afterwards or remove if not needed. Every production package must be in ansible.

### Secrets
- Never decrypt, print, or edit `secrets.yml` directly.
- Access vault values only through Ansible variables (`bose_mac`, `gh_token`, `ssh_private_key`, `ssh_public_key`).
- Tasks needing secrets must work gracefully without vault (`failed_when: false` on include_vars).

### Templating strategy
- Don't template entire config files for a few variables. Instead, export values as env vars in `fish/conf.d/env.fish` (already a Jinja2 template) and reference `$VAR` in configs.
- Only `env.fish` should be a template. Everything else is a static file deployed via `copy`.

### Variable management
- Don't over-abstract. This is a single-host setup - YAGNI.
- Hardcoded values in fish functions are fine when the value is used in one place.
- `defaults/main.yml` is for values that genuinely vary per host or are reused across multiple task files.

### Testing
- Molecule + Testinfra with Docker (Void Linux image).
- Many tags are skipped in molecule (hardware, GUI, runit) - see `molecule.yml` skip-tags.
- Tests must only verify what molecule actually converges.
- Molecule runs on PRs and manual dispatch only, not on every push. Lint + dry-run runs on every push.

### Tags
- Every task must have a tag matching its filename (e.g., `fish.yml` -> `tags: [fish]`).
- Use `notest` tag for tasks that can't run in Docker (hardware, runit services).
- `tags: [always]` only on vault include and cache update.

### Idempotency
- `env.fish` is excluded from the `conf.d/` copy glob and rendered via the `ansible.builtin.template` module (the file lives in `files/`, not in a separate `templates/` directory).
- Never use `shell`/`command` without `changed_when` or a `creates`/`when` guard.
- `update_cache: false` on all `xbps` tasks - cache is updated once in `main.yml`.

### No standalone shell scripts
- Never create bash/sh/zsh scripts. All scripted behavior belongs in fish functions (`files/fish/functions/`).
- If the function should be launchable from bemenu-run (as a GUI shortcut), also add a thin wrapper to `files/shortcuts/` that calls the fish function: `#!/usr/bin/fish\nfunction_name $argv`.
- Shortcuts are deployed to `~/.local/bin/` and must be executable, one-purpose, and named without extensions.

### Sway
- **Window ordering:** Never use `sleep` to sequence window launches. Poll `swaymsg -t get_tree` for the window to appear before launching the next one.
- **app_id casing matters.** Firefox is `"Firefox"` (capital F), wezterm is `"org.wezfurlong.wezterm"`. Always verify actual app_id values from `swaymsg -t get_tree` - don't guess.
- Known app_ids: `Firefox`, `org.wezfurlong.wezterm`, `notepad` (custom wezterm class).

### Fish shell - NOT bash
This project uses Fish, not bash/zsh. Fish syntax differs fundamentally:
- **No heredocs.** Fish has no `<<EOF`. Use `printf` or multiline strings with `\n`.
- **No `export`.** Use `set -gx VAR value`.
- **No `$()`.** Command substitution is `(command)`.
- **No `[[ ]]`.** Use `test` or `[ ]` (single brackets).
- **No `$(( ))`.** Use `math "1 + 2"`.
- **No `case`/`esac`.** Use `switch`/`case`/`end`.
- **No `function() {}`.** Use `function name ... end`.
- **No `&&`/`||` chaining in older fish.** Prefer `; and`/`; or` for max compat - though `&&`/`||` work in fish 3.0+.
- **No `$?`.** Use `$status`.
- **No `2>&1`.** Use `2>&1` (same) or `&|` to pipe stderr.
- **No arrays with `()`.** Use `set arr val1 val2`, access with `$arr[1]` (1-indexed).
- **No `source ~/.bashrc`.** Use `source ~/.config/fish/config.fish` or `. file`.
- **No `local`.** Variables are function-scoped by default. Use `set -l` to be explicit.
- **String ops.** Use `string` builtin (`string match`, `string replace`, `string split`) instead of `sed`/`grep` for simple cases.
