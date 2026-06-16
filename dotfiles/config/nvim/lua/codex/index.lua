--------------------------------------------------------------------------------
--                                                                            --
--  Codex Index                                                               --
--                                                                            --
--  In-memory index of all notes: path, title, tags, mtime. Built with two   --
--  ripgrep invocations (file list + frontmatter lines), refreshed cheaply    --
--  on subsequent opens, and updated incrementally on BufWritePost.           --
--                                                                            --
--------------------------------------------------------------------------------

local util = require('codex.util')

local index = {}

-- module state
local state = {
  built   = false,
  root    = nil,   -- realpath of notes root used for rel computation
  notes   = {},    -- array of records
  by_path = {},    -- path -> record (same table refs as notes)
}

-- record = {
--   path  = '/Users/x/Codex/Topics/jhanas/jhanas.md',
--   rel   = 'Topics/jhanas/jhanas.md',
--   name  = 'jhanas',
--   title = 'Jhanas',           -- frontmatter title, falls back to name
--   tags  = { buddhism = true } -- lowercased set, categories merged in
--   mtime = 1749600000.123,
-- }

---------------
--  Helpers  --
---------------

-- Normalize Tag
--
-- Tags may contain spaces ('weed thoughts'); internal whitespace becomes a
-- hyphen so they remain matchable by whitespace-delimited query tokens
-- ('#weed-thoughts', or '#weed' via prefix match).
--
-- @param tag: string
-- @return string|nil: normalized tag, nil when empty
local function normalize_tag(tag)
  tag = tag:gsub('^%s+', ''):gsub('%s+$', ''):gsub('%s+', '-'):lower()
  if tag == '' then
    return nil
  end
  return tag
end

-- Parse Tag Value
--
-- Parse an inline frontmatter tag value into the provided set. Handles
-- [a, b] and comma separated forms; tags themselves may contain spaces.
--
-- @param value: string after 'tags:' or 'categories:'
-- @param tags: table, set to populate
-- @return nil
local function parse_tag_value(value, tags)
  value = value:gsub('[%[%]]', '')
  for tag in value:gmatch('[^,]+') do
    local normalized = normalize_tag(tag)
    if normalized then
      tags[normalized] = true
    end
  end
end

-- Parse Frontmatter
--
-- Parse title and tags out of a frontmatter block given the head lines of a
-- file. Frontmatter is only recognized when line 1 is '---'. Supports inline
-- tag forms as well as yaml block lists.
--
-- @param lines: array of strings (head of file)
-- @return string|nil: title
-- @return table: tags set
local function parse_frontmatter(lines)
  local title = nil
  local tags  = {}

  if lines[1] == nil or not lines[1]:match('^---%s*$') then
    return title, tags
  end

  local in_list = false
  for i = 2, #lines do
    local line = lines[i]
    if line:match('^---%s*$') then
      break
    end

    local key, value = line:match('^(%w+):%s*(.-)%s*$')
    if key then
      in_list = false
      if key == 'title' then
        title = value ~= '' and value or nil
      elseif key == 'tags' or key == 'categories' then
        if value ~= '' then
          parse_tag_value(value, tags)
        else
          in_list = true
        end
      end
    elseif in_list then
      local item = line:match('^%s*-%s+(.+)%s*$')
      if item then
        local normalized = normalize_tag(item)
        if normalized then
          tags[normalized] = true
        end
      else
        in_list = false
      end
    end
  end

  return title, tags
end

-- Make Record
--
-- Build an index record for a path, optionally with pre-parsed frontmatter.
--
-- @param path: string, absolute path under state.root
-- @param title: string|nil
-- @param tags: table|nil
-- @return table|nil: record, nil if the file does not exist
local function make_record(path, title, tags)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end

  local rel  = path:sub(#state.root + 2)
  local name = vim.fn.fnamemodify(path, ':t:r')

  return {
    path  = path,
    rel   = rel,
    name  = name,
    title = title or name,
    tags  = tags or {},
    mtime = stat.mtime.sec + stat.mtime.nsec * 1e-9,
  }
end

-- Parse File
--
-- Read the head of a file and parse its frontmatter.
--
-- @param path: string
-- @return string|nil: title
-- @return table: tags set
local function parse_file(path)
  local ok, lines = pcall(vim.fn.readfile, path, '', 60)
  if not ok then
    return nil, {}
  end
  return parse_frontmatter(lines)
end

-- Build Rg Args
--
-- Common ripgrep arguments honoring the configured ignore globs.
--
-- @param config: codex config table
-- @return table: argument list
local function rg_globs(config)
  local args = { '--glob', '*' .. config.extension, '--no-ignore-vcs', '--no-messages', '--follow' }
  for _, pattern in ipairs(config.ignore or {}) do
    table.insert(args, '--glob')
    table.insert(args, '!' .. pattern)
  end
  return args
end

-- List Files
--
-- Run `rg --files` over the notes root.
--
-- @param config: codex config table
-- @return table: array of absolute paths
local function list_files(config)
  local cmd = { 'rg', '--files' }
  vim.list_extend(cmd, rg_globs(config))
  table.insert(cmd, state.root)

  local result = vim.system(cmd, { text = true }):wait()
  local paths = {}
  for line in (result.stdout or ''):gmatch('[^\n]+') do
    table.insert(paths, line)
  end
  return paths
end

-- Scan Frontmatter
--
-- Run a single ripgrep over the notes root collecting frontmatter-relevant
-- lines, then reduce them per file with a small state machine. Only inline
-- tag forms are captured here; block lists are picked up by the per-file
-- parse path (update_file / refresh).
--
-- @param config: codex config table
-- @return table: path -> { title = string|nil, tags = set }
local function scan_frontmatter(config)
  local cmd = { 'rg', '--no-heading', '--with-filename', '--line-number' }
  vim.list_extend(cmd, rg_globs(config))
  table.insert(cmd, '^(---\\s*$|title:|tags:|categories:|\\s*- )')
  table.insert(cmd, state.root)

  local result = vim.system(cmd, { text = true }):wait()

  -- group matched lines per file, in order
  local by_file = {}
  for line in (result.stdout or ''):gmatch('[^\n]+') do
    local path, lnum, text = line:match('^(.-' .. vim.pesc(config.extension) .. '):(%d+):(.*)$')
    if path then
      by_file[path] = by_file[path] or {}
      table.insert(by_file[path], { lnum = tonumber(lnum), text = text })
    end
  end

  -- reduce to title/tags per file, only honoring lines inside a frontmatter
  -- block opened by '---' on line 1 and closed by the next '---'
  local parsed = {}
  for path, entries in pairs(by_file) do
    local title  = nil
    local tags   = {}
    local opened = entries[1] and entries[1].lnum == 1 and entries[1].text:match('^---%s*$')

    if opened then
      -- yaml block-list items ('- tag') only count when contiguous with a
      -- bare tags:/categories: line; lnum tracking enforces that since rg
      -- output omits the non-matching lines in between
      local list_lnum = nil
      for i = 2, #entries do
        local lnum, text = entries[i].lnum, entries[i].text
        if text:match('^---%s*$') then
          break
        end
        local key, value = text:match('^(%w+):%s*(.-)%s*$')
        if key == 'title' then
          title = value ~= '' and value or nil
          list_lnum = nil
        elseif key == 'tags' or key == 'categories' then
          if value ~= '' then
            parse_tag_value(value, tags)
            list_lnum = nil
          else
            list_lnum = lnum + 1
          end
        else
          local item = text:match('^%s*-%s+(.+)%s*$')
          if item and list_lnum == lnum then
            local normalized = normalize_tag(item)
            if normalized then
              tags[normalized] = true
            end
            list_lnum = lnum + 1
          else
            list_lnum = nil
          end
        end
      end
    end

    parsed[path] = { title = title, tags = tags }
  end

  return parsed
end

-- Insert Record
--
-- Add or replace a record in module state.
--
-- @param record: table
-- @return nil
local function insert_record(record)
  local existing = state.by_path[record.path]
  if existing then
    for i, r in ipairs(state.notes) do
      if r.path == record.path then
        state.notes[i] = record
        break
      end
    end
  else
    table.insert(state.notes, record)
  end
  state.by_path[record.path] = record
end

------------
--  Main  --
------------

-- Build
--
-- Full index build (two rg passes) or, when already built and not forced, a
-- cheap refresh: re-list files, drop removed paths, and re-parse only new or
-- mtime-changed files.
--
-- @param config: codex config table
-- @param opts: table|nil, { force = bool }
-- @return nil
index.build = function(config, opts)
  opts = opts or {}
  state.root = util.realpath(config.notes)

  if state.built and not opts.force then
    -- cheap refresh
    local paths = list_files(config)
    local seen  = {}
    for _, path in ipairs(paths) do
      seen[path] = true
      local existing = state.by_path[path]
      local stat = vim.uv.fs_stat(path)
      local mtime = stat and (stat.mtime.sec + stat.mtime.nsec * 1e-9) or 0
      if not existing or existing.mtime ~= mtime then
        local title, tags = parse_file(path)
        local record = make_record(path, title, tags)
        if record then
          insert_record(record)
        end
      end
    end

    -- drop removed files
    for i = #state.notes, 1, -1 do
      local record = state.notes[i]
      if not seen[record.path] then
        state.by_path[record.path] = nil
        table.remove(state.notes, i)
      end
    end
    return
  end

  -- full build
  state.notes   = {}
  state.by_path = {}

  local paths       = list_files(config)
  local frontmatter = scan_frontmatter(config)

  for _, path in ipairs(paths) do
    local fm = frontmatter[path] or {}
    local record = make_record(path, fm.title, fm.tags)
    if record then
      table.insert(state.notes, record)
      state.by_path[path] = record
    end
  end

  state.built = true
end

-- Update File
--
-- Re-parse a single file (BufWritePost hook). Accepts paths inside the notes
-- root in either symlinked or resolved form.
--
-- @param config: codex config table
-- @param path: string, absolute path
-- @return nil
index.update_file = function(config, path)
  if not state.built then
    return
  end

  -- normalize to an index key under state.root
  if not vim.startswith(path, state.root .. '/') then
    local real = vim.uv.fs_realpath(path)
    if real and vim.startswith(real, state.root .. '/') then
      path = real
    else
      return
    end
  end

  local title, tags = parse_file(path)
  local record = make_record(path, title, tags)
  if record then
    insert_record(record)
  else
    index.remove_file(path)
  end
end

-- Remove File
--
-- Drop a path from the index.
--
-- @param path: string
-- @return nil
index.remove_file = function(path)
  if not state.by_path[path] then
    return
  end
  state.by_path[path] = nil
  for i, record in ipairs(state.notes) do
    if record.path == path then
      table.remove(state.notes, i)
      break
    end
  end
end

-- Get
--
-- Return all records, building the index on first call.
--
-- @param config: codex config table
-- @return table: array of records
index.get = function(config)
  if not state.built then
    index.build(config)
  end
  return state.notes
end

-- Is Built
--
-- @return bool
index.is_built = function()
  return state.built
end

return index
