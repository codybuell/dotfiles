-- fold only headers
local markdown = function()
  -- To debug this, set these to show the fold level in the gutter:
  --    :set statuscolumn=%l\ %{foldlevel(v:lnum)}
  --    :set numberwidth=6

  -- lines[1]
  -- lines[2] current line    header
  -- lines[3]                 ======
  -- lines[4]
  local lnum = vim.v.lnum
  local lines = vim.fn.getline(lnum - 1, lnum + 2)

  -- if lnum is 1, insert "" at the start of the lines table
  if lnum == 1 then
    table.insert(lines, 1, "")
  end

  -- pad the end of the table as needed
  while #lines < 4 do
    table.insert(lines, "")
  end

  -- handle last line
  if lnum == vim.fn.line('$') then
    return "="
  end

  -- detect frontmatter
  local is_in_frontmatter = false
  if lnum <= 20 and vim.fn.getline(1):match('^%-%-%-$') then
    for i = 2, math.min(vim.fn.line('$'), 20) do
      if vim.fn.getline(i):match('^%-%-%-$') then
        if lnum <= i then
          is_in_frontmatter = true
        end
        break
      end
    end
  end

  -- handle header folding
  if not is_in_frontmatter then
    if lines[2]:match('^# .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">1"
    elseif lines[2]:match('^## .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">2"
    elseif lines[2]:match('^### .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">3"
    elseif lines[2]:match('^#### .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">4"
    elseif lines[2] ~= '' and lines[3]:match('^===+$') and lines[4]:match('^%s*$') then
      return ">1"
    elseif lines[2] ~= '' and lines[3]:match('^%-%-%-+$') and lines[4]:match('^%s*$') then
      print(lines[1], lines[2], lines[3], lines[4])
      return ">2"
    end
  end

  -- use previous fold level if available
  local prev_level = vim.fn.foldlevel(lnum - 1)
  if prev_level ~= -1 then
    return prev_level
  end

  return "="
end

return markdown
