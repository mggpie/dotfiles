# Startup behavior

# Start in Desktop if interactive and in home
if status is-interactive; and test "$PWD" = "$HOME"
    cd ~/Desktop
end
