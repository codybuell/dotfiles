-- Split String
--
-- Lua provides no split builtin, this implements a basic function to split
-- strings by provided separator.
--
-- @param input: string to be split
-- @param sep: string to split by
-- @return table
local split_str = function(input, sep)
  if sep == nil then
     sep = "%s"
  end
  local t={}
  for str in string.gmatch(input, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

return split_str
