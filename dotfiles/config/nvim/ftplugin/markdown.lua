-- Markdown
--
-- This is largely a partial re-implementation of the vim-markdown plugin,
-- https://github.com/preservim/vim-markdown. Implemented components:
--   - fenced codeblock syntax highlighting
--   - buffer specific mappings (calls lua.buell.markdown.[funcs])
--   - ...

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

--------------------------------------------------------------------------------
--                                                                            --
--  Configuration                                                             --
--                                                                            --
--------------------------------------------------------------------------------

vim.opt_local.spell = true

-- map misc filetypes to vim filetypes
local filetype_dict = {
  ['c++']  = 'cpp',
  ['viml'] = 'vim',
  ['bash'] = 'sh',
  ['ini']  = 'dosini',
}

--------------------------------------------------------------------------------
--                                                                            --
--  Helpers                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

-- No New Types
--
-- Deteremine if there are new elements between a known and new findings table.
-- This only searches one layer deep.
--
-- @param known: table of known elements
-- @param found: table of new found elements
-- @return bool: true -> no new items
local no_new_types = function (known, found)
  for ft, _ in pairs(found) do
    if known[ft] == nil then
      return false
    end
  end
  return true
end

-- Syntax Include
--
-- Include vim syntax files from runtimepath for specified filetype.
--
-- @param filetype: string of filetype
-- @return string: name of include group
local syntax_include = function(filetype)
  local grouplistname = '@' .. string.upper(filetype)
  local syntax_save
  if vim.b.current_syntax then
    syntax_save = vim.b.current_syntax
    vim.b.current_syntax = nil
  end
  vim.cmd('silent! syntax include ' .. grouplistname .. ' syntax/' .. filetype .. '.vim')
  vim.cmd('silent! syntax include ' .. grouplistname .. ' after/syntax/' .. filetype .. '.vim')
  if syntax_save then
    vim.b.current_syntax = syntax_save
  elseif vim.b.current_syntax then
    vim.b.current_syntax = nil
  end
  return grouplistname
end

-- Clear Syntax Variables
--
-- Helper to clear syntax buffer variable.
--
-- @param nil
-- @return nil
local clear_syntax_vars = function()
  if vim.bo.filetype == 'markdown' then
    vim.b.mkd_included_filetypes = nil
  end
end

--------------------------------------------------------------------------------
--                                                                            --
--  Main                                                                      --
--                                                                            --
--------------------------------------------------------------------------------

-- Highlight Sources
--
-- Highlight markdown codeblocks with specified languages. Crawls entire
-- document looking for fenced codeblocks, grabs the specified filetype and
-- defines a syntax region within the buffer.
--
-- @param force: bool of whether to force a full run
-- @return nil
local highlight_sources = function(force)
  -- prep variables
  local known_filetypes
  local included_filetypes
  local filetypes={}

  -- detect filetypes in buffer
  for _, line in ipairs(vim.fn.getline(1, '$')) do
    local ft = string.match(line, '%s*```%s*([%w_+-]*)')
    if ft and not string.match(ft, '^%d*$') then
      filetypes[ft] = 1
    end
  end

  -- pull in previous known and imported filetypes
  if not vim.b.mkd_known_filetypes then
    known_filetypes = {}
  else
    known_filetypes = vim.b.mkd_known_filetypes
  end
  if not vim.b.mkd_included_filetypes then
    included_filetypes = {}
  else
    included_filetypes = vim.b.mkd_included_filetypes
  end

  -- if we know about the filetypes already or if none found return
  if not force and (next(filetypes) == nil or no_new_types(known_filetypes, filetypes)) then
    return
  end

  local startgroup = 'mkdCodeStart'
  local endgroup   = 'mkdCodeEnd'

  -- highlight the code blocks
  for ft, _ in pairs(filetypes) do
    if force or known_filetypes[ft] == nil then
      local filetype = filetype_dict[ft] or ft
      local group = 'mkdSnippet' .. string.gsub(filetype, '[+-]', '_'):upper()
      local include
      if not included_filetypes[filetype] then
        include = syntax_include(filetype)
        included_filetypes[filetype] = 1
        vim.b.mkd_included_filetypes = included_filetypes
      else
        include = '@' .. filetype:upper()
      end
      local command_backtick = 'syntax region %s matchgroup=%s start="^\\s*`\\{3,}\\s*%s.*$" matchgroup=%s end="\\s*`\\{3,}$" keepend contains=%s%s'
      vim.cmd(string.format(command_backtick, group, startgroup, ft, endgroup, include, ' concealends'))
      vim.cmd(string.format('syntax cluster mkdNonListItem add=%s', group))
      known_filetypes[ft] = 1
      vim.b.mkd_known_filetypes = known_filetypes
    end
  end
end

-- Refresh Syntax
--
-- Wrapper for handling conditional calling highlight_sources.
--
-- @param force: bool of whether to force a full run
-- @return nil
local refresh_syntax = function(force)
    if vim.bo.filetype == 'markdown' and vim.fn.line('$') > 1 and vim.bo.syntax ~= 'OFF' then
      highlight_sources(force)
    end
end

--------------------------------------------------------------------------------
--                                                                            --
--  Autocommands                                                              --
--                                                                            --
--------------------------------------------------------------------------------

-- autocommands for markdown codeblock syntax
augroup('BuellMarkdown', function()
  autocmd('BufWinEnter', '<buffer>', function() refresh_syntax(true) end)
  autocmd('BufUnload', '<buffer>', function() clear_syntax_vars() end)
  autocmd('BufWritePost', '<buffer>', function() refresh_syntax(false) end)
  autocmd('InsertEnter,InsertLeave', '<buffer>', function() refresh_syntax(false) end)
  autocmd('CursorHold,CursorHoldI', '<buffer>', function() refresh_syntax(false) end)
end)

--------------------------------------------------------------------------------
--                                                                            --
--  Mappings                                                                  --
--                                                                            --
--------------------------------------------------------------------------------

vim.keymap.set('n', '<C-]>', '<CMD>lua buell.markdown.create_or_follow_link()<CR>', {remap = false, silent = false, buffer = true})
vim.keymap.set('v', '<C-]>', '<CMD>lua buell.markdown.create_or_follow_link()<CR>', {remap = false, silent = false, buffer = true})
