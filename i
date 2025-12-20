#!/bin/sh
# Void Linux installer bootstrap
echo "Installing curl..."
xbps-install -Sy curl 2>/dev/null || true
echo "Downloading installer..."
curl -sSL mggpie.github.io/dotfiles/install-void.sh -o /tmp/install-void.sh
chmod +x /tmp/install-void.sh
echo "Starting installation..."
/tmp/install-void.sh
