function fish_prompt
    set -l last_status $status
    
    # Colors
    set -l color_cwd 0087AF
    set -l color_git 5FD700
    set -l color_git_dirty D7AF00
    set -l color_success 5FD700
    set -l color_error FF0000
    
    # Current directory
    set -l pwd_display (prompt_pwd)
    set_color $color_cwd
    echo -n $pwd_display
    set_color normal
    
    # Git status
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_branch (git branch --show-current 2>/dev/null)
        test -z "$git_branch" && set git_branch (git rev-parse --short HEAD 2>/dev/null)
        
        # Check if dirty
        if not git diff-index --quiet HEAD -- 2>/dev/null
            set_color $color_git_dirty
            echo -n "  $git_branch"
        else
            set_color $color_git
            echo -n "  $git_branch"
        end
        
        # Show ahead/behind
        set -l upstream (git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)
        if test -n "$upstream"
            set -l ahead (git rev-list --count HEAD..$upstream 2>/dev/null)
            set -l behind (git rev-list --count $upstream..HEAD 2>/dev/null)
            
            if test "$behind" -gt 0
                echo -n " ↑$behind"
            end
            if test "$ahead" -gt 0
                echo -n " ↓$ahead"
            end
        end
        
        set_color normal
    end
    
    # Prompt character
    echo -n ' '
    if test $last_status -eq 0
        set_color $color_success
    else
        set_color $color_error
    end
    echo -n '❯ '
    set_color normal
end
