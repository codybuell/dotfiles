-- lua/buell/statusline/utils.lua

local M = {}

function M.safe_call(fn, fallback, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return result
  else
    if fallback then
      return fallback
    end
    return ''
  end
end

function M.with_fallback(primary_fn, fallback_fn)
  return function(...)
    local ok, result = pcall(primary_fn, ...)
    if ok and result ~= nil then
      return result
    end
    return fallback_fn and fallback_fn(...) or ''
  end
end

return M
