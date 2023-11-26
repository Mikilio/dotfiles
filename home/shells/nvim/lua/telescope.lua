local function telescope_setup ()
  local telescope = require("telescope")

  local prefix = '<leader>f'
  local map = vim.keymap.set

  local builtin = require("telescope.builtin")
  map('n',  prefix .. 'f', builtin.find_files, {})
  map('n',  prefix .. 'g', builtin.git_files, {})
  map('n',  prefix .. 'b', builtin.buffers, {})
  map('n',  prefix .. 'h', builtin.help_tags, {})
  map('n',  prefix .. 'x', builtin.lsp_document_symbols, {})
  map('n',  prefix .. 't', builtin.live_grep, {})
  map('n',  prefix .. '?', builtin.keymaps, {})
  map('n',  prefix .. 'j', telescope.extensions.harpoon.marks, {})
  map('n',  prefix .. 'z', telescope.extensions.zoxide.list)
  map('n',  prefix .. 'u', telescope.extensions.undo.undo, {})

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
      project = {
        base_dirs = {
          {'~/.', max_depth = 2},
          {'$XDG_DEV_DIR'},
        },
      }
    }
  })

  telescope.load_extension("media_files")
  telescope.load_extension("fzy_native")
  telescope.load_extension('harpoon')
  telescope.load_extension("undo")
  telescope.load_extension('zoxide')
end

xpcall(telescope_setup, function () print("Setup of telescope failed!") end)
