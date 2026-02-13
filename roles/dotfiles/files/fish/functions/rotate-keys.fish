function rotate-keys -d "rotate SSH and GitHub tokens seamlessly"
    set -l temp_dir (mktemp -d)
    set -l new_key "$temp_dir/id_ed25519"
    
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
    
    # add new key to GitHub via gh CLI
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
    
    # replace SSH keys in vault content
    set -l updated_vault (printf "%s\n" "$vault_content" | \
        awk -v new_priv="$new_private" -v new_pub="$new_public" '
        BEGIN { in_private=0 }
        /^ssh_private_key:/ { 
            print "ssh_private_key: |"
            print "  " new_priv
            in_private=1
            next
        }
        /^ssh_public_key:/ { 
            print "ssh_public_key: \"" new_pub "\""
            next
        }
        /^[a-z_]+:/ { in_private=0 }
        !in_private { print }
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
    
    # delete old key from GitHub
    if test -n "$old_fingerprint"
        for key_id in (gh api /user/keys --jq '.[] | select(.key | contains("'$old_fingerprint'")) | .id')
            gh api -X DELETE "/user/keys/$key_id" >/dev/null 2>&1
        end
    end
    
    # cleanup
    rm -rf "$temp_dir"
    
    # commit and push vault update
    git -C (dirname (status --current-filename)) add secrets.yml
    git -C (dirname (status --current-filename)) commit -m "rotate ssh keys"
    git -C (dirname (status --current-filename)) push
    
    printf "keys rotated successfully\n"
end
