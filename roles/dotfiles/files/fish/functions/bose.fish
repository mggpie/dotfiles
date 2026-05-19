function bose --description "Toggle Bose QC45 connection with audio switching"
    set -l repair_mode false
    if contains -- --repair $argv
        set repair_mode true
    end

    set -l mac "$BOSE_QC45_MAC"
    set -l mac_underscore (string replace -a ':' '_' $mac)
    set -l bt_card "bluez_card.$mac_underscore"
    set -l hdmi_card "alsa_card.pci-0000_00_1f.3"

    if test -z "$mac"
        echo "❌ BOSE_QC45_MAC not set"
        return 1
    end

    # Determine current output sink for fallback when disconnecting
    set -l fallback_profile ""
    set -l fallback_sink ""
    set -l tv_active (swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.name == "HDMI-A-2") | .active')
    if test "$tv_active" = "true"
        set fallback_profile "output:analog-stereo"
        set fallback_sink "alsa_output.pci-0000_00_1f.3.analog-stereo"
    else
        set fallback_profile "output:hdmi-stereo"
        set fallback_sink "alsa_output.pci-0000_00_1f.3.hdmi-stereo"
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
    set -l connect_error ""

    if test "$repair_mode" = "true"
        echo "Resetting stored Bose pairing..."
        bluetoothctl disconnect $mac 2>/dev/null
        bluetoothctl remove $mac 2>/dev/null
        set is_paired false
    end

    if test "$is_paired" = "true"
        # Already paired - try direct connect from PC
        set -l connect_output (bluetoothctl connect $mac 2>&1)
        if test (count $connect_output) -gt 0
            printf '%s\n' $connect_output
        end

        if string match -rq 'br-connection-key-missing' -- $connect_output
            set connect_error "stale-bond"
        end

        for i in (seq 8)
            if bluetoothctl info $mac 2>/dev/null | grep -q "Connected: yes"
                set connected true
                break
            end
            sleep 1
        end
    end

    if test "$connect_error" = "stale-bond"
        echo "Stored Bose pairing is stale - removing old bond"
        bluetoothctl disconnect $mac 2>/dev/null
        bluetoothctl remove $mac 2>/dev/null
        set is_paired false
        set connected false
    end

    # Not paired or direct connect failed - scan, pair, and connect
    if test "$connected" != "true"
        if test "$connect_error" = "stale-bond"
            echo "⏳ Old pairing removed - put Bose QC45 in pairing mode..."
        else if test "$is_paired" = "true"
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
            set -l pair_output (bluetoothctl pair $mac 2>&1)
            if test (count $pair_output) -gt 0
                printf '%s\n' $pair_output
            end

            if not bluetoothctl info $mac 2>/dev/null | grep -q "Paired: yes"
                bluetoothctl discoverable off 2>/dev/null
                bluetoothctl scan off 2>/dev/null
                echo "❌ Pairing failed - hold the power slider until the LED blinks blue and retry"
                return 1
            end

            sleep 2
        end

        # Trust + connect
        bluetoothctl trust $mac 2>/dev/null
        set -l connect_output (bluetoothctl connect $mac 2>&1)
        if test (count $connect_output) -gt 0
            printf '%s\n' $connect_output
        end

        if string match -rq 'br-connection-key-missing' -- $connect_output
            set connect_error "stale-bond"
        end

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

    # Wait for PipeWire to register the bluetooth card first.
    echo "⏳ Setting up audio..."
    set -l card_ready false
    for i in (seq 10)
        if pactl list cards short 2>/dev/null | grep -Fq $bt_card
            set card_ready true
            break
        end
        sleep 0.5
    end

    if test "$card_ready" != "true"
        if test "$connect_error" = "stale-bond"
            echo "⚠️  Bluetooth connected without an audio card"
            echo "    Old pairing was removed. Put Bose QC45 in pairing mode and run: bose --repair"
        else
            echo "⚠️  Connected but PipeWire didn't register bluetooth card"
            echo "    Try: bluetoothctl info $mac"
        end
        return 1
    end

    pactl set-card-profile $bt_card a2dp-sink 2>/dev/null
    sleep 0.5

    set -l sink_ready false
    set -l bt_sink ""
    for i in (seq 10)
        set bt_sink (pactl list sinks short 2>/dev/null | grep -F "bluez_output.$mac_underscore" | awk 'NR == 1 { print $2 }')
        if test -n "$bt_sink"
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

    pactl set-default-sink $bt_sink 2>/dev/null

    echo "✅ Connected - audio on Bose QC45 (AAC)"
    notify-send -i audio-headphones "Bose QC45" "Connected"
    return 0
end
