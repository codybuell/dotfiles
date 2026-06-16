--------------------------------------------------------------------------------
--                                                                            --
--  Codex Util                                                                --
--                                                                            --
--  Shared helpers for the codex note module. Must remain free of any        --
--  references to _G.buell or templated paths so the module can be           --
--  extracted as a standalone plugin.                                        --
--                                                                            --
--------------------------------------------------------------------------------

local util = {}

-- Create Directories
--
-- Create any missing directories in the path provided.
--
-- @param path: string of desired path
-- @return nil
util.create_directories = function(path)
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

-- Realpath
--
-- Resolve symlinks in a path, falling back to an absolute path if the file
-- does not (yet) exist.
--
-- @param path: string
-- @return string: resolved absolute path
util.realpath = function(path)
  return vim.uv.fs_realpath(path) or vim.fn.fnamemodify(path, ':p'):gsub('/$', '')
end

-- Shorten Path
--
-- Shorten a path to fit within max_width by truncating directory names.
--
-- @param path: string
-- @param max_width: int
-- @return string: shortened path
util.shorten_path = function(path, max_width)
  -- split path into parts
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do
    table.insert(parts, part)
  end

  -- if path is already short enough, return as is
  if #path <= max_width then
    return path
  end

  local filename = parts[#parts]
  local dirs = {}
  for i = 1, #parts - 1 do
    dirs[i] = parts[i]
  end

  -- calculate minimum required length
  local min_length = #filename + #dirs + 1  -- +1 for separators

  -- if we can't fit even the minimum, truncate filename
  if min_length > max_width then
    return string.sub(path, 1, max_width - 1) .. "…"
  end

  -- calculate available space for directories
  local available_space = max_width - #filename - #dirs
  local space_per_dir = math.floor(available_space / #dirs)

  -- ensure minimum of 3 chars (2 chars + "…") per directory
  if space_per_dir < 3 then
    local result = {}
    for i = 1, #dirs do
      table.insert(result, string.sub(dirs[i], 1, 1))
    end
    return table.concat(result, "/") .. "/" .. filename
  end

  -- shorten all directories evenly
  local shortened = {}
  for i = 1, #dirs do
    local dir = dirs[i]
    if #dir > space_per_dir then
      shortened[i] = string.sub(dir, 1, space_per_dir - 1) .. "…"
    else
      shortened[i] = dir
    end
  end

  return table.concat(shortened, "/") .. "/" .. filename
end

-- Popup Geometry
--
-- Compute the bounding box for the chooser (centered in the editor).
--
-- @return table: {width, height, row, col}
util.popup_geometry = function()
  local max_width  = 180
  local max_height = 50

  local editor_width  = vim.o.columns
  local editor_height = vim.o.lines

  local width  = math.min(editor_width - 4, max_width)
  local height = math.min(editor_height - 6, max_height)

  local row = math.floor((editor_height - height) / 2) - 1
  local col = math.floor((editor_width - width) / 2)

  return {
    width  = math.floor(width),
    height = math.floor(height),
    row    = math.max(row, 0),
    col    = math.max(col, 0),
  }
end

return util
