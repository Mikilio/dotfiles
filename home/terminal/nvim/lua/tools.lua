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

local function flash_setup()
  local fl = require('flash')

  fl.setup({
    labels = "arstgmneioqwfpbjluyzxcdvkh",
    label = {
      rainbow = {
        enabled = true,
      }
    },
    modes = {
      char = {
        jump_labels = true,
        char_actions = function(motion)
          return {
            [";"] = "next", -- set to `right` to always go right
            [","] = "prev", -- set to `left` to always go left
            -- jump2d style: same case goes next, opposite case goes prev
            [motion] = "next",
            [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
          }
        end,
      }
    }
  })

  local function get_map(indc)
    local mappings = {
      l = { function() require("flash").treesitter() end, "Flash Treesitter" },
      r = { function() require("flash").remote() end, "Remote Flash" },
      R = { function() require("flash").treesitter_search() end, "Treesitter Search" },
      ['<c-s>'] = { function() require("flash").toggle() end, "Toggle Flash Search" },
    }
    local map = {}
    for _, index in ipairs(indc) do
      map[index] = mappings[index]
    end
    return map
  end

  require('which-key').register(get_map { 'l', 'R' }, { mode = 'x' })
  require('which-key').register(get_map { 'l', 'r', 'R' }, { mode = 'o' })
  require('which-key').register(get_map { 'l' }, { mode = 'n' })
  require('which-key').register(get_map { '<c-l>' }, { mode = 'c' })
end

xpcall(autopairs_setup, function() print("Setup of autopairs failed!") end)
xpcall(comment_setup, function() print("Setup of comments failed!") end)
xpcall(surround_setup, function() print("Setup of surround failed!") end)
xpcall(flash_setup, function() print("Setup of hop failed!") end)
