function tv --description "Toggle between TV and Monitor with audio switching"
    # Define outputs
    set -l monitor_output "DP-1"
    set -l tv_output "HDMI-A-2"
    set -l monitor_audio_profile "output:hdmi-stereo"
    set -l tv_audio_profile "output:hdmi-stereo-extra1"
    set -l audio_card "alsa_card.pci-0000_00_1f.3"
    
    # Parse optional mode argument (4k60, 4k30, fhd, 1080p)
    set -l tv_mode "4k30"  # Default to 4K 30Hz (best for Intel integrated)
    if test (count $argv) -gt 0
        set tv_mode $argv[1]
    end

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
        
        # Set resolution based on mode
        switch $tv_mode
            case "4k60"
                swaymsg output $tv_output mode 3840x2160@60.000Hz
                swaymsg output $tv_output scale 2.0
                echo "Mode: 4K 60Hz (may flicker on Intel integrated)"
            case "4k30"
                swaymsg output $tv_output mode 3840x2160@30.000Hz
                swaymsg output $tv_output scale 2.0
                echo "Mode: 4K 30Hz (recommended for Intel integrated)"
            case "fhd" "1080p"
                swaymsg output $tv_output mode 1920x1080@60.000Hz
                swaymsg output $tv_output scale 1.0
                echo "Mode: Full HD 60Hz"
            case "*"
                swaymsg output $tv_output mode 3840x2160@30.000Hz
                swaymsg output $tv_output scale 2.0
                echo "Mode: 4K 30Hz (default)"
        end
        
        # Move all workspaces to TV while both are active
        for workspace in (seq 1 10)
            swaymsg workspace $workspace
            swaymsg move workspace to output $tv_output 2>/dev/null
        end
        
        # Now disable monitor
        swaymsg output $monitor_output disable
        
        # Switch audio to TV HDMI
        pactl set-card-profile $audio_card $tv_audio_profile
        
        echo "✓ Switched to TV with audio"
        echo "💡 Available modes: tv (4k30 default), tv 4k60, tv fhd"
    end
end
