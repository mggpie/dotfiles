function radio
    set -l stations \
        "Lofi Hip-Hop"       "https://www.youtube.com/watch?v=jfKfPfyJRdk" \
        "Jarkendar"          "https://www.youtube.com/watch?v=dRnH2cU3_m4" \
        "Forest sounds"      "https://www.youtube.com/watch?v=OVLIbpPejCU" \
        "Life in the Colony" "https://www.youtube.com/watch?v=s0aDp1CFZ7Q" \
        "Swamp Camp"         "https://www.youtube.com/watch?v=EZG7xHVwyXk" \
        "Relaxing Forest"    "https://www.youtube.com/watch?v=td7xQnweIFE" \
        "Gothic OST"         "https://www.youtube.com/watch?v=Q7gVCSu7imE" \
        "Campfire"           "https://www.youtube.com/watch?v=8KrLtLr-Gy8" \
        "Robin Hood"         "https://www.youtube.com/watch?v=LpuaYBEW0D0"

    set -l names
    set -l urls
    for i in (seq 1 2 (count $stations))
        set -a names $stations[$i]
        set -a urls $stations[(math $i + 1)]
    end

    set -l pid_file /tmp/radio_pid
    set -l state_file /tmp/radio_state
    set -l history_file /tmp/radio_history

    switch "$argv[1]"
        case start
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                return
            end
            set -l idx
            if test -f $state_file
                set idx (cat $state_file)
            else
                set idx (math (random) % (count $names) + 1)
                echo $idx >$state_file
            end
            echo $idx >>$history_file
            mpv --vo=null --no-video --really-quiet --force-media-title=radio-stream $urls[$idx] &
            echo $last_pid >$pid_file
            disown $last_pid

        case stop
            if test -f $pid_file
                kill (cat $pid_file) 2>/dev/null
                rm -f $pid_file
            end
            rm -f $history_file

        case toggle
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                radio stop
            else
                radio start
            end

        case prev
            if not test -f $history_file
                return
            end
            # Remove current station from history
            sed -i '$d' $history_file
            # Get previous station
            set -l idx (tail -1 $history_file 2>/dev/null)
            if test -z "$idx"
                return
            end
            echo $idx >$state_file
            if test -f $pid_file
                kill (cat $pid_file) 2>/dev/null
                rm -f $pid_file
            end
            sleep 1
            mpv --vo=null --no-video --really-quiet --force-media-title=radio-stream $urls[$idx] &
            echo $last_pid >$pid_file
            disown $last_pid

        case next
            set -l idx (math (random) % (count $names) + 1)
            if test -f $state_file
                set -l current (cat $state_file)
                while test $idx -eq $current -a (count $names) -gt 1
                    set idx (math (random) % (count $names) + 1)
                end
            end
            echo $idx >$state_file
            echo $idx >>$history_file
            if test -f $pid_file
                kill (cat $pid_file) 2>/dev/null
                rm -f $pid_file
            end
            sleep 1
            mpv --vo=null --no-video --really-quiet --force-media-title=radio-stream $urls[$idx] &
            echo $last_pid >$pid_file
            disown $last_pid

        case status
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                set -l idx 1
                if test -f $state_file
                    set idx (cat $state_file)
                end
                printf "{\"text\": \"<span rise='2000'>%s</span>\", \"tooltip\": \"Radio: %s (click to stop)\"}" \
                    "$names[$idx]" "$names[$idx]"
            else
                printf "{\"text\": \"<span rise='2000'>Radio</span>\", \"tooltip\": \"Radio (click to start)\"}"
            end

        case '*'
            echo "Usage: radio [start|stop|toggle|prev|next|status]"
    end
end
