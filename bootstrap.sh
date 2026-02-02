#!/bin/sh
# Bootstrap script for Void Linux dotfiles
# Installs Ansible and required dependencies, then runs the playbook

set -e

echo "==> Updating package repository..."
doas xbps-install -Sy

echo "==> Installing Ansible and dependencies..."
doas xbps-install -y ansible python3-packaging

echo "==> Bootstrap complete!"
echo "==> Running playbook..."
echo ""

ansible-playbook playbook.yml --ask-become-pass
