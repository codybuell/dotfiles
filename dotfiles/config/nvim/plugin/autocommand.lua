local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellAutocommands', function()

  -------------------
  --  BufWinEnter  --
  -------------------

  autocmd('BufWinEnter', '*', function()
    -- set statusline based on buffer
    buell.statusline.update()

    -- load last folding views
    vim.cmd('silent! loadview')
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


  -------------------
  --  BufWritePre  --
  -------------------

  autocmd('BufWritePre', '*', function()
    -- create dirs as needed when saving
    buell.util.create_directories(vim.fn.expand('%:p:h'))
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
  end)

end)
