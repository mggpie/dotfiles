function solaar-watch
    # Supervisor loop - solaar can exit on device sleep/wake events or crashes.
    # Without a restart loop it stays dead until the next sway session.
    #
    # Deploys restart the watchdog from outside the sway session (ansible),
    # which loses SWAYSOCK. Recover it so rule actions can still reach sway.
    if not set -q SWAYSOCK
        set -l sock (ls -t /run/user/(id -u)/sway-ipc.(id -u).*.sock 2>/dev/null | head -1)
        if test -n "$sock"
            set -gx SWAYSOCK $sock
        end
    end
    while true
        solaar -w hide
        sleep 2
    end
end
