local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function lsp_setup()
  local lsp_zero = require("lsp-zero")
  local config = require('lspconfig')
  local cmp = require('cmp')
  local lspkind = require('lspkind')
  local luasnip = require("luasnip")
  local navic = require('nvim-navic')
  local ltex = require('ltex_extra')
  local wk = require('which-key')

  local lsp = lsp_zero.preset({})

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  lsp.on_attach(function(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    lsp.default_keymaps({ buffer = bufnr })

    wk.register({
      --  TODO: add labels
    })

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

  cmp.setup({
    preselect = 'item',
    completion = {
      completeopt = 'menu,menuone,noinsert',
      autocomplete = false,
    },

    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'nvim_lua' },
      { name = 'nvim_lsp_signature_help' },
    },

    mapping = {
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- that way you will only jump inside the snippet region
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },

    formatting = {
      fields = { 'abbr', 'kind', 'menu' },
      format = lspkind.cmp_format({
        mode = 'symbol',       -- show only symbol annotations
        maxwidth = 50,         -- prevent the popup from showing more than provided characters
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
      ltex.setup { path = vim.fn.stdpath("data") .. '/ltex' }
    end,
    settings = {
      ltex = {
        disabledRules = {
          ["en-US"] = { "BACHELOR_ABBR" }
        },
        dictionary = {
          ["en-US"] = {}
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

xpcall(lsp_setup, function() print("Setup of LSP failed!") end)
