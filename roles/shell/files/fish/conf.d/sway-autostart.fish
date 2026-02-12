# Autostart sway on TTY1
if status is-login
    if test (tty) = /dev/tty1
        if test -z "$WAYLAND_DISPLAY"
            if test -z "$SWAY_AUTOSTART_DONE"
                set -gx SWAY_AUTOSTART_DONE 1
                dbus-run-session sway
            end
        end
    end
end
