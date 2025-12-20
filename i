#!/bin/sh
# Void Linux installer bootstrap
xbps-install -Sy curl 2>/dev/null || true
curl -sSL mggpie.github.io/dotfiles/install-void.sh | sh
