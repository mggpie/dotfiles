#!/usr/bin/env fish

# Update repositories
sudo dnf update --color=always -qy

# Upgrade installed packages
sudo dnf upgrade --color=always -qy

# Refresh repositories and upgrade packages
sudo dnf upgrade --color=always --refresh -qy

# Check package integrity
sudo dnf check --color=always -qy

# Remove unnecessary dependencies
sudo dnf autoremove --color=always -qy

# Get a list of devices for firmware updates
sudo fwupdmgr get-devices -y

# Refresh information about available firmware updates
sudo fwupdmgr refresh --force -y

# Get a list of available firmware updates
sudo fwupdmgr get-updates -y

# Update firmware
sudo fwupdmgr update -y

# Print completion message
echo "The system update and firmware update have completed."
