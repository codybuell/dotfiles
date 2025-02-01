--------------------------------------------------------------------------------
--                                                                            --
--  Copilot.vim                                                               --
--                                                                            --
--  https://github.com/github/copilot.vim                                     --
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  Configuration  --
---------------------

vim.g.copilot_no_tab_map = true

vim.g.copilot_filetypes = {
  ['*'] = false,
  markdown = false,
  python = true,
  go = true,
  javascript = true,
  typescript = true,
  rust = true,
  lua = true,
  vim = true,
  sh = true,
  yaml = true,
  json = true,
  toml = true,
}

----------------
--  Mappings  --
----------------

-- mapping is handled in ./nvim-cmp.lua
-- vim.keymap.set('i', '<C-o>', 'copilot#Accept("\\<CR>")', {
--   expr = true,
--   replace_keycodes = false
-- })
