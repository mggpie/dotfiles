function deploy
    if test (count $argv) -ne 1
        echo "Usage: deploy <tag>"
        echo "Example: deploy sway"
        return 1
    end
    
    set tag $argv[1]
    
    # Save current directory
    set original_dir (pwd)
    
    # Go to dotfiles directory
    cd ~/Desktop/1-Projects/dotfiles
    
    # Check if there are changes to commit
    if git status --porcelain | grep -q .
        echo "📝 Committing changes..."
        git add .
        git commit -m "Auto-deploy: $tag config - $(date '+%Y-%m-%d %H:%M:%S')"
        
        echo "⬆️  Pushing to GitHub..."
        git push
    else
        echo "✓ No changes to commit"
    end
    
    # Deploy with ansible
    echo "🚀 Deploying $tag tag..."
    ansible-playbook playbook.yml --tags $tag
    
    # Return to original directory
    cd $original_dir
end
