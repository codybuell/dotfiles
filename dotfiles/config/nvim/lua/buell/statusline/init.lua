-- lua/buell/statusline/init.lua

local config = require('buell.statusline.config')
local components = require('buell.statusline.components')
local codecompanion = require('buell.statusline.codecompanion')
local lsp = require('buell.statusline.lsp')
local builders = require('buell.statusline.builders')

local M = {}

-- Initialize all modules
local function init()
  codecompanion.init()
end

-- Main statusline update function
function M.update()
  -- Get all windows and set appropriate statusline for each
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local filetype = vim.bo[bufnr].filetype
    local builder = builders.get_builder_for_filetype(filetype)

    local line
    if type(builder) == 'function' then
      -- Pass buffer number to the evaluation
      line = string.format("%%!luaeval('buell.statusline.build_current(%d)')", bufnr)
    else
      line = builder -- for static strings
    end

    -- Set statusline for this specific window
    vim.api.nvim_win_set_option(winid, 'statusline', line)
  end
end

-- Function to build statusline for current buffer (called by vim)
function M.build_current(bufnr)
  -- Use passed bufnr or fall back to current buffer
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get filetype from the specific buffer
  local filetype = vim.bo[bufnr].filetype
  local builder = builders.get_builder_for_filetype(filetype)

  return builder(bufnr)
end

-- Public API - expose component functions for vim to call
M.components = components
M.builders = builders
M.codecompanion = codecompanion
M.lsp = lsp
M.config = config

-- Legacy API compatibility - expose individual functions at module level
M.cur_func = components.current_function
M.lhs = components.left_side
M.path = components.file_path
M.session = components.session_name
M.rhs = components.right_side
M.meta = components.file_meta
M.wordcountprogress = builders.word_count_progress

-- Legacy statusline builders
M.default = builders.default
M.codecompanion = builders.codecompanion

-- Initialize on module load
init()

return M
