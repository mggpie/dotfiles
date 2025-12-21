#!/bin/sh
# =============================================================================
# Void Linux Post-Installation Bootstrap Script
# =============================================================================
# This script prepares the system for Ansible configuration.
# Run after first boot into freshly installed Void Linux.
#
# Usage: curl -sSL mggpie.github.io/dotfiles/bootstrap | sh
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
HOME_DIR=$(eval echo ~$USERNAME)

log_info "╔══════════════════════════════════════════════════════════════╗"
log_info "║        Void Linux Post-Installation Bootstrap                 ║"
log_info "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "User: $USERNAME"
log_info "Home: $HOME_DIR"
echo ""

# =============================================================================
# Step 1: Update system
# =============================================================================
log_info "Step 1: Updating system packages..."
sudo xbps-install -Syu

# =============================================================================
# Step 2: Install required packages
# =============================================================================
log_info "Step 2: Installing required packages..."
sudo xbps-install -Sy \
    git \
    python3 \
    python3-pip \
    ansible \
    doas

# =============================================================================
# Step 3: Configure doas for passwordless sudo
# =============================================================================
log_info "Step 3: Configuring doas..."
sudo mkdir -p /etc/doas.d
echo "permit nopass $USERNAME" | sudo tee /etc/doas.d/me.conf > /dev/null
sudo chmod 600 /etc/doas.d/me.conf

# Verify doas works
if doas true 2>/dev/null; then
    log_info "doas configured successfully"
else
    log_warn "doas may need manual configuration"
fi

# =============================================================================
# Step 4: Clone dotfiles repository
# =============================================================================
log_info "Step 4: Cloning dotfiles repository..."
DOTFILES_DIR="$HOME_DIR/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    log_warn "Dotfiles directory already exists, pulling latest..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    git clone https://github.com/mggpie/dotfiles.git "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# =============================================================================
# Step 5: Install Ansible requirements
# =============================================================================
log_info "Step 5: Installing Ansible dependencies..."
if [ -f "$DOTFILES_DIR/requirements.yml" ]; then
    ansible-galaxy install -r "$DOTFILES_DIR/requirements.yml"
fi

# Install ansible-lint via pip if not available
if ! command -v ansible-lint >/dev/null 2>&1; then
    pip3 install --user ansible-lint
fi

# =============================================================================
# Step 6: Create vault password file (optional)
# =============================================================================
log_info "Step 6: Setting up Ansible Vault..."
VAULT_PASS_FILE="$DOTFILES_DIR/.vault_pass"

if [ ! -f "$VAULT_PASS_FILE" ]; then
    log_warn "No vault password file found."
    echo ""
    printf "Do you want to create a vault password now? (y/N): "
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        printf "Enter vault password: "
        stty -echo
        read -r vault_pass
        stty echo
        echo ""
        echo "$vault_pass" > "$VAULT_PASS_FILE"
        chmod 600 "$VAULT_PASS_FILE"
        log_info "Vault password file created"
        unset vault_pass
    else
        log_info "Skipping vault setup. You can run playbook with --ask-vault-pass"
    fi
fi

# =============================================================================
# Step 7: Display next steps
# =============================================================================
echo ""
log_info "╔══════════════════════════════════════════════════════════════╗"
log_info "║                   Bootstrap Complete!                         ║"
log_info "╠══════════════════════════════════════════════════════════════╣"
log_info "║  Next steps:                                                  ║"
log_info "║                                                               ║"
log_info "║  1. Create vault file with sensitive data:                    ║"
log_info "║     cd ~/dotfiles                                             ║"
log_info "║     ansible-vault create group_vars/all/vault.yml             ║"
log_info "║                                                               ║"
log_info "║  2. Run the Ansible playbook:                                 ║"
log_info "║     ansible-playbook playbook.yml                             ║"
log_info "║                                                               ║"
log_info "║  3. Or run specific roles:                                    ║"
log_info "║     ansible-playbook playbook.yml --tags base                 ║"
log_info "║     ansible-playbook playbook.yml --tags shell                ║"
log_info "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Ask if user wants to run playbook now
printf "Run the full playbook now? (y/N): "
read -r run_now
if [ "$run_now" = "y" ] || [ "$run_now" = "Y" ]; then
    cd "$DOTFILES_DIR"
    if [ -f "$VAULT_PASS_FILE" ]; then
        ansible-playbook playbook.yml
    else
        ansible-playbook playbook.yml --ask-vault-pass
    fi
fi
