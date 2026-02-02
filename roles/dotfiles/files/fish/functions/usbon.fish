function usbon -d "Mount and open USB devices"
    # List available USB devices (removable drives)
    set devices (lsblk -nrpo NAME,TYPE,SIZE,MOUNTPOINT,LABEL,RM | awk '($2=="disk" || $2=="part") && $NF=="1"')

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
        set type $parts[2]
        set size $parts[3]

        # Check if mounted by looking for paths starting with /
        set mount ""
        set label ""
        for part in $parts[4..-2]
            if string match -r '^/' $part
                set mount $part
            else if test -z "$mount"
                set label $part
            end
        end

        if test -n "$mount"
            echo "[$i] $dev ($size) - Mounted at: $mount"
        else
            echo "[$i] $dev ($size) - Not mounted"
        end
        if test -n "$label"
            echo "    Label: $label"
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

        # Parse mount point from selected device
        set mount ""
        for part in $parts[4..-2]
            if string match -r '^/' $part
                set mount $part
                break
            end
        end

        if test -n "$mount"
            echo "Opening $mount..."
            pcmanfm "$mount" &
        else
            echo "Mounting $dev..."
            set mount_point "/run/media/$USER/"(basename $dev)
            set uid (id -u)
            set gid (id -g)
            if sudo mkdir -p $mount_point && sudo mount -o uid=$uid,gid=$gid,dmask=022,fmask=133 $dev $mount_point
                echo "Mounted at: $mount_point"
                pcmanfm "$mount_point" &
            else
                echo "Failed to mount device"
                sudo rmdir $mount_point 2>/dev/null
                return 1
            end
        end
    else
        echo "Invalid choice"
        return 1
    end
end
