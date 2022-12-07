local opt = vim.opt
local g = vim.g
local api = vim.api

-- only load filtype.lua
g.do_filetype_lua = 1
g.did_load_filetypes = 0

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
  { pattern = { "nix", "lua" }, command = "setlocal shiftwidth = 2" }
)

-- Keybinds
local map = vim.api.nvim_set_keymap
local opts = { silent = true, noremap = true }

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map('n', '<C-n>', ':Telescope live_grep <CR>', opts)
map('n', '<C-f>', ':Telescope find_files <CR>', opts)
map('n', 'j', 'gj', opts)
map('n', 'k', 'gk', opts)
map('n', ';', ':', { noremap = true } )

g.mapleader = ' '

-- Performance
opt.lazyredraw = true;
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

