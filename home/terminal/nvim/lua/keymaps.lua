local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Better window control --
vim.keymap.set('n', '<A-Left>', require('smart-splits').resize_left)
vim.keymap.set('n', '<A-Down>', require('smart-splits').resize_down)
vim.keymap.set('n', '<A-Up>', require('smart-splits').resize_up)
vim.keymap.set('n', '<A-Right>', require('smart-splits').resize_right)

-- moving between splits
vim.keymap.set('n', '<C-Left>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-Down>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-Up>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-Right>', require('smart-splits').move_cursor_right)


-- Naviagate tabs --
keymap("n", "<Leader><TAB>n", ":tabnext<CR>", opts)
keymap("n", "<Leader><TAB>N", ":tabprevious<CR>", opts)
keymap("n", "<Leader><TAB>d", ":tabclose<CR>", opts)

-- Naviagate tabs --
keymap("n", "<Leader>bn", ":bnext<CR>", opts)
keymap("n", "<Leader>bN", ":bprevious<CR>", opts)
keymap("n", "<Leader>bd", ":bdelete<CR>", opts)

-- Stay in indent mode --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down --
keymap("x", '<S-Down>', ":move '>+1<CR>gv=gv", opts)
keymap("x", '<S-Up>', ":move '<-2<CR>gv=gv", opts)
keymap("v", '<S-Left>', ":move '>+1<CR>gv=gv", opts)
keymap("v", '<S-Right>', ":move '<-2<CR>gv=gv", opts)

-- Better split screen --
keymap("", "s", "<Nop>", opts)
keymap("n", 's<Down>', ":set nosplitbelow<CR>:split<CR>", opts)
keymap("n", 's<Up>', ":set splitbelow<CR>:split<CR>", opts)
keymap("n", 's<Left>', ":set splitright<CR>:vsplit<CR>", opts)
keymap("n", 's<Right>', ":set nosplitright<CR>:vsplit<CR>", opts)

--  Average adjustment window --
keymap("n", "<C-=>", "<C-w>=", opts)

-- Adjust the direction of the split screen --
keymap("n", ",", "<C-w>t<C-w>K", opts)
keymap("n", ".", "<C-w>t<C-w>H", opts)

-- Better viewing of search results --
keymap("n", "<Space><CR>", ":nohlsearch<CR>", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)

-- System clipboard
keymap("v", "<C-S-C>", '"*y', opts)
keymap("v", "<C-S-X>", '"*d', opts)

--debug
keymap("n", "<Leader>xdb", ":lua require('dapui').toggle()<CR>", opts)
keymap("n", "<C-b>", ":lua require'dap'.toggle_breakpoint()<CR>", opts)


-- msic --
-- keymap("n", "K", "5k", opts)
-- keymap("n", "J", "5j", opts)
-- keymap("n", "H", "7h", opts)
-- keymap("n", "L", "7l", opts)
-- keymap("v", "p", '"_dP', opts)
