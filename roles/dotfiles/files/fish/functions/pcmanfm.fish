function pcmanfm --description "PCManFM file manager - defaults to ~/Documents"
    if test (count $argv) -eq 0
        command pcmanfm ~/Documents
    else
        command pcmanfm $argv
    end
end
