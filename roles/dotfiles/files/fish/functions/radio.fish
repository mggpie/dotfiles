function radio
    set -l stations \
        "lofi hip hop"       "https://www.youtube.com/watch?v=jfKfPfyJRdk" \
        "lofi sleep"         "https://www.youtube.com/watch?v=28KRPhVzCus" \
        "lofi jazz"          "https://www.youtube.com/watch?v=HuFYqnbVbzY" \
        "synthwave"          "https://www.youtube.com/watch?v=4xDzrJKXOOY" \
        "dark ambient"       "https://www.youtube.com/watch?v=S_MOd40zlYU" \
        "gothic 1 ambient"   "https://www.youtube.com/watch?v=Li4i5JmYXDY" \
        "gothic 2 ambient"   "https://www.youtube.com/watch?v=6OU1Wo2vJZQ" \
        "gothic 3 ambient"   "https://www.youtube.com/watch?v=7x9nzN54GtY"

    set -l names
    set -l urls
    for i in (seq 1 2 (count $stations))
        set -a names $stations[$i]
        set -a urls $stations[(math $i + 1)]
    end

    set -l pid_file /tmp/radio_pid
    set -l state_file /tmp/radio_state

    switch "$argv[1]"
        case start
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                return
            end
            set -l idx (math (random) % (count $names) + 1)
            echo $idx >$state_file
            mpv --vo=null --no-video --really-quiet --force-media-title=radio-stream $urls[$idx] &
            echo $last_pid >$pid_file
            disown $last_pid

        case stop
            if test -f $pid_file
                kill (cat $pid_file) 2>/dev/null
                rm -f $pid_file
            end
            rm -f $state_file

        case toggle
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                radio stop
            else
                radio start
            end

        case prev
            set -l idx 1
            if test -f $state_file
                set idx (cat $state_file)
            end
            set idx (math $idx - 1)
            if test $idx -lt 1
                set idx (count $names)
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
            set -l idx 1
            if test -f $state_file
                set idx (cat $state_file)
            end
            set idx (math $idx + 1)
            if test $idx -gt (count $names)
                set idx 1
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

        case status
            if test -f $pid_file && kill -0 (cat $pid_file) 2>/dev/null
                set -l idx 1
                if test -f $state_file
                    set idx (cat $state_file)
                end
                printf "{\"text\": \"<span rise='2000'>%s</span>\", \"tooltip\": \"Radio: %s (click to stop)\"}" \
                    "$names[$idx]" "$names[$idx]"
            else
                printf "{\"text\": \"<span rise='2000'>off</span>\", \"tooltip\": \"Radio (click to start)\"}"
            end

        case '*'
            echo "Usage: radio [start|stop|toggle|prev|next|status]"
    end
end
