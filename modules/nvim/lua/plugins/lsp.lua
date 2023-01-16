local lsp = require("lsp-zero")

lsp.preset('system-lsp')

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

lsp.setup_servers({
  'rnix',
  'rust_analyzer',
  'bashls',
  'pyright',
  'zk',
  force = true})

lsp.setup_nvim_cmp({
  sorces = {
      name = 'spell',
      option = {
        keep_all_entries = false,
        enable_in_context = function()
          return require('cmp.config.context').in_treesitter_capture('spell')
        end,
      },
  },
})

-- Lua-for-nvim
-- TODO: make this smarter by recognizing context (nvim or other)
lsp.configure('sumneko', {
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})

null_ls.setup({
  on_attach = null_opts.on_attach,
  sources = {
    -- you must download code formatter by yourself!
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.nixpkgs_fmt,
    null_ls.builtins.formatting.beautysh,
    null_ls.builtins.formatting.rustfmt,
    --[[ null_ls.builtins.diagnostics.cspell, ]]
    --[[ null_ls.builtins.code_actions.cspell ]]
  },
})

lsp.nvim_workspace()

lsp.setup()
