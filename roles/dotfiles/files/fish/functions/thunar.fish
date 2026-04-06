function thunar --description "Thunar file manager - defaults to ~"
    if test (count $argv) -eq 0
        command thunar ~
    else
        command thunar $argv
    end
end
