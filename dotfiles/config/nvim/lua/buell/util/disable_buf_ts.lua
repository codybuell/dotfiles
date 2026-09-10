-- Disable Buf TS
--
-- Disables treesitter for the buffer. Useful for handling large or uglified
-- files as treesitter does not respect synmaxcol and can just choke at a
-- certain point.
--
-- @param none
-- @return nil
local disable_buf_ts = function()
  -- the master-branch TSBufDisable commands are gone on nvim-treesitter
  -- main; native stop() detaches the highlighter (and with it folds/etc)
  pcall(vim.treesitter.stop)
  vim.opt_local.foldmethod = 'manual'
end

return disable_buf_ts
