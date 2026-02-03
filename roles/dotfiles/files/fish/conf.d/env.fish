# Environment variables

# Default applications
set -gx EDITOR micro
set -gx VISUAL micro
set -gx PAGER "less -R"
set -gx MANPAGER "less -R --use-color -Dd+r -Du+b"
set -gx TERMINAL wezterm
set -gx BROWSER firefox-wayland
set -gx FILE_MANAGER thunar
set -gx IMAGE_VIEWER imv
set -gx MICRO_TRUECOLOR 1
set -gx fish_term24bit 1
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgrep/ripgreprc

# XDG Base Directory
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# Wayland
set -gx MOZ_ENABLE_WAYLAND 1                   # Firefox/Mozilla native Wayland
set -gx ELECTRON_OZONE_PLATFORM_HINT auto      # Electron Wayland auto-detect
set -gx QT_QPA_PLATFORM wayland                # Qt Wayland (breaks old Qt)
set -gx QT_QPA_PLATFORMTHEME gtk3              # Qt uses GTK3 theme
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1  # Sway handles decorations
set -gx SDL_VIDEODRIVER wayland                # SDL2 Wayland (fallback X11)
set -gx ECORE_EVAS_ENGINE wayland-egl          # Enlightenment Wayland
set -gx ELM_ENGINE wayland-egl                 # Elementary Wayland
set -gx _JAVA_AWT_WM_NONREPARENTING 1          # Fix Java tiling WM blanks
set -gx XCURSOR_THEME capitaine-cursors
set -gx XCURSOR_SIZE 24
set -gx XCURSOR_PATH $HOME/.nix-profile/share/icons:$HOME/.local/share/icons:/usr/share/icons
#set -gx QT_WAYLAND_FORCE_DPI physical          # Physical DPI (breaks scaling)
#set -gx JAVA_HOME /usr/lib/jvm/default         # Java path (if installed)
#set -gx GTK_USE_PORTAL 1                       # xdg-portal (0=breaks Flatpak)

# Bluetooth devices (from secrets.yml)
set -gx BOSE_QC45_MAC "{{ bose_mac }}"

# D-Bus session (fix "disabled:" issue)
if test "$DBUS_SESSION_BUS_ADDRESS" = "disabled:"
    set -e DBUS_SESSION_BUS_ADDRESS
end

# GIO/GVFS for trash support in file managers
set -gx GIO_USE_VFS gvfs
