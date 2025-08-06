-- lua/buell/statusline/lsp.lua

local config = require('buell.statusline.config')
local cache = require('buell.statusline.cache')
local utils = require('buell.statusline.utils')

local M = {}

-- Check if buffer has LSP clients
local function has_lsp_clients(bufnr)
  bufnr = bufnr or 0
  return #vim.lsp.get_clients({bufnr = bufnr}) > 0
end

-- Format diagnostic counts
local function format_diagnostics(diagnostics)
  local status_parts = {}
  local only_hint = true
  local some_diagnostics = false

  -- Errors
  if diagnostics.errors and diagnostics.errors > 0 then
    table.insert(status_parts,
      config.symbols.indicator_errors ..
      config.symbols.indicator_separator ..
      diagnostics.errors
    )
    only_hint = false
    some_diagnostics = true
  end

  -- Warnings
  if diagnostics.warnings and diagnostics.warnings > 0 then
    table.insert(status_parts,
      config.symbols.indicator_warnings ..
      config.symbols.indicator_separator ..
      diagnostics.warnings
    )
    only_hint = false
    some_diagnostics = true
  end

  -- Info
  if diagnostics.info and diagnostics.info > 0 then
    table.insert(status_parts,
      config.symbols.indicator_info ..
      config.symbols.indicator_separator ..
      diagnostics.info
    )
    only_hint = false
    some_diagnostics = true
  end

  -- Hints
  if diagnostics.hints and diagnostics.hints > 0 then
    table.insert(status_parts,
      config.symbols.indicator_hint ..
      config.symbols.indicator_separator ..
      diagnostics.hints
    )
    some_diagnostics = true
  end

  return status_parts, only_hint, some_diagnostics
end

-- Format a single LSP message
local function format_message(msg)
  local name = config.aliases[msg.name] or msg.name
  local client_name = '[' .. name .. ']'
  local contents = ''

  -- Handle progress messages
  if msg.progress then
    -- Currently showing spinner only, content commented out as in original
    if msg.spinner then
      contents = config.symbols.spinner_frames[(msg.spinner % #config.symbols.spinner_frames) + 1] .. ' ' .. contents
    end
  -- Handle status messages
  elseif msg.status then
    contents = msg.content
    if msg.uri then
      local filename = vim.uri_to_fname(msg.uri)
      filename = vim.fn.fnamemodify(filename, ':~:.')
      local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))

      if #filename > space then
        filename = vim.fn.pathshorten(filename)
      end

      contents = '(' .. filename .. ') ' .. contents
    end
  -- Handle general messages
  else
    contents = msg.content
  end

  return client_name .. ' ' .. contents
end

-- Format all LSP messages
local function format_messages(messages)
  local msgs = {}

  for _, msg in ipairs(messages) do
    table.insert(msgs, format_message(msg))
  end

  return msgs
end

-- Get comprehensive LSP status
function M.get_status(bufnr)
  bufnr = bufnr or 0

  return cache.get_or_compute('lsp_status_' .. bufnr, function()
    return utils.safe_call(function()
      if not has_lsp_clients(bufnr) then
        return ''
      end

      -- Batch LSP calls to avoid multiple round trips
      local diagnostics, messages

      -- Use pcall for individual LSP calls since they can be unreliable
      local diag_ok, diag_result = pcall(require('lsp-status/diagnostics'), bufnr)
      diagnostics = diag_ok and diag_result or {}

      local msg_ok, msg_result = pcall(require('lsp-status/messaging').messages)
      messages = msg_ok and msg_result or {}

      -- Format components (your original logic preserved)
      local status_parts, only_hint, some_diagnostics = format_diagnostics(diagnostics)
      local msgs = format_messages(messages)

      -- Concatenate diagnostics and messages
      local base_status = vim.trim(
        table.concat(status_parts, ' ') .. ' ' .. table.concat(msgs, ' ')
      )

      -- Create symbol with conditional spacing
      local symbol = config.symbols.lsp_status_symbol .. ' ' ..
        ((some_diagnostics and only_hint) and '' or ' ')

      -- Return formatted status
      if base_status ~= '' then
        return symbol .. base_status .. ' '
      end

      -- Return basic "lsp on" indicator
      return symbol .. config.symbols.indicator_ok .. ' '
    end, '') -- fallback to empty string on any error
  end)
end

-- Get current function name from LSP
function M.get_current_function(bufnr)
  bufnr = bufnr or 0

  if not has_lsp_clients(bufnr) then
    return ''
  end

  return vim.b.lsp_current_function or ''
end

-- Check if buffer has LSP clients (public API)
function M.has_clients(bufnr)
  return has_lsp_clients(bufnr)
end

-- Get just diagnostic counts (useful for other components)
function M.get_diagnostics(bufnr)
  bufnr = bufnr or 0

  if not has_lsp_clients(bufnr) then
    return nil
  end

  return require('lsp-status/diagnostics')(bufnr)
end

-- Get just LSP messages (useful for other components)
function M.get_messages()
  return require('lsp-status/messaging').messages()
end

-- Add cache invalidation on LSP events
local function setup_cache_invalidation()
  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    callback = function(args)
      cache.invalidate('lsp_status_' .. args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    callback = function(args)
      cache.invalidate('lsp_status_' .. args.buf)
    end,
  })
end

-- Initialize cache invalidation when module loads
setup_cache_invalidation()

return M
