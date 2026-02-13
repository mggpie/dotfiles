function inbox --description "Create a new markdown file in PARA inbox"
    if test (count $argv) -eq 0
        echo "Usage: inbox \"text\""
        return 1
    end

    set -l inbox_dir ~/Desktop/0-Inbox
    set -l timestamp (date +"%Y-%m-%d-%H%M%S")
    set -l filename "$inbox_dir/$timestamp.md"

    printf "# %s\n\n%s\n" (date +"%Y-%m-%d %H:%M:%S") "$argv[1]" > $filename
    echo "Created: $filename"
end
