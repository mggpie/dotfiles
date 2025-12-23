# Void Linux Dotfiles

Minimalistyczny setup Void Linux z Sway, Fish i defaultowymi configami.

## Quick Start

```bash
# Na VMce testowej
ssh me@192.168.0.87
cd ~
git clone https://github.com/mggpie/dotfiles.git
cd dotfiles

# Pełna instalacja
doas ansible-playbook -i hosts playbook.yml

# Tylko Fish + Tide
doas ansible-playbook -i hosts playbook.yml --tags fish

# Tylko Sway
doas ansible-playbook -i hosts playbook.yml --tags sway
```

## Tagi

**Base System:**
- `base` - Wszystko base (doas, locale, user, services)
- `doas` - Tylko doas config
- `locale` - Język, timezone, keymap
- `microcode` - Intel/AMD microcode
- `user` - User creation
- `xdg` - XDG directories
- `autologin` - TTY1 autologin
- `tty` - Disable TTY 3-6
- `services` - Enable system services
- `ssh` - SSH config (VM only)

**Shell:**
- `shell` - Fish + wszystkie narzędzia
- `fish` - Tylko Fish
- `tide` - Tide prompt

**Wayland:**
- `wayland` - Wszystko Wayland
- `sway` - Tylko Sway
- `waybar` - Tylko Waybar  
- `foot` - Tylko Foot terminal
- `graphics` - Sterowniki Intel
- `autostart` - Sway autostart on TTY1

**Audio:**
- `audio` - PipeWire + Bluetooth
- `pipewire` - Tylko PipeWire
- `bluetooth` - Tylko Bluetooth

**Apps:**
- `apps` - User applications
- `dev` - Development tools
- `docker` - Docker + compose
- `virt` - QEMU + libvirt

**Nix:**
- `nix` - Nix package manager (VSCode, Wezterm)

**Tweaks:**
- `tweaks` - System optimizations
- `power` - TLP power management
- `updates` - Auto-updates script
- `cron` - Cron jobs (TRIM, updates, maza)
- `maza` - Ad-blocking

## Stack

- **OS**: Void Linux glibc + runit
- **Shell**: Fish + Tide (Rainbow, Transient)
- **WM**: Sway (default config)
- **Bar**: Waybar (default config)
- **Terminal**: Foot (default config)
- **Audio**: PipeWire + Bluetooth
- **Apps**: Firefox, mpv, zathura, qutebrowser, micro, lf, imv
- **Dev**: Python, Lua, Go, Docker, Ansible, Terraform
- **Nix**: VSCode, Wezterm

## Features

- ✅ Defaultowe configi (działają od razu)
- ✅ Granularne tagi (fish, sway, waybar osobno)
- ✅ Auto-login na TTY1
- ✅ Sway autostart
- ✅ Intel microcode auto-detect
- ✅ XDG directories
- ✅ Maza ad-blocking z auto-update
- ✅ Tygodniowe auto-updates (sobota 3:00)
- ✅ Daily TRIM (4:00)
- ✅ SSH tylko na VM
- ✅ TTY 3-6 disabled

## TODO

- [ ] Custom dotfiles (po testach)
- [ ] GRUB performance tweaks
- [ ] Kanshi display management
- [ ] Screenshot tool config
