local function telescope_setup()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local wk = require("which-key")
  local session = require('session_manager')

  wk.register({
    ['<leader>t'] = {
      name = 'telescope',
      f = { builtin.find_files, "File" },
      g = { builtin.git_files, "Git-file" },
      b = { builtin.buffers, "Buffers" },
      h = { builtin.help_tags, "Help" },
      x = { builtin.lsp_document_symbols, "LSP" },
      t = { builtin.live_grep, "Text" },
      ['?'] = { builtin.keymaps, "Keymaps" },
      z = { telescope.extensions.zoxide.list, "Zoxide" },
      u = { telescope.extensions.undo.undo, "Undotree" },
    },
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
      project = {
        base_dirs = {
          { '~/.',         max_depth = 2 },
          { '$XDG_DEV_DIR' },
        },
      },
      zoxide = {
        mappings = {
          default = {
            action = function(selection)
              session.autosave_session()
              vim.cmd.cd(selection.path)
              if vim.env.NVIM_BUILD_PANE_ID then
                require('wezterm').exec({
                  'cli', 'send-text',
                  '--pane-id', vim.env.NVIM_BUILD_PANE_ID,
                  '--no-paste',
                  'z ' .. selection.path .. '\n'
                }, function(obj)
                  if obj.code ~= 0 then
                    vim.notify(
                      "Wezterm failed to change cwd",
                      vim.log.levels.ERROR, { title = "Wezterm", }
                    )
                  end
                end
                )
                require('wezterm').exec({
                  'cli', 'set-tab-title',
                  '--pane-id', vim.env.NVIM_BUILD_PANE_ID,
                  vim.fn.fnamemodify(selection.path, ':t')
                }, function(obj)
                  if obj.code ~= 0 then
                    vim.notify(
                      "Wezterm failed to set tab-title",
                      vim.log.levels.ERROR, { title = "Wezterm", }
                    )
                  end
                end
                )
              end
              session.load_current_dir_session(true)
              vim.cmd [[LspRestart]]
            end,
          },
          ["<c-b>"] = {
            keepinsert = true,
            action = function(selection)
              builtin.file_browser({ cwd = selection.path })
            end
          },
          ["<c-f>"] = {
            keepinsert = true,
            action = function(selection)
              builtin.find_files({ cwd = selection.path })
            end
          },
          ["<C-t>"] = {
            action = function(selection)
              require('wezterm').exec({
                'cli', 'spawn',
                '--cwd', selection.path,
              }, function(obj)
                require('wezterm').exec({
                  'cli', 'split-pane',
                  '--cwd', selection.path,
                  '--top',
                  '--percent', '80',
                  '--pane-id', string.format('%d', obj.stdout),
                  '--', 'direnv', 'exec', '.', 'sh', '-c',
                  'NVIM_BUILD_PANE_ID=' .. string.format('%d', obj.stdout)
                  .. ' nvim -c "SessionManager load_current_dir_session"'
                }, function(objj)
                  if objj.code ~= 0 then
                    vim.notify(
                      "Wezterm failed to open nvim",
                      vim.log.levels.ERROR, { title = "Wezterm", }
                    )
                  end
                end
                )
                require('wezterm').exec({
                  'cli', 'set-tab-title',
                  '--pane-id', string.format('%d', obj.stdout),
                  vim.fn.fnamemodify(selection.path, ':t')
                }, function(objj)
                  if objj.code ~= 0 then
                    vim.notify(
                      "Wezterm failed to set tab-title",
                      vim.log.levels.ERROR, { title = "Wezterm", }
                    )
                  end
                end
                )
              end)
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
