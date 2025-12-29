# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ansible-managed configuration for Void Linux with Sway.

## Quick Start

```sh
# Install Void Linux first
xbps-install -Syu xbps curl && curl -sL https://mggpie.github.io/void-installer/bootstrap.sh | sh

# After reboot, clone and run
git clone https://github.com/mggpie/dotfiles.git
cd dotfiles
doas xbps-install -S ansible
ansible-playbook playbook.yml
```

## Usage

```sh
# Full setup
ansible-playbook playbook.yml

# Only specific tags
ansible-playbook playbook.yml --tags sway
ansible-playbook playbook.yml --tags fish,foot

# List available tags
ansible-playbook playbook.yml --list-tags
```

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
| `intel-graphics` | Mesa, Vulkan, VA-API drivers |
| `tlp` | Power management |
| `virtualization` | QEMU/KVM/libvirt |
| `fonts` | Inter, Intel One Mono, Nerd Fonts |

### Development
| Tag | Description |
|-----|-------------|
| `dev` | Python, Lua, Go, Docker, Terraform, Ansible |
| `git` | Git configuration |
| `vscode` | Visual Studio Code |

### Desktop Environment
| Tag | Description |
|-----|-------------|
| `sway` | Sway window manager |
| `waybar` | Status bar |
| `kanshi` | Dynamic output configuration |
| `bemenu` | Application launcher |
| `mako` | Notifications |
| `pipewire` | Audio |

### Terminal
| Tag | Description |
|-----|-------------|
| `fish` | Fish shell |
| `foot` | Foot terminal |
| `wezterm` | WezTerm terminal |

### CLI Tools
| Tag | Description |
|-----|-------------|
| `lf` | File manager |
| `bat` | Cat with syntax highlighting |
| `ripgrep` | Fast grep |
| `fastfetch` | System info |
| `htop` | Process monitor |

### Applications
| Tag | Description |
|-----|-------------|
| `firefox` | Web browser |
| `pcmanfm` | GUI file manager |
| `mpv` | Media player |
| `imv` | Image viewer |
| `zathura` | PDF viewer |
| `newsboat` | RSS reader |

## Secrets

```sh
cp secrets.yml.example secrets.yml
ansible-vault encrypt secrets.yml
ansible-playbook playbook.yml --ask-vault-pass
```

## License

[MIT](LICENSE)

## Related

- [void-installer](https://github.com/mggpie/void-installer) - Void Linux installer with LUKS
