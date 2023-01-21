set -e fish_user_paths # Without this line fish will start to slow down.
set -U fish_user_paths $HOME/.local/bin $HOME/.cargo/bin $fish_user_paths

function fish_greeting
    echo The time is (set_color yellow; date +%T; set_color normal)
end

# Hardware
set -Ux XKB_DEFAULT_LAYOUT "pl"
set -Ux XKB_DEFAULT_OPTIONS "caps:escape"
set -Ux WLR_DRM_DEVICES "/dev/dri/card0"

# Defaults
set -Ux TERM "footclient"
set -Ux EDITOR "micro"
set -Ux VISUAL "$EDITOR | $TERM"
set -Ux MANPAGER "less -R --use-color -Dd+r -Du+b"
set -Ux BROWSER "qutebrowser"

alias sudo "doas"
alias pkgs "xbps-query -v -Rs"
alias pkgi "doas xbps-install -Sy"
alias pkgfi "doas xbps-install -Sfy"
alias pkgr "doas xbps-remove -v -y"
alias pkgu "doas fstrim / & \
            doas xbps-remove -v -O cleanup & \
            doas xbps-remove -yO & \
            doas xbps-remove -yo & \
            doas vkpurge rm all & \
            doas xbps-install -Syuv & \
            asusfan & \
            maza update & \
            yes | doas trash-empty"

alias logout "pkill -u $USER"
alias suspend "doas zzz"
alias hibernate "doas ZZZ"
alias reboot "doas reboot"
alias poweroff "doas poweroff"

alias bt "bluetoothctl"

alias data "$EDITOR $XDG_DATA_HOME"
alias settings "$EDITOR $HOME/fish/config.fish"
alias gpg-check "gpg2 --keyserver-options auto-key-retrieve --verify"
alias gpg-retrieve "gpg2 --keyserver-options auto-key-retrieve --receive-keys"
alias trashclean "rm -rf ~/.local/share/Trash/*"

alias .. "cd .."
alias ... "cd ../.."
alias vim "nvim"
alias ls "exa -l --color=always --group-directories-first"
alias lss "exa -al --color=always --group-directories-first"
alias fontsearch "fc-list | grep -i"
alias asusfan "sudo modprobe acpi_call; \
               sudo asus-fan-control set-temps 80 88 90 95 96 97 98 99"

alias firefoxkiosk "firefox-wayland -new-window https://duckduckgo.com/ -P profile -no-remote --kiosk --class=notion"
alias chromiumkiosk "chromium-browser https://duckduckgo.com/ –check-for-update-interval=1 –simulate-critical-update –window-size=1920,1080 –window-position=0,0 –start-fullscreen –kiosk –incognito –noerrdialogs –disable-translate –no-first-run –fast –fast-start –disable-infobars –disable-features=TranslateUI –disk-cache-dir=/dev/null –overscroll-history-navigation=0 –disable-pinch"

alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias gc='git clone'
alias gco='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias tag='git tag'
alias newtag='git tag -a'

# Eye candy
set -Ux MICRO_TRUECOLOR "1"
set -Ux fish_term24bit "1"

alias grep "grep --color=auto"
alias egrep "egrep --color=auto"
alias fgrep "fgrep --color=auto"
alias diff "diff --color=auto"
alias ip "ip -color=auto"

set -Ux fish_color_command 164CC9
set -Ux fish_color_quote 4C3499
set -Ux fish_color_redirection 248E8E
set -Ux fish_color_end 02BDBD
set -Ux fish_color_error 9177E5
set -Ux fish_color_param 4319CC
set -Ux fish_color_comment 007B7B
set -Ux fish_color_match --background=brblue
set -Ux fish_color_selection white --bold --background=brblack
set -Ux fish_color_search_match bryellow --background=brblack
set -Ux fish_color_history_current --bold
set -Ux fish_color_operator 00a6b2
set -Ux fish_color_escape 00a6b2
set -Ux fish_color_cwd green
set -Ux fish_color_cwd_root red
set -Ux fish_color_valid_path --underline
set -Ux fish_color_autosuggestion 7596E4
set -Ux fish_color_user brgreen
set -Ux fish_color_host normal
set -Ux fish_color_cancel --reverse
set -Ux fish_pager_color_prefix normal --bold --underline
set -Ux fish_pager_color_progress brwhite --background=cyan
set -Ux fish_pager_color_completion normal
set -Ux fish_pager_color_description B3A06D
set -Ux fish_pager_color_selected_background --background=brblack
set -Ux fish_pager_color_selected_prefix 
set -Ux fish_pager_color_selected_completion 
set -Ux fish_color_keyword 
set -Ux fish_pager_color_secondary_completion 
set -Ux fish_color_host_remote 
set -Ux fish_pager_color_background 
set -Ux fish_pager_color_secondary_background 
set -Ux fish_pager_color_selected_description 
set -Ux fish_color_option 
set -Ux fish_pager_color_secondary_prefix 
set -Ux fish_pager_color_secondary_description 

set -Ux base00 "#0C0F12" # ---- (Default Background)
set -Ux base01 "#14191e" # --- (Lighter background - Status bars, line number and folding marks)
set -Ux base02 "#191F26" # -- (Selection Background)
set -Ux base03 "#1F272E" # - (Comments, Invisibles, Line Highlighting)
set -Ux base04 "#252D35" # + (Dark Foreground - Status bars)
set -Ux base05 "#d4d4d6" # ++ (Default Foreground, Caret, Delimiters, Operators)
set -Ux base06 "#e6e6e8" # +++ (Light Foreground)
set -Ux base07 "#f2f2f2" # ++++ (Light Background)
set -Ux base08 "#e55c7a" # red (Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted)
set -Ux base09 "#cd9575" # orange (Integers, Boolean, Constants, XML Attributes, Markup Link Url)
set -Ux base0A "#f5c791" # yellow (Classes, Markup Bold, Search Text Background)
set -Ux base0B "#31e183" # green (Strings, Inherited Class, Markup Code, Diff Inserted)
set -Ux base0C "#62e5bf" # cyan (Support, Regular Expressions, Escape Characters, Markup Quotes)
set -Ux base0D "#0e9e97" # blue (Functions, Methods, Attribute IDs, Headings)
set -Ux base0E "#9d81ba" # magenta (Keywords, Storage, Selector, Markup Italic, Diff Changed)
set -Ux base0F "#7c7b92" # pink (Deprecated, Opening/Closing Embedded Language Tags)

set_color 002635 black
set_color FF5A67 red
set_color 7FC06E green
set_color FFCC1B yellow
set_color 9A70A4 magenta
set_color 5DD7B9 cyan
set_color FAFAF8 white
set_color 002635 brblack
set_color FF5A67 brred
set_color 7FC06E brgreen
set_color FFCC1B bryellow
set_color 9A70A4 brmagenta
set_color 5DD7B9 brcyan
set_color FAFAF8 brwhite

# Functions
function fish_prompt
    printf '> ' \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

function __async_prompt
    status is-interactive
    or exit 0
    
    set -g __async_prompt_tmpdir (command mktemp -d)
    
    # Setup after the user defined prompt functions are loaded.
    function __async_prompt_setup_on_startup --on-event fish_prompt
        functions -e (status current-function)
    
        for func in (__async_prompt_config_functions)
            function $func -V func
                test -e $__async_prompt_tmpdir'/'$fish_pid'_'$func
                and cat $__async_prompt_tmpdir'/'$fish_pid'_'$func
            end
        end
    end
    
    not set -q async_prompt_on_variable
    and set async_prompt_on_variable fish_bind_mode
    function __async_prompt_fire --on-event fish_prompt (for var in $async_prompt_on_variable; printf '%s\n' --on-variable $var; end)
        set -l __async_prompt_last_pipestatus $pipestatus
    
        for func in (__async_prompt_config_functions)
            set -l tmpfile $__async_prompt_tmpdir'/'$fish_pid'_'$func
    
            if functions -q $func'_loading_indicator' && test -e $tmpfile
                read -zl last_prompt <$tmpfile
                eval (string escape -- $func'_loading_indicator' "$last_prompt") >$tmpfile
            end
    
            __async_prompt_config_inherit_variables | __async_prompt_last_pipestatus=$__async_prompt_last_pipestatus __async_prompt_spawn \
                $func' | read -z prompt
                echo -n $prompt >'$tmpfile
        end
    end
    
    function __async_prompt_spawn -a cmd
        set -l envs
        begin
            while read line
                switch "$line"
                    case fish_bind_mode
                        echo fish_bind_mode $fish_bind_mode
                    case FISH_VERSION PWD _ history 'fish_*' hostname version
                    case status pipestatus
                        echo pipestatus $__async_prompt_last_pipestatus
                    case SHLVL
                        set envs $envs SHLVL=$SHLVL
                    case '*'
                        echo $line (string escape -- $$line)
                end
            end
        end | read -lz vars
        echo $vars | env $envs fish -c '
        function __async_prompt_signal
            kill -s "'(__async_prompt_config_internal_signal)'" '$fish_pid'
        end
        while read -a line
            test -z "$line"
            and continue
    
            if test "$line[1]" = pipestatus
                set -f _pipestatus $line[2..]
            else
                eval set "$line"
            end
        end
    
        function __async_prompt_set_status
            return $argv
        end
        if set -q _pipestatus
            switch (count $_pipestatus)
                case 1
                    __async_prompt_set_status $_pipestatus[1]
                case 2
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2]
                case 3
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3]
                case 4
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4]
                case 5
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4] \
                    | __async_prompt_set_status $_pipestatus[5]
                case 6
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4] \
                    | __async_prompt_set_status $_pipestatus[5] \
                    | __async_prompt_set_status $_pipestatus[6]
                case 7
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4] \
                    | __async_prompt_set_status $_pipestatus[5] \
                    | __async_prompt_set_status $_pipestatus[6] \
                    | __async_prompt_set_status $_pipestatus[7]
                case 8
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4] \
                    | __async_prompt_set_status $_pipestatus[5] \
                    | __async_prompt_set_status $_pipestatus[6] \
                    | __async_prompt_set_status $_pipestatus[7] \
                    | __async_prompt_set_status $_pipestatus[8]
                default
                    __async_prompt_set_status $_pipestatus[1] \
                    | __async_prompt_set_status $_pipestatus[2] \
                    | __async_prompt_set_status $_pipestatus[3] \
                    | __async_prompt_set_status $_pipestatus[4] \
                    | __async_prompt_set_status $_pipestatus[5] \
                    | __async_prompt_set_status $_pipestatus[6] \
                    | __async_prompt_set_status $_pipestatus[7] \
                    | __async_prompt_set_status $_pipestatus[8] \
                    | __async_prompt_set_status $_pipestatus[-1]
            end
        else
            true
        end
        '$cmd'
        __async_prompt_signal
        sleep 0.3
        __async_prompt_signal
        sleep 0.3
        __async_prompt_signal' &
        disown
    end
    
    function __async_prompt_config_inherit_variables
        if set -q async_prompt_inherit_variables
            if test "$async_prompt_inherit_variables" = all
                set -ng
            else
                for item in $async_prompt_inherit_variables
                    echo $item
                end
            end
        else
            echo status
            echo pipestatus
            echo SHLVL
            echo CMD_DURATION
            echo fish_bind_mode
        end
    end
    
    function __async_prompt_config_functions
        set -l funcs (
            if set -q async_prompt_functions
                string join \n $async_prompt_functions
            else
                echo fish_prompt
                echo fish_right_prompt
            end
        )
        for func in $funcs
            functions -q "$func"
            or continue
    
            echo $func
        end
    end
    
    function __async_prompt_config_internal_signal
        if test -z "$async_prompt_signal_number"
            echo SIGUSR1
        else
            echo "$async_prompt_signal_number"
        end
    end
    
    function __async_prompt_repaint_prompt --on-signal (__async_prompt_config_internal_signal)
        commandline -f repaint >/dev/null 2>/dev/null
    end
end

# Function for printing a row
# ex: seq 3 | rown 3
# output: 3
function rown --argument index
    sed -n "$index p"
end

# Function for taking the first 'n' lines
# ex: seq 10 | take 5
# results: prints only the first 5 lines
function take --argument number
    head -$number
end

# Function for creating a backup file
# ex: backup file.txt
# result: copies file as file.txt.bak
function backup --argument filename
    cp $filename $filename.bak
end

# Function for ignoring the first 'n' lines
# ex: seq 10 | skip 5
# results: prints everything but the first 5 lines
function skip --argument n
    tail +(math 1 + $n)
end

# Function for printing a column (splits input on whitespace)
# ex: echo 1 2 3 | coln 3
# output: 3
function coln
    while read -l input
        echo $input | awk '{print $'$argv[1]'}'
    end
end

# If su starts with Bash because Bash is the target user's 
# (root if no username is provided) default shell,
# one can define a function to redirect it to fish whatever the user's shell.
function su
   command su --shell=/usr/bin/fish $argv
end

# Wayland
set -Ux MOZ_ENABLE_WAYLAND "1"
set -Ux XDG_SESSION_TYPE "wayland"
set -Ux QT_QPA_PLATFORM "wayland-egl"
set -Ux QT_WAYLAND_FORCE_DPI "physical"
set -Ux QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
set -Ux ECORE_EVAS_ENGINE "wayland-egl"
set -Ux ELM_ENGINE "wayland-egl"
set -Ux SDL_VIDEODRIVER "wayland"
set -Ux _JAVA_AWT_WM_NONREPARENTING "1"
set -Ux STUDIO_JDK "/usr/lib/jvm/java-14-openjdk"
set -Ux JAVA_HOME "/usr/lib/jvm/java-8-openjdk"
set -Ux GTK_USE_PORTAL "0"

# If running from tty1 start compositor
set TTY1 (tty)
[ "$TTY1" = "/dev/tty1" ] && exec river # "river", "sway", "sway --unsupported-gpu" or "dwl".
