function rotate-keys -d "rotate SSH and GitHub tokens seamlessly"
    printf "[1/9] initializing key rotation...\n"
    set -l temp_dir (mktemp -d)
    set -l new_key "$temp_dir/id_ed25519"
    
    printf "[2/9] capturing old GitHub token...\n"
    set -l old_gh_token (gh auth token 2>/dev/null)
    
    printf "[3/9] generating new SSH ed25519 key...\n"
    ssh-keygen -t ed25519 -f "$new_key" -N "" -C "mggpie@void"
    
    if not test $status -eq 0
        printf "failed to generate SSH key\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    set -l new_private (cat "$new_key")
    set -l new_public (cat "$new_key.pub")
    printf "  public key: %s\n" (string sub -l 50 "$new_public")...
    
    set -l old_fingerprint (ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
    printf "  old fingerprint: %s\n" "$old_fingerprint"
    
    printf "[4/9] refreshing GitHub token (will open browser for OAuth)...\n"
    gh auth refresh -s repo,read:org,gist,write:packages,delete:packages,admin:public_key
    
    if not test $status -eq 0
        printf "failed to refresh GitHub token\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    set -l new_gh_token (gh auth token 2>/dev/null)
    printf "  new token: %s...\n" (string sub -l 20 "$new_gh_token")
    
    printf "[5/9] adding new SSH key to GitHub...\n"
    printf "%s" "$new_public" | gh ssh-key add - --title "void-$(date +%Y%m%d)"
    
    if not test $status -eq 0
        printf "failed to add SSH key to GitHub\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    printf "[6/9] backing up and updating vault...\n"
    cp secrets.yml "$temp_dir/secrets.yml.bak"
    
    set -l vault_content (ansible-vault view secrets.yml 2>/dev/null)
    
    if not test $status -eq 0
        printf "failed to decrypt vault\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    # replace SSH keys and GitHub token in vault content
    set -l updated_vault (printf "%s\n" "$vault_content" | \
        awk -v new_priv="$new_private" -v new_pub="$new_public" -v new_token="$new_gh_token" '
        BEGIN { in_private=0; in_gh_hosts=0 }
        /^github_token:/ {
            print "github_token: \"" new_token "\""
            next
        }
        /^gh_hosts_yml:/ {
            in_gh_hosts=1
            print "gh_hosts_yml: |"
            print "  github.com:"
            print "      users:"
            print "          mggpie:"
            print "              oauth_token: " new_token
            print "      git_protocol: ssh"
            print "      oauth_token: " new_token
            print "      user: mggpie"
            next
        }
        /^ssh_private_key:/ { 
            in_gh_hosts=0
            print "ssh_private_key: |"
            print "  " new_priv
            in_private=1
            next
        }
        /^ssh_public_key:/ { 
            print "ssh_public_key: \"" new_pub "\""
            next
        }
        /^[a-z_]+:/ { in_private=0; in_gh_hosts=0 }
        !in_private && !in_gh_hosts { print }
    ')
    
    printf "  encrypting updated vault...\n"
    printf "%s\n" "$updated_vault" | ansible-vault encrypt --output secrets.yml 2>/dev/null
    
    if not test $status -eq 0
        printf "failed to encrypt vault, restoring backup\n" >&2
        cp "$temp_dir/secrets.yml.bak" secrets.yml
        rm -rf "$temp_dir"
        return 1
    end
    
    printf "[7/9] deploying new SSH key locally...\n"
    cp "$new_key" ~/.ssh/id_ed25519
    cp "$new_key.pub" ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    
    printf "[8/9] restarting ssh-agent...\n"
    ssh-add -D
    ssh-add ~/.ssh/id_ed25519
    
    printf "[9/9] cleaning up old credentials...\n"
    if test -n "$old_fingerprint"
        printf "  deleting old SSH key from GitHub...\n"
        for key_id in (gh api /user/keys --jq '.[] | select(.key | contains("'$old_fingerprint'")) | .id')
            gh api -X DELETE "/user/keys/$key_id"
        end
    end
    
    if test -n "$old_gh_token"
        and test "$old_gh_token" != "$new_gh_token"
        printf "  revoking old GitHub token...\n"
        gh api -X DELETE "/applications/Iv1.0000000000000000/token" \
            -f access_token="$old_gh_token"
    end
    
    rm -rf "$temp_dir"
    
    printf "\ncommitting vault changes...\n"
    git -C (dirname (status --current-filename)) add secrets.yml
    git -C (dirname (status --current-filename)) commit -m "rotate ssh keys"
    git -C (dirname (status --current-filename)) push
    
    printf "\n✓ keys rotated successfully\n"
    printf "\npress any key to close...\n"
    read -n 1
end
