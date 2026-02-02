function trash
    if test (count $argv) -eq 0
        $FILE_MANAGER ~/.local/share/Trash/files &
        return
    end
    
    switch $argv[1]
        case list
            ls -lh ~/.local/share/Trash/files/
        case size
            du -sh ~/.local/share/Trash/
        case clean
            set trash_size (du -sh ~/.local/share/Trash/ 2>/dev/null | cut -f1)
            echo "Trash size: $trash_size"
            rm -rf ~/.local/share/Trash/*
            echo "Trash cleaned!"
        case '*'
            echo "Usage: trash [list|size|clean]"
    end
end
