-- Has Value
--
-- Searches a table for specific value.
--
-- @param table: haystack
-- @param value: needle
-- @return bool
local has_value = function(table, value)
  for _, val in ipairs(table) do
    if val == value then
      return true
    end
  end

  return false
end

return has_value
