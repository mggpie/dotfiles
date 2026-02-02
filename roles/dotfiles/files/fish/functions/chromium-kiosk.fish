function chromium-kiosk
    set -l url (count $argv >/dev/null && echo $argv[1] || echo "https://youtube.com/")
    chromium $url \
        --kiosk \
        --incognito \
        --noerrdialogs \
        --disable-infobars \
        --disable-translate \
        --disable-features=TranslateUI \
        --no-first-run \
        --disable-pinch \
        --overscroll-history-navigation=0 \
        --disk-cache-dir=/dev/null \
        --class=chromium-kiosk
end
