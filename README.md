# Dotfiles

My configuration files for Void Linux with Sway.

## Structure

```
roles/
├── fish/files/config.fish      # Fish shell config
├── sway/files/config           # Sway window manager
├── waybar/files/               # Waybar status bar
│   ├── config
│   └── style.css
├── foot/files/foot.ini         # Foot terminal
├── mako/files/config           # Mako notifications
├── lf/files/lfrc               # lf file manager
├── mpv/files/mpv.conf          # mpv media player
├── imv/files/config            # imv image viewer
├── zathura/files/zathurarc     # zathura PDF viewer
├── newsboat/files/config       # newsboat RSS reader
└── btop/files/btop.conf        # btop system monitor
```

## Installation

First install Void Linux with LUKS using [void-installer](https://github.com/mggpie/void-installer):

```sh
curl -sL https://raw.githubusercontent.com/mggpie/void-installer/main/bootstrap | sh
```

## Related

- Installer: [github.com/mggpie/void-installer](https://github.com/mggpie/void-installer)
