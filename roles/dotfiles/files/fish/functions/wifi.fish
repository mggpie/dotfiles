# WiFi management function (use when cable fails)
function wifi --description "Manage WiFi connection (backup for cable)"
    # Auto-detect WiFi interface
    set -l wifi_iface (iw dev 2>/dev/null | grep Interface | awk '{print $2}' | head -n1)
    
    if test -z "$wifi_iface"
        echo "❌ Error: No WiFi interface found"
        return 1
    end
    
    switch $argv[1]
        case start
            echo "Starting WiFi on $wifi_iface..."
            doas ln -sf /etc/sv/wpa_supplicant /var/service/
            sleep 3
            doas dhcpcd $wifi_iface
            
            # Wait for connection and IP
            echo "Waiting for connection..."
            sleep 3
            
            # Check connection status
            if doas wpa_cli -i $wifi_iface status 2>/dev/null | grep -q "wpa_state=COMPLETED"
                set -l ssid (doas wpa_cli -i $wifi_iface status | grep "^ssid=" | cut -d= -f2)
                echo "✅ Connected to: $ssid"
                
                # Wait for IP address (up to 5 seconds)
                for i in (seq 5)
                    set -l ip (ip addr show $wifi_iface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
                    if test -n "$ip"
                        echo "📶 IP address: $ip"
                        break
                    end
                    sleep 1
                end
            else
                echo "⚠️  WiFi service started but not connected yet"
                echo "   Check status with: wifi status"
            end
            
        case stop
            echo "Stopping WiFi on $wifi_iface..."
            doas dhcpcd -k $wifi_iface
            doas rm -f /var/service/wpa_supplicant
            sleep 1
            
            # Verify stopped
            if not test -e /var/service/wpa_supplicant
                echo "✅ WiFi stopped"
            else
                echo "⚠️  Failed to stop WiFi service"
                return 1
            end
            
        case status
            if test -e /var/service/wpa_supplicant
                echo "WiFi service: running"
                doas wpa_cli -i $wifi_iface status 2>/dev/null
            else
                echo "WiFi service: stopped"
            end
            
        case '*'
            echo "Usage: wifi {start|stop|status}"
            echo ""
            echo "WiFi is disabled by default (cable preferred)."
            echo "Use 'wifi start' when cable connection fails."
            return 1
    end
end
