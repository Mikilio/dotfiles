local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fx', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>rg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fp', telescope.extensions.project.project, {})
vim.keymap.set('n', '<leader>fw', telescope.extensions.git_worktree.git_worktrees, {})
vim.keymap.set('n', '<leader>nw', telescope.extensions.git_worktree.create_git_worktree, {})

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
        {'~/.', max_depth = 1},
        {'~/Src'},
      },
    }
  }
})

telescope.load_extension("media_files")
telescope.load_extension("fzy_native")
telescope.load_extension("project");
telescope.load_extension("git_worktree");
