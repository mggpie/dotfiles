#!/bin/sh
#
# Void Linux Automated Installation Script
# This script automates the Void Linux installation process
# Compatible with POSIX sh (dash)
#

set -e  # Exit on error

# Source configuration
if [ -f "$(dirname "$0")/config.sh" ]; then
    . "$(dirname "$0")/config.sh"
else
    # Default configuration if config.sh not found
    TARGET_DISK="/dev/nvme0n1"
    HOSTNAME="here"
    TIMEZONE="Europe/Warsaw"
    LOCALE="en_US.UTF-8"
    KEYMAP="pl"
    USERNAME="me"
    USER_GROUPS="wheel audio video storage network input optical kvm lp"
    USE_SWAP="yes"
    SWAP_SIZE="auto"
    FILESYSTEM="ext4"
    USE_ENCRYPTION="yes"
    BOOTLOADER="grub"
    BOOT_MODE="uefi"
    NETWORK_MANAGER="dhcpcd"
    ENABLE_SSH="yes"
    DOTFILES_REPO="https://github.com/mggpie/dotfiles.git"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root"
    exit 1
fi

# Check if running from Void Linux live ISO
if ! grep -q "void" /etc/os-release 2>/dev/null; then
    log_warn "This doesn't appear to be Void Linux. Continue anyway? (y/N)"
    read -r response
    case "$response" in
        [Yy]*) ;;
        *) exit 1 ;;
    esac
fi

log_info "Starting Void Linux automated installation..."
log_info "Target disk: $TARGET_DISK"
log_info "Hostname: $HOSTNAME"
log_info "Username: $USERNAME"

# Confirm before proceeding
echo ""
log_warn "WARNING: This will ERASE all data on $TARGET_DISK!"
echo -n "Type 'YES' to continue: "
read -r confirm
if [ "$confirm" != "YES" ]; then
    log_error "Installation cancelled"
    exit 1
fi

# ============================================================================
# STEP 1: Partition the disk
# ============================================================================
log_info "Step 1: Partitioning disk $TARGET_DISK..."

# Wipe existing partition table
wipefs -af "$TARGET_DISK"
sgdisk --zap-all "$TARGET_DISK"

# Create GPT partition table
sgdisk -o "$TARGET_DISK"

# Create EFI partition (512MB)
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$TARGET_DISK"

# Create boot partition (1GB)
sgdisk -n 2:0:+1G -t 2:8300 -c 2:"BOOT" "$TARGET_DISK"

# Create root partition (rest of disk)
sgdisk -n 3:0:0 -t 3:8300 -c 3:"ROOT" "$TARGET_DISK"

# Inform kernel of partition changes
partprobe "$TARGET_DISK"
sleep 2

# Determine partition naming scheme
if echo "$TARGET_DISK" | grep -q "nvme\|mmcblk"; then
    PART1="${TARGET_DISK}p1"
    PART2="${TARGET_DISK}p2"
    PART3="${TARGET_DISK}p3"
else
    PART1="${TARGET_DISK}1"
    PART2="${TARGET_DISK}2"
    PART3="${TARGET_DISK}3"
fi

log_info "Created partitions: $PART1 (EFI), $PART2 (BOOT), $PART3 (ROOT)"

# ============================================================================
# STEP 2: Setup LUKS encryption
# ============================================================================
log_info "Step 2: Setting up LUKS encryption..."

echo ""
log_warn "Enter encryption passphrase for root partition:"
cryptsetup luksFormat --type luks2 "$PART3"

echo ""
log_warn "Enter passphrase again to unlock:"
cryptsetup open "$PART3" voidcrypt

# ============================================================================
# STEP 3: Create filesystems
# ============================================================================
log_info "Step 3: Creating filesystems..."

# Format EFI partition
mkfs.vfat -F32 -n EFI "$PART1"

# Format boot partition
mkfs.ext4 -L BOOT "$PART2"

# Format encrypted root partition
mkfs.ext4 -L ROOT /dev/mapper/voidcrypt

# Create swap file if enabled (on encrypted partition)
if [ "$USE_SWAP" = "yes" ]; then
    log_info "Swap will be created as a file after system installation"
fi

# ============================================================================
# STEP 4: Mount filesystems
# ============================================================================
log_info "Step 4: Mounting filesystems..."

mount /dev/mapper/voidcrypt /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/boot/efi
mount "$PART2" /mnt/boot
mount "$PART1" /mnt/boot/efi

# ============================================================================
# STEP 5: Install base system
# ============================================================================
log_info "Step 5: Installing base system..."

# Ensure we have the latest xbps
xbps-install -Suy xbps

# Install base system
# Note: Adjust microcode package based on your CPU (intel-ucode or amd-ucode)
BASE_PACKAGES="base-system grub-x86_64-efi efibootmgr cryptsetup lvm2 linux linux-firmware linux-firmware-intel intel-ucode curl git vim sudo"

# Add selected network manager
if [ "$NETWORK_MANAGER" = "NetworkManager" ]; then
    BASE_PACKAGES="$BASE_PACKAGES NetworkManager"
else
    BASE_PACKAGES="$BASE_PACKAGES dhcpcd"
fi

XBPS_ARCH=x86_64 xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt $BASE_PACKAGES

# ============================================================================
# STEP 6: Configure the system
# ============================================================================
log_info "Step 6: Configuring the system..."

# Set hostname
echo "$HOSTNAME" > /mnt/etc/hostname

# Configure hosts file
cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /mnt/etc/localtime

# Set locale
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
echo "$LOCALE UTF-8" >> /mnt/etc/default/libc-locales
chroot /mnt xbps-reconfigure -f glibc-locales

# Set keyboard layout
echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf

# Configure fstab
log_info "Generating fstab..."
EFI_UUID=$(blkid -s UUID -o value "$PART1")
BOOT_UUID=$(blkid -s UUID -o value "$PART2")

cat > /mnt/etc/fstab << EOF
# /etc/fstab: static file system information
#
# <file system> <mount point> <type> <options> <dump> <pass>
UUID=$EFI_UUID  /boot/efi  vfat  defaults,noatime  0 2
UUID=$BOOT_UUID /boot      ext4  defaults,noatime  0 2
/dev/mapper/voidcrypt /    ext4  defaults,noatime  0 1
tmpfs           /tmp       tmpfs defaults,nosuid,nodev 0 0
EOF

# Configure crypttab
ROOT_UUID=$(blkid -s UUID -o value "$PART3")
echo "voidcrypt UUID=$ROOT_UUID none luks" > /mnt/etc/crypttab

# Configure dracut for LUKS
mkdir -p /mnt/etc/dracut.conf.d
cat > /mnt/etc/dracut.conf.d/10-crypt.conf << EOF
add_dracutmodules+=" crypt dm rootfs-block "
install_items+=" /etc/crypttab "
EOF

# ============================================================================
# STEP 7: Install and configure GRUB
# ============================================================================
log_info "Step 7: Installing GRUB..."

# Configure GRUB for encrypted root
cat > /mnt/etc/default/grub << EOF
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Void"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 quiet"
GRUB_CMDLINE_LINUX="rd.luks.uuid=$ROOT_UUID rd.lvm=0"
GRUB_ENABLE_CRYPTODISK=y
EOF

# Chroot and install GRUB
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
mount --rbind /proc /mnt/proc

chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --recheck
chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# ============================================================================
# STEP 8: Create user and set passwords
# ============================================================================
log_info "Step 8: Creating user and setting passwords..."

# Set root password
echo ""
log_warn "Set root password:"
chroot /mnt passwd root

# Create user
chroot /mnt useradd -m -G wheel,audio,video,storage,network,input,optical,kvm,lp -s /bin/sh "$USERNAME"

# Set user password
echo ""
log_warn "Set password for user $USERNAME:"
chroot /mnt passwd "$USERNAME"

# Configure sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
chmod 0440 /mnt/etc/sudoers.d/wheel

# ============================================================================
# STEP 9: Enable services
# ============================================================================
log_info "Step 9: Enabling services..."

# Enable network service
if [ "$NETWORK_MANAGER" = "NetworkManager" ]; then
    chroot /mnt ln -sf /etc/sv/NetworkManager /etc/runit/runsvdir/default/
else
    chroot /mnt ln -sf /etc/sv/dhcpcd /etc/runit/runsvdir/default/
fi

# Enable SSH if configured
if [ "$ENABLE_SSH" = "yes" ]; then
    chroot /mnt ln -sf /etc/sv/sshd /etc/runit/runsvdir/default/
fi

# ============================================================================
# STEP 10: Create swap file (if enabled)
# ============================================================================
if [ "$USE_SWAP" = "yes" ]; then
    log_info "Step 10: Creating swap file..."
    
    # Determine swap size
    if [ "$SWAP_SIZE" = "auto" ]; then
        # Get RAM size in GB
        RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
        SWAP_SIZE="${RAM_GB}G"
    fi
    
    # Create swap file
    chroot /mnt fallocate -l "$SWAP_SIZE" /swapfile
    chroot /mnt chmod 600 /swapfile
    chroot /mnt mkswap /swapfile
    
    # Add to fstab
    echo "/swapfile none swap sw 0 0" >> /mnt/etc/fstab
    
    log_info "Created ${SWAP_SIZE} swap file"
fi

# ============================================================================
# STEP 11: Reconfigure all packages
# ============================================================================
log_info "Step 11: Reconfiguring all packages..."

chroot /mnt xbps-reconfigure -fa

# ============================================================================
# STEP 12: Final steps
# ============================================================================
log_info "Step 12: Final configuration..."

# Create a post-install script for the user
cat > /mnt/home/$USERNAME/post-install.sh << 'EOF'
#!/bin/sh
# Post-installation script
# Run this after first boot to clone dotfiles and run Ansible

echo "Void Linux Post-Installation Script"
echo "===================================="
echo ""
echo "This script will:"
echo "1. Clone your dotfiles repository"
echo "2. Set up Ansible"
echo "3. Run your Ansible playbook"
echo ""
printf "Continue? (y/N) "
read -r reply
case "$reply" in
    [Yy]*) ;;
    *) exit 1 ;;
esac

# Update system
echo "Updating system..."
sudo xbps-install -Suy

# Install git and ansible if not present
echo "Installing prerequisites..."
sudo xbps-install -Sy git ansible

# Clone dotfiles
echo "Cloning dotfiles..."
cd ~
if [ ! -d "dotfiles" ]; then
    git clone https://github.com/mggpie/dotfiles.git
    cd dotfiles
else
    cd dotfiles
    git pull
fi

echo ""
echo "Dotfiles cloned successfully!"
echo "Next steps:"
echo "1. Review the Ansible playbook"
echo "2. Configure ansible-vault for secrets (WiFi passwords, etc.)"
echo "3. Run: ansible-playbook playbook.yml"
echo ""
EOF

chmod +x /mnt/home/$USERNAME/post-install.sh
chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/post-install.sh

# Create a reminder file
cat > /mnt/home/$USERNAME/README.md << EOF
# Void Linux Installation Complete!

Your Void Linux system has been installed with the following configuration:

- **Hostname:** $HOSTNAME
- **Username:** $USERNAME
- **Disk:** $TARGET_DISK (encrypted with LUKS)
- **Bootloader:** GRUB (UEFI)
- **Timezone:** $TIMEZONE
- **Locale:** $LOCALE
- **Keyboard:** $KEYMAP

## Next Steps

After rebooting into your new system:

1. Run the post-install script:
   \`\`\`bash
   ./post-install.sh
   \`\`\`

2. Configure your Ansible vault for secrets:
   \`\`\`bash
   cd ~/dotfiles
   ansible-vault create group_vars/all/vault.yml
   \`\`\`

3. Add your WiFi credentials and other secrets to the vault

4. Run your Ansible playbook:
   \`\`\`bash
   ansible-playbook playbook.yml --ask-vault-pass
   \`\`\`

## Important Notes

- Your root partition is encrypted with LUKS
- You will need to enter your encryption password at boot
- SSH daemon is enabled by default
- NetworkManager is installed but not enabled (using dhcpcd)

## Troubleshooting

If you have any issues booting:
- Make sure you entered the correct LUKS passphrase
- Check GRUB configuration in /etc/default/grub
- Regenerate initramfs: \`xbps-reconfigure -f linux\`

Enjoy your new Void Linux system!
EOF

chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/README.md

# Unmount filesystems
log_info "Unmounting filesystems..."
umount -R /mnt

log_info "============================================"
log_info "Installation complete!"
log_info "============================================"
echo ""
log_info "You can now reboot into your new Void Linux system."
log_info "Remember to:"
log_info "  1. Remove the installation media"
log_info "  2. Enter your LUKS passphrase at boot"
log_info "  3. Run ~/post-install.sh after first login"
echo ""
log_warn "Reboot now? (y/N)"
read -r reboot_now
case "$reboot_now" in
    [Yy]*) reboot ;;
    *) ;;
esac
