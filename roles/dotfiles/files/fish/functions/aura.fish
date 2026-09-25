# Direct HID control for the ASUS Aura USB mainboard controller.
#
# OpenRGB 1.0 sends EC 52 53 00 01 ("stop using gen 2") on connect. On this
# board's AULA3-AR32-0207 firmware that command wedges the lighting engine:
# the controller keeps answering reads but ignores every mode/color/direct
# packet until it gets a USB port reset. OpenRGB 0.9 never sent it, which is
# why the old openrgb-based functions worked for years. We speak the Gen1
# protocol directly instead.
#
# Protocol (65-byte zero-padded HID reports):
#   EC 35 <channel> 00 00 <mode>        set effect mode
#   EC 36 <mask hi> <mask lo> 00 ...    set effect color; one mask bit per
#                                       LED, colors shifted by 3 * start_led
#   EC 3F 55                            commit current effect to NVRAM
#
# Modes: 00 off, 01 static, 02 breathing, 03 flashing, 04 spectrum cycle,
#        05 rainbow, 07 chase fade, 09 chase.

function __aura_node
    for h in /sys/class/hidraw/hidraw*
        if string match -q '*0B05:19AF*' (readlink -f $h/device 2>/dev/null)
            echo /dev/(basename $h)
            return 0
        end
    end
    return 1
end

function __aura_send
    set -l node (__aura_node)
    or begin
        echo "aura: ASUS Aura controller not found" >&2
        return 1
    end

    set -l fmt
    for byte in $argv
        set fmt "$fmt\\x"(printf '%02X' (math "0x$byte"))
    end
    for i in (seq (math 65 - (count $argv)))
        set fmt "$fmt\\x00"
    end

    # dd keeps the report in one 65-byte write; hidraw rejects short reports.
    printf $fmt | dd of=$node bs=65 count=1 status=none
end

function __aura_effect
    set -l mode $argv[1]
    set -l color $argv[2..-1]

    # Channel 0 is the onboard Aura LED, channel 1 the addressable header.
    __aura_send EC 35 00 00 00 $mode
    __aura_send EC 35 01 00 00 $mode

    if test (count $color) -eq 3
        # Fixed channel: LED mask 0x0001, color at offset 0.
        __aura_send EC 36 00 01 00 00 $color[1] $color[2] $color[3]
        # Addressable header: mask 0x0002, color shifted by 3 bytes (1 LED).
        __aura_send EC 36 00 02 00 00 00 00 $color[1] $color[2] $color[3]
    end
end

function __aura_reset
    set -l usbdev
    for dev in /sys/bus/usb/devices/*
        if test -f $dev/idVendor
            and test (cat $dev/idVendor) = "0b05"
            and test (cat $dev/idProduct) = "19af"
            set usbdev $dev
            break
        end
    end
    if test -z "$usbdev"
        echo "aura: Aura USB device not found" >&2
        return 1
    end

    set -l path (printf '/dev/bus/usb/%03d/%03d' (cat $usbdev/busnum) (cat $usbdev/devnum))
    echo "aura: resetting $path"
    doas python3 -c "
import fcntl, sys
with open(sys.argv[1], 'rb+') as f:
    fcntl.ioctl(f, 0x5514)  # USBDEVFS_RESET
" $path
    or return 1
    sleep 3
end

function aura
    if test (count $argv) -eq 0
        echo "Usage: aura [tango|rainbow|flashing|off|commit|reset]"
        return 1
    end

    switch $argv[1]
        case tango
            __aura_effect 01 34 65 A4
        case rainbow
            __aura_effect 05
        case flashing
            __aura_effect 03 FF 00 00
        case off
            __aura_effect 00
        case commit
            # Persist the active effect so it survives a power cycle.
            __aura_send EC 3F 55
        case reset
            # Recover the controller after OpenRGB 1.0 wedged it, then light
            # the ready state again.
            __aura_reset
            and __aura_effect 05
        case '*'
            echo "Usage: aura [tango|rainbow|flashing|off|commit|reset]"
            return 1
    end
end