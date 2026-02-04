# WiFi management function (use when cable fails)
function wifi --description "Manage WiFi connection (backup for cable)"
    switch $argv[1]
        case start
            echo "Starting WiFi..."
            doas ln -sf /etc/sv/wpa_supplicant /var/service/
            sleep 2
            doas dhcpcd wlo1
            
        case stop
            echo "Stopping WiFi..."
            doas rm -f /var/service/wpa_supplicant
            doas dhcpcd -k wlo1
            
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
