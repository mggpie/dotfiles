# Fish configuration

# Path
set -e fish_user_paths  # Without this line fish will start to slow down
set -U fish_user_paths $HOME/.local/bin $HOME/.nix-profile/bin $fish_user_paths

# Disable greeting
set -g fish_greeting

# Environment
set -gx EDITOR micro
set -gx VISUAL micro
set -gx PAGER less
set -gx MANPAGER "less -R --use-color -Dd+r -Du+b"
set -gx TERMINAL foot
set -gx BROWSER firefox-wayland
set -gx FILE_MANAGER pcmanfm
set -gx IMAGE_VIEWER imv
set -gx MICRO_TRUECOLOR 1
set -gx fish_term24bit 1
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgrep/ripgreprc

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
alias sudo "doas"
alias pkgs "xbps-query -v -Rs"          # search packages
alias pkgl "xbps-query -l"              # list installed packages
alias pkgi "doas xbps-install -Suy"     # install package + update system
alias pkgfi "doas xbps-install -Sfuy"   # force install package + update system
alias pkgr "doas xbps-remove -v -y"     # remove package
alias pkgu "doas xbps-install -Su"      # update system
alias logout "swaymsg exit"
alias suspend "loginctl suspend"
alias hibernate "loginctl hibernate"
alias reboot "loginctl reboot"
alias poweroff "loginctl poweroff"
alias .. "cd .."
alias ... "cd ../.."
alias vim "nvim"
alias fontsearch "fc-list | grep -i"
alias gpg-check "gpg --keyserver-options auto-key-retrieve --verify"
alias gpg-retrieve "gpg --keyserver-options auto-key-retrieve --receive-keys"
alias notepad "micro ~/me.md"
alias grep "grep --color=auto"
alias egrep "egrep --color=auto"
alias fgrep "fgrep --color=auto"
alias diff "diff --color=auto"
alias ip "ip -color=auto"
alias dmesg "dmesg --color=always"
alias watch "watch --color"
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
