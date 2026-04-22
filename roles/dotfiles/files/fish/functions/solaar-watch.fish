function solaar-watch
    # Supervisor loop - solaar can exit on device sleep/wake events or crashes.
    # Without a restart loop it stays dead until the next sway session.
    while true
        solaar -w hide
        sleep 2
    end
end
