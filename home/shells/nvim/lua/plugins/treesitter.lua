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
  context_commentstring = {
    enable = true,
    enable_autocmd = true,
  },
})
