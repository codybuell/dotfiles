--------------------------------------------------------------------------------
--                                                                            --
--  Fugitive                                                                  --
--                                                                            --
--  https://github.com/tpope/vim-fugitive                                     --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':Git') then

  ---------------------
  --  Configuration  --
  ---------------------

  -- see corresponding syntax defs in after/syntax/qf.vim
  vim.g.fugitive_summary_format = "%ad   %<(16,trunc)%aN%d %s"

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>gs', ':Git<CR>:40wincmd_<CR>', {remap = false, silent = true})
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

end
