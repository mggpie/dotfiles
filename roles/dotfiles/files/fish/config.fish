# Fish configuration

# Disable greeting
set -g fish_greeting

# Environment
set -gx EDITOR micro
set -gx VISUAL micro
set -gx PAGER less
set -gx TERMINAL foot

# XDG
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# Wayland
set -gx MOZ_ENABLE_WAYLAND 1
set -gx ELECTRON_OZONE_PLATFORM_HINT auto

# Path
fish_add_path $HOME/.local/bin

# Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias tree='eza --tree --icons'
alias cat='bat --plain'
alias grep='rg'
alias find='fd'

# USB mount function
function usb
    # List available USB devices
    set devices (lsblk -nrpo NAME,TYPE,SIZE,MOUNTPOINT,LABEL | grep 'part' | grep -v '/boot' | grep -v '/home' | grep -v '/$')

    if test (count $devices) -eq 0
        echo "No USB devices found"
        return 1
    end

    echo "Available devices:"
    echo ""
    set -l i 1
    for device in $devices
        set parts (string split ' ' $device)
        set dev $parts[1]
        set size $parts[3]
        set mount $parts[4]
        set label $parts[5]

        if test -n "$mount"
            echo "[$i] $dev ($size) - Mounted at: $mount"
            if test -n "$label"
                echo "    Label: $label"
            end
        else
            echo "[$i] $dev ($size) - Not mounted"
            if test -n "$label"
                echo "    Label: $label"
            end
        end
        set i (math $i + 1)
    end

    echo ""
    echo "Enter device number to mount/open (or 'q' to quit): "
    read -n 1 choice

    if test "$choice" = "q"
        return 0
    end

    if test "$choice" -ge 1 -a "$choice" -le (count $devices)
        set selected $devices[$choice]
        set parts (string split ' ' $selected)
        set dev $parts[1]
        set mount $parts[4]

        if test -n "$mount"
            echo "Opening $mount..."
            pcmanfm "$mount" &
        else
            echo "Mounting $dev..."
            if udisksctl mount -b $dev
                set mountpoint (udisksctl info -b $dev | grep MountPoints | awk '{print $2}')
                echo "Mounted at: $mountpoint"
                pcmanfm "$mountpoint" &
            else
                echo "Failed to mount device"
                return 1
            end
        end
    else
        echo "Invalid choice"
        return 1
    end
end

# Unmount USB function
function usboff
    set devices (lsblk -nrpo NAME,TYPE,SIZE,MOUNTPOINT,LABEL | grep 'part' | grep -v '/boot' | grep -v '/home' | grep -v '/$' | grep -v '^$')

    set mounted_devices
    for device in $devices
        set parts (string split ' ' $device)
        set mount $parts[4]
        if test -n "$mount"
            set -a mounted_devices $device
        end
    end

    if test (count $mounted_devices) -eq 0
        echo "No mounted USB devices found"
        return 1
    end

    echo "Mounted devices:"
    echo ""
    set -l i 1
    for device in $mounted_devices
        set parts (string split ' ' $device)
        set dev $parts[1]
        set size $parts[3]
        set mount $parts[4]
        set label $parts[5]

        echo "[$i] $dev ($size) - $mount"
        if test -n "$label"
            echo "    Label: $label"
        end
        set i (math $i + 1)
    end

    echo ""
    echo "Enter device number to unmount (or 'q' to quit): "
    read -n 1 choice

    if test "$choice" = "q"
        return 0
    end

    if test "$choice" -ge 1 -a "$choice" -le (count $mounted_devices)
        set selected $mounted_devices[$choice]
        set parts (string split ' ' $selected)
        set dev $parts[1]

        echo "Unmounting $dev..."
        if udisksctl unmount -b $dev
            echo "Device unmounted successfully"
            echo "Powering off $dev..."
            udisksctl power-off -b $dev
        else
            echo "Failed to unmount device"
            return 1
        end
    else
        echo "Invalid choice"
        return 1
    end
end

# Screenshot function - select area, save to Pictures/Screenshots, copy to clipboard
function screenshot
    # Create Screenshots directory if it doesn't exist
    mkdir -p $HOME/Pictures/Screenshots

    # Generate filename with timestamp
    set filename $HOME/Pictures/Screenshots/(date +%Y%m%d-%H%M%S).png

    # Take screenshot of selected area, save to file and copy to clipboard
    grim -g (slurp) - | tee $filename | wl-copy
end

# Start sway on TTY1
if test (tty) = /dev/tty1
    exec sway
end
