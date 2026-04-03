function screenshot --description "Take screenshot - select area, save to Pictures/Screenshots, copy to clipboard"
    # Create Screenshots directory if it does not exist
    mkdir -p $HOME/Pictures/Screenshots

    # Generate filename with timestamp
    set filename $HOME/Pictures/Screenshots/(date +%Y%m%d-%H%M%S).png

    # Freeze compositor output so videos/animations don't change during area selection
    wayfreeze &
    set freeze_pid $last_pid
    set geom (slurp 2>/dev/null)
    kill $freeze_pid 2>/dev/null

    # slurp exits non-zero when user cancels - only capture if selection was made
    if test -n "$geom"
        grim -g $geom - | tee $filename | wl-copy
    end
end
