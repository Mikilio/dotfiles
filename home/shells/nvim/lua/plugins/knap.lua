-- set shorter name for keymap function
local kmap = vim.keymap.set
local knap = require("knap")
local scan = require'plenary.scandir'

local group = vim.api.nvim_create_augroup('knap', {clear = true})

vim.api.nvim_create_autocmd(
  {'LspAttach'},
  { pattern = {'*.tex'}, group = group,
    callback = function ()
      local root_dir = vim.lsp.buf.list_workspace_folders()[1]
      if (root_dir ~= nil and scan.scan_dir(root_dir, { depth = 1, search_pattern = 'Makefile'})) then
          local knapsettings = vim.b.knap_settings or {}
          knapsettings["textopdf"] = 'make -C ' .. root_dir;
          knapsettings["outdir"] = root_dir ..  '/build/';
          vim.b.knap_settings = knapsettings
      end
    end
  })

vim.api.nvim_create_autocmd(
  {'LspAttach'},
  { pattern = {'*ME.md'}, group = group,
    callback = function ()
      local knapsettings = vim.b.knap_settings or {}
      knapsettings["mdtohtml"] = 'pandoc --standalone  -c %css% -f gfm -s %docroot% -o %outputpath%';
      knapsettings["css"] = "$XDG_TEMPLATES_DIR/css/github-markdown.css"
      vim.b.knap_settings = knapsettings
    end
  })

vim.api.nvim_create_autocmd(
  {'BufUnload'},
  { group = group,
    callback = ( function() if (vim.b.knap_viewerpid) then os.execute("pkill -f live-server") end end )
  })

vim.api.nvim_create_autocmd( {'VimLeavePre'}, {
  group = vim.api.nvim_create_augroup('knap_def', {}),
  callback = function () os.execute("rm -r /tmp/knap_preview*") end
})

-- processes the document once, and refreshes the view
kmap('n','<leader>cc', function() knap.process_once() end)

-- closes the viewer application, and allows settings to be reset
kmap('n', '<leader>ev', function() knap.close_viewer() end)

-- toggles the auto-processing on and off
kmap('n','<leader>acc', function() knap.toggle_autopreviewing() end)

-- invokes a SyncTeX forward search, or similar, where appropriate
kmap('n','gv', function() knap.forward_jump() end)
