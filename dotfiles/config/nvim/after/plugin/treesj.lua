--------------------------------------------------------------------------------
--                                                                            --
--  TreeSJ                                                                    --
--                                                                            --
--  https://github.com/Wansmer/treesj                                         --
--                                                                            --
--------------------------------------------------------------------------------

local has_treesj, treesj = pcall(require, 'treesj')
if has_treesj then

  ---------------------
  --  Configuration  --
  ---------------------

  local config = {
    use_default_keymaps = false,
  }

  -------------
  --  Setup  --
  -------------

  treesj.setup(config)

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>s', ':TSJSplit<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>j', ':TSJJoin<CR>', {remap = false, silent = true})

end
