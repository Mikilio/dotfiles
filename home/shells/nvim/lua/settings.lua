local g = vim.g
local api = vim.api

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

local options  = {
	mouse = "a",
	undofile = true,
	ignorecase = true,
	smartcase = true,
	showmode = false,
	showtabline = 2,
	swapfile = false,
	hidden = true, --default on
	expandtab = true,
	cmdheight = 1,
	shiftwidth = 2, --insert 2 spaces for each indentation
	tabstop = 2, --insert 2 spaces for a tab
	cursorline = true, --Highlight the line where the cursor is located
	cursorcolumn = false,
	number = true,
	numberwidth = 4,
	relativenumber = true,
	textwidth = 0,
	scrolloff = 8,
	fileencodings = "utf-8,gbk",
  updatetime = 50, -- faster completion (4000ms default)
  incsearch = true,
	spelllang = 'en_us',
  spelloptions = 'camel'
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

g.netrw_banner = 0
