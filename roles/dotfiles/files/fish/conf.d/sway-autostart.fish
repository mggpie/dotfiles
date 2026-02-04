# Autostart sway on TTY1
if status is-login; and test (tty) = /dev/tty1; and test -z "$WAYLAND_DISPLAY"
    exec dbus-run-session sway
end
