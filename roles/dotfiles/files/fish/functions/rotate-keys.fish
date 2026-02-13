function rotate-keys -d "rotate SSH and GitHub tokens seamlessly"
    set -l temp_dir (mktemp -d)
    set -l new_key "$temp_dir/id_ed25519"
    
    # get old GitHub token for deletion
    set -l old_gh_token (gh auth token 2>/dev/null)
    
    # generate new SSH key without passphrase
    ssh-keygen -t ed25519 -f "$new_key" -N "" -C "mggpie@void" >/dev/null 2>&1
    
    if not test $status -eq 0
        printf "failed to generate SSH key\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    set -l new_private (cat "$new_key")
    set -l new_public (cat "$new_key.pub")
    
    # get old public key fingerprint for deletion
    set -l old_fingerprint (ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
    
    # rotate GitHub token
    gh auth refresh -s repo,read:org,gist,write:packages,delete:packages,admin:public_key >/dev/null 2>&1
    
    if not test $status -eq 0
        printf "failed to refresh GitHub token\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    set -l new_gh_token (gh auth token 2>/dev/null)
    
    # add new SSH key to GitHub via gh CLI
    printf "%s" "$new_public" | gh ssh-key add - --title "void-$(date +%Y%m%d)" >/dev/null 2>&1
    
    if not test $status -eq 0
        printf "failed to add SSH key to GitHub\n" >&2
        rm -rf "$temp_dir"
        return 1
    end
    
    # backup current vault
    cp secrets.yml "$temp_dir/secrets.yml.bak"
    
    # update vault with new keys
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
    
    # encrypt updated vault
    printf "%s\n" "$updated_vault" | ansible-vault encrypt --output secrets.yml 2>/dev/null
    
    if not test $status -eq 0
        printf "failed to encrypt vault, restoring backup\n" >&2
        cp "$temp_dir/secrets.yml.bak" secrets.yml
        rm -rf "$temp_dir"
        return 1
    end
    
    # deploy new SSH key locally
    cp "$new_key" ~/.ssh/id_ed25519
    cp "$new_key.pub" ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    
    # restart ssh-agent with new key
    ssh-add -D >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
    
    # delete old SSH key from GitHub
    if test -n "$old_fingerprint"
        for key_id in (gh api /user/keys --jq '.[] | select(.key | contains("'$old_fingerprint'")) | .id')
            gh api -X DELETE "/user/keys/$key_id" >/dev/null 2>&1
        end
    end
    
    # revoke old GitHub token
    if test -n "$old_gh_token"
        and test "$old_gh_token" != "$new_gh_token"
        gh api -X DELETE "/applications/Iv1.0000000000000000/token" \
            -f access_token="$old_gh_token" >/dev/null 2>&1
    end
    
    # cleanup
    rm -rf "$temp_dir"
    
    # commit and push vault update
    git -C (dirname (status --current-filename)) add secrets.yml
    git -C (dirname (status --current-filename)) commit -m "rotate ssh keys"
    git -C (dirname (status --current-filename)) push
    
    printf "keys rotated successfully\n"
end
