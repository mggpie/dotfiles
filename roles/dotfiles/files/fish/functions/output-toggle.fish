function output-toggle --description "Toggle audio output between monitor HDMI and line-out jack"
    set -l card alsa_card.pci-0000_00_1f.3
    set -l hdmi_sink alsa_output.pci-0000_00_1f.3.hdmi-stereo
    set -l analog_sink alsa_output.pci-0000_00_1f.3.analog-stereo
    set -l profile output:analog-stereo
    set -l sink $analog_sink
    set -l label "line-out (jack)"

    # Only one output profile can be active at a time on this card, so the
    # analog sink only exists in analog mode - its presence picks the direction.
    if pactl list sinks short | grep -q $analog_sink
        set profile output:hdmi-stereo
        set sink $hdmi_sink
        set label "monitor HDMI"
    end

    pactl set-card-profile $card $profile

    # The profile change is applied asynchronously; poll until the sink shows up
    for i in (seq 20)
        if pactl list sinks short | grep -q $sink
            break
        end
        sleep 0.1
    end

    pactl set-default-sink $sink
    # WirePlumber persists route mute state - clear it or the sink stays silent
    pactl set-sink-mute @DEFAULT_SINK@ 0
    echo "Audio: $label"
end
