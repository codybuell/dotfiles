--------------------------------------------------------------------------------
--                                                                            --
--  Copilot.vim                                                               --
--                                                                            --
--  https://github.com/github/copilot.vim                                     --
--                                                                            --
--------------------------------------------------------------------------------

if not vim.fn.exists(':Copilot') then
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
