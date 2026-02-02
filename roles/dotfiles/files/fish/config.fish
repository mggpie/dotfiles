# Fish configuration

set -g fish_greeting

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

alias ls "eza -l --icons --group-directories-first --git"
alias la "eza -la --icons --group-directories-first --git"
alias lt "eza --tree --icons --level=2"
alias tree "eza --tree --icons"
alias cat "bat --paging=never --plain"
