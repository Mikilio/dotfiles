require('harpoon').setup({
  mark_branch = true,
})
local keymap = vim.keymap.set
local prefix = '<leader>j'
local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

keymap('n', '<leader>jn', mark.add_file)

keymap('n', prefix .. 'a', function() ui.nav_file(1) end)
keymap('n', prefix .. 's', function() ui.nav_file(2) end)
keymap('n', prefix .. 'd', function() ui.nav_file(3) end)
keymap('n', prefix .. 'f', function() ui.nav_file(4) end)
keymap('n', prefix .. 'j', function() ui.nav_file(5) end)
keymap('n', prefix .. 'k', function() ui.nav_file(6) end)
keymap('n', prefix .. 'l', function() ui.nav_file(7) end)
keymap('n', prefix .. ';', function() ui.nav_file(8) end)

vim.api.nvim_set_hl(0, 'HarpoonInactive', { link = 'lualine_b_inactive' })
vim.api.nvim_set_hl(0, 'HarpoonActive', { link = 'lualine_b_normal' })
vim.api.nvim_set_hl(0, 'HarpoonNumberActive', { link = 'lualine_b_normal' , bold = true })
vim.api.nvim_set_hl(0, 'HarpoonNumberInactive', { link = 'lualine_b_inactive', bold = true })
