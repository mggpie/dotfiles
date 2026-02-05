# Start sway on TTY1 (only if not already running and not in a logout loop)
if test (tty) = /dev/tty1; and test -z "$WAYLAND_DISPLAY"; and test -z "$SWAYSOCK"
    dbus-run-session sway
    exit
end
