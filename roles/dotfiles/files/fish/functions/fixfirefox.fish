function fixfirefox --description "Fix Firefox font rendering issues"
    echo "Fixing Firefox..."
    
    # Kill Firefox if running
    pkill firefox
    sleep 1
    
    # Clear Firefox cache
    rm -rf ~/.cache/mozilla/firefox/
    
    # Regenerate font cache
    fc-cache -fv > /dev/null 2>&1
    
    echo "Firefox cache cleared and fonts regenerated"
    echo "Starting Firefox..."
    
    # Start Firefox in background
    firefox &
    disown
end
