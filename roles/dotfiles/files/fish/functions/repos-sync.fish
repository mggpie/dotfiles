function repos-sync
    # Scans PARA directories for GitHub repos and updates vars/main.yml to match.
    # Runs on boot via cron. Skips if last sync was less than 1 day ago.

    set -l state_file $HOME/.local/state/repos-sync-last
    set -l threshold 86400 # 1 day in seconds

    if test -f $state_file
        set -l last_run (cat $state_file)
        set -l now (date +%s)
        if test (math "$now - $last_run") -lt $threshold
            return 0
        end
    end

    set -l dotfiles $HOME/Desktop/1-Projects/dotfiles
    set -l vars_file $dotfiles/roles/dotfiles/vars/main.yml
    set -l para_base $HOME/Desktop

    # Get list of repos from GitHub
    set -l repos (gh repo list --json name --limit 100 --no-archived -q '.[].name' 2>/dev/null)
    test (count $repos) -eq 0; and return 0

    # Scan 1-Projects and 2-Areas for repos that are "active"
    set -l active
    for repo in $repos
        for dir in 1-Projects 2-Areas
            if test -d "$para_base/$dir/$repo/.git"
                set -a active $repo
                break
            end
        end
    end

    # If nothing found active, keep at least dotfiles
    if test (count $active) -eq 0
        set active dotfiles
    end

    # Build the new repos_active YAML block
    set -l new_block "repos_active:"
    for repo in $active
        set new_block "$new_block\n  - $repo"
    end

    # Update vars/main.yml - replace repos_active section using awk
    awk -v new=(printf '%s' "$new_block") '
        /^repos_active:/ { found=1; print new; next }
        found && /^  - / { next }
        found && !/^  - / { found=0 }
        { print }
    ' $vars_file >$vars_file.tmp && mv $vars_file.tmp $vars_file

    # Check if anything changed in dotfiles
    cd $dotfiles; or return 0
    if not git diff --quiet -- roles/dotfiles/vars/main.yml
        git add roles/dotfiles/vars/main.yml
        git commit -m "auto: repos-sync updated PARA destinations"
        git push
    end

    # Save last run timestamp
    mkdir -p (dirname $state_file)
    date +%s >$state_file
end
