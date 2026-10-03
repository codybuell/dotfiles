--------------------------------------------------------------------------------
--                                                                            --
--  Copilot.vim                                                               --
--                                                                            --
--  https://github.com/github/copilot.vim                                     --
--                                                                            --
--  DISABLED: packadd commented out in init.lua (no copilot access). This     --
--  config and the copilot hooks in nvim-cmp.lua / statusline are guarded on  --
--  g:loaded_copilot so re-enabling is just restoring the packadd.            --
--                                                                            --
--------------------------------------------------------------------------------

if vim.g.loaded_copilot ~= 1 then
  return
end

---------------------
--  Configuration  --
---------------------

vim.g.copilot_no_tab_map = true

vim.g.copilot_filetypes = {
  ['*'] = true,
  markdown = false,
  codecompanion = false,
  gitcommit = false,
}

----------------
--  Mappings  --
----------------

-- mapping is handled in ./nvim-cmp.lua
-- vim.keymap.set('i', '<C-o>', 'copilot#Accept("\\<CR>")', {
--   expr = true,
--   replace_keycodes = false
-- })
