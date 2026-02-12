function file-manager --description "Open file manager - defaults to ~/Desktop"
    if test (count $argv) -eq 0
        command $FILE_MANAGER ~/Desktop
    else
        command $FILE_MANAGER $argv
    end
end
