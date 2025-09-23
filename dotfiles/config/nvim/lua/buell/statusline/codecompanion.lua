-- lua/buell/statusline/codecompanion.lua

local config = require('buell.statusline.config')
local redraw = require('buell.statusline.redraw')

local M = {}

-- Private state management
local state = {
  processing    = false,
  spinner_index = 1,
  adapter       = nil,
  model         = nil,
  token_count   = nil,
  context_count = 0,
  tools_count   = 0,
  status        = 'idle', -- idle, processing, streaming, complete, error, cancelled
  spinner_timer = nil,
  strategy      = nil,
  request_id    = nil,
}

-- Private timer functions
local function start_spinner_timer()
  if state.spinner_timer then
    return
  end

  state.spinner_timer = vim.uv.new_timer()
  state.spinner_timer:start(0, 150, function()
    if state.processing then
      state.spinner_index = (state.spinner_index % #config.symbols.spinner_frames) + 1
      vim.schedule(redraw.smart_redraw)
    end
  end)
end

local function stop_spinner_timer()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
end

-- Add state change notifications
local function notify_state_change()
  vim.api.nvim_exec_autocmds('User', {
    pattern = 'StatuslineCodeCompanionStateChanged',
    data = { status = state.status, adapter = state.adapter }
  })
end

-- Initialize CodeCompanion integration
function M.init()
  local group = vim.api.nvim_create_augroup("CodeCompanionStatuslineHooks", {})

  -- Show adapter/model when entering chat buffer
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionChatOpened",
    group = group,
    callback = function(request)
      local ok, codecompanion = pcall(require, "codecompanion")
      if ok and codecompanion.buf_get_chat then
        local bufnr = request and request.buf or vim.api.nvim_get_current_buf()
        local chat = codecompanion.buf_get_chat(bufnr)
        if chat and chat.adapter then
          state.adapter = chat.adapter.name or chat.adapter.formatted_name

          -- Try parameters first (after request), then fall back to schema default
          local model = nil
          if chat.adapter.parameters and chat.adapter.parameters.model then
            model = chat.adapter.parameters.model
          elseif chat.adapter.schema and chat.adapter.schema.model and chat.adapter.schema.model.default then
            model = chat.adapter.schema.model.default
          end

          if model then
            state.model = model
          else
            state.model = nil
          end

          redraw.smart_redraw() -- Force a redraw
        end
      end
    end,
  })

  -- Handle request lifecycle events
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        state.processing = true
        state.status = 'processing'
        start_spinner_timer()

        if request.data and request.data.adapter then
          state.adapter = request.data.adapter.name or request.data.adapter.formatted_name

          -- Request adapter has model directly, chat adapter has it in schema/parameters
          local model = request.data.adapter.model or
                        (request.data.adapter.parameters and request.data.adapter.parameters.model) or
                        (request.data.adapter.schema and request.data.adapter.schema.model and request.data.adapter.schema.model.default)

          state.model = model
          state.strategy = request.data.strategy
          state.request_id = request.data.id
        end
        notify_state_change()
      elseif request.match == "CodeCompanionRequestStreaming" then
        state.processing = true
        state.status = 'streaming'
        notify_state_change()
      elseif request.match == "CodeCompanionRequestFinished" then
        state.processing = false
        stop_spinner_timer()

        local status = 'idle'
        if request.data then
          if request.data.status == 'success' then
            status = 'complete'
          elseif request.data.status == 'error' then
            status = 'error'
          elseif request.data.status == 'cancelled' then
            status = 'cancelled'
          end
        end
        state.status = status
        notify_state_change()
      elseif request.match == "CodeCompanionRequestError" then
        state.processing = false
        state.status = 'error'
        stop_spinner_timer()
        notify_state_change()
      elseif request.match == "CodeCompanionRequestCancelled" then
        state.processing = false
        state.status = 'cancelled'
        stop_spinner_timer()
        notify_state_change()
      end
    end,
  })

  -- Track chat state changes
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionChat*",
    group = group,
    callback = function(_)
      if vim.bo.filetype == 'codecompanion' then
        -- Reset counts - could be enhanced to parse buffer content
        state.context_count = 0
        state.tools_count = 0
      end
    end,
  })
end

-- Get adapter and model information
function M.get_adapter_info()
  if not state.adapter then
    return nil
  end

  local adapter_display = state.adapter

  if state.model then
    local model = tostring(state.model)
      :gsub("gpt%-4o%-", "4o-")
      :gsub("claude%-3%.5%-", "3.5-")
    adapter_display = adapter_display .. ':' .. model
  end

  -- if state.request_id then
  --   adapter_display = adapter_display .. ' #' .. tostring(state.request_id)
  -- end

  return config.symbols.adapter_symbol .. ' ' .. adapter_display
end

-- Get current processing status
function M.get_status_info()
  if state.status == 'processing' or state.status == 'streaming' then
    local msg = state.status == 'streaming' and ' Streaming' or ' Processing'
    return config.symbols.spinner_frames[state.spinner_index] .. msg
  elseif state.status == 'complete' then
    return config.symbols.complete_symbol .. ' Complete'
  elseif state.status == 'error' then
    return config.symbols.error_symbol .. ' Error'
  elseif state.status == 'cancelled' then
    return '󰜺 Cancelled'
  end

  return nil
end

-- Get context information (tools, context count, etc.)
function M.get_context_info()
  local parts = {}

  if state.tools_count > 0 then
    table.insert(parts, config.symbols.tools_symbol .. state.tools_count)
  end

  if state.context_count > 0 then
    table.insert(parts, config.symbols.context_symbol .. state.context_count)
  end

  return #parts > 0 and table.concat(parts, ' ') or nil
end

-- Public API for checking state
function M.is_processing()
  return state.processing
end

function M.get_status()
  return state.status
end

return M
