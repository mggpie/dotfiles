function poweroff-timer
    if test "$argv[1]" = "cancel"
        if test -f /tmp/timer.pid
            set pid (cat /tmp/timer.pid)
            kill $pid 2>/dev/null && echo "Timer cancelled" || echo "No active timer"
            rm -f /tmp/timer.pid
        else
            echo "No active timer"
        end
        return
    end

    if test (count $argv) -eq 0
        echo "Usage: poweroff-timer <minutes> | poweroff-timer cancel"
        return 1
    end

    set minutes $argv[1]
    set seconds (math "$minutes * 60")

    echo "System will power off in $minutes minute(s)"
    echo "To cancel: poweroff-timer cancel"

    # Turn off RGB aura immediately
    openrgb -d 0 --mode off >/dev/null 2>&1

    fish -c "sleep $seconds && $HOME/.local/bin/poweroff" &
    echo $last_pid > /tmp/timer.pid
end
