-- remap copilot accept to something instead of tab
vim.keymap.set('i', '<C-o>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true
