vim.opt.termguicolors = true
require("bufferline").setup{
  highlights = require("catppuccin.groups.integrations.bufferline").get()
}
