# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Configuration files for Void Linux with Sway.

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

# Only specific app
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
├── inventory/localhost.yml      # variables
├── secrets.yml.example          # template for secrets
└── roles/dotfiles/
    ├── tasks/
    │   ├── main.yml             # imports all
    │   ├── base.yml             # system config
    │   ├── fish.yml
    │   ├── sway.yml
    │   └── ...
    └── files/
        ├── fish/config.fish
        ├── sway/config
        └── ...
```

## Tags

| Tag | Description |
|-----|-------------|
| `base` | System: locale, doas, services |
| `fish` | Fish shell |
| `sway` | Sway window manager |
| `waybar` | Status bar |
| `foot` | Terminal |
| `mako` | Notifications |
| `pipewire` | Audio |
| `lf` | File manager |
| `mpv` | Media player |
| `imv` | Image viewer |
| `zathura` | PDF viewer |
| `newsboat` | RSS reader |
| `htop` | System monitor |
| `apps` | Extra applications |

## Secrets

```sh
# Create secrets file from example
cp secrets.yml.example secrets.yml
ansible-vault encrypt secrets.yml

# Edit secrets
ansible-vault edit secrets.yml

# Run with secrets
ansible-playbook playbook.yml --ask-vault-pass
```

## License

[MIT](LICENSE)

## Related

- [void-installer](https://github.com/mggpie/void-installer) - Void Linux installer with LUKS
