-- Cleaner/simpler clone of the built-in tabline, but without the window
-- counts, the modified flag, or the close widget.
local render = function()
  local gutter_width = buell.util.gutter_width()
  local window_width = vim.o.columns
  local avail_width  = window_width - gutter_width
  local line_start   = string.rep(' ', gutter_width)
  local current_tab  = vim.api.nvim_tabpage_get_number(0)
  local tab_count    = vim.fn.tabpagenr('$')

  -- determine full size tab bar and build compression array
  local width = 0
  local trim_array = {}
  for i = 1, tab_count do
    width = width + #buell.tabline.label(i, 0) + 2
    table.insert(trim_array, 0)
  end

  -- if the tabbar is too wide determine how many chars to remove from each tab
  if width > avail_width then
    local over = width - avail_width
    local per_tab, slop
    if over >= tab_count then
      per_tab = math.floor(over / tab_count)
      slop = over % tab_count
    else
      per_tab = 0
      slop = over % tab_count
    end
    for i = 1, tab_count do
      trim_array[i] = trim_array[i] + per_tab
    end
    for i = 1, slop do
      trim_array[i] = trim_array[i] + 1
    end
  end

  -- build the tabline with per tab trims
  local line = ''
  for i = 1, vim.fn.tabpagenr('$') do
    if i == current_tab then
      line = line .. '%#TabLineSel#'
    else
      line = line .. '%#TabLine#'
    end
    line = line .. '%' .. i .. 'T' -- Starts mouse click target region.
    line = line .. ' %{v:lua.buell.tabline.label(' .. i .. ', ' .. trim_array[i] .. ')} '
  end


  line = line .. '%#TabLineFill#'
  line = line .. '%T' -- Ends mouse click target region(s).
  return line_start .. line
end

return render
