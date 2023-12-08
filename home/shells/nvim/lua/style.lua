local function catppuccin_setup ()
  require("catppuccin").setup({
    transparent_background = true,
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

local function netrw_setup ()
  require'netrw'.setup ({

  })
end

local function treesitter_setup ()

  require('ts_context_commentstring').setup {}
  vim.g.skip_ts_commentstring_module = true

  local configs = require("nvim-treesitter.configs")
  configs.setup({

    modules = {}, auto_install = false, sync_install = false, ignore_install = {},
    ensure_installed = {}, parser_install_dir = nil,
    ------------------------------------------------------
    -- installation of modules is fully handeled by nix --
    ------------------------------------------------------

    autopairs = {
      enable = true,
    },
    highlight = {
      enable = true, -- false will disable the whole extension
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
  
xpcall(catppuccin_setup, function () print("Setup of Catppuccin failed!") end)
xpcall(netrw_setup, function () print("Setup of netrw failed!") end)
xpcall(treesitter_setup, function () print("Setup of treesitter failed!") end)
