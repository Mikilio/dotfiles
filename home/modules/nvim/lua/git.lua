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

      require('which-key').add({
        { "<Leader>g",  buffer = bufnr,                               group = "git" },
        { "<Leader>gD", function() diff() end,                        buffer = bufnr, desc = "Vimdiff: prompt" },
        { "<Leader>gR", function() gs.stage_buffer() end,             buffer = bufnr, desc = "Reset buffer" },
        { "<Leader>gS", function() gs.reset_buffer_index() end,       buffer = bufnr, desc = "Stage buffer" },
        { "<Leader>gU", function() gs.reset_buffer() end,             buffer = bufnr, desc = "Unstage buffer" },
        { "<Leader>gb", function() gs.blame_line { full = true } end, buffer = bufnr, desc = "Git-blame" },
        { "<Leader>gd", function() gs.diffthis() end,                 buffer = bufnr, desc = "Vimdiff: default" },
        { "<Leader>gp", function() gs.preview_hunk() end,             buffer = bufnr, desc = "Preview hunk" },
        { "<Leader>gr", function() gs.reset_hunk() end,               buffer = bufnr, desc = "Reset hunk" },
        { "<Leader>gs", function() gs.stage_hunk() end,               buffer = bufnr, desc = "Stage hunk" },
        { "<Leader>gt", function() gs.setqflist() end,                buffer = bufnr, desc = "Trouble" },
        { "<Leader>gu", function() gs.undo_stage_hunk() end,          buffer = bufnr, desc = "Unstage hunk" },
        { "[g",         function() prev() end,                        buffer = bufnr, desc = "Previus hunk" },
        { "]g",         function() next() end,                        buffer = bufnr, desc = "Next hunk" },
      })
    end
  })
end

xpcall(git_setup, function() print("Setup of git integration failed!") end)
