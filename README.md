# Void Linux Dotfiles & Automation

Kompletna automatyzacja instalacji i konfiguracji Void Linux z LUKS encryption, zarządzana przez Ansible.

## 🎯 Przegląd

Repozytorium składa się z dwóch faz:

### Faza 1: Instalacja systemu (`installer/`)
- Automatyczne partycjonowanie z LUKS2 encryption
- Instalacja bazowego systemu Void Linux (glibc)
- Konfiguracja GRUB z obsługą szyfrowania
- Tworzenie użytkownika

### Faza 2: Konfiguracja (`roles/`)
- Ansible playbooki do instalacji pakietów
- Symlinki do dotfiles
- Konfiguracja systemu (doas, PipeWire, River WM, etc.)

## ⚙️ Co zostanie skonfigurowane

| Komponent | Technologia |
|-----------|-------------|
| **Init** | runit |
| **Shell** | Fish + Tide prompt |
| **WM** | River (Wayland) |
| **Terminal** | Foot + Intel One Mono |
| **Audio** | PipeWire + Bluetooth |
| **Packages** | xbps + Nix (stable) + Flatpak |
| **Privilege** | doas (passwordless) |
| **Network** | wpa_supplicant |
| **Dev** | Python, Go, Lua, Docker, KVM/QEMU |

## 🚀 Szybki start

### Z Void Linux Live ISO

```bash
xbps-install -Sy curl
curl -sL https://raw.githubusercontent.com/me/dotfiles/main/installer/bootstrap | sh
```

### Po pierwszym uruchomieniu

```bash
curl -sL https://raw.githubusercontent.com/me/dotfiles/main/bootstrap.sh | sh
```

## 📁 Struktura repozytorium

```
├── installer/              # Faza 1: Instalacja systemu
│   ├── bootstrap          # Skrypt pobierający instalator
│   ├── install-void.sh    # Główny skrypt instalacyjny
│   ├── config.sh          # Konfiguracja instalacji
│   └── index.html         # Strona z instrukcjami
│
├── roles/                  # Faza 2: Ansible roles
│   ├── base/              # Repozytoria, doas, użytkownicy, pakiety
│   ├── shell/             # Fish + Tide + aliasy
│   ├── wayland/           # River, foot, yambar, kanshi
│   ├── audio/             # PipeWire, Bluetooth
│   ├── nix/               # Nix package manager, Flatpak
│   ├── dev/               # Narzędzia deweloperskie
│   ├── apps/              # Aplikacje użytkownika
│   ├── dotfiles/          # Symlinki do konfiguracji
│   └── tweaks/            # GRUB, SSD, power management
│
├── group_vars/             # Zmienne Ansible
│   └── all/
│       ├── main.yml       # Główne zmienne
│       └── vault.yml      # Sekretne zmienne (encrypted)
│
├── files/
│   └── colors/
│       └── palette.yml    # Paleta kolorów (Catppuccin Mocha)
│
├── playbook.yml            # Główny playbook
├── hosts                   # Inventory
├── ansible.cfg             # Konfiguracja Ansible
└── bootstrap.sh            # Skrypt post-instalacyjny
```

## 🔧 Konfiguracja

### Przed instalacją systemu

Edytuj `installer/config.sh`:

```bash
TARGET_DISK="/dev/nvme0n1"   # Dysk docelowy
HOSTNAME="here"              # Nazwa hosta
USERNAME="me"                # Nazwa użytkownika
TIMEZONE="Europe/Warsaw"     # Strefa czasowa
KEYMAP="pl"                  # Układ klawiatury
```

### Przed konfiguracją Ansible

1. Skopiuj przykładowy vault:
   ```bash
   cp group_vars/all/vault.yml.example group_vars/all/vault.yml
   ```

2. Zaszyfruj vault:
   ```bash
   ansible-vault encrypt group_vars/all/vault.yml
   ```

3. Edytuj zmienne w `group_vars/all/main.yml`

## 🎨 Paleta kolorów

Używamy zmodyfikowanego schematu Catppuccin Mocha:

| Kolor | Hex | Zastosowanie |
|-------|-----|--------------|
| Background | `#1e1e2e` | Tła |
| Foreground | `#cdd6f4` | Tekst |
| Blue | `#89b4fa` | Akcenty, linki |
| Green | `#a6e3a1` | Sukces, git add |
| Red | `#f38ba8` | Błędy, git remove |
| Yellow | `#f9e2af` | Ostrzeżenia |
| Mauve | `#cba6f7` | Specjalne |

## 🖥️ Hardware

Skonfigurowane dla:
- **CPU:** Intel i5-11600
- **GPU:** Intel UHD 750
- **Motherboard:** ASUS ROG STRIX B560-I GAMING WIFI
- **RAM:** 32GB DDR4
- **Storage:** NVMe SSD (LUKS encrypted)
- **Monitors:**
  - DP-1: IVM PL3493WQ 3440x1440@75Hz (scale 0.9)
  - HDMI-A-2: VESTEL TV 4K@60Hz (scale 2.0)

## 📦 Uruchamianie playbooka

```bash
# Cały playbook
ansible-playbook playbook.yml --ask-vault-pass

# Tylko wybrane role
ansible-playbook playbook.yml --tags "shell,wayland"

# Bez restartu usług
ansible-playbook playbook.yml --skip-tags "restart"

# Dry run
ansible-playbook playbook.yml --check --diff
```

## 🔐 Ansible Vault

Sekretne dane (hasła WiFi, tokeny) przechowywane są w zaszyfrowanym vault:

```bash
# Edycja vault
ansible-vault edit group_vars/all/vault.yml

# Zmiana hasła
ansible-vault rekey group_vars/all/vault.yml
```

## ✅ TODO

- [ ] Profile-sync-daemon dla Firefox
- [ ] OpenRGB/AURA LED control dla płyty ASUS
- [ ] Settings TUI app
- [ ] Automatyczne wykrywanie hardware

## ⚠️ Ostrzeżenia

1. **Faza 1 formatuje dysk!** Zrób backup przed instalacją.
2. **Zapamiętaj hasło LUKS!** Bez niego nie odszyfrujesz dysku.
3. **doas jest bez hasła** - nie używaj na współdzielonym systemie.

## 📄 Licencja

MIT

---

🚀 *Void Linux + Ansible = ❤️*
