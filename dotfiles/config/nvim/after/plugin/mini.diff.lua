--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Diff                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_minidiff, minidiff = pcall(require, 'mini.diff')
if not has_minidiff then
  return
end

-------------
--  Setup  --
-------------

minidiff.setup()

----------------
--  Mappings  --
----------------

vim.keymap.set('n', '<Leader>gd', ':lua MiniDiff.toggle_overlay()<CR>', {remap = false, silent = true})
