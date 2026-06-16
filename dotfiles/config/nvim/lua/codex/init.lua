--------------------------------------------------------------------------------
--                                                                            --
--  Codex                                                                     --
--                                                                            --
--  Corpus-style note module: split chooser (filtered list + live preview)    --
--  with unified search across filename, frontmatter title/tags, and file     --
--  contents, plus note/journal creation and wiki-style link handling.        --
--                                                                            --
--  Query syntax (tokens AND together):                                       --
--    plain   fuzzy match against filename and frontmatter title              --
--    #tag    frontmatter tag/category filter (prefix match)                  --
--    *term   file content match (ripgrep)                                    --
--                                                                            --
--  All paths come in through setup(); no templated or hardcoded paths so     --
--  the module can be extracted as a standalone plugin.                       --
--                                                                            --
--------------------------------------------------------------------------------

local codex = {}

codex.config = {
  notes     = nil,    -- absolute path to notes root, required
  journal   = nil,    -- absolute path to journal root, defaults to notes/Journal
  wikis     = {},     -- wiki name -> absolute path, used by link handling
  ignore    = {},     -- rg glob patterns to exclude from the index
  extension = '.md',
}

-- Setup
--
-- Merge user config, wire the incremental index autocmd, and define user
-- commands.
--
-- @param opts: table
-- @return nil
codex.setup = function(opts)
  local util = require('codex.util')

  codex.config = vim.tbl_extend('force', codex.config, opts or {})

  if not codex.config.notes then
    vim.notify('codex: setup requires a notes path', vim.log.levels.ERROR)
    return
  end

  codex.config.notes = vim.fn.fnamemodify(codex.config.notes, ':p'):gsub('/$', '')
  if codex.config.journal then
    codex.config.journal = vim.fn.fnamemodify(codex.config.journal, ':p'):gsub('/$', '')
  else
    codex.config.journal = codex.config.notes .. '/Journal'
  end

  -- re-index saved notes
  local augroup = vim.api.nvim_create_augroup('CodexIndex', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group    = augroup,
    pattern  = '*' .. codex.config.extension,
    callback = function(ev)
      local index = require('codex.index')
      if index.is_built() then
        index.update_file(codex.config, util.realpath(ev.match))
      end
    end,
  })

  -- user commands
  vim.api.nvim_create_user_command('Codex', codex.open, {})
  vim.api.nvim_create_user_command('CodexIndex', codex.rebuild_index, {})
end

-- Open
--
-- Open the chooser.
--
-- @return nil
codex.open = function()
  require('codex.ui').open(codex.config)
end

-- Rebuild Index
--
-- Force a full index rebuild.
--
-- @return nil
codex.rebuild_index = function()
  require('codex.index').build(codex.config, { force = true })
  vim.notify('codex: index rebuilt (' .. #require('codex.index').get(codex.config) .. ' notes)')
end

-- New Note
--
-- Create or open a note. Prompts for a name when none is given. Subdirectory
-- paths are allowed and created as needed. Empty files get a frontmatter
-- stub.
--
-- @param name: string|nil, note name relative to the notes root
-- @param opts: table|nil, { tags = array of strings }
-- @return nil
codex.new_note = function(name, opts)
  opts = opts or {}

  if name == nil or name == '' then
    vim.fn.inputsave()
    name = vim.fn.input('Note name: ')
    vim.fn.inputrestore()
  end

  if name == '' then
    return
  end

  -- append an extension if needed
  if not name:match('%.[%C%X]') then
    name = name .. codex.config.extension
  end

  local full = codex.config.notes .. '/' .. name

  -- make directories if needed
  require('codex.util').create_directories(vim.fn.fnamemodify(full, ':h'))

  -- open the file
  vim.cmd('edit ' .. vim.fn.fnameescape(full))

  -- stub out template if needed
  if vim.fn.getfsize(vim.fn.expand(full)) <= 0 then
    local title = vim.fn.fnamemodify(full, ':t:r')
    local lines = require('codex.templates').note(title, opts.tags)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd(#lines .. ' | startinsert!')
  end
end

-- New Journal
--
-- Create or open a journal entry for today plus an optional day offset.
--
-- @param offset: int|nil, days from today (vim.v.count from the mapping)
-- @return nil
codex.new_journal = function(offset)
  local date = os.time()
  if offset then
    date = date + (offset * 24 * 60 * 60)
  end

  local year  = os.date('%Y', date)
  local month = os.date('%m', date)
  local day   = os.date('%d', date)
  local path  = codex.config.journal .. '/' .. year .. '/' .. month
  local full  = path .. '/' .. year .. '.' .. month .. '.' .. day .. '.md'

  -- make directories if needed
  require('codex.util').create_directories(path)

  -- edit the file
  vim.cmd('edit ' .. vim.fn.fnameescape(full))

  -- stub out template if needed
  if vim.fn.getfsize(vim.fn.expand(full)) <= 0 then
    local lines = require('codex.templates').journal(year, month, day)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd(#lines .. ' | startinsert!')
  end
end

return codex
