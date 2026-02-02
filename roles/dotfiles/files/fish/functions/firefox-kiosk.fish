function firefox-kiosk
    set -l url (count $argv >/dev/null && echo $argv[1] || echo "https://youtube.com/")
    firefox-wayland -new-window $url --kiosk --class=firefox-kiosk
end
