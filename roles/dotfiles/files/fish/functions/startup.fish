function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null
    pkill -x Telegram 2>/dev/null

    # Workspace 1: VSCode (75%) + notepad terminal (25%)
    swaymsg 'workspace number 1'
    swaymsg 'exec code'
    sleep 2
    swaymsg 'exec wezterm start -- fish -c notepad'
    sleep 1
    swaymsg '[app_id="org.wezfurlong.wezterm"] resize set width 25 ppt'

    # Workspace 2: Firefox (restores previous session)
    swaymsg 'workspace number 2; exec firefox'
    # Wait for Firefox window to appear
    while not swaymsg -t get_tree | grep -q '"app_id": "Firefox"'
        sleep 0.5
    end
    sleep 1

    # Workspace 9: Messenger (left) + Telegram (right)
    swaymsg 'workspace number 9'
    swaymsg 'exec firefox --new-window https://www.messenger.com'
    sleep 2
    swaymsg 'exec Telegram'

    # Return to workspace 2
    sleep 1
    swaymsg 'workspace number 2'
end
