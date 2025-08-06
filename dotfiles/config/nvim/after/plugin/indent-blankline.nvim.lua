--------------------------------------------------------------------------------
--                                                                            --
--  Indent Blankline                                                          --
--                                                                            --
--  https://github.com/lukas-reineke/indent-blankline.nvim                    --
--                                                                            --
--------------------------------------------------------------------------------

local has_ibl, ibl = pcall(require, 'ibl')
if not has_ibl then
  return
end

---------------------
--  Configuration  --
---------------------

local config  = {
  exclude = {
    filetypes = {
      -- defaults
      'lspinfo',
      'packer',
      'checkhealth',
      'help',
      'man',
      'gitcommit',
      '',

      -- additions
      'markdown',
    }
  },
-- space_char_blankline = ' ',
}

-----------
-- Setup --
-----------

ibl.setup(config)

----------------
--  Mappings  --
----------------

local indent_wrap_mapping = buell.util.indent_blankline.wrap_mapping

-- remap indent-related remaps for compatibility with indent-blankline.nvim
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
