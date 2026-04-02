function tv --description "Toggle between TV and Monitor with audio switching"
    # Define outputs
    set -l monitor_output "DP-1"
    set -l tv_output "HDMI-A-2"
    set -l monitor_audio_profile "output:hdmi-stereo"
    set -l tv_audio_profile "output:analog-stereo"
    set -l audio_card "alsa_card.pci-0000_00_1f.3"

    # Check current state by checking if TV is enabled
    set -l tv_active (swaymsg -t get_outputs -r | jq -r ".[] | select(.name == \"$tv_output\") | .active")

    # Remember current workspace to restore after moving workspaces around
    set -l current_ws (swaymsg -t get_workspaces -r | jq -r '.[] | select(.focused) | .name')

    if test "$tv_active" = "true"
        # TV is currently on, switch to Monitor
        echo "Switching to Monitor..."

        # Stop silence stream, kill easyeffects, turn off external speakers
        pkill -f 'paplay --raw.*/dev/zero' 2>/dev/null
        pkill -x easyeffects 2>/dev/null
        smarthome 1 off &

        # Move all workspaces to monitor while both are active
        swaymsg output $monitor_output enable
        sleep 0.2
        for workspace in (seq 1 10)
            swaymsg workspace $workspace
            swaymsg move workspace to output $monitor_output 2>/dev/null
        end

        # Configure monitor (60Hz - smoother Sway rendering, most apps target 60fps)
        swaymsg output $monitor_output mode 3440x1440@59.973Hz
        swaymsg output $monitor_output scale 1.0

        # Switch audio to monitor HDMI before disabling TV to avoid dummy output
        pactl set-card-profile $audio_card $monitor_audio_profile
        pactl set-default-sink alsa_output.pci-0000_00_1f.3.hdmi-stereo
        pactl set-sink-volume @DEFAULT_SINK@ 20%
        sleep 0.1

        # Now disable TV
        swaymsg output $tv_output disable

        # Restore the workspace that was focused before the switch
        swaymsg workspace $current_ws

        echo "Switched to Monitor with audio"
    else
        # Monitor is currently on, switch to TV
        echo "Switching to TV..."

        # Verify TV is physically connected before switching
        set -l tv_connected (swaymsg -t get_outputs -r | jq -r ".[] | select(.name == \"$tv_output\")")
        if test -z "$tv_connected"
            echo "TV ($tv_output) not connected, aborting"
            return 1
        end

        # Start easyeffects first so EQ/limiter is active before any sound plays
        if not pgrep -x easyeffects >/dev/null
            easyeffects --gapplication-service &
            disown
            sleep 1
        end
        easyeffects -l bass

        # Turn on external speakers
        smarthome 1 on &

        # Enable and configure TV (4K 60Hz only - TV doesn't display other modes)
        swaymsg output $tv_output enable
        sleep 0.2

        # Check that TV actually came up - HDMI handshake may fail if TV is off
        set -l tv_now_active (swaymsg -t get_outputs -r | jq -r ".[] | select(.name == \"$tv_output\") | .active")
        if test "$tv_now_active" != "true"
            echo "TV enabled but not active (is it turned on?), reverting"
            swaymsg output $tv_output disable 2>/dev/null
            pkill -x easyeffects 2>/dev/null
            smarthome 1 off &
            return 1
        end

        swaymsg output $tv_output mode 3840x2160@60.000Hz
        swaymsg output $tv_output scale 3.0

        # Move all workspaces to TV while both are active
        for workspace in (seq 1 10)
            swaymsg workspace $workspace
            swaymsg move workspace to output $tv_output 2>/dev/null
        end

        # Now disable monitor
        swaymsg output $monitor_output disable

        # Switch audio to analog line-out (external speakers via 3.5mm)
        pactl set-card-profile $audio_card $tv_audio_profile
        pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
        pactl set-sink-volume @DEFAULT_SINK@ 50%

        # Play silence to keep audio stream active - prevents amp buzzing
        pkill -f 'paplay --raw.*/dev/zero' 2>/dev/null
        paplay --raw --format=s16le --rate=48000 --channels=2 /dev/zero &
        disown $last_pid

        # Restore the workspace that was focused before the switch
        swaymsg workspace $current_ws

        echo "Switched to TV (4K 60Hz) with line-out audio at 50%"
    end
end
