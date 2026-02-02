local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font 'IntoneMono NF'
config.font_size = 9.0

-- Font rendering
config.freetype_load_target = 'Normal'
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' } -- ligatury

-- Colors (Tango)
config.colors = {
  foreground = '#D0CFCC',
  background = '#000000',
  cursor_bg = '#D0CFCC',
  cursor_fg = '#000000',
  cursor_border = '#D0CFCC',
  ansi = {
    '#2E3436', -- black
    '#CC0000', -- red
    '#4E9A06', -- green
    '#C4A000', -- yellow
    '#3465A4', -- blue
    '#75507B', -- magenta
    '#06989A', -- cyan
    '#D3D7CF', -- white
  },
  brights = {
    '#555753', -- bright black
    '#EF2929', -- bright red
    '#8AE234', -- bright green
    '#FCE94F', -- bright yellow
    '#729FCF', -- bright blue
    '#AD7FA8', -- bright magenta
    '#34E2E2', -- bright cyan
    '#EEEEEC', -- bright white
  },
  -- Tab bar colors (Adwaita Dark)
  tab_bar = {
    background = '#282828',
    active_tab = {
      bg_color = '#3d3d3d',
      fg_color = '#ffffff',
    },
    inactive_tab = {
      bg_color = '#282828',
      fg_color = '#909090',
    },
    inactive_tab_hover = {
      bg_color = '#353535',
      fg_color = '#c0c0c0',
    },
    new_tab = {
      bg_color = '#282828',
      fg_color = '#909090',
    },
    new_tab_hover = {
      bg_color = '#353535',
      fg_color = '#c0c0c0',
    },
  },
}

-- Cursor
config.default_cursor_style = 'SteadyBar'

-- Appearance
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 25
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "NONE"
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Behavior
config.enable_wayland = true
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- SSH domains (przykład - dodaj swoje serwery)
-- config.ssh_domains = {
--   { name = 'server', remote_address = 'user@server.com', username = 'user' }
-- }

-- Key bindings
config.keys = {
  -- Tab management
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  -- Switch to tabs by number
  { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(8) },
  -- Font zoom
  { key = '+', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
  -- Pane splitting
  { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },
}

return config
