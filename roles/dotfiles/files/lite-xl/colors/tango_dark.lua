-- Tango Dark theme for Lite-XL
-- Matches: foot, sway, waybar, qutebrowser color scheme
local style = require "core.style"
local common = require "core.common"

-- UI colors
style.background       = { common.color "#000000" }
style.background2      = { common.color "#0a0a0a" }
style.background3      = { common.color "#0a0a0a" }
style.text             = { common.color "#d0cfcc" }
style.caret            = { common.color "#eeeeec" }
style.accent           = { common.color "#3465a4" }
style.dim              = { common.color "#555753" }
style.divider          = { common.color "#2e3436" }
style.selection        = { common.color "#3465a480" }
style.line_number      = { common.color "#555753" }
style.line_number2     = { common.color "#d0cfcc" }
style.line_highlight   = { common.color "#0a0a0a" }
style.scrollbar        = { common.color "#3465a4" }
style.scrollbar2       = { common.color "#729fcf" }
style.scrollbar_track  = { common.color "#0a0a0a" }
style.nagbar           = { common.color "#cc0000" }
style.nagbar_text      = { common.color "#eeeeec" }
style.nagbar_dim       = { common.color "#000000" }
style.drag_overlay     = { common.color "#3465a4aa" }
style.drag_overlay_tab = { common.color "#729fcf" }
style.good             = { common.color "#4e9a06" }
style.warn             = { common.color "#c4a000" }
style.error            = { common.color "#cc0000" }
style.modified         = { common.color "#3465a4" }

-- Syntax highlighting - Tango palette
style.syntax["normal"]   = { common.color "#d0cfcc" }
style.syntax["symbol"]   = { common.color "#d0cfcc" }
style.syntax["comment"]  = { common.color "#555753" }
style.syntax["keyword"]  = { common.color "#ad7fa8" }  -- Plum
style.syntax["keyword2"] = { common.color "#729fcf" }  -- Sky Blue
style.syntax["number"]   = { common.color "#fce94f" }  -- Butter
style.syntax["literal"]  = { common.color "#fcaf3e" }  -- Orange
style.syntax["string"]   = { common.color "#8ae234" }  -- Chameleon
style.syntax["operator"] = { common.color "#d3d7cf" }  -- Aluminium
style.syntax["function"] = { common.color "#3465a4" }  -- Sky Blue Dark
