--------------------------------------------------------------------------------
--                                                                            --
--  Visual Mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

vim.keymap.set('v', '<Leader>rl', ':VtrSendLinesToRunner<CR>', {remap = false})
vim.keymap.set('v', '<Leader>sl', ':\'<,\'>!awk \'{print length(), $0 | "sort -n | cut -d\\" \\" -f2-" }\'<CR>', {remap = false})
vim.keymap.set('v', '<Leader>sa', ':\'<,\'>!sort<CR>', {remap = false})

vim.keymap.set('v', '<C-h>', ':<C-U>TmuxNavigateLeft<CR>', {remap=false, silent=true})
vim.keymap.set('v', '<C-j>', ':<C-U>TmuxNavigateDown<CR>', {remap=false, silent=true})
vim.keymap.set('v', '<C-k>', ':<C-U>TmuxNavigateUp<CR>', {remap=false, silent=true})
vim.keymap.set('v', '<C-l>', ':<C-U>TmuxNavigateRight<CR>', {remap=false, silent=true})
