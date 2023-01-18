-- set shorter name for keymap function
local kmap = vim.keymap.set
local knap = require("knap")

-- F5 processes the document once, and refreshes the view
kmap('i','<leader>cc', function() knap.process_once() end)
kmap('v','<leader>cc', function() knap.process_once() end)
kmap('n','<leader>cc', function() knap.process_once() end)

-- F6 closes the viewer application, and allows settings to be reset
kmap('i','<leader>ev', function() knap.close_viewer() end)
kmap('v','<leader>ev', function() knap.close_viewer() end)
kmap('n','<leader>ev', function() knap.close_viewer() end)

-- F7 toggles the auto-processing on and off
kmap('i','<leader>acc', function() knap.toggle_autopreviewing() end)
kmap('v','<leader>acc', function() knap.toggle_autopreviewing() end)
kmap('n','<leader>acc', function() knap.toggle_autopreviewing() end)

-- F8 invokes a SyncTeX forward search, or similar, where appropriate
kmap('i','gV', function() knap.forward_jump() end)
kmap('v','gV', function() knap.forward_jump() end)
kmap('n','gV', function() knap.forward_jump() end)
