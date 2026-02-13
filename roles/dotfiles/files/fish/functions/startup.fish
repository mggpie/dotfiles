function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    # Workspace 1: Firefox (40% left) + VSCode (40% middle) + WezTerm (20% right)
    swaymsg 'workspace number 1'
    swaymsg 'exec firefox'
    swaymsg 'exec code'
    swaymsg 'exec wezterm'
    while not swaymsg -t get_tree | grep -q '"name": "Visual Studio Code"'
        sleep 0.5
    end
    swaymsg '[app_id="Firefox"] resize set width 40 ppt'
    while not swaymsg -t get_tree | grep -q '"app_id": "org.wezfurlong.wezterm"'
        sleep 0.5
    end
    swaymsg '[app_id="org.wezfurlong.wezterm"] resize set width 20 ppt'

    # Scratchpad notepad (floating, hidden until Super+`)
    swaymsg 'exec wezterm start --class notepad -- micro ~/Desktop/0-Inbox/notepad.md'
end
