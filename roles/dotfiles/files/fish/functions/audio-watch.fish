function audio-watch --description "Restart the PipeWire stack if it dies"
    # PipeWire crashed at session start twice (segfault in libspa-support.so) and
    # nothing restarts it - audio then stays dead until a reload, and apps end up
    # on raw ALSA. Restart only the component that died: a full stack restart also
    # kills pipewire-pulse, which drops the audio connections of running apps
    # (Firefox does not recover from that). pipewire-pulse survives a pipewire
    # restart and reconnects on its own.
    # exec_always starts this on every reload, so keep a single watcher.
    for pid in (pgrep -f '^fish -c audio-watch$' 2>/dev/null)
        test $pid = $fish_pid; and continue
        return 0
    end

    # Give the autostart block time to bring the stack up before judging it.
    sleep 10

    while true
        set -l pipewire_was_down 0
        if not pgrep -x pipewire >/dev/null
            echo (date "+%F %T") "audio-watch: pipewire down, starting" >>/tmp/audio-watch.log
            pipewire >/dev/null 2>&1 &
            set pipewire_was_down 1
        end
        if not pgrep -x wireplumber >/dev/null
            echo (date "+%F %T") "audio-watch: wireplumber down, starting" >>/tmp/audio-watch.log
            wireplumber >/dev/null 2>&1 &
        end

        # Only judge pulse once pipewire has had time to come up.
        if test $pipewire_was_down = 0
            if not pactl info >/dev/null 2>&1
                echo (date "+%F %T") "audio-watch: pulse not serving, restarting" >>/tmp/audio-watch.log
                pkill -x pipewire-pulse 2>/dev/null
                sleep 1
                pipewire-pulse >/dev/null 2>&1 &
            end
        end

        sleep 5
    end
end
