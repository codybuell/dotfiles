-- Disable Buf TS
--
-- Disables treesitter for the buffer. Useful for handling large or uglified
-- files as treesitter does not respect synmaxcol and can just choke at a
-- certain point.
--
-- @param none
-- @return nil
local disable_buf_ts = function()
  vim.cmd('exec "TSBufDisable autotag<CR>"')
  vim.cmd('exec "TSBufDisable highlight<CR>"')
  vim.cmd('exec "TSBufDisable incremental_selection<CR>"')
  vim.cmd('exec "TSBufDisable indent<CR>"')
  vim.cmd('exec "TSBufDisable playground<CR>"')
  vim.cmd('exec "TSBufDisable query_linter<CR>"')
  vim.cmd('exec "TSBufDisable rainbow<CR>"')
  vim.cmd('exec "TSBufDisable refactor.highlight_definitions<CR>"')
  vim.cmd('exec "TSBufDisable refactor.navigation<CR>"')
  vim.cmd('exec "TSBufDisable refactor.smart_rename<CR>"')
  vim.cmd('exec "TSBufDisable refactor.highlight_current_scope<CR>"')
  vim.cmd('exec "TSBufDisable textobjects.swap<CR>"')
  vim.cmd('exec "TSBufDisable textobjects.lsp_interop<CR>"')
  vim.cmd('exec "TSBufDisable textobjects.select<CR>"')
  vim.cmd('exec "TSBufDisable textobjects.move"')

  vim.opt_local.foldmethod = 'manual'
end

return disable_buf_ts
