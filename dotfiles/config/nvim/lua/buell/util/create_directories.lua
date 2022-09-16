-- Create Directories
--
-- Create any missing directories in the path provided.
--
-- @param path: string of desired path
-- @return nil
local create_directories = function(path)
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

return create_directories
