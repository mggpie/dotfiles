function fixaudio --description "Restart PipeWire audio stack"
    echo "Stopping audio services..."
    pkill wireplumber 2>/dev/null
    pkill pipewire-pulse 2>/dev/null
    pkill pipewire 2>/dev/null
    sleep 1

    echo "Starting PipeWire..."
    pipewire &
    disown
    sleep 0.5

    echo "Starting PipeWire-Pulse..."
    pipewire-pulse &
    disown
    sleep 0.5

    echo "Starting WirePlumber..."
    wireplumber &
    disown
    sleep 1

    echo "Verifying..."
    if pactl info >/dev/null 2>&1
        lineout-keepalive sync

        echo "✓ Audio stack restarted successfully"
    else
        echo "✗ Something went wrong, check 'pactl info'"
    end
end
