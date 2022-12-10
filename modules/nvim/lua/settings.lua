local opt = vim.opt
local g = vim.g
local api = vim.api

-- cursor behavior
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd(
  { "InsertLeave", "WinEnter" },
  { pattern = "*", command = "set cursorline", group = cursorGrp }
)
api.nvim_create_autocmd(
  { "InsertEnter", "WinLeave" },
  { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- highlight on yank
local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
  command = "silent! lua vim.highlight.on_yank()",
  group = yankGrp,
})

-- reduce shiftwidth in certain filtypes
api.nvim_create_autocmd(
  "FileType",
  { pattern = { "nix", "lua" }, command = "setlocal shiftwidth=2" }
)

-- Keybinds
require('keymaps')
-- Performance
opt.lazyredraw = true
opt.shell = "bash"
opt.shadafile = "NONE"

-- Colors
opt.termguicolors = true

-- Undo files
opt.undofile = true

-- Indentation (autoindentation behavior on by default)
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.expandtab = true
opt.scrolloff = 15

-- Set clipboard to use system clipboard
opt.clipboard = "unnamedplus"

-- Use mouse
opt.mouse = "a"

-- Nicer UI settings
opt.cursorline = true
opt.relativenumber = true
opt.number = true

-- Get rid of annoying viminfo file
opt.viminfo = ""
opt.viminfofile = "NONE"

-- Miscellaneous quality of life
opt.ignorecase = true
opt.ttimeoutlen = 5
opt.hidden = true
opt.shortmess = "atI"
opt.wrap = false
opt.backup = false
opt.writebackup = false
opt.errorbells = false
opt.swapfile = false
opt.showmode = false
opt.laststatus = 3
opt.pumheight = 6
opt.splitright = true
opt.splitbelow = true
opt.completeopt = "menuone,noselect"

