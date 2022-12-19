require('lualine').setup {
    options = {
        theme = "catppuccin"
  },
  sections = {
    lualine_b = {
      'branch',
      {
        "diff",
        symbols = { added = " ", modified = "柳", removed = " " },
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
      },
    },
    lualine_c = {
      {
        'filename',
        color = {gui = "bold"},
        separator = { right = ''},
      },
      {
        "%=",
        separator = { right = ''},
      },
      {
        function()
          local msg = "No Active Lsp"
          local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then
            return msg
          end
          local t = { }
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              t[#t+1] = client.name
            end
          end
          if(#t > 0)
          then
            return table.concat(t,', ')
          end
          return msg
        end,
        icon = " LSP:",
        color = { fg = "#ffffff", gui = "bold" },
      },
    },
  },
  globalstatus = false
}
