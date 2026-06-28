function opencode-tunnel
    echo "Starting opencode server on localhost:4096..."
    nohup opencode serve --port 4096 > /dev/null 2>&1 &
    set -l void_ip (tailscale ip -4 2>/dev/null | head -1)
    if test -z "$void_ip"
        echo "Tailscale not connected. Run: sudo tailscale up"
        return 1
    end
    echo ""
    echo "OpenCode running. On your Mac, run:"
    echo "  ssh -N -L 4096:localhost:4096 $void_ip"
    echo ""
    echo "Then OpenChamber in VSCode will auto-connect to localhost:4096."
end
