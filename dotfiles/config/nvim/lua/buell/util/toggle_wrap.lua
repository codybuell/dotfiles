-- Toggle Wrap
--
-- Helper to add or remove function calls around a string. Note this requires
-- tpope's vim-surround plugin.

--
-- @param nil
-- @return nil
local toggle_wrap = function()
  local ignore_types = {
    'quickfix',   -- quickfix
    'nofile',     -- empty buffer
    'help',       -- help docs
    'vim',        -- command window
  }

  local filetype = vim.bo.filetype

  if filetype == 'qf' then
    vim.cmd('.cc')
  elseif buell.util.has_value(ignore_types, filetype) then
    vim.cmd('execute "normal! <CR>"')
  else
    vim.cmd('execute "normal csw)"')
    vim.cmd('startinsert')
  end

  -- if wrapped in a func, to undo, Bdt(ds)
end

return toggle_wrap
