# =============================================================================
# Qutebrowser Configuration - Catppuccin Mocha theme
# =============================================================================

config.load_autoconfig(False)

# =============================================================================
# General Settings
# =============================================================================

c.aliases = {
    'q': 'quit',
    'w': 'session-save',
    'wq': 'quit --save',
}

c.auto_save.session = True
c.session.lazy_restore = True

c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = False

c.tabs.show = 'multiple'
c.tabs.last_close = 'close'
c.tabs.position = 'top'

c.scrolling.smooth = True

c.content.autoplay = False

# =============================================================================
# Privacy & Security
# =============================================================================

c.content.cookies.accept = 'no-3rdparty'
c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
c.content.geolocation = False
c.content.notifications.enabled = False

config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')

# =============================================================================
# Dark Mode
# =============================================================================

config.set("colors.webpage.darkmode.enabled", True)
config.set("colors.webpage.preferred_color_scheme", "dark")

# =============================================================================
# User Agent Overrides
# =============================================================================

config.set('content.headers.user_agent', 
    'Mozilla/5.0 ({os_info}; rv:109.0) Gecko/20100101 Firefox/115.0', 
    'https://accounts.google.com/*')
config.set('content.headers.user_agent', 
    'Mozilla/5.0 ({os_info}; rv:109.0) Gecko/20100101 Firefox/115.0', 
    'https://docs.google.com/*')
config.set('content.headers.user_agent', 
    'Mozilla/5.0 ({os_info}; rv:109.0) Gecko/20100101 Firefox/115.0', 
    'https://drive.google.com/*')

# =============================================================================
# Start Pages & Search
# =============================================================================

c.url.default_page = 'about:blank'
c.url.start_pages = ['about:blank']

c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'g': 'https://www.google.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'gh': 'https://github.com/search?q={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
    'vw': 'https://wiki.voidlinux.org/index.php?search={}',
    'r': 'https://www.reddit.com/r/{}',
    'w': 'https://en.wikipedia.org/wiki/{}',
    'nix': 'https://search.nixos.org/packages?query={}',
}

# =============================================================================
# Fonts
# =============================================================================

c.fonts.default_family = ['Intel One Mono', 'monospace']
c.fonts.default_size = '11pt'
c.fonts.web.family.fixed = 'Intel One Mono'
c.fonts.web.family.sans_serif = 'Inter'
c.fonts.web.family.serif = 'Inter'

# =============================================================================
# Catppuccin Mocha Colors
# =============================================================================

# Base colors
bg = "#1e1e2e"
fg = "#cdd6f4"
surface0 = "#313244"
surface1 = "#45475a"
surface2 = "#585b70"
overlay0 = "#6c7086"
blue = "#89b4fa"
green = "#a6e3a1"
red = "#f38ba8"
yellow = "#f9e2af"
mauve = "#cba6f7"
teal = "#94e2d5"
peach = "#fab387"

# Completion
c.colors.completion.fg = fg
c.colors.completion.odd.bg = bg
c.colors.completion.even.bg = surface0
c.colors.completion.category.fg = mauve
c.colors.completion.category.bg = bg
c.colors.completion.category.border.top = bg
c.colors.completion.category.border.bottom = bg
c.colors.completion.item.selected.fg = bg
c.colors.completion.item.selected.bg = blue
c.colors.completion.item.selected.border.top = blue
c.colors.completion.item.selected.border.bottom = blue
c.colors.completion.item.selected.match.fg = red
c.colors.completion.match.fg = green
c.colors.completion.scrollbar.fg = blue
c.colors.completion.scrollbar.bg = bg

# Context menu
c.colors.contextmenu.menu.bg = bg
c.colors.contextmenu.menu.fg = fg
c.colors.contextmenu.selected.bg = blue
c.colors.contextmenu.selected.fg = bg

# Downloads
c.colors.downloads.bar.bg = bg
c.colors.downloads.start.fg = bg
c.colors.downloads.start.bg = blue
c.colors.downloads.stop.fg = bg
c.colors.downloads.stop.bg = green
c.colors.downloads.error.fg = red

# Hints
c.colors.hints.fg = bg
c.colors.hints.bg = yellow
c.colors.hints.match.fg = overlay0

# Keyhint
c.colors.keyhint.fg = fg
c.colors.keyhint.suffix.fg = yellow
c.colors.keyhint.bg = bg

# Messages
c.colors.messages.error.fg = bg
c.colors.messages.error.bg = red
c.colors.messages.error.border = red
c.colors.messages.warning.fg = bg
c.colors.messages.warning.bg = peach
c.colors.messages.warning.border = peach
c.colors.messages.info.fg = fg
c.colors.messages.info.bg = bg
c.colors.messages.info.border = bg

# Prompts
c.colors.prompts.fg = fg
c.colors.prompts.border = bg
c.colors.prompts.bg = bg
c.colors.prompts.selected.fg = bg
c.colors.prompts.selected.bg = blue

# Statusbar
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.normal.bg = bg
c.colors.statusbar.insert.fg = bg
c.colors.statusbar.insert.bg = green
c.colors.statusbar.passthrough.fg = bg
c.colors.statusbar.passthrough.bg = mauve
c.colors.statusbar.private.fg = bg
c.colors.statusbar.private.bg = surface1
c.colors.statusbar.command.fg = fg
c.colors.statusbar.command.bg = bg
c.colors.statusbar.caret.fg = bg
c.colors.statusbar.caret.bg = yellow
c.colors.statusbar.caret.selection.fg = bg
c.colors.statusbar.caret.selection.bg = blue
c.colors.statusbar.progress.bg = blue
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.error.fg = red
c.colors.statusbar.url.hover.fg = teal
c.colors.statusbar.url.success.http.fg = fg
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.warn.fg = yellow

# Tabs
c.colors.tabs.bar.bg = bg
c.colors.tabs.indicator.start = blue
c.colors.tabs.indicator.stop = green
c.colors.tabs.indicator.error = red
c.colors.tabs.odd.fg = fg
c.colors.tabs.odd.bg = surface0
c.colors.tabs.even.fg = fg
c.colors.tabs.even.bg = bg
c.colors.tabs.selected.odd.fg = bg
c.colors.tabs.selected.odd.bg = blue
c.colors.tabs.selected.even.fg = bg
c.colors.tabs.selected.even.bg = blue
c.colors.tabs.pinned.odd.fg = bg
c.colors.tabs.pinned.odd.bg = teal
c.colors.tabs.pinned.even.fg = bg
c.colors.tabs.pinned.even.bg = green
c.colors.tabs.pinned.selected.odd.fg = bg
c.colors.tabs.pinned.selected.odd.bg = blue
c.colors.tabs.pinned.selected.even.fg = bg
c.colors.tabs.pinned.selected.even.bg = blue

# =============================================================================
# Key Bindings
# =============================================================================

# Clear some defaults for remapping
config.unbind('j')
config.unbind('k')
config.unbind('J')
config.unbind('K')

# Navigation (ijkl)
config.bind('i', 'scroll-page 0 -0.5')
config.bind('k', 'scroll-page 0 0.5')
config.bind('j', 'back')
config.bind('l', 'forward')

config.bind('I', 'scroll up')
config.bind('K', 'scroll down')
config.bind('J', 'scroll left')
config.bind('L', 'scroll right')

# Tabs
config.bind('u', 'tab-prev')
config.bind('o', 'tab-next')
config.bind('U', 'tab-move -')
config.bind('O', 'tab-move +')

# Tab management
config.bind('t', 'open -t')
config.bind('x', 'tab-close')
config.bind('X', 'undo')

# Search
config.bind('/', 'set-cmd-text /')
config.bind('n', 'search-next')
config.bind('N', 'search-prev')

# Misc
config.bind('r', 'reload')
config.bind('R', 'reload -f')
config.bind('yy', 'yank')
config.bind('yt', 'yank title')
config.bind('p', 'open -- {clipboard}')
config.bind('P', 'open -t -- {clipboard}')

# Hints
config.bind('f', 'hint')
config.bind('F', 'hint all tab')

# Video/media
config.bind(';m', 'hint links spawn mpv {hint-url}')
config.bind(';d', 'hint links spawn yt-dlp -o "~/Downloads/%(title)s.%(ext)s" {hint-url}')
