# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ansible-managed configuration for Void Linux with Sway.

## Quick Start

```sh
# Install Void Linux first
xbps-install -Syu xbps curl && curl -sL https://mggpie.github.io/void-installer/bootstrap.sh | sh

# After reboot, clone and configure
git clone https://github.com/mggpie/dotfiles.git
cd dotfiles

# Edit password files (placeholders included in repo)
micro .vault_pass      # Your ansible-vault password
micro .become_pass     # Your root/sudo password

# Run bootstrap
./bootstrap.sh
```

## Usage

```sh
# Re-run playbook (passwords auto-loaded from files)
ansible-playbook playbook.yml

# Only specific tags
ansible-playbook playbook.yml --tags sway
ansible-playbook playbook.yml --tags fish,foot

# List available tags
ansible-playbook playbook.yml --list-tags
```

## Password Files

- `.vault_pass` - Ansible vault password (gitignored after first edit)
- `.become_pass` - Root/sudo/doas password (gitignored after first edit)
- Both files are tracked with placeholder values but changes are ignored by git

## Structure

```
dotfiles/
├── playbook.yml
├── ansible.cfg
├── inventory/localhost.yml
└── roles/dotfiles/
    ├── tasks/
    │   ├── main.yml
    │   ├── base.yml
    │   ├── sway.yml
    │   └── ...
    └── files/
        ├── sway/config
        ├── fish/config.fish
        └── ...
```

### Design Principles

- **1 task file = 1 application = 1 config**
- **Execution order:** base → drivers → dev → desktop → terminal → cli → apps
- **Tags on everything** for selective runs

## Tags

### System
| Tag | Description |
|-----|-------------|
| `base` | Locale, doas, services, Nix |
| `grub` | GRUB bootloader configuration |
| `intel-graphics` | Mesa, Vulkan, VA-API drivers |
| `tlp` | Power management |
| `virtualization` | QEMU/KVM/libvirt |
| `fonts` | Inter, Intel One Mono, Nerd Fonts |
| `theme` | GTK/Qt theming |
| `bluetooth` | Bluetooth configuration |

### Development
| Tag | Description |
|-----|-------------|
| `dev` | Python, Lua, Go, Docker, Terraform, Ansible |
| `git` | Git configuration + git-filter-repo |
| `gh` | GitHub CLI |
| `ssh` | SSH configuration |
| `vscode` | Visual Studio Code |

### Desktop Environment
| Tag | Description |
|-----|-------------|
| `sway` | Sway window manager |
| `waybar` | Status bar |
| `kanshi` | Dynamic output configuration |
| `bemenu` | Application launcher |
| `mako` | Notifications |
| `pipewire` | Audio (PipeWire/WirePlumber) |
| `shortcuts` | System shortcuts in ~/.local/bin |

### Terminal
| Tag | Description |
|-----|-------------|
| `fish` | Fish shell |
| `foot` | Foot terminal |
| `wezterm` | WezTerm terminal |
| `fastfetch` | System info tool |

### CLI Tools
| Tag | Description |
|-----|-------------|
| `micro` | Terminal text editor |
| `lf` | Terminal file manager |
| `htop` | Process viewer |
| `maza` | Ad-blocking hosts file |

### Applications
| Tag | Description |
|-----|-------------|
| `firefox` | Web browser |
| `pcmanfm` | GUI file manager (PCManFM) |
| `thunar` | GUI file manager (Thunar) |
| `mpv` | Media player |
| `imv` | Image viewer |
| `zathura` | PDF viewer |
| `newsboat` | RSS reader |
| `qbittorrent` | Torrent client |
| `telegram` | Telegram messenger |
| `obsidian` | Note-taking app |
| `krita` | Digital painting |
| `vlc` | Media player |
| `para` | PARA workspace setup |

## System Maintenance

Automated weekly maintenance with `upall` function (runs automatically via cron on boot if ≥7 days passed):

```sh
upall           # Manual run: SSD trim, package updates, cache cleanup
upall status    # Check last run status
upall logs      # View full log
```

Features:
- 9-step maintenance: fstrim, xbps updates, kernel cleanup, maza ad-blocking, Nix updates, trash cleanup
- Automatic weekly execution via `@reboot` cron job
- Error tracking with file report in `~/Downloads/upall-error.txt`
- Log saved to `~/.local/state/upall.log`

## Secrets

Vault is **only required** for these tags:
- `ssh` - SSH keys
- `gh` - GitHub CLI authentication
- `bluetooth` / `fish` - Bose QC45 Bluetooth MAC address

All other tags work without vault. Passwords are auto-loaded from `.vault_pass` and `.become_pass` files.

Setup:

```sh
cp secrets.yml.example secrets.yml
ansible-vault encrypt secrets.yml
```

## License

[MIT](LICENSE)

## Related

- [void-installer](https://github.com/mggpie/void-installer) - Void Linux installer with LUKS
