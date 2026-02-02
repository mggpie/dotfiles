# Fish configuration

# Path
fish_add_path $HOME/.local/bin

# Disable greeting
set -g fish_greeting

# Environment
set -gx EDITOR micro
set -gx VISUAL micro
set -gx PAGER less
set -gx TERMINAL foot

# XDG
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# Wayland
set -gx MOZ_ENABLE_WAYLAND 1                   # Firefox/Mozilla native Wayland
set -gx ELECTRON_OZONE_PLATFORM_HINT auto      # Electron Wayland auto-detect
set -gx QT_QPA_PLATFORM wayland                # Qt Wayland (breaks old Qt)
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1  # Sway handles decorations
set -gx SDL_VIDEODRIVER wayland                # SDL2 Wayland (fallback X11)
set -gx ECORE_EVAS_ENGINE wayland-egl          # Enlightenment Wayland
set -gx ELM_ENGINE wayland-egl                 # Elementary Wayland
set -gx _JAVA_AWT_WM_NONREPARENTING 1          # Fix Java tiling WM blanks
#set -gx QT_WAYLAND_FORCE_DPI physical          # Physical DPI (breaks scaling)
#set -gx JAVA_HOME /usr/lib/jvm/default         # Java path (if installed)
#set -gx GTK_USE_PORTAL 1                       # xdg-portal (0=breaks Flatpak)

# Aliases
#alias ls='eza --icons'
#alias ll='eza -l --icons'
#alias la='eza -la --icons'
#alias tree='eza --tree --icons'
#alias cat='bat --plain'
#alias grep='rg'
#alias find='fd'

## Start sway on TTY1
#if test (tty) = /dev/tty1
#    exec sway
#end
