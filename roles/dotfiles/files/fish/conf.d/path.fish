# PATH configuration
set -e fish_user_paths  # Without this line fish will start to slow down
set -U fish_user_paths $HOME/.local/bin $HOME/.nix-profile/bin $fish_user_paths
