vim.opt_local.conceallevel = 2                            -- conceal markdown syntax on markdown buffers
vim.opt_local.tabstop      = 2                            -- spaces per tab
vim.opt_local.shiftwidth   = 2                            -- spaces per tab

----------------------------------
--  list item wrap indentation  --
----------------------------------

-- Note that this works when set in the equivalent vimscript file but not when
-- set below. May be due to the vimscript file being present? Test this at some
-- point when migrating the vimscript file over to here.

-- vim.opt_local.breakindent  = true                         -- turn on improved soft wrapping
-- vim.opt_local.breakindentopt = 'list:-1,shift:2,sbr'      -- use formatlistpat to determine soft wrap depth
-- We are dealing with double escaping for vim eg `\\s == \s` and then escaping
-- again for lua eg `\\\\s == \\s == \s`, then joining multiple regexes with
-- `\\\\\\|`, so do to deal with the complexity we'll break it into a table and
-- concat for the setting. Defines regex for list type 'headers' used to
-- determine the wrap depth.
-- vim.opt_local.formatlistpat = table.concat({
--   -- '^\\\\s*-\\\\s\\\\[\\\\s]\\\\s\\\\ze.*',             -- makdown todo lists '- [ ] '
--   '^\\\\s*-\\\\s\\\\[.]\\\\s*',                           -- makdown todo lists '- [ ] '
--   '\\\\\\|',                                              -- concatenation of regexes
--   '^\\\\s*\\\\d\\\\+\\\\.\\\\s\\\\+',                     -- numbered lists '1. '
--   '\\\\\\|',                                              -- concatenation of regexes
--   '^\\\\s*[-*+]\\\\s\\\\+',                               -- unordered lists '-|*|+ '
--   '\\\\\\|',                                              -- concatenation of regexes
--   '^\\\\[^\\\\ze[^\\\\]]\\\\+\\\\]:\\\\&^.\\\\{4\\\\}',   -- ?? too lazy to read this regex now
-- })

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
