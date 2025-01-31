local markdown = {}

--------------------------------------------------------------------------------
--                                                                            --
--  Configuration                                                             --
--                                                                            --
--------------------------------------------------------------------------------

-- wikis, wiki cannot have a name of http[s]?
local wikis = {
  notes   = vim.fn.fnamemodify('{{ Notes }}', ':p'),
}

-- define link syntaxes, order is important in link_types due to lua's lack of
-- regex and my bad pattern writting skills... url must come first
local link_syntax = '%[[^%]]*%]%([^%)]*%)'        -- [...](...)
local link_types  = {
  {
    -- [title](http[s]://link)
    kind = 'url',
    expr = '%[[^%]]*%]%(http[s]?://[^%)]*%)',
  },
  {
    -- [title]([any/path/]file)
    kind = 'file',
    expr = '%[[^%]]*%]%([^%):#]*%)',
  },
  {
    -- [title]([[path/]file[.ext]]#section)
    kind = 'section',
    expr = '%[[^%]]*%]%([^#%):]*#[^%)%/:#]*%)',
  },
  {
    -- [title](wiki:link[#section])
    kind = 'wiki',
    expr = '%[[^%]]*%]%([^:)]*:[^%)]*%)',
  },
}

-- TEST:
-- file
-- file without extension (should default add on .txt)
-- section within a file
-- section in another file
-- wiki:file
-- wiki:file w/o extension
-- wiki:file w/ section
-- wiki:file w/o extension w/ section

--------------------------------------------------------------------------------
--                                                                            --
--  Helpers                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

local markdown_fold_level = function ()
  local lines = vim.fn.getline(vim.v.lnum - 1, vim.v.lnum + 1)

  -- fenced code blocks
  if lines[1]:match('^%s*```.+$') then
      -- start of a fenced block
      return "a1"
  elseif lines[1]:match('^%s*```%s*$') then
      -- end of a fenced block
      return "s1"
  end

  -- headers (fold h2 on)
  if lines[1]:match('^## .*$') and lines[0]:match('^%s*$') and lines[2]:match('^%s*$') then
      -- begin a fold of level two here
      return ">1"
  elseif lines[1]:match('^### .*$') and lines[0]:match('^%s*$') and lines[2]:match('^%s*$') then
      -- begin a fold of level three here
      return ">2"
  elseif lines[1] ~= '' and lines[2]:match('^---*$') then
      -- elseif the line ends with at least two --
      return ">1"
  elseif vim.fn.foldlevel(vim.v.lnum-1) ~= "-1" then
      return vim.fn.foldlevel(vim.v.lnum - 1)
  -- this as an absolute last resort! without the above condition this func
  -- gets recursively called some 66K times vs 1K times... 3 sec vs 0.03 sec
  -- save time difference
  else
      return "="
  end
end

-- Get URL for Position
--
-- Detects if the cursor is over a url and return it's target if found.
--
-- @param lnum: int, line number to check
-- @param col: int, column number to check
-- @return string: url under cursor
local get_url_for_position = function (lnum, col)
  local cur_line = vim.fn.getline(lnum)

  -- loop through all links in the line
  for link in cur_line:gmatch(link_syntax) do
    -- local link_escaped = link:gsub('[%(%)%.%+%-%*%%%?%[%^%$%]]', '%%%1')
    local str_start, str_end = cur_line:find(link, 1, true)
    if str_start and col >= str_start and col <= str_end then
      return link
    end
  end
end

-- Open Link
--
-- Opens up a makrdown link in the format of [text](target). Handles a mix of
-- link types defined above.
--
-- @param link: string in format of [text](target)
-- @return nil
local open_link = function (link)
  -- find first matching link type
  local link_type
  for _, type in ipairs(link_types) do
    if link:match(type['expr']) then
      link_type = type['kind']
      goto continue
    end
  end
  ::continue::

  -- grab the target
  local target, _ = link:gsub('%[[^%(]+%(([^%)]*)%)', '%1')

  if target == '' then
    -- TODO: make smart and infer a target based on text?
    print('No target defined')
  else
    if link_type == 'url' then
      vim.fn['netrw#BrowseX'](target, 0)
    else
      -- get section and target from section type links
      local section = ''
      if link_type == 'section' then
        section = target:gsub('^[^#]*#', '')
        target  = target:gsub('#.*$', '')
      end

      -- get wiki, target, and section from wiki type links
      local wiki = ''
      if link_type == 'wiki' then
        wiki    = target:gsub(':.*$', '')
        section = target:gsub('^[^#]*#', '')
        target  = target:gsub('^[^:]*:', ''):gsub('#.*$', '')
      end

      -- if target is defined open it up
      if target ~= '' then
        -- append an extension if needed
        if not target:match('%.[%C%X]') then
          target = target .. '.md'
        end

        -- build full path to file
        local open_path
        if wiki ~= '' then
          open_path = wikis[wiki] .. '/' .. target
        elseif target:sub(1,1):match('[~/%.]') then
          open_path = target
        else
          open_path = vim.fn.expand('%:p:h') .. '/' .. target
        end

        -- open up the path
        vim.cmd('edit ' .. open_path)
      end

      -- navigate to section if defined
      if section ~= '' then
        local dashes = vim.fn.execute('%s/^' .. section .. '\\n[=-]\\+$//n', 'silent!')
        local hashes = vim.fn.execute('%s/^#\\+\\s\\+' .. section .. '\\s*$//n', 'silent!')
        if dashes ~= '' then
          vim.cmd('g/^' .. section .. '\\n[=-]\\+$/ norm ggn,/')
        elseif hashes ~= '' then
          vim.cmd('g/#* ' .. section .. '/ norm ggn,/')
        else
          print('Section "' .. section .. '" not found')
        end
      end
    end
  end
end

--------------------------------------------------------------------------------
--                                                                            --
--  Main                                                                      --
--                                                                            --
--------------------------------------------------------------------------------

markdown.create_or_follow_link = function ()
  local line_nr = vim.fn.line('.')
  local col_nr  = vim.fn.col('.')
  local target  = get_url_for_position(line_nr, col_nr)
  if target then
    open_link(target)
  else
    local str_start
    local str_end
    local link_str
    local current_line = vim.fn.getline('.')
    local mode = vim.fn.mode()

    if mode == "V" or mode == "CTRL-V" or mode == "\22" then
      -- map out the scope of visual selection
      local line_nr_v, col_nr_v = vim.fn.line('v'), vim.fn.col('v')
      local v_start_ln, v_start_col
      local v_end_ln, v_end_col
      if line_nr == line_nr_v then
        if col_nr <= col_nr_v then
          v_start_ln, v_start_col = line_nr, col_nr
          v_end_ln, v_end_col = line_nr_v, col_nr_v
          v_start_col = v_start_col + 1
        else
          v_start_ln, v_start_col = line_nr_v, col_nr_v
          v_end_ln, v_end_col = line_nr, col_nr
        end
      elseif line_nr < line_nr_v then
        v_start_ln, v_start_col = line_nr, col_nr
        v_end_ln, v_end_col = line_nr_v, col_nr_v
        v_start_col = v_start_col + 1
      else
        v_start_ln, v_start_col = line_nr_v, col_nr_v
        v_end_ln, v_end_col = line_nr, col_nr
      end

      -- only apply to visual selections on the same line
      if v_start_ln ~= v_end_ln then
        return
      end

      -- grab start and stop indices
      str_start = v_start_col
      str_end   = v_end_col

      -- grab the string to be replaced and build link string
      local current_word = current_line:sub(str_start, str_end)
      link_str = '[' .. current_word .. '](' .. current_word:lower() .. ')'
    else
      -- grab the current character under the cursor
      local char = string.sub(vim.fn.getline(line_nr), col_nr, col_nr)

      -- ignore spaces
      if char:match('[%w%p]') then
        local current_word = vim.fn.expand('<cWORD>')

        -- build link string
        link_str = '[' .. current_word .. '](' .. current_word:lower() .. ')'

        local start_index = 1
        while true do
          str_start, str_end = current_line:find(current_word, start_index, true)
          if str_start and col_nr >= str_start and col_nr <= str_end then
            goto continue
          else
            start_index = str_end + 1
          end
        end
        ::continue::
      else
        return
      end
    end
    -- run effectively a noop so that if you undo the following substitution it
    -- returns cursor position as expected rather than jumping to the start of
    -- the line
    vim.cmd("normal! i ")
    vim.cmd("normal! x")
    vim.fn.cursor(0, col_nr)
    -- make substitution, put cursor back where it was, and clear hlsearch
    vim.cmd(':s~\\%' .. str_start .. 'c.*\\%' .. (str_end + 1) .. 'c~' .. link_str .. '~')
    vim.fn.cursor(0, col_nr + 1)
    vim.cmd('let @/ = ""')
  end
end

return markdown
