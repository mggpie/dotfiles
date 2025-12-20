#!/bin/sh
# Void Linux installer bootstrap
echo "Downloading installer..."
curl -sSL mggpie.github.io/dotfiles/install-void.sh -o /tmp/install-void.sh
chmod +x /tmp/install-void.sh
echo "Starting installation..."
/tmp/install-void.sh
