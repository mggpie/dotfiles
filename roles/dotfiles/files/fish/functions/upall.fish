function upall
    set -l log_file ~/.local/state/upall.log
    set -l error_file ~/Downloads/upall-error.txt

    # Handle 'logs' argument
    if test "$argv[1]" = "logs"
        echo "Log file location: $log_file"
        echo ""
        if test -f $log_file
            cat $log_file
        else
            echo "No log file found yet. Run 'upall' first."
        end
        return
    end

    # Handle 'status' argument
    if test "$argv[1]" = "status"
        if test -f $log_file
            set -l last_run (grep "System Maintenance Completed:" $log_file | tail -1 | sed 's/.*Completed: //' | sed 's/ ===.*//')
            set -l last_status (grep "Status:" $log_file | tail -1 | sed 's/.*Status: //')
            echo "Last run: $last_run"
            echo "Status: $last_status"
            if test -f $error_file
                echo "⚠️  Error file exists: $error_file"
            end
        else
            echo "No upall runs recorded yet."
        end
        return
    end

    set -l timestamp (date '+%Y-%m-%d %H:%M:%S')
    set -l has_errors 0

    # Create log directory if it doesn't exist
    mkdir -p (dirname $log_file)

    echo "=== System Maintenance Started: $timestamp ===" | tee -a $log_file

    # Get initial disk usage
    set -l disk_before (df -h / | tail -1 | awk '{print $4}')
    echo "Free space before: $disk_before" | tee -a $log_file

    # 1. Trim SSD
    echo -e "\n[1/10] Trimming SSD..." | tee -a $log_file
    if not doas fstrim -av 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 2. Remove orphaned packages
    echo -e "\n[2/10] Removing orphaned packages..." | tee -a $log_file
    if not doas xbps-remove -yO 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 3. Remove old kernels
    echo -e "\n[3/10] Removing old kernels..." | tee -a $log_file
    if not doas vkpurge rm all 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 4. Update system packages
    echo -e "\n[4/10] Updating system packages..." | tee -a $log_file
    if not doas xbps-install -Syu 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 5. Clean package cache
    echo -e "\n[5/10] Cleaning package cache..." | tee -a $log_file
    if not doas xbps-remove -O 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 6. Update maza ad blocking
    echo -e "\n[6/10] Updating maza ad blocking..." | tee -a $log_file
    if not doas maza update 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 7. Update Nix packages
    echo -e "\n[7/10] Updating Nix packages..." | tee -a $log_file
    if not nix-channel --update 2>&1 | tee -a $log_file
        set has_errors 1
    end
    if not nix profile upgrade '.*' 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 8. Clean Nix garbage
    echo -e "\n[8/10] Cleaning Nix garbage..." | tee -a $log_file
    if not nix-collect-garbage -d 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 9. Update Flatpak packages
    echo -e "\n[9/10] Updating Flatpak packages..." | tee -a $log_file
    if not flatpak update -y 2>&1 | tee -a $log_file
        set has_errors 1
    end

    # 10. Empty trash
    echo -e "\n[10/10] Emptying trash..." | tee -a $log_file
    if test -d ~/.local/share/Trash/files
        set trash_size (du -sh ~/.local/share/Trash/ 2>/dev/null | cut -f1)
        echo "Trash size: $trash_size" | tee -a $log_file
        find ~/.local/share/Trash/ -mindepth 1 -delete 2>&1 | tee -a $log_file
        echo "Trash emptied!" | tee -a $log_file
    else
        echo "Trash is already empty" | tee -a $log_file
    end

    # Get final disk usage
    set -l disk_after (df -h / | tail -1 | awk '{print $4}')
    echo -e "\nFree space after: $disk_after" | tee -a $log_file

    # Determine status and handle errors
    if test $has_errors -eq 0
        echo "Status: SUCCESS" | tee -a $log_file
        # Remove error file if it exists
        rm -f $error_file
    else
        echo "Status: FAILED (check log for details)" | tee -a $log_file
        # Create error file in Downloads
        echo "=== UPALL MAINTENANCE FAILED ===" > $error_file
        echo "Date: $timestamp" >> $error_file
        echo "" >> $error_file
        echo "Some steps failed during system maintenance." >> $error_file
        echo "Check the full log for details:" >> $error_file
        echo "  $log_file" >> $error_file
        echo "" >> $error_file
        echo "Run 'upall logs' to view the full log." >> $error_file
        echo "" >> $error_file
        echo "Recent errors from log:" >> $error_file
        tail -50 $log_file >> $error_file
        echo "" | tee -a $log_file
        echo "⚠️  Errors occurred! Error report saved to: $error_file" | tee -a $log_file
    end

    echo -e "\n=== System Maintenance Completed: "(date '+%Y-%m-%d %H:%M:%S')" ===" | tee -a $log_file
    echo -e "\nLog saved to: $log_file"
end
