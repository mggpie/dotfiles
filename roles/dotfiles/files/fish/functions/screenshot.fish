function screenshot --description "Take screenshot - select area, save to ~/3-Resources/pics/screenshots, copy to clipboard"
    # Guard against concurrent invocations from key repeat or rapid presses
    if pgrep -x slurp > /dev/null
        return
    end

    mkdir -p $HOME/3-Resources/pics/screenshots

    # Named pipe lets us block until slurp finishes inside wayfreeze's after-freeze-cmd.
    # --after-freeze-cmd runs slurp only after the compositor is fully frozen, so there's
    # no race between wayfreeze initializing and slurp appearing (the previous flash/double-click issue).
    set geom_pipe (mktemp -u /tmp/screenshot-XXXXXX)
    mkfifo $geom_pipe
    wayfreeze --hide-cursor --after-freeze-cmd "slurp 2>/dev/null > $geom_pipe" &
    set freeze_pid $last_pid

    # Blocks until slurp writes a selection or exits (on cancel the pipe closes with no data)
    set geom (cat $geom_pipe)
    rm -f $geom_pipe
    kill $freeze_pid 2>/dev/null

    if test -n "$geom"
        set filename $HOME/3-Resources/pics/screenshots/(date +%Y%m%d-%H%M%S).png
        grim -g $geom - | tee $filename | wl-copy
    end
end
