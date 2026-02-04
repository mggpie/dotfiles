# WiFi management function (use when cable fails)
function wifi --description "Manage WiFi connection (backup for cable)"
    switch $argv[1]
        case start
            echo "Starting WiFi..."
            doas sv up wpa_supplicant
            sleep 2
            doas dhcpcd wlan0
            
        case stop
            echo "Stopping WiFi..."
            doas sv down wpa_supplicant
            doas dhcpcd -k wlan0
            
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
