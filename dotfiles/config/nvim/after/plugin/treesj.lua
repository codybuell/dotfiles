--------------------------------------------------------------------------------
--                                                                            --
--  TreeSJ                                                                    --
--                                                                            --
--  https://github.com/Wansmer/treesj                                         --
--                                                                            --
--------------------------------------------------------------------------------

local has_treesj, treesj = pcall(require, 'treesj')
if not has_treesj then
  return
end

vim.defer_fn(function()

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

end, 100)
