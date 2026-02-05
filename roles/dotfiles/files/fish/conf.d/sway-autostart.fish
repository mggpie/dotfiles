# Start sway on TTY1 (only if not already running)
if test (tty) = /dev/tty1; and test -z "$WAYLAND_DISPLAY"
    sway
end
