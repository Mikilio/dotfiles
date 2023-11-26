local function fugitive_setup ()
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
  local fugitive = vim.api.nvim_create_augroup('fugitive_extra', {})
  local autocmd = vim.api.nvim_create_autocmd
  autocmd('BufWinEnter', {
      group = fugitive,
      pattern = '*',
      callback = function()
          if vim.bo.ft ~= 'fugitive' then
              return
          end

          local bufnr = vim.api.nvim_get_current_buf()
          local opts = {buffer = bufnr, remap = false}
          -- normal pull push
          vim.keymap.set('n', '<leader>p', function()
              vim.cmd.Git('publish')
          end, opts)

          vim.keymap.set('n', '<leader>fp', function()
              vim.cmd.Git('force-push')
          end, opts)
          -- rebase always
          vim.keymap.set('n', '<leader>r', function()
              vim.cmd.Git({'pull',  '--rebase'})
          end, opts)

          -- NOTE: It allows me to easily set the branch i am pushing and any tracking
          -- needed if i did not set the branch up correctly
          vim.keymap.set('n', '<leader>pb', ':Git push -u origin ', opts);
      end,
  })
  -- TODO: maybe make those keymaps only available in diffmode
  vim.keymap.set('n', '<leader>gj', '<cmd>diffget //2<CR>')
  vim.keymap.set('n', '<leader>gf', '<cmd>diffget //3<CR>')

  -- gitsigns
  require('gitsigns').setup()
end


xpcall(fugitive_setup, function () print("Setup of git integration failed!") end)
