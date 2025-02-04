--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Pick                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pick.md   --
--                                                                            --
--------------------------------------------------------------------------------

local has_minipick, minipick = pcall(require, 'mini.pick')
if has_minipick then

  ---------------
  --  Helpers  --
  ---------------

  local function popup_window_size()
    local max_width  = 150
    local max_height = 60

    -- get the editor window size
    local editor_width  = vim.o.columns
    local editor_height = vim.o.lines

    -- set horizontal padding based on window size
    local width_padding = math.max(0, 25 - math.max(0, 150 - editor_width) / 6)

    -- set the window size
    local width  = math.min(editor_width - (2 * width_padding), max_width)
    local height = math.min(editor_height - 10, max_height)

    -- determine margins
    local row = math.floor((editor_height - height) / 2)
    local col = math.floor((editor_width - width) / 2)

    -- ensure width and height are integers
    width = math.floor(width)
    height = math.floor(height)

    return {
      width  = width,
      height = height,
      row    = row - 2,
      col    = col
    }
  end

  local function shorten_path(path, max_width)
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
      -- Super short version
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

  -- custom function to show items in the picker
  -- TODO: add support for icons
  -- TODO: add support for highlighting matches
  local function custom_show(buf_id, items, query)
    local window = popup_window_size()
    local max_width = window.width

    local lines = vim.tbl_map(function(item)
      return shorten_path(item, max_width)
    end, items)
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  end

  -- helper to center the picker window
  local function get_centered_window_config()
    local window = popup_window_size()

    return {
      relative = 'editor',
      row      = window.row,
      col      = window.col,
      width    = window.width,
      height   = window.height,
      anchor   = 'NW',
      style    = 'minimal'
    }
  end

  -------------
  --  Setup  --
  -------------

  minipick.setup({
    source = {
      show = custom_show
    },
    window = {
      config = get_centered_window_config
    }
  })

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>t', '<CMD>Pick files<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>T', '<CMD>Pick grep_live tool="rg"<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>h', '<CMD>Pick help<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>b', '<CMD>Pick buffers<CR>', { remap = true, silent = true })

  -- pick files from the current buffers directory
  vim.keymap.set('n', '<Leader>.', function()
    local buf_dir = vim.fn.expand('%:p:h')
    minipick.builtin.files({}, { source = { cwd = buf_dir } })
  end, { silent = true })

  -- ripgrep files from the current buffers directory
  vim.keymap.set('n', '<Leader>>', function()
    local buf_dir = vim.fn.expand('%:p:h')
    minipick.builtin.grep_live({ tool = 'rg' }, { source = { cwd = buf_dir } })
  end, { silent = true })

  -- pick files from notes directory
  vim.keymap.set('n', '<Leader>n', function()
    local notes_dir = vim.fn.fnamemodify('{{ Notes }}', ':p')
    minipick.builtin.files({}, { source = { cwd = notes_dir } })
  end, { silent = true })

  -- ripgrep files from notes directory
  vim.keymap.set('n', '<Leader>N', function()
    local notes_dir = vim.fn.fnamemodify('{{ Notes }}', ':p')
    minipick.builtin.grep_live({ tool = 'rg' }, { source = { cwd = notes_dir } })
  end, { silent = true })

  --------------
  --  Colors  --
  --------------

  local pinnacle = require('wincent.pinnacle')

  vim.cmd("highlight! link MiniPickMatchCurrent Directory")
  vim.cmd("highlight! link MiniPickBorder PmenuDarker")
  pinnacle.set('MiniPickBorderBusy', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})
  pinnacle.set('MiniPickBorderText', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})
  pinnacle.set('MiniPickPrompt', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})

end
