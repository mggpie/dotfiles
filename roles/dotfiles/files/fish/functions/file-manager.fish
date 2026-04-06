function file-manager --description "Open file manager - defaults to ~"
    if test (count $argv) -eq 0
        command $FILE_MANAGER ~
    else
        command $FILE_MANAGER $argv
    end
end
