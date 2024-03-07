-- Cleaner/simpler clone of the built-in tabline, but without the window
-- counts, the modified flag, or the close widget.
local render = function()
  local gutter_width = buell.util.gutter_width()
  local window_width = vim.o.columns
  local current_tab  = vim.api.nvim_tabpage_get_number(0)
  local tab_count    = vim.fn.tabpagenr('$')
  local line_start   = string.rep(' ', gutter_width)
  local avail_width  = window_width - gutter_width

  -- determine full size tab bar and build tab table
  local tabs = {}
  local tabsinfo = {}
  local width = 0
  for i = 1, tab_count do
    local buflist = vim.fn.tabpagebuflist(i)
    local winnr   = vim.fn.tabpagewinnr(i)
    local label   = i .. ': ' .. vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':t'))
    table.insert(tabsinfo, {
      index  = i,
      length = #label + 2
    })
    table.insert(tabs, label)
    width = width + #label + 2
  end

  -- sort tab table by label size
  table.sort(tabsinfo, function(a, b) return a.length > b.length end)

  -- shorten longest labels one char at a time until we are within our avail_width
  local iterations = 0
  while width > avail_width do
    -- break when we are within width, have looped 1k times or when we are down to just 4 chars per tab
    if width <= avail_width or iterations > 1000 or tabsinfo[1].length < 4 then
      break
    end
    tabsinfo[1].length = tabsinfo[1].length - 1
    tabs[tabsinfo[1].index] = tabs[tabsinfo[1].index]:sub(1, tabsinfo[1].length - 3) .. '…'
    width = width - 1
    iterations = iterations + 1
    table.sort(tabsinfo, function(a, b) return a.length > b.length end)
  end

  -- build the tabline
  local line = ''
  for i = 1, tab_count do
    if i == current_tab then
      line = line .. '%#TabLineSel#'
    else
      line = line .. '%#TabLine#'
    end
    line = line .. '%' .. i .. 'T' -- starts mouse click target region
    line = line .. ' ' .. tabs[i] .. ' '
    -- line = line .. ' %{v:lua.buell.tabline.label(' .. i .. ', ' .. capacity_array[i] .. ')} '
  end

  line = line .. '%#TabLineFill#'
  line = line .. '%T' -- ends mouse click target region(s)
  return line_start .. line
end

return render
