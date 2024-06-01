local function git_setup()
  -- gitsigns
  require('gitsigns').setup({
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function next()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end

      local function prev()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end

      local function diff()
        vim.ui.input({ prompt = 'Rev: ' }, function(rev) gs.diffthis(rev) end)
      end

      require('which-key').register({
        -- Jump between hunks
        [']g'] = { next, 'Next hunk', { expr = true } },
        ['[g'] = { prev, 'Previus hunk', { expr = true } },

        -- Popup what's changed in a hunk under cursor
        ['<Leader>g'] = {
          name = 'git',
          p = { gs.preview_hunk, 'Preview hunk' },

          -- Stage/reset individual hunks under cursor in a file
          s = { gs.stage_hunk, 'Stage hunk' },
          r = { gs.reset_hunk, 'Reset hunk' },
          u = { gs.undo_stage_hunk, 'Unstage hunk' },

          -- Stage/reset all hunks in a file
          S = { gs.stage_buffer, 'Stage buffer' },
          U = { gs.reset_buffer_index, 'Unstage buffer' },
          R = { gs.reset_buffer, 'Reset buffer' },

          d = { gs.diffthis, 'Vimdiff: default' },
          D = { diff, 'Vimdiff: prompt' },

          b = { function() gs.blame_line { full = true } end, 'Git-blame' },
          t = { gs.setqflist, 'Trouble' }
        }
      }, { buffer = bufnr })
    end
  })
end

xpcall(git_setup, function() print("Setup of git integration failed!") end)
