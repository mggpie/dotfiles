function upall-check
    set -l log_file ~/.local/state/upall.log
    set -l days_threshold 7
    
    # Check if log file exists
    if not test -f $log_file
        echo "No previous upall run found, running now..."
        upall
        return
    end
    
    # Get last run timestamp from log
    set -l last_run (grep "System Maintenance Completed:" $log_file | tail -1 | sed 's/.*Completed: //' | sed 's/ ===.*//')
    
    if test -z "$last_run"
        echo "Could not determine last run time, running upall..."
        upall
        return
    end
    
    # Calculate days since last run
    set -l last_epoch (date -d "$last_run" +%s 2>/dev/null)
    set -l current_epoch (date +%s)
    set -l days_diff (math "($current_epoch - $last_epoch) / 86400")
    
    if test $days_diff -ge $days_threshold
        echo "Last upall run was $days_diff days ago. Running upall now..."
        upall
    else
        echo "Last upall run was $days_diff days ago. No need to run yet (threshold: $days_threshold days)."
    end
end
