function waybar-supervise --description "Keep the Waybar status bar alive"
    # Sway never respawns bar processes. Waybar aborts entirely when its
    # pulseaudio module loses PipeWire (pa_context_new() -> std::runtime_error),
    # so the bar stays gone until a reload. Supervise it instead.
    #
    # Sway spawns a fresh bar process on every reload but does not kill the old
    # one: drop previous supervisors and stray waybars so only one bar survives.
    # Match the full wrapper command line - a bare "waybar-supervise" pattern
    # would also kill unrelated processes that merely mention it.
    for pid in (pgrep -f "^/usr/bin/fish $HOME/.local/bin/waybar-supervise" 2>/dev/null)
        test $pid = $fish_pid; and continue
        kill $pid 2>/dev/null
    end
    pkill -x waybar 2>/dev/null

    # Sway hands bar clients the Wayland socket as an inherited fd
    # (WAYLAND_SOCKET). It is not usable through this wrapper and libwayland
    # fails on it instead of falling back to WAYLAND_DISPLAY.
    set -e WAYLAND_SOCKET

    while true
        waybar $argv
        sleep 1
    end
end
