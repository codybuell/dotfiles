--------------------------------------------------------------------------------
--                                                                            --
--  Obsession                                                                 --
--                                                                            --
--  https://github.com/tpope/vim-obsession                                    --
--                                                                            --
--------------------------------------------------------------------------------

if not vim.fn.exists(':Obsession') then
  return
end

----------------
--  Mappings  --
----------------

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
