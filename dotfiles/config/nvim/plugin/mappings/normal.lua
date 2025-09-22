--------------------------------------------------------------------------------
--                                                                            --
--  normal mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

local indent_wrap_mapping = buell.util.indent_blankline.wrap_mapping

-- modes
vim.keymap.set('n', '<Leader>`', ':Goyo<CR>', {remap=false, silent=true})
vim.keymap.set('n', '<Leader>1', ':CodeCompanionChat Toggle<CR>', {remap=false, silent=true})
vim.keymap.set('n', '<Leader>2', ':CodeCompanionChat copilot<CR>', {remap=false, silent=true})
vim.keymap.set('n', '<Leader>3', ':CodeCompanionChat anthropic<CR>', {remap=false, silent=true})
vim.keymap.set('n', '<Leader>4', ':CodeCompanionChat openai<CR>', {remap=false, silent=true})
--5 (todo-comments)
--6
--7
vim.keymap.set('n', '<Leader>8', ':MarkdownPreviewToggle<CR>', {remap=false, silent=true})
vim.keymap.set('n', '<Leader>9', function()
  local copilot_client = vim.fn['copilot#Enabled']()
  if copilot_client ~= 0 then
    vim.cmd("Copilot disable")
  else
    vim.cmd("Copilot enable")
  end
  vim.cmd('redrawstatus')
end, {remap=false, silent=true})
vim.keymap.set('n', '<Leader>0', function()
  if #vim.lsp.get_clients() == 0 then
    vim.cmd("LspStart")
    buell.lsp.init()
  else
    vim.cmd("LspStop")
    -- vim.lsp.stop_client(vim.lsp.get_clients())<CR>
  end
  vim.cmd('redrawstatus')
end, {remap = false})

-- underline helper
vim.keymap.set('n', '<C-u>', '<CMD> lua buell.util.underline()<CR>', {remap=false, silent=true})

-- toggle fold at current position
vim.keymap.set('n', '<Tab>', indent_wrap_mapping('za'), {silent = true})

-- toggle last buffer
vim.keymap.set('n', '<Leader><Leader>', '<C-^>', {remap = false})

-- quick/location list navigation
vim.keymap.set('n', '<Up>', '<CMD>lua buell.util.list_nav("prev", "item")<CR>', {silent = true})
vim.keymap.set('n', '<Down>', '<CMD>lua buell.util.list_nav("next", "item")<CR>', {silent = true})
vim.keymap.set('n', '<S-Up>', '<CMD>lua buell.util.list_nav("prev", "file")<CR>', {silent = true})
vim.keymap.set('n', '<S-Down>', '<CMD>lua buell.util.list_nav("next", "file")<CR>', {silent = true})
vim.keymap.set('n', '<Left>', '<CMD>lua buell.util.list_nav("prev", "list")<CR>', {silent = true})
vim.keymap.set('n', '<Right>', '<CMD>lua buell.util.list_nav("next", "list")<CR>', {silent = true})

-- search related maps
vim.keymap.set('n', ',,', '/[^\\x00-\\x7F]<CR>', {silent = true})
vim.keymap.set('n', ',/', '<Plug>(LoupeClearHighlight)', {})

-- wiki helpers
vim.keymap.set('n', '<Localleader>n', '<CMD>lua buell.util.create_entry("note")<CR>', {remap = false})
vim.keymap.set('n', '<Localleader>j', '<CMD>lua buell.util.create_entry("journal")<CR>', {remap = false})

-- jump to production dotfile
vim.keymap.set('n', '<Localleader>p', function()
  local cur_file = vim.fn.expand('%:~:.')
  if string.match(cur_file, 'dotfiles/') then
    -- Extract path after 'dotfiles/'
    local relative_path = string.gsub(cur_file, '.*dotfiles/', '')

    -- Split path and add dot to first component
    local parts = vim.split(relative_path, '/', {plain = true})
    parts[1] = '.' .. parts[1]

    -- Construct production file path
    local prod_file = '~/' .. table.concat(parts, '/')
    vim.cmd('tabnew ' .. prod_file)
  end
end, {silent = true, remap = false})

-- overwrite production file
vim.keymap.set('n', '<Localleader>P', function()
  local cur_file = vim.fn.expand('%:~:.')
  if string.match(cur_file, 'dotfiles/') then
    -- Extract path after 'dotfiles/'
    local relative_path = string.gsub(cur_file, '.*dotfiles/', '')

    -- Split path and add dot to first component
    local parts = vim.split(relative_path, '/', {plain = true})
    parts[1] = '.' .. parts[1]

    -- Construct production file path
    local prod_file = '~/' .. table.concat(parts, '/')
    vim.cmd('!cp ' .. cur_file .. ' ' .. prod_file)
  end
end, {silent = true, remap = false})
