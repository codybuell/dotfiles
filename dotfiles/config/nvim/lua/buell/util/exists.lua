-- Exists
--
-- Check if the provided path exists as a file or directory.
--
-- @param path: string, file or directory path
-- @return bool
local exists = function (path)
   local ok, err, code = os.rename(path, path)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

return exists
