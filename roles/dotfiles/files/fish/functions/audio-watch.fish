function audio-watch --description "Restart the PipeWire stack if it dies"
    # PipeWire 1.6.9 segfaults in libspa-support.so shortly after session start
    # (seen twice now) and nothing restarts it - audio then stays dead until a
    # reload, and Firefox falls back to raw ALSA and blocks the card on top.
    # exec_always starts this on every reload, so keep a single watcher.
    for pid in (pgrep -f '^fish -c audio-watch$' 2>/dev/null)
        test $pid = $fish_pid; and continue
        return 0
    end

    # Give the autostart block time to bring the stack up before judging it.
    sleep 10

    while true
        if not pgrep -x pipewire >/dev/null; or not pgrep -x wireplumber >/dev/null; or not pgrep -x pipewire-pulse >/dev/null
            echo (date "+%F %T") "audio-watch: stack incomplete, restarting" >>/tmp/audio-watch.log
            pkill -x wireplumber 2>/dev/null
            pkill -x pipewire-pulse 2>/dev/null
            pkill -x pipewire 2>/dev/null
            sleep 1
            pipewire >/dev/null 2>&1 &
            sleep 0.5
            pipewire-pulse >/dev/null 2>&1 &
            sleep 0.5
            wireplumber >/dev/null 2>&1 &
            sleep 5
        end
        sleep 5
    end
end
