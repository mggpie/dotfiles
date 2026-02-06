function tv --description "Toggle between TV and Monitor with audio switching"
    # Define outputs
    set -l monitor_output "DP-1"
    set -l tv_output "HDMI-A-2"
    set -l monitor_audio_profile "output:hdmi-stereo"
    set -l tv_audio_profile "output:hdmi-stereo-extra1"
    set -l audio_card "alsa_card.pci-0000_00_1f.3"

    # Check current state by checking if TV is enabled
    set -l tv_power (swaymsg -t get_outputs -r | jq -r ".[] | select(.name == \"$tv_output\") | .power // false")

    if test "$tv_power" = "true"
        # TV is currently on, switch to Monitor
        echo "Switching to Monitor..."
        
        # First, move all workspaces to monitor while both are active
        swaymsg output $monitor_output enable
        sleep 0.2
        for workspace in (seq 1 10)
            swaymsg workspace $workspace
            swaymsg move workspace to output $monitor_output 2>/dev/null
        end
        
        # Configure monitor
        swaymsg output $monitor_output mode 3440x1440@75.050Hz
        swaymsg output $monitor_output scale 1.0
        
        # Switch audio to monitor BEFORE disabling TV to avoid dummy output
        pactl set-card-profile $audio_card $monitor_audio_profile
        sleep 0.1
        
        # Now disable TV
        swaymsg output $tv_output disable
        
        echo "✓ Switched to Monitor with audio"
    else
        # Monitor is currently on, switch to TV
        echo "Switching to TV..."
        
        # First, enable and configure TV (4K 60Hz only - TV doesn't display other modes)
        swaymsg output $tv_output enable
        sleep 0.2
        swaymsg output $tv_output mode 3840x2160@60.000Hz
        swaymsg output $tv_output scale 3.0
        
        # Move all workspaces to TV while both are active
        for workspace in (seq 1 10)
            swaymsg workspace $workspace
            swaymsg move workspace to output $tv_output 2>/dev/null
        end
        
        # Now disable monitor
        swaymsg output $monitor_output disable
        
        # Switch audio to TV HDMI
        pactl set-card-profile $audio_card $tv_audio_profile
        
        echo "✓ Switched to TV (4K 60Hz) with audio"
        echo "💡 Tip: Enable 'Game Mode' or 'PC Mode' on TV to reduce input lag/flickering"
    end
end
