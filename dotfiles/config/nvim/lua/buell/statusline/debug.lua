-- lua/buell/statusline/debug.lua

local M = {}

M.enabled = false

function M.log(...)
  if M.enabled then
    print('[Statusline]', ...)
  end
end

function M.profile(name, fn)
  if not M.enabled then
    return fn()
  end

  local start = vim.uv.hrtime()
  local result = fn()
  local duration = (vim.uv.hrtime() - start) / 1000000 -- Convert to ms

  if duration > 1 then -- Log slow operations
    M.log(string.format('%s took %.2fms', name, duration))
  end

  return result
end

function M.dump_cache()
  local cache = require('buell.statusline.cache')
  print(vim.inspect(cache._cache or {}))
end

return M
