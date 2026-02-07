-- Luakit Theme — Tango Dark
-- Matches: foot, sway, waybar, qutebrowser color scheme

local theme = {}

-- Base
theme.font = "11px IntoneMono Nerd Font"
theme.fg   = "#d0cfcc"
theme.bg   = "#000000"

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
theme.ibar_bg = "#0a0a0a"

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

-- SSL
theme.trust_fg   = "#4e9a06"
theme.notrust_fg = "#cc0000"

-- Follow mode hints
theme.follow_font          = "12px IntoneMono Nerd Font bold"
theme.follow_fg            = "#000000"
theme.follow_bg            = "#fce94f"
theme.follow_border        = "1px #c4a000"
theme.follow_active_bg     = "#8ae234"
theme.follow_active_border = "1px #4e9a06"

return theme
