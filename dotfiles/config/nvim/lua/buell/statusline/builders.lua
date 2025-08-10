-- lua/buell/statusline/builders.lua

local config = require('buell.statusline.config')
local components = require('buell.statusline.components')
local codecompanion = require('buell.statusline.codecompanion')

local M = {}

-- Default statusline layout
function M.default(bufnr)
  bufnr = bufnr or 0
  return table.concat {
    "%#" .. config.highlights.lhs .. "#",                -- switch to Status7 highlight group
    string.format("%%{v:lua.buell.statusline.components.left_side(%d)}", bufnr), -- render statusline left hand side
    "%#" .. config.highlights.arrow_left .. "#",         -- switch to Status4 highlight group
    config.symbols.powerline_left,                       -- powerline arrow
    "%#" .. config.highlights.main .. "#",               -- switch to Status2 highlight group
    " ",                                                 -- space
    "%<",                                                -- truncation point if not wide enough
    "%{v:lua.buell.statusline.components.file_path()}",  -- relative path to file's directory
    "%#" .. config.highlights.main_bold .. "#",          -- switch to Status3 highlight group
    "%t",                                                -- filename
    " ",                                                 -- space
    "%#" .. config.highlights.meta .. "#",               -- switch to Status1 highlight group
    "%(",                                                -- start item group
    "[",                                                 -- left bracket literal
    "%{v:lua.buell.statusline.components.file_meta()}",  -- modified, ro, type, encoding, format
    "]",                                                 -- right bracket literal
    "%)",                                                -- end item group
    "%#" .. config.highlights.main .. "#",               -- switch to Status2 highlight group
    "%=",                                                -- split point for left and right groups
    " ",                                                 -- space
    string.format("%%{v:lua.buell.statusline.components.current_function(%d)}", bufnr), -- current function under cursor
    " ",                                                 -- space
    "%#" .. config.highlights.meta .. "#",               -- switch to Status1 highlight group
    config.symbols.powerline_right,                      -- powerline arrow
    "%#" .. config.highlights.rhs .. "#",                -- switch to Status5 highlight group
    "%{v:lua.buell.statusline.components.right_side()}", -- call rhs statusline autocommand
  }
end

-- CodeCompanion-specific statusline
function M.codecompanion(bufnr)
  bufnr = bufnr or 0
  local adapter_info = codecompanion.get_adapter_info()
  local status_info = codecompanion.get_status_info()
  local context_info = codecompanion.get_context_info()

  return table.concat {
    "%#" .. config.highlights.lhs .. "#",                -- switch to Status7 highlight group
    string.format("%%{v:lua.buell.statusline.components.left_side(%d)}", bufnr), -- render statusline left hand side
    "%#" .. config.highlights.arrow_left .. "#",         -- switch to Status4 highlight group
    config.symbols.powerline_left,                       -- powerline arrow
    "%#" .. config.highlights.main .. "#",               -- switch to Status2 highlight group
    " CodeCompanion ",                                   -- buffer type indicator
    "%#" .. config.highlights.main_bold .. "#",          -- switch to Status3 highlight group
    adapter_info and (adapter_info .. " ") or "",        -- adapter and model info
    "%<",                                                -- truncation point
    "%=",                                                -- split point for left and right groups
    "%#" .. config.highlights.main .. "#",               -- switch to Status2 highlight group
    context_info and (context_info .. " ") or "",        -- context and tools info
    status_info and (status_info .. " ") or "",          -- processing status
    "%#" .. config.highlights.meta .. "#",               -- switch to Status1 highlight group
    config.symbols.powerline_right,                      -- powerline arrow
    "%#" .. config.highlights.rhs .. "#",                -- switch to Status5 highlight group
    "%{v:lua.buell.statusline.components.right_side()}", -- call rhs statusline autocommand
  }
end

-- Fugitive (git) buffer statusline
function M.fugitive(_)
  return table.concat {
    string.rep(' ', buell.util.gutter_width()),
    ' ',
    '%<',
    '%q',
    ' ',
    '[fugitive]',
    '%=',
  }
end

-- Quickfix buffer statusline
function M.quickfix(_)
  return table.concat {
    string.rep(' ', buell.util.gutter_width()),
    ' ',
    ' ',
    '%<',
    '%q',
    ' ',
    '%{get(w:,"quickfix_title","")}',
    '%=',
  }
end

-- DAP UI buffer statusline
function M.dapui(window_name)
  return table.concat {
    '  [',
    window_name,
    ']',
  }
end

-- DAP REPL buffer statusline
function M.dap_repl(_)
  return '  [repl]'
end

-- Word count progress bar
function M.word_count_progress(target_words)
  return components.word_count_progress(target_words)
end

-- Minimal statusline (empty)
function M.minimal(_)
  return ''
end

-- Helper function to determine which builder to use based on filetype
function M.get_builder_for_filetype(filetype)
  if filetype == 'codecompanion' then
    return M.codecompanion
  elseif filetype == 'diff' then
    return M.minimal
  elseif filetype == 'fugitive' then
    return M.fugitive
  elseif filetype == 'qf' then
    return M.quickfix
  elseif filetype == 'dap-repl' then
    return M.dap_repl
  elseif buell.util.has_value({'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches', 'dapui_console'}, filetype) then
    local winname = filetype:sub(7, -1)
    return function(_) return M.dapui(winname) end
  else
    return M.default
  end
end

-- Build statusline string based on current buffer
function M.build_for_current_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local builder = M.get_builder_for_filetype(filetype)
  return builder(bufnr)
end

return M
