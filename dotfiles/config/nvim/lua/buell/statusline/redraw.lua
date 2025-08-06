-- lua/buell/statusline/redraw.lua

local M = {}

local last_redraw = 0
local redraw_throttle = 16 -- ~60fps

function M.smart_redraw()
  local now = vim.uv.now()
  if now - last_redraw > redraw_throttle then
    vim.cmd('redrawstatus')
    last_redraw = now
  end
end

-- Debounced redraw for rapid changes
local redraw_timer = nil
function M.debounced_redraw(delay)
  delay = delay or 50

  if redraw_timer then
    redraw_timer:stop()
  end

  redraw_timer = vim.uv.new_timer()
  redraw_timer:start(delay, 0, function()
    vim.schedule(function()
      vim.cmd('redrawstatus')
      redraw_timer:close()
      redraw_timer = nil
    end)
  end)
end

return M
