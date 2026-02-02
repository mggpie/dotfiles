# Connect to Bose QC45 headphones and switch audio output
# NOTE: Bose QC45 must initiate the connection - press BT button on headphones
function boseconnect
    set -l BOSE_MAC "$BOSE_QC45_MAC"
    set -l BOSE_CARD "bluez_card."(string replace -a ':' '_' $BOSE_MAC)
    set -l BOSE_SINK "bluez_output."(string replace -a ':' '_' $BOSE_MAC)".1"

    if test -z "$BOSE_MAC"
        echo "Error: BOSE_QC45_MAC not set in environment"
        return 1
    end

    # Power on Bluetooth if needed
    if not bluetoothctl show | grep -q "Powered: yes"
        bluetoothctl power on
        sleep 1
    end

    # Check if already connected
    if bluetoothctl info $BOSE_MAC 2>/dev/null | grep -q "Connected: yes"
        echo "✅ Already connected!"
    else
        echo "🎧 Bose QC45 - Press Bluetooth button on headphones now"
        echo ""

        # Make discoverable so headphones can find us
        bluetoothctl discoverable on

        echo "⏳ Waiting for headphones to connect (15s timeout)..."

        set -l timeout 15
        set -l connected false

        for i in (seq $timeout)
            if bluetoothctl info $BOSE_MAC 2>/dev/null | grep -q "Connected: yes"
                set connected true
                break
            end
            sleep 1
        end

        bluetoothctl discoverable off

        if test "$connected" != "true"
            echo "❌ Connection timed out."
            echo "Press Bluetooth button on headphones and try again."
            return 1
        end

        echo "✅ Connected!"
    end

    # Wait for PipeWire to register the device
    echo "Setting up audio..."
    sleep 2

    # Set AAC profile (highest quality)
    pactl set-card-profile $BOSE_CARD a2dp-sink 2>/dev/null
    sleep 1

    # Set Bose as default audio output
    if pactl set-default-sink $BOSE_SINK 2>/dev/null
        echo "✅ Audio output: Niecierpek (AAC)"
        notify-send -i audio-headphones "Bose QC45" "Connected with AAC"
    else
        echo "⚠️  Could not set audio output automatically"
        pactl list sinks short
    end

    return 0
end
