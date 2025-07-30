--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Dimming                                                     --
--                                                                            --
--  Handles dimming older exchanges to make it easier to track the active     --
--  part of the conversation. Like limelight for codecompanion chats.         --
--                                                                            --
--------------------------------------------------------------------------------

-- create a dedicated namespace for dimming
local dim_ns = vim.api.nvim_create_namespace('buell_dimming')

local ts = vim.treesitter
local query = ts.query.parse('markdown', [[
  (atx_heading) @h2
]])

local function get_frontmatter_range(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if lines[1]:match("^---") or lines[1]:match("^%%%+") then
    for i = 2, #lines do
      if lines[i]:match("^---") or lines[i]:match("^%%%+") then
        return 0, i
      end
    end
  end
  return nil
end

local function get_headings(bufnr, query_start)
  local parser = ts.get_parser(bufnr, 'markdown')
  local tree
  if parser then
    local parsed = parser:parse()
    if parsed then
      tree = parsed[1]
    end
  end
  local root = tree:root()
  local headings = {}

  for id, node, _ in query:iter_captures(root, bufnr, query_start, -1) do
    local name = query.captures[id]
    if name == 'h2' then
      local start_row, _, end_row, _ = node:range()
      table.insert(headings, {type = name, start_row = start_row, end_row = end_row})
    end
  end

  return headings
end

local function dim_sections(bufnr)
  local _, frontmatter_end = get_frontmatter_range(bufnr)
  local query_start = frontmatter_end and frontmatter_end + 1 or 0
  local headings = get_headings(bufnr, query_start)
  local cursor_row = vim.fn.line('.') - 1
  local active_h2

  for _, heading in ipairs(headings) do
    if heading.type == 'h2' and heading.start_row <= cursor_row then
      if vim.fn.getline(heading.start_row + 1):match('^## CodeCompanion') then
        active_h2 = heading
      end
    end
  end

  vim.api.nvim_buf_clear_namespace(bufnr, dim_ns, 0, -1)

  if active_h2 then
    for i = query_start, active_h2.start_row - 1 do
      vim.hl.range(bufnr, dim_ns, 'buellDimmedText', {i, 0}, {i, -1})
    end
  end
end

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellCodeCompanion', function()
  autocmd('CursorMoved,CursorMovedI', '*', function()
    if vim.bo.filetype == 'codecompanion' then
      dim_sections(vim.api.nvim_get_current_buf())
    end
  end)
end)

local pinnacle = require('wincent.pinnacle')

pinnacle.set('buellDimmedText', {fg = pinnacle.darken('Normal', 0.5).fg})
