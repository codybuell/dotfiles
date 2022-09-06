-- Set Highlight
--
-- Convenience to set highlight groups.
--
-- @param group: group name to set
-- @param settings: color settings
-- @return nil
local set_highlight = function(group, settings)
  vim.cmd("highlight! " .. group .. " " .. settings)
end

return set_highlight
