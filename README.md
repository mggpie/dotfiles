# Void Linux Automated Installation

This repository contains scripts for automated installation and configuration of Void Linux with full disk encryption (LUKS).

## Overview

The installation is split into two phases:

1. **Phase 1: Base System Installation** (from live ISO)
   - Automated partitioning with LUKS encryption
   - Base system installation
   - GRUB bootloader configuration
   - User creation

2. **Phase 2: Post-Installation Configuration** (after first boot)
   - Ansible playbooks for package installation
   - Dotfiles deployment
   - System configuration

## Prerequisites

- Void Linux live ISO (glibc variant)
- USB drive or VM with the ISO
- Internet connection
- Your target disk backed up (will be erased!)

## Quick Start

### 1. Boot into Void Linux Live ISO

Boot from the Void Linux live ISO and log in as root (password: `voidlinux`).

### 2. Get Internet Connection

```bash
# For ethernet (usually works automatically)
dhcpcd

# For WiFi (if needed during install)
# Configure manually or wait for post-install
```

### 3. Install and Run

**Quick installation (recommended):**

```bash
curl -sSL mggpie.github.io/dotfiles/install-void.sh -o /tmp/i.sh && chmod +x /tmp/i.sh && /tmp/i.sh
```

**Or visit the installation page:**

https://mggpie.github.io/dotfiles

Or with manual download:

```bash
curl -sSL raw.githubusercontent.com/mggpie/dotfiles/main/install-void.sh -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh
```

This will use default configuration:
- **Disk:** `/dev/nvme0n1` (will be auto-detected)
- **Hostname:** `here`
- **Username:** `me`
- **Timezone:** `Europe/Warsaw`
- **Locale:** `en_US.UTF-8`
- **Keyboard:** `pl`

To customize, download and edit `config.sh` first:

```bash
# Create working directory
mkdir -p /tmp/void-install
cd /tmp/void-install

# Download installation scripts
curl -O https://raw.githubusercontent.com/mggpie/dotfiles/main/install-void.sh
curl -O https://raw.githubusercontent.com/mggpie/dotfiles/main/config.sh

# Make scripts executable
chmod +x install-void.sh config.sh

# Edit config if needed
vi config.sh

# Run installation
./install-void.sh
```

### 4. Configure Installation (Optional)

```bash
vim config.sh
```

Key configuration options:
- `TARGET_DISK`: Your target disk (default: `/dev/nvme0n1`)
- `HOSTNAME`: Computer name (default: `here`)
- `USERNAME`: Your username (default: `me`)
- `TIMEZONE`: Timezone (default: `Europe/Warsaw`)
- `LOCALE`: System locale (default: `en_US.UTF-8`)
- `KEYMAP`: Keyboard layout (default: `pl`)

**⚠️ WARNING:** The installation will ERASE all data on `TARGET_DISK`!

### 5. Run the Installation

```bash
chmod +x install-void.sh
./install-void.sh
```

The script will:
1. Confirm the target disk
2. Partition the disk (EFI + Boot + Encrypted Root)
3. Prompt for LUKS encryption passphrase (⚠️ **Remember this!**)
4. Install the base system
5. Configure GRUB with encryption support
6. Prompt for root password
5. Prompt for user password
6. Complete installation

### 6. Reboot

After installation completes:

```bash
reboot
```

Remove the installation media and boot into your new system.

### 7. Post-Installation Setup

After first boot and login:

```bash
# Run the post-installation helper script
./post-install.sh
```

This will:
1. Update the system
2. Install Ansible
2. Clone your dotfiles repository
3. Prepare for Ansible playbook execution

### 8. Configure Ansible Vault

Store sensitive data (WiFi passwords, API keys, etc.) in an Ansible vault:

```bash
cd ~/dotfiles
ansible-vault create group_vars/all/vault.yml
```

Add your secrets:

```yaml
---
# WiFi Configuration
wifi_ssid: "YourNetworkName"
wifi_password: "YourWiFiPassword"

# Other secrets...
```

### 9. Run Ansible Playbook

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

This will install and configure:
- Desktop environment
- Applications
- Development tools
- Dotfiles
- System tweaks

## Configuration Details

### Disk Layout

The installation creates the following partition scheme:

```
/dev/nvme0n1
├── nvme0n1p1  512MB   EFI System Partition (FAT32)
├── nvme0n1p2  1GB     Boot Partition (ext4)
└── nvme0n1p3  Rest    Encrypted Root Partition (LUKS → ext4)
    └── voidcrypt      Unlocked LUKS container
```

### Encryption

- **Type:** LUKS2
- **Scope:** Root partition only (boot is unencrypted for GRUB compatibility)
- **Passphrase:** Set during installation
- **Unlock:** Required at every boot

### Services

Enabled by default:
- `dhcpcd` - DHCP client for networking
- `sshd` - SSH daemon (optional, if configured)

### Swap

- **Type:** Swap file (on encrypted partition)
- **Size:** Configurable (default: auto = RAM size)
- **Location:** `/swapfile`

For desktop systems, you may want to reduce swap size or disable it entirely in `config.sh`.

## File Structure

```
dotfiles/
├── install-void.sh      # Main installation script
├── config.sh            # Configuration file
├── README.md            # This file
├── playbook.yml         # Ansible playbook (to be created)
├── group_vars/          # Ansible variables (to be created)
└── roles/               # Ansible roles (to be created)
```

## Troubleshooting

### Boot Issues

If the system doesn't boot:

1. **LUKS passphrase prompt not appearing:**
   - Check GRUB configuration: `/etc/default/grub`
   - Ensure `GRUB_ENABLE_CRYPTODISK=y` is set
   - Regenerate GRUB config: `grub-mkconfig -o /boot/grub/grub.cfg`

2. **Kernel panic or initramfs issues:**
   - Regenerate initramfs: `xbps-reconfigure -f linux`
   - Check `/etc/crypttab` for correct UUID
   - Verify `/etc/dracut.conf.d/10-crypt.conf` includes crypto modules

3. **Wrong keyboard layout at LUKS prompt:**
   - The early boot uses US layout
   - Plan your passphrase accordingly

### Network Issues

```bash
# Check network interfaces
ip link

# Start dhcpcd manually
sudo sv start dhcpcd

# Or use NetworkManager (if preferred)
sudo xbps-install NetworkManager
sudo ln -sf /etc/sv/NetworkManager /var/service/
```

### System Updates

```bash
# Update package database
sudo xbps-install -S

# Update all packages
sudo xbps-install -u

# Remove orphaned packages
sudo xbps-remove -o
```

## Customization

### Changing Installation Parameters

Edit `config.sh` before running the installation script. Key options:

- **Swap size:** Set `SWAP_SIZE="8G"` or `SWAP_SIZE="no"` to disable
- **Filesystem:** Change `FILESYSTEM="btrfs"` for Btrfs (requires additional setup)
- **Network:** Change `NETWORK_MANAGER="NetworkManager"` for GUI network management

### Adding Packages to Base Install

Edit `install-void.sh` and modify the `xbps-install` command in Step 5 to add packages.

**Note:** It's recommended to keep the base installation minimal and install additional packages via Ansible.

## Security Considerations

1. **LUKS Passphrase:** Use a strong passphrase. It's the only protection for your encrypted disk.
2. **Root Password:** Set a strong root password during installation.
3. **SSH:** If enabling SSH, configure key-based authentication via Ansible.
4. **Ansible Vault:** Always encrypt sensitive data (passwords, keys) in your playbooks.

## Next Steps

After completing the installation and post-install setup:

1. **Create Ansible Playbook** (`playbook.yml`)
2. **Define System Roles:**
   - Desktop environment (GNOME, KDE, etc.)
   - Development tools
   - Applications
   - System configuration
3. **Add Dotfiles** (shell configs, editor configs, etc.)
4. **Configure Services** (Docker, databases, etc.)

## Resources

- [Void Linux Documentation](https://docs.voidlinux.org/)
- [Void Linux Handbook](https://docs.voidlinux.org/config/index.html)
- [XBPS Package Manager](https://docs.voidlinux.org/xbps/index.html)
- [Runit Service Management](https://docs.voidlinux.org/config/services/index.html)

## License

This is personal configuration. Feel free to use as reference, but customize for your needs.

## Contributing

This is a personal repository, but suggestions and improvements are welcome via issues or PRs.

---

**Happy Voiding! 🚀**
