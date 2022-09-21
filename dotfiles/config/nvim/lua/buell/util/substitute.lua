-- Substitute
--
-- Performs a substitution on the entire buffer while keeping the cursor
-- posision intact.
--
-- @param string: pattern to find
-- @param string: replacement to insert
-- @param string: flags for substitute command
-- @return nil
local substitute = function(pattern, replacement, flags)
  local num = 1
  for _, line in ipairs(vim.fn.getline(1, '$')) do
    vim.fn.setline(num, vim.fn.substitute(line, pattern, replacement, flags))
    num = num + 1
  end
end

return substitute
