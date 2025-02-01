--------------------------------------------------------------------------------
--                                                                            --
--  Ferret                                                                    --
--                                                                            --
--  https://github.com/wincent/ferret                                         --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':Ack') then

  ---------------------
  --  Configuration  --
  ---------------------

  vim.g.FerretExecutableArguments = {
    --   rg = '--vimgrep --no-heading --max-columns 4096 --hidden'
    rg = '--vimgrep --no-heading --no-config --max-columns 4096 --hidden --glob !.git',
  }

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>aa', '<Plug>(FerretAck)', {})
  vim.keymap.set('n', '<Leader>aw', '<Plug>(FerretAckWord)', {})
  vim.keymap.set('n', '<Leader>as', '<Plug>(FerretAcks)', {})
  vim.keymap.set('n', '<Leader>a.', ':Ack  %:p:h<C-B><RIGHT><RIGHT><RIGHT><RIGHT>', {remap = false})

end
