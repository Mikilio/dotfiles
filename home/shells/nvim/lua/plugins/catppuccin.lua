require("catppuccin").setup({
  transparent_background = true,
  integrations = {
    cmp = true,
    gitsigns = true,
    harpoon = true,
    hop = true,
    lsp_saga = true,
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
