function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null
    sleep 0.5

    # Workspace 1: VSCode (75%) + notepad terminal (25%)
    swaymsg 'workspace number 1'
    swaymsg 'exec code'
    sleep 2
    swaymsg 'exec wezterm start -- fish -c notepad'
    sleep 1
    swaymsg '[app_id="org.wezfurlong.wezterm"] resize set width 25 ppt'

    # Workspace 2: Firefox
    swaymsg 'workspace number 2'
    swaymsg 'exec firefox'
    sleep 1

    # Return to workspace 1
    swaymsg 'workspace number 1'
end
