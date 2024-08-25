local function wk_setup()
  local wk = require("which-key")
  wk.setup({
    plugins = {
      presets = {
        motions = false, -- adds help for motions
      },
    },
  })
  wk.add({
    { "&",           desc = 'Repeat previous ":s"' },
    -- Better window control --
    { '<A-Left>',    function() require('smart-splits').resize_left() end,       hidden = true },
    { '<A-Down>',    function() require('smart-splits').resize_down() end,       hidden = true },
    { '<A-Up>',      function() require('smart-splits').resize_up() end,         hidden = true },
    { '<A-Right>',   function() require('smart-splits').resize_right() end,      hidden = true },
    { '<A-h>',       function() require('smart-splits').resize_left() end,       hidden = true },
    { '<A-j>',       function() require('smart-splits').resize_down() end,       hidden = true },
    { '<A-k>',       function() require('smart-splits').resize_up() end,         hidden = true },
    { '<A-l>',       function() require('smart-splits').resize_right() end,      hidden = true },

    -- moving between splits
    { '<C-Left>',    function() require('smart-splits').move_cursor_left() end,  hidden = true },
    { '<C-Down>',    function() require('smart-splits').move_cursor_down() end,  hidden = true },
    { '<C-Up>',      function() require('smart-splits').move_cursor_up() end,    hidden = true },
    { '<C-Right>',   function() require('smart-splits').move_cursor_right() end, hidden = true },
    { '<C-h>',       function() require('smart-splits').move_cursor_left() end,  hidden = true },
    { '<C-j>',       function() require('smart-splits').move_cursor_down() end,  hidden = true },
    { '<C-k>',       function() require('smart-splits').move_cursor_up() end,    hidden = true },
    { '<C-l>',       function() require('smart-splits').move_cursor_right() end, hidden = true },
    { "<C-L>",       desc = "clear and redraw the screen" },
    { "<C-S-Down>",  "<C-W>J",                                                   hidden = true },
    { "<C-S-Left>",  "<C-W>H",                                                   hidden = true },
    { "<C-S-Right>", "<C-W>L",                                                   hidden = true },
    { "<C-S-Up>",    "<C-W>K",                                                   hidden = true },
    { "<C-S-h>",     "<C-W>H",                                                   hidden = true },
    { "<C-S-j>",     "<C-W>J",                                                   hidden = true },
    { "<C-S-k>",     "<C-W>K",                                                   hidden = true },
    { "<C-S-l>",     "<C-W>L",                                                   hidden = true },
    { "<leader>ex",  ":Explore<CR>",                                             desc = "netrw" },
    { "F",           hidden = true },
    { "N",           "Nzz",                                                      hidden = true },
    { "T",           hidden = true },
    { "Y",           hidden = true },
    { "f",           hidden = true },
    { "n",           "nzz",                                                      hidden = true },
    { "s",           group = "split" },
    { "s<Down>",     ":set splitbelow<CR>:split<CR>",                            desc = "New Window down" },
    { "s<Left>",     ":set nosplitright<CR>:vsplit<CR>",                         desc = "New Window left" },
    { "s<Right>",    ":set splitright<CR>:vsplit<CR>",                           desc = "New Window right" },
    { "s<Up>",       ":set nosplitbelow<CR>:split<CR>",                          desc = "New Window up" },
    { "s=",          "<C-w>=",                                                   desc = "Adjust window size" },
    { "sh",          ":set splitbelow<CR>:split<CR>",                            desc = "New Window down" },
    { "sj",          ":set nosplitbelow<CR>:split<CR>",                          desc = "New Window up" },
    { "sk",          ":set nosplitright<CR>:vsplit<CR>",                         desc = "New Window left" },
    { "sl",          ":set splitright<CR>:vsplit<CR>",                           desc = "New Window right" },
    { "sx",          ":close<CR>",                                               desc = "Close current window" },
    { "t",           hidden = true },
  })

  wk.add({
    { "#",        desc = "Search backward" },
    { "*",        desc = "Search forward" },
    { "<",        "<gv",                                      desc = "Move selected line a shiftwidth left" },
    { "<C-S-C>",  '"+y',                                      hidden = true },
    { "<C-S-X",   '"+d',                                      hidden = true },
    { "<S-Down>", ":move '<-2<CR>gv=gv",                      desc = " Move text down" },
    { "<S-Up>",   ":move '>+1<CR>gv=gv",                      desc = "Move text up" },
    { ">",        ">gv",                                      desc = "Move selected line a shiftwidth right" },
    { "@",        desc = "Repeat macro on each line" },
    { 'Q',        desc = "Repeat last recording on each line" },
    mode = "v"
  })

  wk.add({
    { "<S-Down>", ":move '<-2<CR>gv=gv", desc = " Move text down", mode = "x" },
    { "<S-Up>",   ":move '>+1<CR>gv=gv", desc = "Move text up",    mode = "x" },
  })

  wk.add({
    { "<C-U>", desc = "Delete left of cursor", mode = "i" },
    { "<C-W>", desc = "Delete last word",      mode = "i" },
  })
end

vim.g.mapleader = " "

xpcall(wk_setup, function() print("Setup of which-key failed!") end)
