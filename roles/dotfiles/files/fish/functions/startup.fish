function startup
    pkill -x code 2>/dev/null
    pkill -x wezterm-gui 2>/dev/null
    pkill -x firefox 2>/dev/null

    set -l wezterm_window_match '"app_id": "org.wezfurlong.wezterm"|"class": "org.wezfurlong.wezterm"'

    if not test -S "$SWAYSOCK"
        exit 1
    end

    if not swaymsg 'workspace number 1' 2>/dev/null
        exit 1
    end

    swaymsg 'exec firefox' 2>/dev/null
    set -l waited 0
    while test $waited -lt 60
        if swaymsg -t get_tree 2>/dev/null | grep -q '"app_id": "Firefox"'
            break
        end
        sleep 0.5
        set waited (math $waited + 1)
    end

    swaymsg 'exec code' 2>/dev/null
    set waited 0
    while test $waited -lt 60
        if swaymsg -t get_tree 2>/dev/null | grep -q '"name": "Visual Studio Code"'
            break
        end
        sleep 0.5
        set waited (math $waited + 1)
    end

    swaymsg 'exec wezterm start -- fish -c notepad' 2>/dev/null
    set waited 0
    while test $waited -lt 60
        if swaymsg -t get_tree 2>/dev/null | grep -Eq "$wezterm_window_match"
            break
        end
        sleep 0.5
        set waited (math $waited + 1)
    end

    swaymsg '[app_id="Firefox"] resize set width 40 ppt' 2>/dev/null
    swaymsg '[app_id="org.wezfurlong.wezterm"] resize set width 20 ppt' 2>/dev/null
    swaymsg '[class="^org.wezfurlong.wezterm$"] resize set width 20 ppt' 2>/dev/null

    swaymsg 'exec wezterm start --class notepad -- micro ~/0-Inbox/notepad.md' 2>/dev/null
end
