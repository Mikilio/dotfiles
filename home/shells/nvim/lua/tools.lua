local function autopairs_setup ()
  require("nvim-autopairs").setup({
    check_ts = true,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      java = false,
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = 0, -- Offset from pattern match
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  })
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
end

local function comment_setup ()
  require("Comment").setup({
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  })
end

local function surround_setup ()
    require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
    })
end

local function hop_setup ()
  local hop = require('hop')
  hop.setup()
  local directions = require('hop.hint').HintDirection
  vim.keymap.set('', 'f',
    function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = true
      })
    end,
    {remap=true}
  )
  vim.keymap.set('', 'F',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true
      })
    end,
    {remap=true}
  )
  vim.keymap.set('', 't',
    function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1 })
    end,
    {remap=true}
  )
  vim.keymap.set('', 'T',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = 1 })
    end,
    {remap=true}
  )
  vim.keymap.set('', 'gf', hop.hint_char1, {remap=true})
end

local function harpoon_setup ()
  require('harpoon').setup({
    mark_branch = true,
  })
  local keymap = vim.keymap.set
  local prefix = '<leader>j'
  local mark = require('harpoon.mark')
  local ui = require('harpoon.ui')

  keymap('n', prefix .. 'n', mark.add_file)

  keymap('n', prefix .. 'a', function() ui.nav_file(1) end)
  keymap('n', prefix .. 's', function() ui.nav_file(2) end)
  keymap('n', prefix .. 'd', function() ui.nav_file(3) end)
  keymap('n', prefix .. 'f', function() ui.nav_file(4) end)
  keymap('n', prefix .. 'j', function() ui.nav_file(5) end)
  keymap('n', prefix .. 'k', function() ui.nav_file(6) end)
  keymap('n', prefix .. 'l', function() ui.nav_file(7) end)
  keymap('n', prefix .. ';', function() ui.nav_file(8) end)

  vim.api.nvim_set_hl(0, 'HarpoonInactive', { link = 'lualine_b_normal' })
  vim.api.nvim_set_hl(0, 'HarpoonActive', { link = 'lualine_a_normal' })
  vim.api.nvim_set_hl(0, 'HarpoonNumberActive', { link = 'lualine_a_normal' , bold = true })
  vim.api.nvim_set_hl(0, 'HarpoonNumberInactive', { link = 'lualine_b_normal', bold = true })
end

xpcall(autopairs_setup, function () print("Setup of autopairs failed!") end)
xpcall(comment_setup, function () print("Setup of comments failed!") end)
xpcall(surround_setup, function () print("Setup of surround failed!") end)
xpcall(hop_setup, function () print("Setup of hop failed!") end)
xpcall(harpoon_setup, function () print("Setup of harpoon failed!") end)
