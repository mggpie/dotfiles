# Void Linux Dotfiles

Minimalistyczna konfiguracja Void Linux z Sway.

## Struktura

```
.
├── playbook.yml          # Główny playbook (~450 LOC)
├── vars.yml              # Wszystkie zmienne (~100 LOC)
├── files/                # Dotfiles i wszystkie configs
│   ├── colors/palette.yml
│   ├── fish/
│   ├── sway/
│   ├── waybar/
│   ├── foot/
│   └── [mpv, newsboat, zathura, lf, qutebrowser, micro]/
└── bootstrap.sh          # Initial setup script
```

## Quick Start

```bash
# 1. Bootstrap (instalacja git + ansible)
curl -sSL https://raw.githubusercontent.com/mggpie/dotfiles/main/bootstrap.sh | sh

# 2. Clone repo
git clone https://github.com/mggpie/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Pełna instalacja
doas ansible-playbook playbook.yml

# 4. Tylko konkretny komponent
doas ansible-playbook playbook.yml --tags sway
doas ansible-playbook playbook.yml --tags waybar
doas ansible-playbook playbook.yml --tags fish
```

## Tagi

- `base` - System podstawowy (doas, locale, user, services)
- `shell` - Fish + Tide + aliases
- `wayland` - Wszystkie komponenty Wayland
  - `sway` - Tylko config Sway
  - `waybar` - Tylko waybar
  - `foot` - Tylko terminal
- `audio` - PipeWire
- `apps` - Aplikacje użytkownika
- `dev` - Narzędzia developerskie
- `dotfiles` - Symlinki dotfiles
- `tweaks` - Optymalizacje (SSD, cron)

## Dlaczego płaska struktura?

**Stara struktura (roles/)**:
- ~40 katalogów (roles/*/defaults/, handlers/, vars/ - większość pusta)
- ~1000+ LOC rozproszonych po wielu plikach
- Deployment: 80+ tasków nawet dla 1 zmiany w configu

**Nowa struktura (flat)**:
- ~10 katalogów
- ~550 LOC (playbook + vars)
- Deployment: 2-3 taski per komponent
- **65% mniej kodu, 10x szybsze iteracje**
- **Zachowane wszystkie dotfiles** (mpv, newsboat, lf, micro, qutebrowser, zathura)
- **Zachowane tweaki** (maza, xdg, nix, network)

Dla osobistych dotfiles struktura roles to over-engineering. Ansible roles mają sens w dużych projektach zespołowych z wieloma środowiskami.

## Stack

- **OS**: Void Linux (glibc, runit)
- **WM**: Sway
- **Bar**: Waybar
- **Terminal**: Foot
- **Shell**: Fish + Tide
- **Audio**: PipeWire
- **Fonts**: Nerd Fonts, Noto

## License

MIT
