-- Luakit User Configuration
-- Firefox-like keybindings · Tango dark theme

local modes = require "modes"
local settings = require "settings"
local window = require "window"

-- ── Hide scrollbars ──────────────────────────────────────────────
require "hide_scrollbars"

-- ── Auto-hide tab bar + bottom bar with single tab ──────────────
window.add_signal("init", function(w)
    local single = false

    local function update_bars()
        single = w.tabs:count() <= 1
        w.tablist.visible = not single
        w.bar_layout.visible = not single
    end

    -- Show bottom bar when entering command/search mode, hide on exit
    w:add_signal("mode-changed", function(_, mode)
        if single then
            w.bar_layout.visible = (mode == "command" or mode == "search")
        end
    end)

    w.tabs:add_signal("page-added", update_bars)
    w.tabs:add_signal("page-removed", update_bars)
    update_bars()
end)

-- ── Dark background for blank/new pages + selection highlight ─────
local webview = require "webview"
webview.add_signal("init", function(view)
    view:add_signal("load-status", function(v, status)
        if status == "committed" then
            v:eval_js([[
                document.documentElement.style.backgroundColor = "#000000";
                var s = document.createElement("style");
                s.textContent = "::selection { background: #3465a4 !important; color: #eeeeec !important; }";
                document.head.appendChild(s);
            ]], { no_return = true })
        end
    end)
end)

-- ── General settings ─────────────────────────────────────────────
settings.window.home_page        = "about:blank"
settings.window.new_tab_page     = "about:blank"
settings.window.scroll_step      = 160
settings.window.close_with_last_tab = true
settings.webview.zoom_level      = 100
settings.webview.enable_smooth_scrolling = false

-- ── Hardware acceleration ────────────────────────────────────────
settings.webview.hardware_acceleration_policy = "always"
settings.webview.enable_accelerated_2d_canvas = true

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
