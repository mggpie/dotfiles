function waybar-supervise --description "Keep the Waybar status bar alive"
    # Sway never respawns bar processes. Waybar aborts entirely when its
    # pulseaudio module loses PipeWire (pa_context_new() -> std::runtime_error),
    # and the bar then stays gone until a reload. Loop instead.
    # On reload sway kills this wrapper but not its waybar child, so clear the
    # orphan before starting a new one.
    pkill -x waybar 2>/dev/null
    while true
        waybar
        sleep 1
    end
end
