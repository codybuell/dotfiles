local foldtext = {}
local middot  = '·'
local raquo   = '»'
local laquo   = '«'
local small_l = 'ℓ'

foldtext.one = function()
  -- » +-     [100ℓ]: local function() ... end ······················· [::::.....] «
  -- » +--     [10ℓ]: local function() ... end ······················· [::.......] «
  -- » +---  [100+ℓ]: local function() ... end ······················· [::::::...] «
  -- » +---+    [3ℓ]: local function() ... end ······················· [:........] «

  -- get counts / numbers
  local fold_lines = vim.v.foldend - vim.v.foldstart + 1
  local buff_lines = vim.fn.line('$')
  local fold_level = string.len(vim.v.folddashes)
  local pane_width = vim.fn.winwidth(0) - buell.util.gutter_width()

  -- grab first and last line strings
  local first_line = ({vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, true)[1]:gsub(' *', '', 1)})[1]
  local last_line  = ({vim.api.nvim_buf_get_lines(0, vim.v.foldend - 1, vim.v.foldend, true)[1]:gsub(' *', '', 1)})[1]

  -- sparkline numbers
  local sparkline_width = 15
  local normalized_size = math.floor((((fold_lines * 1.0) / buff_lines) * sparkline_width) + 0.5)

  -- build fold level indicator
  local fold_lvl_dashes = string.rep("-", fold_level)
  local fold_lvl_padd = string.rep(" ", 5 - fold_level)
  if fold_level > 3 then
    fold_lvl_dashes = "---+"
    fold_lvl_padd   = " "
  end
  local fold_lvl_str = " +" .. fold_lvl_dashes .. fold_lvl_padd

  -- build lines count box
  local overflow = ''
  if fold_lines > 999 then
    fold_lines = 999
    overflow   = "+"
  end
  local lines_count_str = string.rep(" ", 5 - #tostring(fold_lines)) .. '[' .. fold_lines .. overflow .. small_l .. ']: '

  -- assemble sparkline and summary strings
  local sparkline_str = " [" .. string.rep(":", normalized_size) .. string.rep(".", sparkline_width - normalized_size) .. "]  "
  local summary_str   = first_line .. " ... " .. last_line .. " "
  local summary_str   = first_line .. " "

  -- shorten summary_str if there is not enough space
  local space_available = pane_width - string.len(fold_lvl_str .. lines_count_str .. sparkline_str) - 15
  if #summary_str > space_available then
    summary_str = string.sub(summary_str, 0, space_available):gsub("[ .]*$", "") .. "... "
  end

  -- build expansion to right align some content
  local expansion_str = string.rep(middot, pane_width - string.len(fold_lvl_str .. lines_count_str .. summary_str .. sparkline_str))

  return raquo .. fold_lvl_str .. lines_count_str .. summary_str .. expansion_str .. sparkline_str .. laquo
end

foldtext.two = function()
  -- » +-     [100ℓ]: local function() ······························ [::::.....] «
  -- » +--     [10ℓ]: local function() ······························ [::.......] «
  -- » +---  [100+ℓ]: local function() ······························ [::::::...] «
  -- » +---+    [3ℓ]: local function() ······························ [:........] «

  -- get counts / numbers
  local fold_lines = vim.v.foldend - vim.v.foldstart + 1
  local buff_lines = vim.fn.line('$')
  local fold_level = string.len(vim.v.folddashes)
  local pane_width = vim.fn.winwidth(0) - buell.util.gutter_width()

  -- grab first and last line strings
  local first_line = ({vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, true)[1]:gsub(' *', '', 1)})[1]

  -- sparkline numbers
  local sparkline_width = 15
  local normalized_size = math.floor((((fold_lines * 1.0) / buff_lines) * sparkline_width) + 0.5)

  -- build fold level indicator
  local fold_lvl_dashes = string.rep("-", fold_level)
  local fold_lvl_padd = string.rep(" ", 5 - fold_level)
  if fold_level > 3 then
    fold_lvl_dashes = "---+"
    fold_lvl_padd   = " "
  end
  local fold_lvl_str = " +" .. fold_lvl_dashes .. fold_lvl_padd

  -- build lines count box
  local overflow = ''
  if fold_lines > 999 then
    fold_lines = 999
    overflow   = "+"
  end
  local lines_count_str = string.rep(" ", 5 - #tostring(fold_lines)) .. '[' .. fold_lines .. overflow .. small_l .. ']: '

  -- assemble sparkline and summary strings
  local sparkline_str = " [" .. string.rep(":", normalized_size) .. string.rep(".", sparkline_width - normalized_size) .. "]  "
  local summary_str   = first_line .. " "

  -- shorten summary_str if there is not enough space
  local space_available = pane_width - string.len(fold_lvl_str .. lines_count_str .. sparkline_str) - 15
  if #summary_str > space_available then
    summary_str = string.sub(summary_str, 0, space_available):gsub("[ .]*$", "") .. "... "
  end

  -- build expansion to right align some content
  local expansion_str = string.rep(middot, pane_width - string.len(fold_lvl_str .. lines_count_str .. summary_str .. sparkline_str))

  return raquo .. fold_lvl_str .. lines_count_str .. summary_str .. expansion_str .. sparkline_str .. laquo
end

foldtext.three = function()
  -- »      ### I ········································ 2ℓ[...............]  «
  -- »      ### III ······································ 2ℓ[...............]  «
  -- »      ### Parts ···································· 7ℓ[...............]  «
  -- »    Sends ········································· 33ℓ[:..............]  «
  -- »    Facilitators ·································· 32ℓ[:..............]  «
  -- »    Packing List ·································· 45ℓ[:..............]  «
  -- »  Title 1 ········································ 216ℓ[::::...........]  «

  -- get counts / numbers
  local fold_lines = vim.v.foldend - vim.v.foldstart + 1
  local buff_lines = vim.fn.line('$')
  local fold_level = string.len(vim.v.folddashes)
  local pane_width = vim.fn.winwidth(0) - buell.util.gutter_width()

  -- grab first and last line strings
  local first_line = ({vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, true)[1]:gsub(' *', '', 1)})[1]

  -- sparkline numbers
  local sparkline_width = 15
  local normalized_size = math.floor((((fold_lines * 1.0) / buff_lines) * sparkline_width) + 0.5)

  -- build fold level indicator
  local fold_lvl_spaces = string.rep("  ", fold_level)
  if fold_level > 3 then
    fold_lvl_spaces = "      "
  end

  -- build lines count box
  local overflow = ''
  if fold_lines > 999 then
    fold_lines = 999
    overflow   = "+"
  end
  local lines_count_str = string.rep(middot, 6 - #tostring(fold_lines)) .. " " .. fold_lines .. overflow .. small_l

  -- assemble sparkline and summary strings
  local sparkline_str = " [" .. string.rep(":", normalized_size) .. string.rep(".", sparkline_width - normalized_size) .. "]  "
  -- local summary_str   = first_line .. " ... " .. last_line .. " "
  local summary_str   = first_line .. " "

  -- shorten summary_str if there is not enough space
  local space_available = pane_width - string.len(fold_lvl_spaces .. lines_count_str .. sparkline_str) - 15
  if #summary_str > space_available then
    summary_str = string.sub(summary_str, 0, space_available):gsub("[ .]*$", "") .. "... "
  end

  -- build expansion to right align some content
  local expansion_str = string.rep(middot, pane_width - string.len(fold_lvl_spaces .. lines_count_str .. summary_str .. sparkline_str) + 6 - #tostring(fold_lines))

  return raquo .. fold_lvl_spaces .. summary_str .. expansion_str .. lines_count_str .. sparkline_str .. laquo
end

return foldtext
