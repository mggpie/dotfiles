# Pair Bose QC45 headphones
# NOTE: Bose QC45 require that THEY initiate the connection
function bosepair
    set -l BOSE_MAC "$BOSE_QC45_MAC"
    
    if test -z "$BOSE_MAC"
        echo "Error: BOSE_QC45_MAC not set in environment"
        return 1
    end
    
    echo "🎧 Bose QC45 Pairing"
    echo ""
    echo "1. Put headphones in pairing mode (hold Bluetooth button ~3s)"
    echo "2. Wait for 'ready to pair' voice prompt"
    echo "3. Press Enter here, then SHORT press Bluetooth button on headphones"
    echo "   (the headphones must initiate the connection)"
    echo ""
    read -P "Press Enter when ready..."
    
    # Power on Bluetooth and make discoverable
    echo ""
    echo "Making computer discoverable..."
    bluetoothctl power on
    bluetoothctl discoverable on
    bluetoothctl pairable on
    
    # Remove old pairing if exists
    bluetoothctl remove $BOSE_MAC 2>/dev/null
    
    echo ""
    echo "⏳ Waiting for headphones to connect (press BT button on headphones now)..."
    echo "   Timeout: 30 seconds"
    echo ""
    
    # Wait for connection from headphones
    set -l timeout 30
    set -l connected false
    
    for i in (seq $timeout)
        if bluetoothctl info $BOSE_MAC 2>/dev/null | grep -q "Connected: yes"
            set connected true
            break
        end
        sleep 1
    end
    
    bluetoothctl discoverable off
    
    if test "$connected" = "true"
        # Trust for future connections
        bluetoothctl trust $BOSE_MAC
        echo ""
        echo "✅ Bose QC45 connected!"
        notify-send -i bluetooth "Bose QC45" "Connected"
        return 0
    else
        echo ""
        echo "❌ Connection timed out."
        echo "Make sure you pressed the Bluetooth button on headphones."
        return 1
    end
end
