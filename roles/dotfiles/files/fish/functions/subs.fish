function subs --description "Download subtitles for video files"
    set -l langs "pl,en"
    set -l providers "opensubtitles podnapisi"

    if test (count $argv) -eq 0
        # No arguments - download for all videos in current directory
        echo "Downloading subtitles for all videos in current directory..."
        subliminal download -l pl -l en $providers -- *.mkv *.mp4 *.avi *.mov *.wmv 2>/dev/null
    else
        # Download for specified files
        for file in $argv
            if test -f "$file"
                echo "Downloading subtitles for: $file"
                subliminal download -l pl -l en $providers -- "$file"
            else
                echo "File not found: $file"
            end
        end
    end
end
