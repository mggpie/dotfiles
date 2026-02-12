function thunar --description "Thunar file manager - defaults to ~/Desktop"
    if test (count $argv) -eq 0
        command thunar ~/Desktop
    else
        command thunar $argv
    end
end
