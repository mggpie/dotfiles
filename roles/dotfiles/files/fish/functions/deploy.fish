function deploy
    if test (count $argv) -lt 1
        echo "Usage: deploy <tag> [tag2 tag3 ...]"
        echo "Example: deploy sway"
        echo "Example: deploy sway fish mpv"
        return 1
    end

    set tags (string join "," $argv)
    set tags_readable (string join ", " $argv)

    # Save current directory
    set original_dir (pwd)

    # Find dotfiles directory
    set dotfiles_dir ""
    if test -d ~/1-Projects/dotfiles
        set dotfiles_dir ~/1-Projects/dotfiles
    else if test -d ~/2-Areas/dotfiles
        set dotfiles_dir ~/2-Areas/dotfiles
    else
        echo "Error: dotfiles repository not found in 1-Projects or 2-Areas"
        return 1
    end

    # Go to dotfiles directory
    cd $dotfiles_dir

    # Stage only tracked/modified files, never untracked
    # Prevents accidentally committing secrets or garbage files
    git add -u

    if not git diff --cached --quiet
        echo "Changes staged for commit:"
        git diff --cached --stat
        echo ""
        read -P "Proceed with commit? [Y/n] " -l confirm
        if test -z "$confirm"; or string match -qri "y" $confirm
            # Build commit message with changed files and tags
            set changed_files (git diff --cached --name-only | string join ", ")
            set commit_msg "deploy $tags_readable: $changed_files"
            if test (string length "$commit_msg") -gt 200
                set file_count (git diff --cached --name-only | wc -l | string trim)
                set commit_msg "deploy $tags_readable: $file_count files"
            end
            git commit -m "$commit_msg"

            echo "Pushing to GitHub..."
            git push
        else
            echo "Commit skipped. Unstaging changes..."
            git reset HEAD >/dev/null 2>&1
        end
    else
        echo "No tracked changes to commit"
    end

    # Deploy with ansible
    echo "🚀 Deploying tags: $tags_readable"
    ansible-playbook playbook.yml --tags $tags

    # Return to original directory
    cd $original_dir
end
