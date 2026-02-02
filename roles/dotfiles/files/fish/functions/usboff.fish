function usboff -d "Unmount USB devices"
    set all_devices (lsblk -nrpo NAME,TYPE,SIZE,MOUNTPOINT,LABEL,RM | awk '($2=="disk" || $2=="part") && $NF=="1"')

    set mounted_devices
    for device in $all_devices
        set parts (string split ' ' $device)
        # Check if any part looks like a mount point
        for part in $parts[4..-2]
            if string match -r '^/' $part
                set -a mounted_devices $device
                break
            end
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

        # Parse mount point and label
        set mount ""
        set label ""
        for part in $parts[4..-2]
            if string match -r '^/' $part
                set mount $part
            else if test -z "$mount"
                set label $part
            end
        end

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
        if sudo umount $dev
            echo "Device unmounted successfully"
            # Clean up mount point
            set mount_point "/run/media/$USER/"(basename $dev)
            sudo rmdir $mount_point 2>/dev/null
        else
            echo "Failed to unmount device"
            return 1
        end
    else
        echo "Invalid choice"
        return 1
    end
end
