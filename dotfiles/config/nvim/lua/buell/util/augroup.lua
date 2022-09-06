buell.g.augroup_callbacks = {}

-- Autocommand Group
--
-- Generates an autocommand group of the function provided. Encapsulates the
-- common pattern of creating (or redeclaring) an augroup, clearing it, and
-- populating it with autocommands.
--
-- @param group: name of autocommand group
-- @param func: contents of the autocommand group
-- @return nil
local augroup = function (name, callback)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  callback()
  vim.cmd('augroup END')

  -- allows us to hackily re-register the same group of autocmds in the future
  buell.g.augroup_callbacks[name] = callback
end

return augroup
