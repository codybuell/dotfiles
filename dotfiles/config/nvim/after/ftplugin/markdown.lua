vim.opt_local.conceallevel = 2    -- conceal markdown syntax on markdown buffers
-- vim.opt_local.textwidth    = 80   -- auto hard wrap lines at 80 characters wide

-- TODO: finish porting implementation from ./markdown.vim
local foldexpr_markdown = function(lnum)
  local l1 = vim.fn.getline(lnum)

  -- track fenced blocks and frontmatter
  if string.match(l1, '```*') then
    if vim.b.fenced_block == 0 then
      vim.b.fenced_block = 1
    elseif vim.b.fenced_block == 1 then
      vim.b.fenced_block = 0
    end
  else
    if vim.b.front_matter == 1 and lnum > 2 then
      local l0 = vim.fn.getline(lnum - 1)
      if l0 == '---' then
        vim.b.front_matter = 0
      end
    elseif lnum == 1 then
      if l1 == '---' then
        vim.b.front_matter = 1
      end
    end
  end

  -- if in a code block or frontmatter
  if vim.b.fenced_block == 1 or vim.b.front_matter == 1 then
    if lnum == 1 then
      -- fold preamble
      return '>1'
    else
      -- keep previous foldlevel
      return '='
    end
  end

  local l2 = vim.fn.getline(lnum + 1)
  if string.match(l2, '^==+%s*') and is_mkdcode(lnum + 1) then
    return '>0'
  elseif string.match(l2, '^--') then
  end
end
