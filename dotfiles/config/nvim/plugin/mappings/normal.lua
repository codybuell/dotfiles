--------------------------------------------------------------------------------
--                                                                            --
--  normal mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

local indent_wrap_mapping = buell.util.indent_blankline.wrap_mapping

-- underline helper
vim.keymap.set('n', '<C-u>', '<CMD> lua buell.util.underline()<CR>', {remap=false, silent=true})

-- toggle fold at current position
vim.keymap.set('n', '<Tab>', indent_wrap_mapping('za'), {silent = true})

-- toggle last buffer
vim.keymap.set('n', '<Leader><Leader>', '<C-^>', {remap = false})

-- other indent-related remaps for compatibility with indent-blankline.nvim
vim.keymap.set('n', 'zA', indent_wrap_mapping('zA'), {silent = true})
vim.keymap.set('n', 'zC', indent_wrap_mapping('zC'), {silent = true})
vim.keymap.set('n', 'zM', indent_wrap_mapping('zM'), {silent = true})
vim.keymap.set('n', 'zO', indent_wrap_mapping('zO'), {silent = true})
vim.keymap.set('n', 'zR', indent_wrap_mapping('zR'), {silent = true})
vim.keymap.set('n', 'zX', indent_wrap_mapping('zX'), {silent = true})
vim.keymap.set('n', 'za', indent_wrap_mapping('za'), {silent = true})
vim.keymap.set('n', 'zc', indent_wrap_mapping('zc'), {silent = true})
vim.keymap.set('n', 'zm', indent_wrap_mapping('zm'), {silent = true})
vim.keymap.set('n', 'zo', indent_wrap_mapping('zo'), {silent = true})
vim.keymap.set('n', 'zr', indent_wrap_mapping('zr'), {silent = true})
vim.keymap.set('n', 'zv', indent_wrap_mapping('zv'), {silent = true})
vim.keymap.set('n', 'zx', indent_wrap_mapping('zx'), {silent = true})
vim.keymap.set('n', '<<', indent_wrap_mapping('<<'), {silent = true})
vim.keymap.set('n', '>>', indent_wrap_mapping('>>'), {silent = true})

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

-- command-t
vim.keymap.set('n', '<Leader>b', '<Plug>(CommandTBuffer)', {remap = true})
vim.keymap.set('n', '<Leader>h', '<Plug>(CommandTHelp)', {remap  = true})
vim.keymap.set('n', '<Leader>t', '<Plug>(CommandTWatchman)', {remap = true})
vim.keymap.set('n', '<Leader>.', ':CommandT %:p:h<CR>', {remap = false})
vim.keymap.set('n', '<Leader>n', ':CommandTWiki {{ Notes }}<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>c', ':CommandTWiki {{ Codex }}<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>j', ':CommandTWiki {{ Journal }}<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>p', ':CommandTWiki {{ Projects }}<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>d', ':CommandTWiki {{ Domains }}<CR>', {remap = false, silent = true})

-- vim-fugitive
vim.keymap.set('n', '<Leader>gs', ':Git<CR>:20wincmd_<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gp', ':Git push<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gl', ':silent! 0Gclog!<CR>:bot copen<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gL', ':silent! Git log --pretty="format:%h  %ad  %<(16,trunc)%aN %d %s"<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gd', ':Gvdiffsplit!<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gh', ':diffget //2<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gm', ':diffget //3<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gc', ':Git checkout<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>gg', ':Ggrep<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', {remap = false, silent = true})

-- vim-obsession
vim.keymap.set('n', '<Localleader>ss', ':Obsession ~/.config/nvim/sessions/', {remap = false})
vim.keymap.set('n', '<Localleader>sr', ':so ~/.config/nvim/sessions/', {remap = false})
vim.keymap.set('n', '<Localleader>sp', ':Obsession<CR>', {remap = false})
vim.keymap.set('n', '<Localleader>sn', function()
  if vim.fn.exists(':Obsession') then
    local session = buell.util.split_str(vim.v.this_session, '/')
    local sname   = session[#session] or ''
    if #sname then
      print(sname)
    end
  end
end
, {remap = false})

-- ferret
vim.keymap.set('n', '<Leader>aa', '<Plug>(FerretAck)', {})
vim.keymap.set('n', '<Leader>aw', '<Plug>(FerretAckWord)', {})
vim.keymap.set('n', '<Leader>as', '<Plug>(FerretAcks)', {})
vim.keymap.set('n', '<Leader>a.', ':Ack  %:p:h<C-B><RIGHT><RIGHT><RIGHT><RIGHT>', {remap = false})

-- vim-tmux-runner
vim.keymap.set('n', '<Leader>ra', ':VtrAttachToPane<CR>', {remap = false})
vim.keymap.set('n', '<Leader>rf', ':VtrSendFile<CR>', {remap = false})
vim.keymap.set('n', '<Leader>rl', ':VtrSendLinesToRunner<CR>', {remap = false})
vim.keymap.set('n', '<Leader>re', ':VtrSendCommandToRunner<CR>', {remap = false})
vim.keymap.set('n', '<Leader>rr', ':VtrFlushCommand<CR>', {remap = false})
vim.keymap.set('n', '<Leader>rc', ':VtrClearRunner<CR>', {remap = false})

-- wiki helpers
vim.keymap.set('n', '<Localleader>j', '<CMD>lua buell.util.create_entry("journal")<CR>', {remap = false})
vim.keymap.set('n', '<Localleader>n', '<CMD>lua buell.util.create_entry("note")<CR>', {remap = false})
vim.keymap.set('n', '<Localleader>c', '<CMD>lua buell.util.create_entry("codex")<CR>', {remap = false})
