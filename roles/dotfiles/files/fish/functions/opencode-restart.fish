function opencode-restart
    pkill -x opencode
    sleep 0.3
    nohup opencode > /dev/null 2>&1 &
    disown
end
