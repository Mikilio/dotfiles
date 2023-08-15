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

-- Better window navigation --
keymap("n", "<Leader>wh", "<C-w>h", opts)
keymap("n", "<Leader>wj", "<C-w>j", opts)
keymap("n", "<Leader>wk", "<C-w>k", opts)
keymap("n", "<Leader>wl", "<C-w>l", opts)

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
keymap("x", "J", ":move '>+1<CR>gv=gv", opts)
keymap("x", "K", ":move '<-2<CR>gv=gv", opts)
keymap("v", "J", ":move '>+1<CR>gv=gv", opts)
keymap("v", "K", ":move '<-2<CR>gv=gv", opts)

-- Better split screen --
keymap("", "s", "<Nop>", opts)
keymap("n", "sl", ":set splitright<CR>:vsplit<CR>", opts)
keymap("n", "sh", ":set nosplitright<CR>:vsplit<CR>", opts)
keymap("n", "sk", ":set nosplitbelow<CR>:split<CR>", opts)
keymap("n", "sj", ":set splitbelow<CR>:split<CR>", opts)

--  Average adjustment window --
keymap("n", "<C-=>", "<C-w>=", opts)

-- Swap and move windows --
keymap("n", "<C-w>h", "<C-w>H", opts)
keymap("n", "<C-w>j", "<C-w>J", opts)
keymap("n", "<C-w>k", "<C-w>K", opts)
keymap("n", "<C-w>l", "<C-w>L", opts)

-- Adjust the direction of the split screen --
keymap("n", ",", "<C-w>t<C-w>K", opts)
keymap("n", ".", "<C-w>t<C-w>H", opts)

-- Resize the window --
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Better viewing of search results --
keymap("n", "<Space><CR>", ":nohlsearch<CR>", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)

keymap("v", "<C-S-c>", '"+y', opts)
keymap("v", "<C-S-x>", '"+d', opts)

--debug
keymap("n", "<Leader>xdb", ":lua require('dapui').toggle()<CR>", opts)
keymap("n", "<C-b>", ":lua require'dap'.toggle_breakpoint()<CR>", opts)


-- msic --
-- keymap("n", "K", "5k", opts)
-- keymap("n", "J", "5j", opts)
-- keymap("n", "H", "7h", opts)
-- keymap("n", "L", "7l", opts)
-- keymap("v", "p", '"_dP', opts)
