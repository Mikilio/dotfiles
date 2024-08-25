local function catppuccin_setup()
  require("catppuccin").setup({
    integrations = {
      cmp = true,
      alpha = true,
      gitsigns = true,
      harpoon = true,
      hop = true,
      lsp_trouble = true,
      markdown = true,
      telescope = true,
      treesitter = true,
      treesitter_context = true,
      ts_rainbow = true,

      -- Special integrations, see https://github.com/catppuccin/nvim#special-integrations
      dap = {
        enabled = true,
        enable_ui = true,
      },
      indent_blankline = {
        enabled = true,
        colored_indent_levels = false,
      },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
      },
    },
  })
  vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
  vim.cmd.colorscheme "catppuccin"
end

local function netrw_setup()
  require 'netrw'.setup({

  })
end

local function treesitter_setup()
  require('ts_context_commentstring').setup {}
  vim.g.skip_ts_commentstring_module = true

  local configs = require("nvim-treesitter.configs")
  configs.setup({

    modules = {},
    auto_install = false,
    sync_install = false,
    ignore_install = {},
    ensure_installed = {},
    parser_install_dir = nil,
    ------------------------------------------------------
    -- installation of modules is fully handeled by nix --
    ------------------------------------------------------

    autopairs = {
      enable = true,
    },
    highlight = {
      enable = true,    -- false will disable the whole extension
      disable = { "" }, -- list of language that will be disabled
      additional_vim_regex_highlighting = true,
    },
    indent = { enable = true, disable = { "" } },
    rainbow = {
      enable = true,
      -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = nil, -- Do not enable for files with more than n lines, int
      -- colors = {}, -- table of hex strings
      -- termcolors = {} -- table of color name strings
    },
  })
end

local function shade_setup()
  require("sunglasses").setup()
end

local function trouble_setup()
  require('todo-comments').setup({

  })
  require("which-key").add({
    { "<leader>x",  group = "trouble" },
    { "<leader>xd", function() require("trouble").toggle("document_diagnostics") end,                desc = "Document" },
    { "<leader>xl", function() require("trouble").toggle("loclist") end,                             desc = "Loclist" },
    { "<leader>xq", function() require("trouble").toggle("quickfix") end,                            desc = "Quickfix" },
    { "<leader>xt", function() require("trouble").toggle("todo") end,                                desc = "Todo" },
    { "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end,               desc = "Workspace" },
    { "<leader>xx", function() require("trouble").toggle() end,                                      desc = "Main window" },
    { "[t",         function() require("trouble").previous({ skip_groups = true, jump = true }) end, desc = "Prev trouble item" },
    { "]t",         function() require("trouble").next({ skip_groups = true, jump = true }) end,     desc = "Next trouble item" },
    { "gr",         function() require("trouble").toggle("lsp_references") end,                      desc = "LSP Referces" },
  })
end

xpcall(catppuccin_setup, function() print("Setup of Catppuccin failed!") end)
xpcall(netrw_setup, function() print("Setup of netrw failed!") end)
xpcall(treesitter_setup, function() print("Setup of treesitter failed!") end)
xpcall(shade_setup, function() print("Setup of tint failed!") end)
xpcall(trouble_setup, function() print("Setup of trouble failed!") end)
