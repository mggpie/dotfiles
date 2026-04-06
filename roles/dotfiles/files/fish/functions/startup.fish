function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    # Workspace 1: Firefox (left) + VSCode (middle) + WezTerm (right)
    # Wait for each window before launching the next to guarantee tiling order
    swaymsg 'workspace number 1'

    swaymsg 'exec firefox'
    while not swaymsg -t get_tree | grep -q '"app_id": "Firefox"'
        sleep 0.1
    end

    swaymsg 'exec code'
    while not swaymsg -t get_tree | grep -q '"name": "Visual Studio Code"'
        sleep 0.1
    end

    swaymsg 'exec wezterm start -- fish -c notepad'
    while not swaymsg -t get_tree | grep -q '"app_id": "org.wezfurlong.wezterm"'
        sleep 0.1
    end

    swaymsg '[app_id="Firefox"] resize set width 40 ppt'
    swaymsg '[app_id="org.wezfurlong.wezterm"] resize set width 20 ppt'

    # Scratchpad notepad (floating, hidden until Super+`)
    swaymsg 'exec wezterm start --class notepad -- micro ~/0-Inbox/notepad.md'
end
