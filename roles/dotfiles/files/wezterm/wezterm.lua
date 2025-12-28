local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font 'monospace'
config.font_size = 11.0

-- Appearance
config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = false
config.window_padding = {
  left = 15,
  right = 15,
  top = 15,
  bottom = 15,
}
config.window_background_opacity = 0.95

-- Behavior
config.enable_wayland = true
config.scrollback_lines = 10000

return config
