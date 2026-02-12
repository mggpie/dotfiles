function gnome-scale
    # Get the current text scaling factor
    set current (gsettings get org.gnome.desktop.interface text-scaling-factor | tr -d '"')
    # Use test for floating point comparison in fish
    if test "$current" -le 1.0
        gsettings set org.gnome.desktop.interface text-scaling-factor 2.0
        echo "Text scaling set to 2.0"
    else
        gsettings set org.gnome.desktop.interface text-scaling-factor 0.9
        echo "Text scaling set to 0.9"
    end
end
