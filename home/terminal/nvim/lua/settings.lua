local api = vim.api

-- experimental better startup
vim.loader.enable()

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- cursor behavior
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd(
  { "InsertLeave", "WinEnter" },
  {
    pattern = "*",
    command = "set cursorline",
    group = cursorGrp
  })
api.nvim_create_autocmd(
  { "InsertEnter", "WinLeave" },
  {
    pattern = "*",
    command = "set nocursorline",
    group = cursorGrp
  }
)

-- highlight on yank
local yank_group = augroup("HighlightYank", {})
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

local options = {
  mouse = "a",

  number = true,
  relativenumber = true,
  numberwidth = 4,

  tabstop = 2,   --insert 2 spaces for a tab
  softtabstop = 2,
  shiftwidth = 2, --insert 2 spaces for each indentation
  expandtab = true,

  smartindent = true,

  wrap = false,

  swapfile = false,
  backup = false,
  undodir = os.getenv('XDG_CACHE_HOME') .. '/nvim/undodir',
  undofile = true,

  hlsearch = false,
  incsearch = true,
  ignorecase = true,

  termguicolors = true,

  scrolloff = 8,
  signcolumn = "yes",

  colorcolumn = '80',
  cursorline = true, --Highlight the line where the cursor is located

  updatetime = 50,  -- faster completion (4000ms default)

  spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.isfname:append('@-@')
