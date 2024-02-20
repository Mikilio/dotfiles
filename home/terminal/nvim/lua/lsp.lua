local function lsp_setup ()
  local lsp_zero = require("lsp-zero")
  local config = require('lspconfig')
  local cmp = require('cmp')
  local lspkind = require('lspkind')
  local navic = require('nvim-navic')
  local ltex = require ('ltex_extra')

  local lsp = lsp_zero.preset({})

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  lsp.on_attach( function(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = {buffer = bufnr, remap = false}

    lsp.default_keymaps({buffer = bufnr})

    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

    lsp.buffer_autoformat()
  end)

  lsp.sign_icons = {
      error = ' ',
      warn = ' ',
      hint = ' ',
      info = ' '
  }

  -- -----------------------------------------
  -- ------------Autocomplete-----------------
  -- -----------------------------------------
  lsp.extend_cmp()

  local cmp_action = lsp.cmp_action()

  cmp.setup({
    preselect = 'item',
    completion = {
      completeopt = 'menu,menuone,noinsert',
      autocomplete = false,
    },

    sources = {
      {name = 'nvim_lsp'},
      {name = 'buffer'},
      {name = 'luasnip'},
      {name = 'path'},
      {name = 'nvim_lua'},
      {name = 'nvim_lsp_signature_help' },
    },

    mapping = {
      -- Ctrl+Space to trigger completion menu
      ['<C-Space>'] = cmp.mapping.complete(),

      -- Navigate between snippet placeholder
      ['<C-f>'] = cmp_action.luasnip_jump_forward(),
      ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    },

    formatting = {
      fields = {'abbr', 'kind', 'menu'},
      format = lspkind.cmp_format({
        mode = 'symbol', -- show only symbol annotations
        maxwidth = 50, -- prevent the popup from showing more than provided characters
        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
      })
    },

    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    }
  })

  -- Fix Undefined global 'vim'
  config.lua_ls.setup(lsp.nvim_lua_ls())

  config.ltex.setup {
    on_attach = function(_, _)
      -- rest of your on_attach process.
      ltex.setup {path = vim.fn.stdpath("data") .. '/ltex'}
    end,
    settings = {
      ltex = {
        disabledRules = {
          ["en-US"] = { "BACHELOR_ABBR" }
        },
        dictionary = {
          ["en-US"] = { }
        },
        additionalRules = {
          enablePickyRules = true,
          motherTongue = "en-US",
        },
      },
    },
  }

  lsp.setup_servers({
    'clangd',
    'lua_ls',
    'nixd',
    'pyright',
    'bashls',
    'rust_analyzer',
    'texlab',
    'ltex',
  })
end

xpcall(lsp_setup, function () print("Setup of LSP failed!") end)
