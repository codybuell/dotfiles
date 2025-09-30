--------------------------------------------------------------------------------
--                                                                            --
--  insert mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

-- underline helper
vim.keymap.set('i', '<C-u>', '<C-O>' .. vim.api.nvim_eval('v:lua.require("buell.util.underline").prompt()'), {silent = true})
