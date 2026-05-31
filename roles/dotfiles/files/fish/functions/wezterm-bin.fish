function wezterm-bin --description "Run WezTerm from Nix with nixGL"
    exec $HOME/.nix-profile/bin/nixGL $HOME/.nix-profile/bin/wezterm $argv
end