function lineout-keepalive --description "Keep analog line-out active to prevent amp buzz"
    set -l pattern 'paplay --raw.*/dev/zero'

    switch "$argv[1]"
        case stop
            pkill -f $pattern 2>/dev/null
        case sync
            set -l tv_active (swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.name == "HDMI-A-2") | .active')
            set -l default_sink (pactl info 2>/dev/null | grep '^Default Sink:' | string replace 'Default Sink: ' '')

            if test "$tv_active" = "true"; and string match -q '*analog-stereo' "$default_sink"
                lineout-keepalive start
            else
                lineout-keepalive stop
            end
        case restart
            lineout-keepalive stop
            lineout-keepalive start
        case start ''
            if pgrep -f $pattern >/dev/null
                return 0
            end

            paplay --raw --format=s16le --rate=48000 --channels=2 /dev/zero >/dev/null 2>&1 &
            disown $last_pid
        case '*'
            echo "Usage: lineout-keepalive [start|stop|restart|sync]"
            return 1
    end
end