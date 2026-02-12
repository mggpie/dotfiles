# Qutebrowser configuration
config.load_autoconfig(False)

# General settings
c.auto_save.session = True
c.scrolling.smooth = True
c.tabs.position = "top"
c.tabs.show = "multiple"
c.tabs.title.format = "{audio}{current_title}"
c.tabs.title.format_pinned = "{audio}"
c.tabs.padding = {"top": 4, "bottom": 4, "left": 8, "right": 8}
c.tabs.indicator.width = 0
c.tabs.favicons.scale = 1.0
c.statusbar.show = "in-mode"
c.url.start_pages = ["about:blank"]
c.url.default_page = "about:blank"

# Downloads
c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False
c.downloads.remove_finished = 5000

# Fonts
c.fonts.default_family = "IntoneMono Nerd Font"
c.fonts.default_size = "10pt"
c.fonts.web.family.standard = "Inter"
c.fonts.web.family.sans_serif = "Inter"
c.fonts.web.family.serif = "Inter"
c.fonts.web.family.fixed = "IntoneMono Nerd Font"
c.fonts.completion.entry = "10pt IntoneMono Nerd Font"
c.fonts.completion.category = "bold 10pt IntoneMono Nerd Font"
c.fonts.statusbar = "10pt IntoneMono Nerd Font"
c.fonts.tabs.selected = "bold 10pt IntoneMono Nerd Font"
c.fonts.tabs.unselected = "10pt IntoneMono Nerd Font"

# Content blocking (uBlock-style)
c.content.blocking.enabled = True
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt",
]

# Privacy
c.content.cookies.accept = "no-3rdparty"
c.content.headers.do_not_track = True
c.content.webgl = True
c.content.canvas_reading = False
c.content.webrtc_ip_handling_policy = "default-public-interface-only"

# Colors - matching waybar/sway theme (black background, blue accents)
c.colors.completion.fg = "#D0CFCC"
c.colors.completion.odd.bg = "#000000"
c.colors.completion.even.bg = "#0A0A0A"
c.colors.completion.category.fg = "#FFFFFF"
c.colors.completion.category.bg = "#000000"
c.colors.completion.category.border.top = "#000000"
c.colors.completion.category.border.bottom = "#000000"
c.colors.completion.item.selected.fg = "#FFFFFF"
c.colors.completion.item.selected.bg = "#3465A4"
c.colors.completion.item.selected.border.top = "#3465A4"
c.colors.completion.item.selected.border.bottom = "#3465A4"
c.colors.completion.match.fg = "#EEEEEC"
c.colors.completion.scrollbar.fg = "#D0CFCC"
c.colors.completion.scrollbar.bg = "#000000"

c.colors.contextmenu.disabled.bg = "#0A0A0A"
c.colors.contextmenu.disabled.fg = "#555555"
c.colors.contextmenu.menu.bg = "#000000"
c.colors.contextmenu.menu.fg = "#D0CFCC"
c.colors.contextmenu.selected.bg = "#3465A4"
c.colors.contextmenu.selected.fg = "#FFFFFF"

c.colors.downloads.bar.bg = "#000000"
c.colors.downloads.start.fg = "#000000"
c.colors.downloads.start.bg = "#3465A4"
c.colors.downloads.stop.fg = "#FFFFFF"
c.colors.downloads.stop.bg = "#4E9A06"
c.colors.downloads.error.fg = "#CC0000"

c.colors.hints.fg = "#000000"
c.colors.hints.bg = "#EEEEEC"
c.colors.hints.match.fg = "#3465A4"

c.colors.keyhint.fg = "#D0CFCC"
c.colors.keyhint.suffix.fg = "#EEEEEC"
c.colors.keyhint.bg = "#000000"

c.colors.messages.error.fg = "#FFFFFF"
c.colors.messages.error.bg = "#CC0000"
c.colors.messages.error.border = "#CC0000"
c.colors.messages.warning.fg = "#000000"
c.colors.messages.warning.bg = "#C4A000"
c.colors.messages.warning.border = "#C4A000"
c.colors.messages.info.fg = "#D0CFCC"
c.colors.messages.info.bg = "#000000"
c.colors.messages.info.border = "#000000"

c.colors.prompts.fg = "#D0CFCC"
c.colors.prompts.bg = "#000000"
c.colors.prompts.border = "#3465A4"
c.colors.prompts.selected.fg = "#FFFFFF"
c.colors.prompts.selected.bg = "#3465A4"

c.colors.statusbar.normal.fg = "#D0CFCC"
c.colors.statusbar.normal.bg = "#000000"
c.colors.statusbar.insert.fg = "#000000"
c.colors.statusbar.insert.bg = "#4E9A06"
c.colors.statusbar.passthrough.fg = "#000000"
c.colors.statusbar.passthrough.bg = "#3465A4"
c.colors.statusbar.private.fg = "#FFFFFF"
c.colors.statusbar.private.bg = "#555753"
c.colors.statusbar.command.fg = "#D0CFCC"
c.colors.statusbar.command.bg = "#000000"
c.colors.statusbar.command.private.fg = "#FFFFFF"
c.colors.statusbar.command.private.bg = "#555753"
c.colors.statusbar.caret.fg = "#000000"
c.colors.statusbar.caret.bg = "#C4A000"
c.colors.statusbar.caret.selection.fg = "#000000"
c.colors.statusbar.caret.selection.bg = "#3465A4"
c.colors.statusbar.progress.bg = "#3465A4"
c.colors.statusbar.url.fg = "#D0CFCC"
c.colors.statusbar.url.error.fg = "#CC0000"
c.colors.statusbar.url.hover.fg = "#EEEEEC"
c.colors.statusbar.url.success.http.fg = "#4E9A06"
c.colors.statusbar.url.success.https.fg = "#4E9A06"
c.colors.statusbar.url.warn.fg = "#C4A000"

c.colors.tabs.bar.bg = "#000000"
c.colors.tabs.indicator.start = "#3465A4"
c.colors.tabs.indicator.stop = "#4E9A06"
c.colors.tabs.indicator.error = "#CC0000"
c.colors.tabs.odd.fg = "#888888"
c.colors.tabs.odd.bg = "#000000"
c.colors.tabs.even.fg = "#888888"
c.colors.tabs.even.bg = "#000000"
c.colors.tabs.pinned.odd.fg = "#888888"
c.colors.tabs.pinned.odd.bg = "#000000"
c.colors.tabs.pinned.even.fg = "#888888"
c.colors.tabs.pinned.even.bg = "#000000"
c.colors.tabs.pinned.selected.odd.fg = "#FFFFFF"
c.colors.tabs.pinned.selected.odd.bg = "#0A0A0A"
c.colors.tabs.pinned.selected.even.fg = "#FFFFFF"
c.colors.tabs.pinned.selected.even.bg = "#0A0A0A"
c.colors.tabs.selected.odd.fg = "#FFFFFF"
c.colors.tabs.selected.odd.bg = "#0A0A0A"
c.colors.tabs.selected.even.fg = "#FFFFFF"
c.colors.tabs.selected.even.bg = "#0A0A0A"

c.colors.webpage.bg = "#000000"
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = "smart"
c.colors.webpage.darkmode.algorithm = "brightness-rgb"

# Keybindings
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('d', 'tab-close')
config.bind('u', 'undo')
config.bind('x', 'tab-close')
config.bind('X', 'undo')
config.bind('gt', 'tab-next')
config.bind('gT', 'tab-prev')
config.bind('r', 'reload')
config.bind('R', 'reload -f')
config.bind('<Ctrl-r>', 'reload -f')

# Mouse gestures (configured via input.mouse_gestures)
# Note: qutebrowser doesn't have native complex gesture support like you described
# You'll need to use external tools like easystroke or configure simple gestures
c.input.mouse.back_forward_buttons = True

# Search engines
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'g': 'https://www.google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'w': 'https://en.wikipedia.org/wiki/{}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'ddg': 'https://duckduckgo.com/?q={}',
}

# Per-domain settings
config.set('content.javascript.enabled', True, 'file://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')
