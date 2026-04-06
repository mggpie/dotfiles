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

    # Check if there are changes to commit
    if git status --porcelain | grep -q .
        echo "📝 Committing changes..."
        git add .
        git commit -m "Auto-update $tags_readable configuration"

        echo "⬆️  Pushing to GitHub..."
        git push
    else
        echo "✓ No changes to commit"
    end

    # Deploy with ansible
    echo "🚀 Deploying tags: $tags_readable"
    ansible-playbook playbook.yml --tags $tags

    # Return to original directory
    cd $original_dir
end
