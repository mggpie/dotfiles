-- Lite-XL User Configuration
-- Micro-like keybindings · Tango dark theme · Smooth floating cursor

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"

-- Load custom Tango dark theme
core.reload_module("colors.tango_dark")

-- ── Editor settings ──────────────────────────────────────────────
config.fps = 60
config.max_undos = 10000
config.highlight_current_line = true
config.line_height = 1.6
config.indent_size = 4
config.tab_type = "soft"
config.mouse_wheel_scroll = 50 * SCALE
config.animate_drag_scroll = true
config.scroll_past_end = true

-- ── Fonts ────────────────────────────────────────────────────────
style.font = renderer.font.load(
  "/usr/share/fonts/TTF/inter/Inter-Regular.ttf", 13 * SCALE
)
style.code_font = renderer.font.load(
  "/usr/share/fonts/NerdFonts/ttf/IntoneMonoNerdFont-Regular.ttf", 13 * SCALE
)

-- ── Plugins ──────────────────────────────────────────────────────
-- Smooth floating cursor
config.plugins.smoothcaret = { rate = 0.55 }

-- Motion trail (caret leaves a trail)
config.plugins.motiontrail = { steps = 50 }

-- Minimap
config.plugins.minimap = {
  enabled = true,
  width = 80,
  instant_scroll = false,
  syntax_highlight = true,
  scale = 1,
}

-- ── Micro-like keybindings ───────────────────────────────────────
-- Most standard bindings already match (Ctrl+S/Z/Y/C/X/V/F/G/A, etc.)
-- Below are the micro-specific overrides and additions:
keymap.add {
  ["ctrl+q"]         = "core:quit",
  ["ctrl+e"]         = "core:find-command",
  ["ctrl+h"]         = "find-replace:replace",
  ["alt+/"]          = "doc:toggle-line-comments",
  ["ctrl+shift+d"]   = "doc:duplicate-line",

  -- Tab management
  ["ctrl+w"]         = "root:close",
  ["ctrl+tab"]       = "root:switch-to-next-tab",
  ["ctrl+shift+tab"] = "root:switch-to-previous-tab",
}
