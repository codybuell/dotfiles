--------------------------------------------------------------------------------
--                                                                            --
--  Dirvish                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellDirvish', function()
  autocmd('Filetype', 'dirvish', function()
    vim.keymap.set('n', '!', ':<C-U>Shdo ', {remap = false, nowait = true, buffer = true})
    vim.keymap.set('v', '!', ":<C-U>'<,'>Shdo ", {remap = false, nowait = true, buffer = true})
    vim.keymap.set('n', 'o', ":<C-U>.call dirvish#open('edit', 0)<CR>", {buffer = true, nowait = true, silent = true})
  end)
end)