function move-downloads --description "Move files from Downloads to Documents/0-Inbox"
    set downloads ~/Downloads
    set inbox ~/Documents/0-Inbox

    # Check if Downloads directory exists and is not empty
    if test -d $downloads; and test (count $downloads/*) -gt 0 2>/dev/null
        # Find files not modified in the last 30 minutes and move them
        find $downloads -maxdepth 1 -type f -mmin +30 -exec mv {} $inbox/ \; 2>/dev/null
        
        # Also move directories (folders) not modified in the last 30 minutes
        find $downloads -maxdepth 1 -mindepth 1 -type d -mmin +30 -exec mv {} $inbox/ \; 2>/dev/null
    end
end
