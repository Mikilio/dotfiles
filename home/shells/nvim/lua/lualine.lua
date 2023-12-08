local function lualine_setup ()
  local navic = require("nvim-navic")

  require('lualine').setup {
    options = {
      theme = "catppuccin",
      globalstatus = true,
      component_separators = '|',
      section_separators = { left = '', right = '' },
    },

    tabline = {
      lualine_a = {
        {
          function()
            return vim.fn.fnamemodify(vim.fn.getcwd(),':t') .. ' 󰛢 '
          end,
          color = 'lualine_a_normal',
          separator = { left = '' },
          right_padding = 2 ,
        }
      },
      lualine_b = {
        require("harpoon.tabline").format({
          tabline_prefix = ' ',
          tabline_suffix = ' ',
        })
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {'windows'},
      lualine_z = {
        {
          'tabs',
          separator = {right = '' },
          left_padding = 2,
        },
      }
    },

    winbar = {
      lualine_c = {
        {
          function()
            return navic.get_location()
          end,
          cond = function()
            return navic.is_available()
          end
        },
      }
    },

    sections = {
      lualine_a = {
        { 'mode', separator = { left = '' }, right_padding = 2 },
      },
      lualine_b = {
        'branch',
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
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
          color = 'Title',
        },
      },
      lualine_x = {},
      lualine_y = { 'filetype', 'progress' },
      lualine_z = {
        { 'location', separator = { right = '' }, left_padding = 2 },
      },
    },
    globalstatus = false
  }
end

xpcall(lualine_setup, function () print("Setup of lualine failed!") end)
