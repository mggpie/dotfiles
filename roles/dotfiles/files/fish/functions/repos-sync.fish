function repos-sync
    # Syncs local PARA directories with GitHub repos.
    # Clones new repos to 4-Archives, removes deleted repos, updates vars/main.yml.
    # Runs on every boot via cron. Idempotent.

    set -l dotfiles $HOME/Desktop/1-Projects/dotfiles
    set -l vars_file $dotfiles/roles/dotfiles/vars/main.yml
    set -l para_base $HOME/Desktop
    set -l para_dirs 1-Projects 2-Areas 3-Resources 4-Archives

    # All repo names (including archived) — for deletion check
    set -l all_names (gh repo list --json name --limit 100 -q '.[].name' 2>/dev/null)
    test (count $all_names) -eq 0; and return 0

    # Non-archived repos with SSH URLs — for cloning new repos
    set -l clone_entries (gh repo list --json name,sshUrl --limit 100 --no-archived -q '.[] | "\(.name)\t\(.sshUrl)"' 2>/dev/null)

    # Clone new repos to 4-Archives
    for entry in $clone_entries
        set -l name (string split \t $entry)[1]
        set -l url (string split \t $entry)[2]

        set -l found false
        for dir in $para_dirs
            if test -d "$para_base/$dir/$name"
                set found true
                break
            end
        end

        if test $found = false
            git clone $url "$para_base/4-Archives/$name" 2>/dev/null
        end
    end

    # Remove local clones of repos deleted from GitHub
    for dir in $para_dirs
        for repo_path in (find $para_base/$dir -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
            test -d "$repo_path/.git"; or continue
            set -l name (basename $repo_path)
            set -l remote (git -C $repo_path remote get-url origin 2>/dev/null)
            string match -q '*github.com*' $remote; or continue
            contains $name $all_names; or rm -rf $repo_path
        end
    end

    # Scan 1-Projects and 2-Areas for repos that are "active"
    set -l active
    for name in $all_names
        for dir in 1-Projects 2-Areas
            if test -d "$para_base/$dir/$name/.git"
                set -a active $name
                break
            end
        end
    end

    if test (count $active) -eq 0
        set active dotfiles
    end

    # Build the new repos_active YAML block
    set -l new_block "repos_active:"
    for repo in $active
        set new_block "$new_block\n  - $repo"
    end

    # Update vars/main.yml
    awk -v new=(printf '%s' "$new_block") '
        /^repos_active:/ { found=1; print new; next }
        found && /^  - / { next }
        found && !/^  - / { found=0 }
        { print }
    ' $vars_file >$vars_file.tmp && mv $vars_file.tmp $vars_file

    # Commit and push if changed
    cd $dotfiles; or return 0
    if not git diff --quiet -- roles/dotfiles/vars/main.yml
        git add roles/dotfiles/vars/main.yml
        git commit -m "auto: repos-sync updated PARA destinations"
        git push
    end
end
