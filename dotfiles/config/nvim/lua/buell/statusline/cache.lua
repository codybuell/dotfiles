-- lua/buell/statusline/cache.lua

local M = {}

local cache = {}
local cache_timeout = 100 -- ms

local function is_cache_valid(key)
  local entry = cache[key]
  return entry and (vim.uv.now() - entry.timestamp) < cache_timeout
end

function M.get_or_compute(key, compute_fn, ...)
  if is_cache_valid(key) then
    return cache[key].value
  end

  local value = compute_fn(...)
  cache[key] = {
    value = value,
    timestamp = vim.uv.now()
  }
  return value
end

function M.invalidate(pattern)
  for key, _ in pairs(cache) do
    if key:match(pattern) then
      cache[key] = nil
    end
  end
end

function M.clear()
  cache = {}
end

return M
