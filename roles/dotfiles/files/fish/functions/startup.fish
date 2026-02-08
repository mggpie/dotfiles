function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    # Scratchpad notepad (floating, hidden until Super+`)
    swaymsg 'exec wezterm start --class notepad -- micro ~/Desktop/0-Inbox/notepad.md'
    sleep 2
    swaymsg '[app_id="notepad"] resize set width 80ppt height 80ppt, move position center'
    sleep 0.5

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

    # Workspace 2: WezTerm
    swaymsg 'workspace number 2'
    swaymsg 'exec wezterm'
    sleep 1
    swaymsg 'workspace number 1'
end
