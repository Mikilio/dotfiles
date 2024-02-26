local function wk_setup()
  local wk = require("which-key")
  wk.setup({
    plugins = {
      presets = {
        motions = false, -- adds help for motions
      },
    },
  })
  wk.register({
    -- Better window control --
    ['<A-Left>'] = { require('smart-splits').resize_left, "which_key_ignore" },
    ['<A-Down>'] = { require('smart-splits').resize_down, "which_key_ignore" },
    ['<A-Up>'] = { require('smart-splits').resize_up, "which_key_ignore" },
    ['<A-Right>'] = { require('smart-splits').resize_right, "which_key_ignore" },

    -- moving between splits
    ['<C-Left>'] = { require('smart-splits').move_cursor_left, "which_key_ignore" },
    ['<C-Down>'] = { require('smart-splits').move_cursor_down, "which_key_ignore" },
    ['<C-Up>'] = { require('smart-splits').move_cursor_up, "which_key_ignore" },
    ['<C-Right>'] = { require('smart-splits').move_cursor_right, "which_key_ignore" },

    -- moving between splits
    ['<C-S-Left>'] = { '<C-W>H', "which_key_ignore" },
    ['<C-S-Down>'] = { '<C-W>J', "which_key_ignore" },
    ['<C-S-Up>'] = { '<C-W>K', "which_key_ignore" },
    ['<C-S-Right>'] = { '<C-W>L', "which_key_ignore" },

    -- splitting windows
    s = {
      name = "split",
      ['<Down>'] = { ":set splitbelow<CR>:split<CR>", "New Window down" },
      ['<Up>'] = { ":set nosplitbelow<CR>:split<CR>", "New Window up" },
      ['<Left>'] = { ":set nosplitright<CR>:vsplit<CR>", "New Window left" },
      ['<Right>'] = { ":set splitright<CR>:vsplit<CR>", "New Window right" },
      ['='] = { "<C-w>=", "Adjust window size" },
      x = { ":close<CR>", "Close current window" }
    },

    -- Better viewing of search results --
    n = { "nzz", "which_key_ignore" },
    N = { "Nzz", "which_key_ignore" },

    -- missing descriptions
    ['<C-L>'] = "clear and redraw the screen",
    ['&'] = 'Repeat previous ":s"',
    Y = "which_key_ignore",
    f = "which_key_ignore",
    F = "which_key_ignore",
    t = "which_key_ignore",
    T = "which_key_ignore",
  })

  wk.register({
    -- Stay in indent mode --
    ['<'] = { "<gv", "Move selected line a shiftwidth left" },
    ['>'] = { ">gv", "Move selected line a shiftwidth right" },

    -- System clipboard
    ['<C-S-C>'] = { '"*y', "which_key_ignore" },
    ['<C-S-X'] = { '"*d', "which_key_ignore" },

    -- Move text up and down --
    ['<S-Up>'] = { ":move '>+1<CR>gv=gv", "Move text up" },
    ['<S-Down>'] = { ":move '<-2<CR>gv=gv", " Move text down" },

    -- missing descriptions
    Q = "Repeat last recording on each line",
    ['@'] = "Repeat macro on each line",
    ['*'] = "Search forward",
    ['#'] = "Search backward",

  }, { mode = "v" })

  wk.register({
    -- Move text up and down --
    ['<S-Up>'] = { ":move '>+1<CR>gv=gv", "Move text up" },
    ['<S-Down>'] = { ":move '<-2<CR>gv=gv", " Move text down" },
  }, { mode = "x" })

  wk.register({
    -- missing descriptions
    ['<C-U>'] = "Delete left of cursor",
    ['<C-W>'] = "Delete last word",
  }, { mode = "i" })
end

vim.g.mapleader = " "

xpcall(wk_setup, function() print("Setup of which-key failed!") end)
