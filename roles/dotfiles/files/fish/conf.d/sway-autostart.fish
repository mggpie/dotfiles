# Autostart sway on TTY1
if status is-login
    if test (tty) = /dev/tty1
        if test -z "$WAYLAND_DISPLAY"
            if test -z "$SWAY_AUTOSTART_DONE"
                set -gx SWAY_AUTOSTART_DONE 1
                set -e SWAYSOCK
                set -e I3SOCK
                rm -f "$XDG_RUNTIME_DIR"/sway-ipc.*.sock 2>/dev/null
                rm -f "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null
                dbus-run-session sway
            end
        end
    end
end
