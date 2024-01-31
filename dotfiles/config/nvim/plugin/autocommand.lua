local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellAutocommands', function()

  -------------------
  --  BufWinEnter  --
  -------------------

  autocmd('BufWinEnter', '*', function()
    local ft = vim.bo.filetype

    -- set statusline based on buffer
    buell.statusline.update()

    -- load last folding views
    vim.cmd('silent! loadview')

    -- if a git commit don't restore cursor position
    if ft == 'gitcommit' then
      vim.fn.setpos('.', {0, 1, 1, 0})
    end

    -- handling here instead of in ftplugin/markdown.lua because that file is firing for help docs and breaking ctrl-]
    if ft == 'markdown' then
      vim.keymap.set('n', '<C-]>', '<CMD>lua buell.markdown.create_or_follow_link()<CR>', {remap = false, silent = false, buffer = true})
      vim.keymap.set('v', '<C-]>', '<CMD>lua buell.markdown.create_or_follow_link()<CR>', {remap = false, silent = false, buffer = true})
    end
  end)

  ----------------
  --  WinEnter  --
  ----------------

  autocmd('WinEnter', '*', function()
    -- grab file & buffer types
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype

    -- close neovim if only these buffer types remain
    local close_if_bt = {
      'quickfix',
      'help',
    }

    -- close neovim if only these file types remain
    local close_if_ft = {
      'fugitiveblame',
      'fugitive',
    }

    -- implement closing
    if vim.fn.winnr('$') == 1 and (buell.util.has_value(close_if_bt, bt) or buell.util.has_value(close_if_ft, ft)) then
      vim.cmd('q')
    end

    -- on entering lsp hover floating window bind keys to close
    pcall(function()
      if vim.api.nvim_win_get_var(0, 'textDocument/hover') then
        vim.keymap.set('n', 'K', ':call nvim_win_close(0, v:true)<CR>', {remap = false, silent = true})
        vim.api.nvim_win_set_option(0, 'cursorline', false)
      end
    end)

    -- on entering lsp line diagnostics floating window bind keys to close
    pcall(function()
      if vim.api.nvim_win_get_var(0, 'line') then
        vim.keymap.set('n', '<Leader>e', ':call nvim_win_close(0, v:true)<CR>', {remap = false, silent = true})
      end
    end)

    -- map gq to close window for quickfix or help
    --
  end)

  --------------------
  --  TextYankPost  --
  --------------------

  autocmd('TextYankPost', '*', function()
    vim.highlight.on_yank({higroup="Substitute", timeout=200})
  end)

  -------------------
  --  BufWinLeave  --
  -------------------

  autocmd('BufWinLeave', '*', function()
    -- save fold views
    vim.cmd('silent! mkview')
  end)

  ------------------
  --  BufReadPre  --
  ------------------

  autocmd('BufReadPre', '*', function()
    -- disable treesitter on large files as it doesn't respect synmaxcol and can
    -- get hosted on uglified files, taking forever to load and take any action
    if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then
      buell.util.disable_buf_ts()
    end
  end)

  ------------------
  --  FileReadPre  --
  ------------------

  autocmd('FileReadPre', '*', function()
    -- disable treesitter on large files as it doesn't respect synmaxcol and can
    -- get hosted on uglified files, taking forever to load and take any action
    if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then
      buell.util.disable_buf_ts()
    end
  end)

  -------------------
  --  BufWritePre  --
  -------------------

  autocmd('BufWritePre', '*', function()
    -- create dirs as needed when saving
    buell.util.create_directories(vim.fn.expand('%:p:h'))

    -- remove trailing whitespace
    vim.cmd('silent! %s/\\v\\s+$//')
    -- this command takes minutes to operate on large files...
    -- buell.util.substitute('\\s\\+$', '', '')
  end)

  ----------------
  --  FileType  --
  ----------------

  autocmd('FileType', '*', function()
    -- grab file & buffer types
    local bt = vim.bo.buftype

    -- map gq to close window on these buffer types
    local map_gq_to_close = {
      'quickfix',
      'help',
    }

    -- implement map gq to close
    if buell.util.has_value(map_gq_to_close, bt) then
      vim.keymap.set('n', 'gq', ':q<CR>', {remap = false, silent = true, buffer = true})
    end

    -- quickfix windor <C-t> to open item in new tab
    if bt == 'quickfix' then
      vim.keymap.set('n', '<C-t>', '<C-W><Enter><C-W>T', {remap = false, silent = true, buffer = true})
    end

    -- conditionally map return
    local cr_map_ignore_types = {
      'quickfix',   -- quickfix
      'nofile',     -- empty buffer
      'help',       -- help docs
      'vim',        -- command window
      'nowrite',    -- fugitive and others
    }

    -- wrap for function call
    if not buell.util.has_value(cr_map_ignore_types, bt) then
      vim.keymap.set('n', '<Enter>', '<CMD>lua buell.util.toggle_wrap()<CR>', {silent = true, buffer = true})
    end
  end)

end)
