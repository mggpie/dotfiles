function migrate-para --description "Migrate PARA dirs from ~/Desktop/X to ~/X"
    # One-time migration from the old Desktop-nested PARA layout to flat ~/
    # Safe to run multiple times - skips already-migrated dirs

    set -l dirs 0-Inbox 1-Projects 2-Areas 3-Resources 4-Archives

    for d in $dirs
        if test -d ~/Desktop/$d; and not test -d ~/$d
            mv ~/Desktop/$d ~/$d
            echo "moved ~/Desktop/$d -> ~/$d"
        else if test -d ~/Desktop/$d; and test -d ~/$d
            echo "skipped $d: already exists at ~/$d (old dir still at ~/Desktop/$d)"
        else
            echo "skipped $d: not found at ~/Desktop/$d"
        end
    end

    # Move remaining XDG media dirs into 3-Resources
    for pair in "Music:music" "Videos:videos"
        set -l old (string split : $pair)[1]
        set -l new (string split : $pair)[2]
        if test -d ~/$old; and test (count ~/$old/*) -gt 0 2>/dev/null
            mkdir -p ~/3-Resources/$new
            mv ~/$old/* ~/3-Resources/$new/ 2>/dev/null
            echo "moved ~/$old/* -> ~/3-Resources/$new/"
        end
        test -d ~/$old; and rmdir ~/$old 2>/dev/null; and echo "removed empty ~/$old"
    end

    # Pictures -> 3-Resources/pics
    if test -d ~/Pictures; and test (count ~/Pictures/*) -gt 0 2>/dev/null
        mkdir -p ~/3-Resources/pics
        mv ~/Pictures/* ~/3-Resources/pics/ 2>/dev/null
        echo "moved ~/Pictures/* -> ~/3-Resources/pics/"
    end
    test -d ~/Pictures; and rmdir ~/Pictures 2>/dev/null; and echo "removed empty ~/Pictures"

    # Move Downloads contents into 0-Inbox (they're the same dir now)
    if test -d ~/Downloads; and test (count ~/Downloads/*) -gt 0 2>/dev/null
        mv ~/Downloads/* ~/0-Inbox/ 2>/dev/null
        echo "moved ~/Downloads/* -> ~/0-Inbox/"
    end
    test -d ~/Downloads; and rmdir ~/Downloads 2>/dev/null; and echo "removed empty ~/Downloads"

    # Documents -> 3-Resources
    if test -d ~/Documents; and test (count ~/Documents/*) -gt 0 2>/dev/null
        mv ~/Documents/* ~/3-Resources/ 2>/dev/null
        echo "moved ~/Documents/* -> ~/3-Resources/"
    end
    test -d ~/Documents; and rmdir ~/Documents 2>/dev/null; and echo "removed empty ~/Documents"

    # Clean up empty Desktop
    if test -d ~/Desktop; and test (count ~/Desktop/*) -eq 0 2>/dev/null
        rmdir ~/Desktop
        echo "removed empty ~/Desktop"
    else if test -d ~/Desktop
        echo "~/Desktop still has files - review manually:"
        ls ~/Desktop
    end

    echo "migration complete"
end
