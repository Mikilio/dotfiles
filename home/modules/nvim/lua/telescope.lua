local function telescope_setup()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local wk = require("which-key")

  wk.add({
    { '<leader>t',  group = 'telescope' },
    { '<leader>tf', builtin.find_files,               desc = "File" },
    { '<leader>tg', builtin.git_files,                desc = "Git-file" },
    { '<leader>tb', builtin.buffers,                  desc = "Buffers" },
    { '<leader>th', builtin.help_tags,                desc = "Help" },
    { '<leader>tx', builtin.lsp_document_symbols,     desc = "LSP" },
    { '<leader>tt', builtin.live_grep,                desc = "Text" },
    { '<leader>t?', builtin.keymaps,                  desc = "Keymaps" },
    { '<leader>tz', telescope.extensions.zoxide.list, desc = "Zoxide" },
    { '<leader>tu', telescope.extensions.undo.undo,   desc = "Undotree" },
  })

  telescope.setup({
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      path_display = { "smart" },
      color_devicons = true,
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
        horizontal = {
          width_padding = 0.04,
          height_padding = 0.1,
          preview_width = 0.6,
        },
        vertical = {
          width_padding = 0.05,
          height_padding = 1,
          preview_height = 0.5,
        },
      },
    },

    extensions = {
      media_files = {
        filetypes = { "png", "webp", "jpg", "jpeg", "mp4", "pdf", "webm" },
        find_cmd = "rg", -- find command (defaults to `fd`)
      },
      zoxide = {
        mappings = {
          default = {
            keepinsert = true,
            action = function(selection)
              builtin.find_files({ cwd = selection.path })
            end
          },
        }
      }
    }
  })

  telescope.load_extension("media_files")
  telescope.load_extension("fzy_native")
  telescope.load_extension("undo")
  telescope.load_extension('zoxide')
end

xpcall(telescope_setup, function() print("Setup of telescope failed!") end)
