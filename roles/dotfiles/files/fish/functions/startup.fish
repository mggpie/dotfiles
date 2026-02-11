function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    # Workspace 2: WezTerm (first, so it loads in the background)
    swaymsg 'workspace number 2'
    swaymsg 'exec wezterm'

    # Workspace 1: Firefox (33% left) + VSCode (66% right)
    swaymsg 'workspace number 1'
    swaymsg 'exec firefox'
    swaymsg 'exec code'
    while not swaymsg -t get_tree | grep -q '"name": "Visual Studio Code"'
        sleep 0.5
    end
    swaymsg '[app_id="Firefox"] resize set width 33 ppt'

    # Scratchpad notepad (floating, hidden until Super+`)
    swaymsg 'exec wezterm start --class notepad -- micro ~/Desktop/0-Inbox/notepad.md'
    sleep 1
    swaymsg '[app_id="notepad"] resize set width 40ppt height 80ppt, move position center'
    
    # Fix scratchpad centering bug - simulate mouse movement with sway's cursor command
    swaymsg 'seat - cursor set 960 540'
    sleep 0.1
    swaymsg 'seat - cursor set 961 540'
end
