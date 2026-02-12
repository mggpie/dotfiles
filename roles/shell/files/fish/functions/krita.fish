function krita --description "Krita digital painting - with light GTK theme for text visibility"
    set -lx QT_QPA_PLATFORM wayland
    set -lx QT_WAYLAND_DISABLE_WINDOWDECORATION 1
    set -lx QT_STYLE_OVERRIDE Fusion
    set -lx GTK_THEME Adwaita:light
    set -lx QT_QPA_PLATFORMTHEME gtk3
    command krita $argv
end
