-- Luakit Theme — Tango Dark
-- Matches: foot, sway, waybar, qutebrowser color scheme

local theme = {}

-- Base
theme.font = "11px IntoneMono Nerd Font"
theme.fg   = "#d0cfcc"
theme.bg   = "#000000"

-- General colour pairings
theme.ok    = { fg = "#d0cfcc", bg = "#000000" }
theme.warn  = { fg = "#c4a000", bg = "#000000" }
theme.error = { fg = "#eeeeec", bg = "#cc0000" }

-- Status
theme.success_fg = "#4e9a06"
theme.loaded_fg  = "#3465a4"
theme.error_fg   = "#eeeeec"
theme.error_bg   = "#cc0000"

-- Warning
theme.warning_fg = "#c4a000"
theme.warning_bg = "#000000"

-- Notification
theme.notif_fg = "#d0cfcc"
theme.notif_bg = "#0a0a0a"

-- Menu / completion
theme.menu_fg                 = "#d0cfcc"
theme.menu_bg                 = "#000000"
theme.menu_selected_fg        = "#eeeeec"
theme.menu_selected_bg        = "#3465a4"
theme.menu_title_bg           = "#0a0a0a"
theme.menu_primary_title_fg   = "#3465a4"
theme.menu_secondary_title_fg = "#555753"
theme.menu_disabled_fg        = "#555753"
theme.menu_disabled_bg        = "#000000"
theme.menu_enabled_fg         = "#d0cfcc"
theme.menu_enabled_bg         = "#000000"
theme.menu_active_fg          = "#4e9a06"
theme.menu_active_bg          = "#000000"

-- Proxy
theme.proxy_active_menu_fg   = "#d0cfcc"
theme.proxy_active_menu_bg   = "#000000"
theme.proxy_inactive_menu_fg = "#555753"
theme.proxy_inactive_menu_bg = "#000000"

-- Statusbar
theme.sbar_fg = "#d0cfcc"
theme.sbar_bg = "#000000"

-- Download bar
theme.dbar_fg       = "#d0cfcc"
theme.dbar_bg       = "#000000"
theme.dbar_error_fg = "#cc0000"

-- Input bar
theme.ibar_fg = "#d0cfcc"
theme.ibar_bg = "rgba(0,0,0,0)"

-- Tab labels
theme.tab_fg           = "#888888"
theme.tab_bg           = "#000000"
theme.tab_hover_bg     = "#0a0a0a"
theme.tab_ntheme       = "#d0cfcc"
theme.selected_fg      = "#eeeeec"
theme.selected_bg      = "#0a0a0a"
theme.selected_ntheme  = "#eeeeec"
theme.loading_fg       = "#3465a4"
theme.loading_bg       = "#000000"

theme.selected_private_tab_bg = "#3d295b"
theme.private_tab_bg          = "#22254a"

-- SSL
theme.trust_fg   = "#4e9a06"
theme.notrust_fg = "#cc0000"

-- Follow mode hints
theme.hint_font                  = "12px IntoneMono Nerd Font bold"
theme.hint_fg                    = "#000000"
theme.hint_bg                    = "#fce94f"
theme.hint_border                = "1px dashed #c4a000"
theme.hint_opacity               = "0.3"
theme.hint_overlay_bg            = "rgba(252,233,79,0.3)"
theme.hint_overlay_border        = "1px dotted #c4a000"
theme.hint_overlay_selected_bg   = "rgba(138,226,52,0.3)"
theme.hint_overlay_selected_border = theme.hint_overlay_border

-- Gopher
theme.gopher_light = { bg = "#e8e8e8", fg = "#17181c", link = "#3465a4" }
theme.gopher_dark  = { bg = "#000000", fg = "#d0cfcc", link = "#729fcf" }

return theme
