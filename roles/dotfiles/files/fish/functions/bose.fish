function bose --description "Toggle Bose QC45 connection with audio switching"
    set -l mac "$BOSE_QC45_MAC"
    set -l mac_underscore (string replace -a ':' '_' $mac)
    set -l bt_card "bluez_card.$mac_underscore"
    set -l bt_sink "bluez_output.$mac_underscore.1"
    set -l hdmi_card "alsa_card.pci-0000_00_1f.3"

    if test -z "$mac"
        echo "❌ BOSE_QC45_MAC not set"
        return 1
    end

    # Determine current output sink for fallback when disconnecting
    set -l tv_active (swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.name == "HDMI-A-2") | .active')
    if test "$tv_active" = "true"
        set -l fallback_profile "output:analog-stereo"
        set -l fallback_sink "alsa_output.pci-0000_00_1f.3.analog-stereo"
    else
        set -l fallback_profile "output:hdmi-stereo"
        set -l fallback_sink "alsa_output.pci-0000_00_1f.3.hdmi-stereo"
    end

    # Check if already connected
    if bluetoothctl info $mac 2>/dev/null | grep -q "Connected: yes"
        # --- DISCONNECT ---
        echo "🎧 Disconnecting Bose QC45..."

        # Switch audio back to HDMI before disconnect
        pactl set-card-profile $hdmi_card $fallback_profile 2>/dev/null
        pactl set-default-sink $fallback_sink 2>/dev/null
        sleep 0.2
        lineout-keepalive sync

        bluetoothctl disconnect $mac 2>/dev/null

        echo "✅ Disconnected - audio on "(test "$tv_active" = "true" && echo "TV" || echo "Monitor")
        notify-send -i audio-speakers "Bose QC45" "Disconnected"
        return 0
    end

    # --- CONNECT ---
    echo "Connecting Bose QC45..."

    # Kill easyeffects - not wanted on headphones
    pkill -x easyeffects 2>/dev/null
    lineout-keepalive stop

    # Power on bluetooth if needed
    if not bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
        bluetoothctl power on
        sleep 1
    end

    # Check if device is paired
    set -l is_paired false
    if bluetoothctl info $mac 2>/dev/null | grep -q "Paired: yes"
        set is_paired true
    end

    set -l connected false

    if test "$is_paired" = "true"
        # Already paired - try direct connect from PC
        bluetoothctl connect $mac 2>/dev/null &

        for i in (seq 8)
            if bluetoothctl info $mac 2>/dev/null | grep -q "Connected: yes"
                set connected true
                break
            end
            sleep 1
        end
    end

    # Not paired or direct connect failed - scan, pair, and connect
    if test "$connected" != "true"
        if test "$is_paired" = "true"
            echo "⏳ Direct connect failed - scanning..."
        else
            echo "⏳ Not paired yet - scanning..."
        end

        bluetoothctl discoverable on 2>/dev/null
        bluetoothctl pairable on 2>/dev/null
        bluetoothctl --timeout 20 scan on 2>/dev/null &

        # Wait for device to appear in scan
        for i in (seq 20)
            if bluetoothctl devices 2>/dev/null | grep -q $mac
                break
            end
            sleep 1
        end

        # Pair if needed
        if test "$is_paired" != "true"
            bluetoothctl pair $mac 2>/dev/null
            sleep 2
        end

        # Trust + connect
        bluetoothctl trust $mac 2>/dev/null
        bluetoothctl connect $mac 2>/dev/null

        for i in (seq 10)
            if bluetoothctl info $mac 2>/dev/null | grep -q "Connected: yes"
                set connected true
                break
            end
            sleep 1
        end

        bluetoothctl discoverable off 2>/dev/null
        bluetoothctl scan off 2>/dev/null
    end

    if test "$connected" != "true"
        echo "❌ Connection timed out - put headphones in pairing mode and retry"
        return 1
    end

    # Trust for future auto-reconnects
    bluetoothctl trust $mac 2>/dev/null

    # Wait for PipeWire to register the bluetooth device
    echo "⏳ Setting up audio..."
    set -l sink_ready false
    for i in (seq 10)
        if pactl list sinks short 2>/dev/null | grep -q $bt_sink
            set sink_ready true
            break
        end
        sleep 0.5
    end

    if test "$sink_ready" != "true"
        echo "⚠️  Connected but PipeWire didn't register sink"
        echo "    Try: pactl list sinks short"
        return 1
    end

    # Set high quality profile and switch output
    pactl set-card-profile $bt_card a2dp-sink 2>/dev/null
    sleep 0.5
    pactl set-default-sink $bt_sink 2>/dev/null

    echo "✅ Connected - audio on Bose QC45 (AAC)"
    notify-send -i audio-headphones "Bose QC45" "Connected"
    return 0
end
