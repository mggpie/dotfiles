# WiFi management function (use when cable fails)
function wifi --description "Manage WiFi connection (backup for cable)"
    # Auto-detect WiFi interface
    set -l wifi_iface (iw dev 2>/dev/null | grep Interface | awk '{print $2}' | head -n1)
    
    if test -z "$wifi_iface"
        echo "Error: No WiFi interface found"
        return 1
    end
    
    switch $argv[1]
        case start
            echo "Starting WiFi on $wifi_iface..."
            doas ln -sf /etc/sv/wpa_supplicant /var/service/
            sleep 2
            doas dhcpcd $wifi_iface
            
        case stop
            echo "Stopping WiFi on $wifi_iface..."
            doas rm -f /var/service/wpa_supplicant
            doas dhcpcd -k $wifi_iface
            
        case status
            doas wpa_cli status
            
        case '*'
            echo "Usage: wifi {start|stop|status}"
            echo ""
            echo "WiFi is disabled by default (cable preferred)."
            echo "Use 'wifi start' when cable connection fails."
            return 1
    end
end
