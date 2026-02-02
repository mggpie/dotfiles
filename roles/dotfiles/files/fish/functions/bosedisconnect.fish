# Disconnect Bose QC45 headphones and switch to built-in audio
function bosedisconnect
    set -l BOSE_MAC "$BOSE_QC45_MAC"
    set -l BUILTIN_SINK "alsa_output.pci-0000_00_1f.3.hdmi-stereo"

    if test -z "$BOSE_MAC"
        echo "Error: BOSE_QC45_MAC not set in environment"
        return 1
    end

    # Switch audio to built-in first (before disconnect)
    echo "🔊 Switching audio to built-in..."
    if pactl set-default-sink $BUILTIN_SINK 2>/dev/null
        echo "✅ Audio output: Built-in"
    else
        # Try to find any non-bluetooth sink
        set -l fallback_sink (pactl list sinks short | grep -v bluez | head -1 | awk '{print $2}')
        if test -n "$fallback_sink"
            pactl set-default-sink $fallback_sink 2>/dev/null
            echo "✅ Audio output: $fallback_sink"
        end
    end

    # Check if connected
    if not bluetoothctl info $BOSE_MAC 2>/dev/null | grep -q "Connected: yes"
        echo "ℹ️  Bose QC45 is not connected"
        return 0
    end

    echo "🎧 Disconnecting Bose QC45..."

    if bluetoothctl disconnect $BOSE_MAC
        echo "✅ Disconnected"
        notify-send -i audio-speakers "Bose QC45" "Disconnected - using built-in audio"
        return 0
    else
        echo "❌ Failed to disconnect"
        return 1
    end
end
