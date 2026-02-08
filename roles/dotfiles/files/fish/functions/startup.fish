function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    # Scratchpad notepad (floating, hidden until Super+`)
    swaymsg 'exec wezterm start --title notepad -- fish -c notepad'
    sleep 1

    # Workspace 1: Firefox (33% left) + VSCode (66% right)
    swaymsg 'workspace number 1'
    swaymsg 'exec firefox'
    while not swaymsg -t get_tree | grep -q '"app_id": "Firefox"'
        sleep 0.5
    end
    sleep 1
    swaymsg 'exec code'
    sleep 2
    swaymsg '[app_id="Firefox"] resize set width 33 ppt'
end
