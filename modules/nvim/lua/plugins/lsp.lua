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

-- Lua-for-nvim
-- TODO: make this smarter by recognizing context
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
    require('null-ls').builtins.formatting.stylua,
    require('null-ls').builtins.formatting.black,
    require('null-ls').builtins.formatting.prettier,
    require('null-ls').builtins.formatting.nixpkgs_fmt,
    require('null-ls').builtins.formatting.beautysh,
    require('null-ls').builtins.formatting.rustfmt,
  },
})

lsp.nvim_workspace()

lsp.setup()
