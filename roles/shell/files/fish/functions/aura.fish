function aura
    switch $argv[1]
        case tango
            openrgb -d 0 --mode static --color 3465A4 >/dev/null 2>&1
        case rainbow
            openrgb -d 0 --mode rainbow >/dev/null 2>&1
        case off
            openrgb -d 0 --mode off >/dev/null 2>&1
        case '*'
            echo "Usage: aura [tango|rainbow|off]"
    end
end
