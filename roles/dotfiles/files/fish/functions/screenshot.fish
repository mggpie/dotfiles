function screenshot --description "Take screenshot - select area, save to Pictures/Screenshots, copy to clipboard"
    # Create Screenshots directory if it does not exist
    mkdir -p $HOME/Pictures/Screenshots

    # Generate filename with timestamp
    set filename $HOME/Pictures/Screenshots/(date +%Y%m%d-%H%M%S).png

    # Take screenshot of selected area, save to file and copy to clipboard
    grim -g (slurp) - | tee $filename | wl-copy
end
