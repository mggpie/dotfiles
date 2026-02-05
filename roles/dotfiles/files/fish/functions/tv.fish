function tv --description "Toggle between TV and Monitor with audio switching"
    # Define outputs
    set -l monitor_output "DP-1"
    set -l tv_output "HDMI-A-2"
    set -l monitor_audio_profile "output:hdmi-stereo"
    set -l tv_audio_profile "output:hdmi-stereo-extra1"
    set -l audio_card "alsa_card.pci-0000_00_1f.3"

    # Check current state by checking if TV is enabled
    set -l tv_status (swaymsg -t get_outputs -r | string match -r "\"name\"\\s*:\\s*\"$tv_output\".*?\"power\"\\s*:\\s*true" )

    if test -n "$tv_status"
        # TV is currently on, switch to Monitor
        echo "Switching to Monitor..."
        
        # First, move all workspaces to monitor while both are active
        swaymsg output $monitor_output enable
        sleep 0.2
        for workspace in (seq 1 10)
            swaymsg "[workspace=$workspace]" move workspace to output $monitor_output 2>/dev/null
        end
        
        # Configure monitor
        swaymsg output $monitor_output mode 3440x1440@75.050Hz
        swaymsg output $monitor_output scale 1.0
        
        # Now disable TV
        swaymsg output $tv_output disable
        
        # Switch audio to monitor HDMI
        pactl set-card-profile $audio_card $monitor_audio_profile
        
        echo "✓ Switched to Monitor with audio"
    else
        # Monitor is currently on, switch to TV
        echo "Switching to TV..."
        
        # First, enable and configure TV
        swaymsg output $tv_output enable
        sleep 0.2
        swaymsg output $tv_output mode 3840x2160@60Hz
        swaymsg output $tv_output scale 2.0
        
        # Move all workspaces to TV while both are active
        for workspace in (seq 1 10)
            swaymsg "[workspace=$workspace]" move workspace to output $tv_output 2>/dev/null
        end
        
        # Now disable monitor
        swaymsg output $monitor_output disable
        
        # Switch audio to TV HDMI
        pactl set-card-profile $audio_card $tv_audio_profile
        
        echo "✓ Switched to TV (4K scaled 2.0) with audio"
    end
end
