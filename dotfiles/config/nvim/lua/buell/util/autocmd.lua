buell.g.autocommand_callbacks = {}

-- Autocommand
--
-- Wrapper for simple autocmd use cases. `cmd` may be a string or a Lua
-- function.
--
-- @param name: name of event(s), comma separated no spaces, see :h {event}
-- @param pattern: filetype(s) patterns, see :h {aupat}
-- @param cmd: command to run, a lua function or vim string
-- @param opts: table, key = bool, possible keys: bang, once
-- @return nil
local autocmd = function (name, pattern, cmd, opts)
  opts = opts or {}
  local cmd_type = type(cmd)
  if cmd_type == 'function' then
    local key = buell.util.get_key_for_fn(cmd, buell.g.autocommand_callbacks)
    buell.g.autocommand_callbacks[key] = cmd
    cmd = 'lua buell.g.autocommand_callbacks.' .. key .. '()'
  elseif cmd_type ~= 'string' then
    error('autocmd(): unsupported cmd type: ' .. cmd_type)
  end
  local bang = opts.bang and '!' or ''
  local once = opts.once and '++once' or ''
  vim.cmd(
    table.concat(
      vim.tbl_filter(
        function (item) return item ~= '' end, {
          'autocmd' .. bang,
          name,
          pattern,
          once,
          cmd,
        }
      ), ' '
    )
  )
end

return autocmd
