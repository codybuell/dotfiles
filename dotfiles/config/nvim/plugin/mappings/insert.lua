--------------------------------------------------------------------------------
--                                                                            --
--  insert mode                                                               --
--                                                                            --
--------------------------------------------------------------------------------

-- underline helper
vim.keymap.set('i', '<C-u>', function()
  -- Clear the cache explicitly to force a new prompt
  require('buell.util.underline').clear_cache()
  -- Execute the operation
  local keys = vim.api.nvim_eval('v:lua.require("buell.util.underline").prompt()')
  -- Feed the keys as if typed
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-O>' .. keys, true, false, true), 'n', false)
end, {silent = true})
