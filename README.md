# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

My configuration files for Void Linux with Sway window manager.

## Overview

Minimal, keyboard-driven setup using Wayland-native applications.

| Component | Application |
|-----------|-------------|
| Shell | Fish + Tide prompt |
| Window Manager | Sway |
| Status Bar | Waybar |
| Terminal | Foot |
| Notifications | Mako |
| File Manager | lf |
| Media Player | mpv |
| Image Viewer | imv |
| PDF Viewer | Zathura |
| RSS Reader | Newsboat |
| System Monitor | btop |

## Structure

```
roles/
├── fish/files/config.fish      # Fish shell
├── sway/files/config           # Sway window manager
├── waybar/files/               # Waybar status bar
│   ├── config
│   └── style.css
├── foot/files/foot.ini         # Foot terminal
├── mako/files/config           # Mako notifications
├── lf/files/lfrc               # lf file manager
├── mpv/files/mpv.conf          # mpv media player
├── imv/files/config            # imv image viewer
├── zathura/files/zathurarc     # Zathura PDF viewer
├── newsboat/files/config       # Newsboat RSS reader
└── btop/files/btop.conf        # btop system monitor
```

## Installation

### 1. Install Void Linux

Use [void-installer](https://github.com/mggpie/void-installer) for automated installation with LUKS encryption:

```sh
curl -sL https://mggpie.github.io/void-installer/bootstrap.sh | sh
```

### 2. Apply configurations

After first boot, clone and apply:

```sh
git clone https://github.com/mggpie/dotfiles.git
cd dotfiles
# Apply configs manually or with your preferred method
```

## Screenshots

*Coming soon*

## License

[MIT](LICENSE)

## Related

- [void-installer](https://github.com/mggpie/void-installer) - Void Linux installer with LUKS encryption
