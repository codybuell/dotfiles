-- Gutter Width
--
-- Determines the width of the LHS gutter, comprised of fold indecator, signs,
-- and number columns plus some amount of padding.
--
-- @param nil
-- @return int
local gutter_width = function()
  local signcolumn = 0
  local option = vim.wo.signcolumn
  if option == 'yes' then
    signcolumn = 2
  elseif option == 'auto' then
    local signs = vim.fn.sign_getplaced('')
    if #signs[1].signs > 0 then
      signcolumn = 2
    end
  elseif string.find(option, ':') then
    signcolumn = tonumber(string.gsub(option, ".*:", ""))
  end

  local minwidth = 2
  local numberwidth = vim.wo.numberwidth
  local row = vim.api.nvim_buf_line_count(0)
  local gutterwidth = math.max(
    (#tostring(row) + 1),
    minwidth,
    numberwidth
  ) + signcolumn + vim.o.foldcolumn
  return gutterwidth
end

return gutter_width
