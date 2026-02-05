#!/bin/sh
# VS Code launcher with proper Wayland fractional scaling
exec code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --force-device-scale-factor=0.9 "$@"
