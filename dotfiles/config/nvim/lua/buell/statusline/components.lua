-- lua/buell/statusline/components.lua

local config = require('buell.statusline.config')
local lsp = require('buell.statusline.lsp')
local cache = require('buell.statusline.cache')

local M = {}

-- Visual line position indicator
function M.line_position_indicator()
  local indicator = config.line_indicators

  local cur_line = vim.fn.line('.')
  local tot_line = vim.fn.line('$')

  local index
  if cur_line == 1 then
    index = 1
  elseif cur_line == tot_line then
    index = #indicator
  else
    local percentage = cur_line / tot_line
    index = math.floor((percentage * #indicator) + 0.5)
  end

  -- Fix for lua's non-zero indexing
  if index == 0 then
    index = 1
  end

  return indicator[index]
end

-- File path component
function M.file_path()
  local bufnr = vim.api.nvim_get_current_buf()
  return cache.get_or_compute('file_path_' .. bufnr, function()
    local basename = vim.fn.fnamemodify(vim.fn.expand('%:h'), ':p:~:.')

    if basename == '' or basename == '.' then
      return ''
    end

    local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
    local path = basename:gsub('/$', '') .. '/'

    if #path > space then
      path = vim.fn.pathshorten(path)
    end

    return path
  end)
end

-- Session component
function M.session_name()
  if not vim.fn.exists(':Obsession') then
    return nil
  end

  local session = buell.util.split_str(vim.v.this_session, '/')
  local sname = session[#session] or ''

  if #sname > 0 then
    return sname .. ' '
  end

  return nil
end

-- Copilot status indicator
function M.copilot_status()
  -- copilot.vim
  local copilot_client = vim.fn['copilot#Enabled']()
  if copilot_client ~= 0 then
    return config.symbols.copilot_status_symbol
  end

  -- Alternative: copilot.lua (commented out in original)
  -- if require("copilot.client").buf_is_attached(0) == true then
  --   return config.symbols.copilot_status_symbol
  -- end

  return nil
end

-- TreeSitter status indicator
function M.treesitter_status()
  local treesitter = vim.fn['nvim_treesitter#statusline']({1})

  if treesitter ~= vim.NIL then
    return config.symbols.treesitter_status_symbol
  end

  return nil
end

-- File metadata (modified, readonly, filetype, encoding, format)
function M.file_meta()
  local states = {}

  -- Session indicator
  if vim.fn.exists(':Obsession') and vim.v.this_session and #vim.v.this_session > 0 then
    table.insert(states, 'S')
  end

  -- Modified indicator
  if vim.bo.modified then
    table.insert(states, '+')
  end

  -- Read only indicator
  if vim.bo.readonly then
    table.insert(states, 'ro')
  end

  -- File type
  local filetype = vim.bo.filetype
  if #filetype > 0 then
    table.insert(states, filetype)
  end

  -- File encoding
  if vim.bo.fenc and vim.bo.fenc ~= "" then
    table.insert(states, vim.bo.fenc)
  end

  -- File format
  if vim.bo.ff then
    table.insert(states, vim.bo.ff)
  end

  return table.concat(states, ",")
end

-- Left-hand side component (gutter area with LSP/Copilot/TreeSitter)
function M.left_side(bufnr)
  bufnr = bufnr or 0
  return cache.get_or_compute('left_side_' .. bufnr, function()
    local gutter_width = buell.util.gutter_width()
    local treesitter = M.treesitter_status()
    local copilot = M.copilot_status()
    local has_lsp = lsp.has_clients(bufnr)
    local line = ' '

    -- Add copilot indicator
    if copilot then
      line = line .. ' ' .. copilot
    end

    -- Add treesitter and LSP indicators
    if treesitter or has_lsp then
      if treesitter then
        line = line .. ' ' .. treesitter
      end

      if has_lsp then
        line = line .. ' ' .. lsp.get_status()
      end

      -- Pad to gutter width
      local diff = gutter_width - string.len(line) + 2
      if diff > 0 then
        line = line .. string.rep(" ", diff)
      end
    else
      line = line .. string.rep(" ", gutter_width)
    end

    return line
  end)
end

-- Right-hand side component (line/column position)
function M.right_side()
  local line = ' '

  if vim.fn.winwidth(0) > 80 then
    local _, c = unpack(vim.api.nvim_win_get_cursor(0))
    local col_pos = c + 1
    local col_size = vim.fn.strwidth(vim.fn.getline('.'))
    local horiz_pos = col_pos .. '/' .. col_size

    line = table.concat {
      ' ',
      config.symbols.line_indicator,
      ' ',
      M.line_position_indicator(),
      ' ',
      config.symbols.column_indicator,
      ' ',
      horiz_pos,
      ' ',
    }

    -- Add padding to prevent jumping
    local count = 5 - string.len(horiz_pos)
    line = line .. string.rep(' ', count)
  end

  return line
end

-- Word count progress bar (from original wordcountprogress function)
function M.word_count_progress(target_words)
  local targetwords = target_words or 750
  local wordcount = vim.fn.wordcount().words
  local windowwidth = vim.fn.winwidth(0)

  local padding = string.rep(' ', math.floor((wordcount * windowwidth) / targetwords))

  if wordcount >= targetwords then
    return "%#Normal#"
  else
    return table.concat {
      "%#Status7#",
      padding,
      "%#Status4#",
      config.symbols.powerline_left,
    }
  end
end

-- Current function name (delegates to LSP module)
function M.current_function(bufnr)
  return lsp.get_current_function(bufnr)
end

return M
