-- Neovim configuration
-- Micro-like keybindings · Tango dark theme

-- ── Plugin bootstrap (no plugin manager) ─────────────────────────
local pack_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/"

local function ensure_plugin(name, repo)
    local dir = pack_path .. name
    if not vim.uv.fs_stat(dir) then
        vim.fn.system({ "git", "clone", "--depth", "1",
            "https://github.com/" .. repo .. ".git", dir })
    end
end

ensure_plugin("vim-visual-multi", "mg979/vim-visual-multi")

-- VM settings (before plugin loads)
vim.g.VM_theme = "neon"
vim.g.VM_maps = {
    ["Find Under"]         = "<C-d>",    -- select word / next match
    ["Find Subword Under"] = "<C-d>",    -- same in visual mode
    ["Add Cursor Up"]      = "<S-C-Up>",
    ["Add Cursor Down"]    = "<S-C-Down>",
    ["Select All"]         = "<S-C-a>",  -- select all matches
    ["Skip Region"]        = "<C-x>",    -- skip current match
}

-- ── Options ──────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number         = true
o.relativenumber = true
o.cursorline     = true
o.signcolumn     = "yes"
o.scrolloff      = 8
o.sidescrolloff  = 8
o.wrap           = true
o.linebreak      = true
o.breakindent    = true
o.showbreak      = "↪ "

o.expandtab      = true
o.shiftwidth     = 4
o.tabstop        = 4
o.smartindent    = true

o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = true
o.incsearch      = true

o.splitright     = true
o.splitbelow     = true
o.mouse          = "a"
o.clipboard      = "unnamedplus"
o.undofile       = true
o.swapfile       = false
o.termguicolors  = true
o.updatetime     = 250
o.timeoutlen     = 300
o.showmode       = false
o.laststatus     = 3
o.confirm        = true

-- ── Tango Dark Colorscheme ───────────────────────────────────────
local function tango()
    local hi = vim.api.nvim_set_hl

    -- Tango palette
    local bg      = "#000000"
    local fg      = "#D0CFCC"
    local black   = "#2E3436"
    local red     = "#CC0000"
    local green   = "#4E9A06"
    local yellow  = "#C4A000"
    local blue    = "#3465A4"
    local magenta = "#75507B"
    local cyan    = "#06989A"
    local white   = "#D3D7CF"
    local br_black   = "#555753"
    local br_red     = "#EF2929"
    local br_green   = "#8AE234"
    local br_yellow  = "#FCE94F"
    local br_blue    = "#729FCF"
    local br_magenta = "#AD7FA8"
    local br_cyan    = "#34E2E2"
    local br_white   = "#EEEEEC"
    local sel_bg  = "#3465A4"
    local sel_fg  = "#EEEEEC"
    local gutter  = "#555753"
    local comment = "#555753"
    local line_bg = "#1A1A1A"

    -- UI
    hi(0, "Normal",       { fg = fg, bg = bg })
    hi(0, "NormalFloat",  { fg = fg, bg = "#1A1A1A" })
    hi(0, "FloatBorder",  { fg = br_black, bg = "#1A1A1A" })
    hi(0, "CursorLine",   { bg = line_bg })
    hi(0, "CursorLineNr", { fg = br_yellow, bold = true })
    hi(0, "LineNr",        { fg = gutter })
    hi(0, "SignColumn",    { fg = gutter, bg = bg })
    hi(0, "Visual",        { bg = sel_bg, fg = sel_fg })
    hi(0, "Search",        { fg = bg, bg = br_yellow })
    hi(0, "IncSearch",     { fg = bg, bg = br_green })
    hi(0, "CurSearch",     { fg = bg, bg = br_green })
    hi(0, "Pmenu",         { fg = fg, bg = "#1A1A1A" })
    hi(0, "PmenuSel",      { fg = sel_fg, bg = sel_bg })
    hi(0, "PmenuThumb",    { bg = br_black })
    hi(0, "StatusLine",    { fg = fg, bg = "#1A1A1A" })
    hi(0, "StatusLineNC",  { fg = br_black, bg = "#0D0D0D" })
    hi(0, "WinSeparator",  { fg = black })
    hi(0, "MatchParen",    { fg = br_yellow, bold = true, underline = true })
    hi(0, "NonText",       { fg = black })
    hi(0, "SpecialKey",    { fg = black })
    hi(0, "Directory",     { fg = br_blue })
    hi(0, "Title",         { fg = br_blue, bold = true })
    hi(0, "ErrorMsg",      { fg = br_red, bold = true })
    hi(0, "WarningMsg",    { fg = br_yellow })
    hi(0, "ModeMsg",       { fg = green, bold = true })
    hi(0, "MoreMsg",       { fg = cyan })
    hi(0, "Question",      { fg = cyan })
    hi(0, "Folded",        { fg = br_black, bg = "#0D0D0D" })
    hi(0, "DiffAdd",       { fg = green, bg = "#0D1A0D" })
    hi(0, "DiffChange",    { fg = yellow, bg = "#1A1A0D" })
    hi(0, "DiffDelete",    { fg = red, bg = "#1A0D0D" })
    hi(0, "DiffText",      { fg = bg, bg = yellow })
    hi(0, "DiagnosticError",   { fg = br_red })
    hi(0, "DiagnosticWarn",    { fg = br_yellow })
    hi(0, "DiagnosticInfo",    { fg = br_blue })
    hi(0, "DiagnosticHint",    { fg = br_cyan })

    -- Syntax
    hi(0, "Comment",    { fg = comment, italic = true })
    hi(0, "Constant",   { fg = br_red })
    hi(0, "String",     { fg = green })
    hi(0, "Character",  { fg = green })
    hi(0, "Number",     { fg = br_magenta })
    hi(0, "Boolean",    { fg = br_magenta })
    hi(0, "Float",      { fg = br_magenta })
    hi(0, "Identifier", { fg = fg })
    hi(0, "Function",   { fg = br_blue })
    hi(0, "Statement",  { fg = white, bold = true })
    hi(0, "Keyword",    { fg = white, bold = true })
    hi(0, "Operator",   { fg = fg })
    hi(0, "PreProc",    { fg = br_magenta })
    hi(0, "Include",    { fg = br_magenta })
    hi(0, "Type",       { fg = br_yellow })
    hi(0, "Special",    { fg = cyan })
    hi(0, "Delimiter",  { fg = fg })
    hi(0, "Error",      { fg = br_red, undercurl = true })
    hi(0, "Todo",       { fg = br_yellow, bg = bg, bold = true })

    -- Treesitter
    hi(0, "@variable",        { fg = fg })
    hi(0, "@variable.builtin",{ fg = br_red })
    hi(0, "@constant",        { fg = br_red })
    hi(0, "@constant.builtin",{ fg = br_magenta })
    hi(0, "@function",        { fg = br_blue })
    hi(0, "@function.builtin",{ fg = cyan })
    hi(0, "@method",          { fg = br_blue })
    hi(0, "@keyword",         { fg = white, bold = true })
    hi(0, "@keyword.return",  { fg = br_red, bold = true })
    hi(0, "@string",          { fg = green })
    hi(0, "@number",          { fg = br_magenta })
    hi(0, "@boolean",         { fg = br_magenta })
    hi(0, "@type",            { fg = br_yellow })
    hi(0, "@type.builtin",    { fg = yellow })
    hi(0, "@property",        { fg = fg })
    hi(0, "@field",           { fg = fg })
    hi(0, "@parameter",       { fg = fg })
    hi(0, "@punctuation",     { fg = fg })
    hi(0, "@comment",         { fg = comment, italic = true })
    hi(0, "@tag",             { fg = br_blue })
    hi(0, "@tag.attribute",   { fg = br_yellow })
    hi(0, "@tag.delimiter",   { fg = br_black })
end

tango()

-- ── Statusline ───────────────────────────────────────────────────
function Statusline()
    local mode_map = {
        n = " NORMAL ", i = " INSERT ", v = " VISUAL ", V = " V-LINE ",
        ["\22"] = " V-BLOCK ", c = " COMMAND ", R = " REPLACE ", t = " TERMINAL ",
    }
    local mode = mode_map[vim.fn.mode()] or " " .. vim.fn.mode() .. " "
    local file = " %f %m"
    local pos = " %l:%c "
    local pct = " %p%% "
    return "%#PmenuSel#" .. mode .. "%#StatusLine#" .. file
        .. "%=" .. pos .. "%#PmenuSel#" .. pct
end
o.statusline = "%!v:lua.Statusline()"

-- ── Micro-like Keybindings ───────────────────────────────────────
local map = vim.keymap.set

-- Save / Quit
map({"n", "i", "v"}, "<C-s>", "<Cmd>w<CR>",           { desc = "Save" })
map({"n", "i", "v"}, "<C-q>", "<Cmd>confirm q<CR>",    { desc = "Quit" })

-- Undo / Redo
map("n", "<C-z>", "u",        { desc = "Undo" })
map("i", "<C-z>", "<C-o>u",   { desc = "Undo" })
map("n", "<C-y>", "<C-r>",    { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })

-- Select all
map("n", "<C-a>", "ggVG",     { desc = "Select all" })

-- Comment toggle (Ctrl+/)
map({"n", "v"}, "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("i", "<C-_>", "<Esc>gcc", { remap = true, desc = "Toggle comment" })

-- Move lines (Ctrl+Up/Down like micro)
map("n", "<C-Up>",   "<Cmd>move .-2<CR>==",       { desc = "Move line up" })
map("n", "<C-Down>", "<Cmd>move .+1<CR>==",        { desc = "Move line down" })
map("i", "<C-Up>",   "<Esc><Cmd>move .-2<CR>==gi", { desc = "Move line up" })
map("i", "<C-Down>", "<Esc><Cmd>move .+1<CR>==gi", { desc = "Move line down" })
map("v", "<C-Up>",   ":move '<-2<CR>gv=gv",        { desc = "Move selection up" })
map("v", "<C-Down>", ":move '>+1<CR>gv=gv",        { desc = "Move selection down" })

-- Duplicate line (Ctrl+Shift+D)
map("n", "<S-C-d>", "<Cmd>t.<CR>",          { desc = "Duplicate line" })
map("i", "<S-C-d>", "<Esc><Cmd>t.<CR>gi",   { desc = "Duplicate line" })

-- Delete word backward (Ctrl+Backspace)
map("i", "<C-BS>", "<C-w>",  { desc = "Delete word left" })
map("i", "<C-h>",  "<C-w>",  { desc = "Delete word left" })

-- Word navigation (Alt+Left/Right like micro)
map({"n", "i"}, "<A-Left>",  "<C-Left>",  { desc = "Word left" })
map({"n", "i"}, "<A-Right>", "<C-Right>", { desc = "Word right" })

-- Find (Ctrl+F)
map("n", "<C-f>", "/",          { desc = "Find" })
map("i", "<C-f>", "<Esc>/",    { desc = "Find" })

-- Find and replace (Ctrl+H)
map("n", "<C-h>", ":%s//g<Left><Left>", { desc = "Replace" })

-- Clear search highlight
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search" })

-- Tab navigation
map("n", "<C-t>",     "<Cmd>tabnew<CR>",     { desc = "New tab" })
map("n", "<C-w>",     "<Cmd>confirm close<CR>", { desc = "Close tab" })
map("n", "<C-Tab>",   "<Cmd>tabnext<CR>",    { desc = "Next tab" })
map("n", "<S-C-Tab>", "<Cmd>tabprev<CR>",    { desc = "Prev tab" })

-- File explorer (netrw)
map("n", "<C-e>", "<Cmd>Explore<CR>", { desc = "File explorer" })

-- Better indenting in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ── Autocommands ─────────────────────────────────────────────────

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ timeout = 200 }) end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})
