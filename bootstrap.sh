#!/bin/sh
# =============================================================================
# Void Linux Post-Installation Bootstrap Script
# =============================================================================
# Run after first boot into freshly installed Void Linux.
# This is a one-liner - installs everything and runs Ansible.
#
# Usage: curl -sL https://raw.githubusercontent.com/mggpie/dotfiles/main/bootstrap.sh | sh
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# Check if running as correct user
if [ "$(id -u)" -eq 0 ]; then
    log_error "Don't run as root. Run as your regular user."
    exit 1
fi

USERNAME=$(whoami)
HOME_DIR=$(eval echo ~"$USERNAME")
DOTFILES_DIR="$HOME_DIR/dotfiles"

log_info "╔════════════════════════════════════════════╗"
log_info "║   Void Linux Post-Install Bootstrap        ║"
log_info "╚════════════════════════════════════════════╝"
log_info "User: $USERNAME"

# =============================================================================
# Step 1: Install dependencies (git, ansible, opendoas)
# =============================================================================
log_info "Installing git, ansible, opendoas..."
sudo xbps-install -Syu
sudo xbps-install -Sy git ansible opendoas

# =============================================================================
# Step 2: Configure doas (passwordless for this user)
# =============================================================================
log_info "Configuring doas..."
echo "permit nopass $USERNAME" | sudo tee /etc/doas.conf > /dev/null
sudo chmod 600 /etc/doas.conf

# =============================================================================
# Step 3: Clone dotfiles
# =============================================================================
log_info "Cloning dotfiles repository..."
if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR" && git pull origin main
else
    git clone https://github.com/mggpie/dotfiles.git "$DOTFILES_DIR"
fi

# =============================================================================
# Step 4: Run Ansible playbook
# =============================================================================
log_info "Running Ansible playbook..."
cd "$DOTFILES_DIR"
ansible-playbook playbook.yml

log_info "╔════════════════════════════════════════════╗"
log_info "║            Setup Complete!                 ║"
log_info "║      Reboot to apply all changes.         ║"
log_info "╚════════════════════════════════════════════╝"
