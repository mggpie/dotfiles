function tv --description "Toggle between TV and Monitor with audio switching"
    # Define outputs
    set -l monitor_output "DP-1"
    set -l tv_output "HDMI-A-2"
    set -l monitor_audio_profile "output:hdmi-stereo"
    set -l tv_audio_profile "output:hdmi-stereo-extra1"
    set -l audio_card "alsa_card.pci-0000_00_1f.3"

    # Check current state by checking if TV is enabled
    set -l current_outputs (swaymsg -t get_outputs | grep -E "^Output" | awk '{print $2}')
    set -l tv_enabled (swaymsg -t get_outputs | grep "$tv_output" | grep -c "Power: on")

    if test "$tv_enabled" -gt 0
        # TV is currently on, switch to Monitor
        echo "Switching to Monitor..."
        
        # Enable monitor with native resolution
        swaymsg output $monitor_output enable
        swaymsg output $monitor_output mode 3440x1440@75.050Hz
        
        # Disable TV
        swaymsg output $tv_output disable
        
        # Switch audio to monitor HDMI
        pactl set-card-profile $audio_card $monitor_audio_profile
        
        # Move all workspaces to monitor
        for workspace in (seq 1 10)
            swaymsg workspace $workspace, move workspace to output $monitor_output 2>/dev/null
        end
        
        echo "✓ Switched to Monitor with audio"
    else
        # Monitor is currently on, switch to TV
        echo "Switching to TV..."
        
        # Enable TV with Full HD resolution (not 4K)
        swaymsg output $tv_output enable
        swaymsg output $tv_output mode 1920x1080@60Hz
        
        # Disable monitor
        swaymsg output $monitor_output disable
        
        # Switch audio to TV HDMI
        pactl set-card-profile $audio_card $tv_audio_profile
        
        # Move all workspaces to TV
        for workspace in (seq 1 10)
            swaymsg workspace $workspace, move workspace to output $tv_output 2>/dev/null
        end
        
        echo "✓ Switched to TV (1080p) with audio"
    end
end
