--------------------------------------------------------------------------------
--                                                                            --
--  LSP                                                                       --
--                                                                            --
--  see lua/buell/lsp.lua                                                     --
--                                                                            --
--------------------------------------------------------------------------------

-- initialize lsp configurations
buell.lsp.init()

-- Set up global keybinding for unicode toggle (available even without LSP)
vim.keymap.set("n", "<leader>u", "<Cmd>lua buell.lsp.toggle_unicode_check()<CR>", { noremap = true, silent = true })
