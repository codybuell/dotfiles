-- fold only headers
local markdown = function ()
  -- To debug this, set these to show the fold level in the gutter:
  --    :set statuscolumn=%l\ %{foldlevel(v:lnum)}
  --    :set numberwidth=6

  -- lines[1]
  -- lines[2] current line    header
  -- lines[3]                 ======
  -- lines[4]                 ======
  local lnum  = vim.v.lnum
  local lines = vim.fn.getline(lnum - 1, lnum + 2)

  -- if lnum is 1, insert "" at the start of the lines table
  if lnum == 1 then
    table.insert(lines, 1, "")
  end

  -- pad the end of the table as needed
  local length = #lines
  if length > 4 then
    for i = 1, 4 - length do
      table.insert(lines, length + i, "")
    end
  end

  -- handle last line
  if lnum == vim.fn.line('$') then
    return "="
  end

  -- detect frontmatter
  local is_in_frontmatter = false
  if vim.fn.getline(1):match('^---$') then
    for i = 2, vim.fn.line('$') do
      if vim.fn.getline(i):match('^---$') then
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
      return ">1"      -- begin a fold of level one here
    elseif lines[2]:match('^## .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">2"      -- begin a fold of level two here
    elseif lines[2]:match('^### .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">3"      -- begin a fold of level three here
    elseif lines[2]:match('^#### .*$') and lines[1]:match('^%s*$') and lines[3]:match('^%s*$') then
      return ">4"      -- begin a fold of level four here
    elseif lines[2] ~= '' and lines[3]:match('^===*$') and lines[4]:match('^%s*$') then
      return ">1"      -- h1 fold with underscores (2 or more equals for underscores)
    elseif lines[2] ~= '' and lines[3]:match('^---*$') and lines[4]:match('^%s*$') then
      return ">2"      -- h2 fold with underscores (2 or more dashes for underscores)
    end
  end

  if vim.fn.foldlevel(lnum - 1) ~= -1 then
    return vim.fn.foldlevel(lnum - 1)
  end

  return "="
end

return markdown
