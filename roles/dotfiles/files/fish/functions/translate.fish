function translate --description "Translate selected text and replace it"
    set -l selected (wl-paste -p 2>/dev/null)
    
    if test -z "$selected"
        return 1
    end

    set -l translated (trans -b pl:en "$selected" 2>/dev/null)
    
    if test -z "$translated"
        return 1
    end

    echo -n "$translated" | wl-copy
    sleep 0.1
    wtype -k Delete -M ctrl -k v -m ctrl
end
