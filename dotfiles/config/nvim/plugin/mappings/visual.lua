--------------------------------------------------------------------------------
--                                                                            --
--  Visual Mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

vim.keymap.set('v', '<Leader>rl', ':VtrSendLinesToRunner<CR>', {remap = false})
vim.keymap.set('v', '<Leader>sl', ':\'<,\'>!awk \'{print length(), $0 | "sort -n | cut -d\\" \\" -f2-" }\'<CR>', {remap = false})
vim.keymap.set('v', '<Leader>sa', ':\'<,\'>!sort<CR>', {remap = false})
