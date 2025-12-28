# Fish configuration

# Disable greeting
set -g fish_greeting

# Environment
set -gx EDITOR micro
set -gx VISUAL micro
set -gx PAGER less

# XDG
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# Path
fish_add_path $HOME/.local/bin

# Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias tree='eza --tree --icons'
alias cat='bat --plain'
alias grep='rg'
alias find='fd'

# Start sway on TTY1
if test (tty) = /dev/tty1
    exec sway
end
