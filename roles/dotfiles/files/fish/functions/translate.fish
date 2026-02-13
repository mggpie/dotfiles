function translate --description "Translate selected text and copy to clipboard"
    set -l selected (wl-paste -p 2>/dev/null)
    
    if test -z "$selected"
        notify-send "Translate" "No text selected"
        return 1
    end

    set -l translated (trans -b pl:en "$selected" 2>/dev/null)
    
    if test -z "$translated"
        notify-send "Translate" "Translation failed"
        return 1
    end

    echo -n "$translated" | wl-copy
    notify-send "Translate" "$translated"
end
