-- Luakit User Configuration
-- Firefox-like keybindings · Tango dark theme

local modes = require "modes"
local settings = require "settings"
local window = require "window"

-- ── General settings ─────────────────────────────────────────────
settings.window.home_page        = "about:blank"
settings.window.new_tab_page     = "about:blank"
settings.window.scroll_step      = 40
settings.window.close_with_last_tab = true
settings.webview.zoom_level      = 100
settings.webview.enable_smooth_scrolling = true

-- ── Search engines ───────────────────────────────────────────────
settings.window.search_engines = {
    google = "https://www.google.com/search?q=%s",
    gh     = "https://github.com/search?q=%s",
    w      = "https://en.wikipedia.org/wiki/%s",
    yt     = "https://www.youtube.com/results?search_query=%s",
    ddg    = "https://duckduckgo.com/?q=%s",
}
settings.window.default_search_engine = "google"

-- ── Downloads ────────────────────────────────────────────────────
local downloads = require "downloads"
downloads.default_dir = os.getenv("HOME") .. "/Downloads"

-- ── Firefox-like keybindings (normal mode) ───────────────────────
modes.add_binds("normal", {
    -- Tabs
    { "<Control-t>",          "Open new tab",       function(w) w:new_tab("about:blank") end },
    { "<Control-w>",          "Close current tab",  function(w) w:close_tab() end },
    { "<Control-Tab>",        "Next tab",           function(w) w:next_tab() end },
    { "<Shift-Control-Tab>",  "Previous tab",       function(w) w:prev_tab() end },
    { "<Shift-Control-t>",    "Undo close tab",     function(w) w:undo_close_tab() end },

    -- Navigation
    { "<Control-l>",       "Focus address bar",  function(w) w:enter_cmd(":open ") end },
    { "<Control-r>",       "Reload page",        function(w) w:reload() end },
    { "<F5>",              "Reload page",        function(w) w:reload() end },
    { "<Mod1-Left>",       "Go back",            function(w) w:back() end },
    { "<Mod1-Right>",      "Go forward",         function(w) w:forward() end },

    -- Find
    { "<Control-f>",       "Find in page",       function(w) w:enter_cmd("/") end },

    -- Zoom
    { "<Control-equal>",   "Zoom in",            function(w) w:zoom_in() end },
    { "<Control-Minus>",   "Zoom out",           function(w) w:zoom_out() end },
    { "<Control-0>",       "Reset zoom",         function(w) w:zoom_set() end },

    -- Window
    { "<Control-n>",       "New window",         function() window.new({"about:blank"}) end },
    { "<F11>",             "Toggle fullscreen",  function(w) w.win.fullscreen = not w.win.fullscreen end },
})
