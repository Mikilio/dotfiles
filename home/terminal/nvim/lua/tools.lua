local function autopairs_setup()
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

local function comment_setup()
  require("Comment").setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  })
end

local function surround_setup()
  require("nvim-surround").setup({
    -- Configuration here, or leave empty to use defaults
  })
end

local function hop_setup()
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
    { remap = true }
  )
  vim.keymap.set('', 'F',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true
      })
    end,
    { remap = true }
  )
  vim.keymap.set('', 't',
    function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1
      })
    end,
    { remap = true }
  )
  vim.keymap.set('', 'T',
    function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = 1
      })
    end,
    { remap = true }
  )
  vim.keymap.set('', 'gf', hop.hint_char1, { remap = true })
end

xpcall(autopairs_setup, function() print("Setup of autopairs failed!") end)
xpcall(comment_setup, function() print("Setup of comments failed!") end)
xpcall(surround_setup, function() print("Setup of surround failed!") end)
xpcall(hop_setup, function() print("Setup of hop failed!") end)
