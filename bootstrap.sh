#!/bin/sh
# Bootstrap script for Void Linux dotfiles
# Installs Ansible and required dependencies, then runs the playbook

set -e

echo "==> Updating package repository..."
doas xbps-install -Sy

echo "==> Installing Ansible and dependencies..."
doas xbps-install -y ansible python3-packaging

echo "==> Bootstrap complete!"
echo ""

# Verify password files exist
if [ ! -f .vault_pass ]; then
    echo "ERROR: .vault_pass not found. Create it with your vault password."
    exit 1
fi

if [ ! -f .become_pass ]; then
    echo "ERROR: .become_pass not found. Create it with your sudo/doas password."
    exit 1
fi

echo "==> Running playbook..."
echo ""

ansible-playbook playbook.yml
