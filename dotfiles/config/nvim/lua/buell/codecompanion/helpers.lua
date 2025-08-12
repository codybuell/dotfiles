--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Helpers and Utilities                                       --
--                                                                            --
--  This module contains utility functions and keymap configurations that    --
--  support the CodeCompanion workflow. It includes:                         --
--    - Smart chat functions: Context-preserving chat interactions           --
--    - Keymap setup: All CodeCompanion-related key bindings                 --
--    - Bug fixes: Workarounds for known issues                              --
--    - Documentation workflow shortcuts: Quick access to common tasks       --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

---------------
--  Helpers  --
---------------

-- Smart Chat Add
--
-- Prevent double code entries when calling CodeCompanionChat Add.
local function smart_chat_add()
  local mode = vim.api.nvim_get_mode().mode
  local chat = require('codecompanion.strategies.chat')
  local cmd = ''

  if mode == 'n' then
    cmd = 'V'
  end

  -- If we have an existing chat append to it, otherwise start a new one
  if chat and chat.last_chat and chat.last_chat() then
    return cmd .. '<CMD>CodeCompanionChat Add<CR>'
  else
    return cmd .. '<CMD>CodeCompanionChat<CR><C-\\><C-n>Go<Esc>o'
  end
end

-- Smart Inline
--
-- Handle <leader>c mapping intelligently based on selection state.
-- No selection: Start with current file context
-- With selection: Use range-based CodeCompanion
local function smart_inline()
  local mode = vim.api.nvim_get_mode().mode

  if mode == 'n' then
    return ':CodeCompanion #{buffer} '
  else
    -- Visual mode - use range selection ('<,'> is automatically added)
    return ":CodeCompanion "
  end
end

-- Setup Keymaps
--
-- Configures all keymaps related to CodeCompanion functionality.
function M.setup_keymaps()
  -- Alias cc to CodeCompanion
  vim.cmd([[cab cc CodeCompanion]])

  -- Mapping to close without killing the session (gq) in plugin/autocommand.lua
  -- Other maps are in normal.lua, eg <Leader>[1-4] to init chat interfaces

  -- Core mappings
  vim.keymap.set({'n', 'v'}, '<C-c>', smart_chat_add, { noremap = true, silent = true, expr = true })
  vim.keymap.set({'n', 'v'}, '<Leader>c', smart_inline, { noremap = true, silent = false, expr = true })
  vim.keymap.set({'n', 'v'}, '<Leader>a', '<CMD>CodeCompanionActions<CR>', { noremap = true, silent = true })

  -- Documentation workflow mappings (check dap for conflicts if you use any of these)
  -- vim.keymap.set("n", "<leader>di", ":CodeCompanion init_docs<cr>", { desc = "Initialize living docs" })
  -- vim.keymap.set("n", "<leader>dr", ":CodeCompanion review_docs<cr>", { desc = "Review documentation" })
  -- vim.keymap.set("n", "<leader>de", ":CodeCompanion expand_docs<cr>", { desc = "Expand documentation" })
  -- vim.keymap.set("n", "<leader>du", ":CodeCompanion update_context<cr>", { desc = "Update context docs" })
  -- vim.keymap.set("n", "<leader>dg", ":CodeCompanion gaps<cr>", { desc = "Detect documentation gaps" })
  -- vim.keymap.set('n', '<leader>dw', '<cmd>CodeCompanionChat<cr>/workspace<cr>', { desc = "Load workspace context" })
  -- vim.keymap.set('n', '<leader>dc', '<cmd>CodeCompanion capture<cr>', { desc = "Capture insight/decision" })

  -- Enhanced send key, overload send key to go back to normal mode then submit
  vim.keymap.set({'i', 'n', 'v'}, '<C-s>', function()
    vim.cmd('stopinsert')
    vim.schedule(function()
      local chat = require('codecompanion.strategies.chat')
      if chat and chat.last_chat then
        chat.last_chat():submit()
      end
    end)
  end, { noremap = true, silent = true })
end

-- Mini Pick Action Menu
--
-- Override the built in mini pick action menu to show strategies and format
-- the output in a more user-friendly way. Also handles picker actions. Also
-- updates the "Open chats ..." action to show the first user message in the
-- chat for easy identification.
--
-- Patches codecompanion/providers/actions/mini_pick.lua.
function M.mini_pick_action_menu()
  local mini_pick_path = "codecompanion.providers.actions.mini_pick"
  local original_provider = require(mini_pick_path)

  -- Store the original picker method
  local original_picker = original_provider.picker

  -- Override the picker method
  original_provider.picker = function(self, items, opts)
    opts = opts or {}
    local MiniPick = require("mini.pick")

    -- Store provider reference (this is important!)
    local provider = self

    -- Calculate column widths
    local max_name_width = 0
    local max_strategy_width = 0

    for _, item in ipairs(items) do
      max_name_width = math.max(max_name_width, #item.name)
      local strategy = item.strategy or ""
      max_strategy_width = math.max(max_strategy_width, #strategy)
    end

    max_name_width = max_name_width + 2
    max_strategy_width = math.max(max_strategy_width + 2, 8)

    -- Format items
    local picker_items = {}
    for _, item in ipairs(items) do
      local name = string.format("%-" .. max_name_width .. "s", item.name)
      local strategy = string.format("%-" .. max_strategy_width .. "s", item.strategy or "")
      local description = item.description or ""

      table.insert(picker_items, {
        text = string.format("%s│ %s│ %s", name, strategy, description),
        item = item,
      })
    end

    local source = {
      items = picker_items,
      name = opts.prompt or "CodeCompanion actions",
      choose = function(chosen_item)
        if chosen_item and chosen_item.item then
          -- Get the target window before closing the picker
          local win_target = MiniPick.get_picker_state().windows.target
          if not vim.api.nvim_win_is_valid(win_target) then
            win_target = vim.api.nvim_get_current_win()
          end

          -- Handle picker actions (like "Open chats ...")
          if chosen_item.item.picker then
            local picker_items = {}
            local items = chosen_item.item.picker.items()

            for i, picker_item in ipairs(items) do
              -- Get adapter info and chat preview
              local adapter_info = ""
              local chat_preview = "[No messages]" -- Default fallback

              if picker_item.bufnr then
                local success, chat_data = pcall(function()
                  local codecompanion = require("codecompanion")
                  local chats = codecompanion.buf_get_chat()
                  for _, chat in ipairs(chats) do
                    if chat.chat.bufnr == picker_item.bufnr then
                      local adapter = chat.chat.adapter
                      if adapter then
                        local adapter_name = adapter.name or adapter.formatted_name or "unknown"

                        -- Handle different model storage formats
                        local model_name = "unknown"
                        if type(adapter.model) == "string" then
                          model_name = adapter.model
                        elseif type(adapter.model) == "table" then
                          -- Try different possible model name locations
                          model_name = adapter.model.name
                            or adapter.model.default
                            or adapter.model.model
                            or (adapter.schema and adapter.schema.model and adapter.schema.model.default)
                            or "table"
                        elseif adapter.schema and adapter.schema.model then
                          local schema_model = adapter.schema.model.default
                          if type(schema_model) == "function" then
                            schema_model = schema_model(adapter)
                          end
                          model_name = schema_model or "unknown"
                        end

                        -- Shorten common model names for cleaner display
                        model_name = string.gsub(model_name, "^gpt%-4o%-2024%-08%-06$", "gpt-4o")
                        model_name = string.gsub(model_name, "^claude%-3%-5%-sonnet%-20241022$", "sonnet")
                        model_name = string.gsub(model_name, "^claude%-3%-5%-sonnet$", "sonnet")

                        -- NEW: Extract first user message for preview
                        if chat.chat.messages and #chat.chat.messages > 0 then
                          -- Look for first user message that's not empty
                          for _, message in ipairs(chat.chat.messages) do
                            if message.role == "user" and message.content and
                               message.content ~= "" and not message.content:match("^%s*$") then
                              -- Truncate and clean the message
                              local content = message.content:gsub("\n", " "):gsub("%s+", " ")
                              chat_preview = content:len() > 50 and (content:sub(1, 47) .. "...") or content
                              break
                            end
                          end
                        end

                        return {
                          adapter_info = string.format("[%s/%s]", adapter_name, model_name),
                          preview = chat_preview
                        }
                      end
                    end
                  end
                  return { adapter_info = "[unknown/unknown]", preview = "[No messages]" }
                end)

                if success and chat_data then
                  adapter_info = chat_data.adapter_info
                  chat_preview = chat_data.preview
                else
                  adapter_info = "[unknown/unknown]"
                end
              else
                adapter_info = "[no-adapter]"
              end

              -- Format: "01. [adapter/model] Preview of first message"
              local formatted_text = string.format("%02d. %s %s", i, adapter_info, chat_preview)

              table.insert(picker_items, {
                text = formatted_text,
                item = picker_item,
              })
            end

            local nested_source = {
              items = picker_items,
              name = chosen_item.item.picker.prompt or chosen_item.item.name,
              choose = function(nested_chosen_item)
                if nested_chosen_item and nested_chosen_item.item and nested_chosen_item.item.callback then
                  nested_chosen_item.item.callback()
                end
                return false -- Close picker
              end,
              show = function(buf_id, items_to_show, query)
                MiniPick.default_show(buf_id, items_to_show, query)
              end,
            }

            MiniPick.start({
              source = nested_source,
              window = {
                config = function()
                  local height = math.floor(0.4 * vim.o.lines) -- Smaller height for chat list
                  local width = math.floor(0.7 * vim.o.columns)
                  return {
                    border = "rounded",
                    anchor = "NW",
                    height = height,
                    width = width,
                    row = math.floor(0.5 * (vim.o.lines - height)),
                    col = math.floor(0.5 * (vim.o.columns - width)),
                  }
                end,
              },
            })
            return false -- Close current picker
          end

          -- Handle normal actions through the original select method
          vim.api.nvim_win_call(win_target, function()
            provider:select(chosen_item.item)
            MiniPick.set_picker_target_window(vim.api.nvim_get_current_win())
          end)
          return false -- Close picker after selection
        end
      end,
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query)
      end,
    }

    local pick_opts = {
      window = {
        config = function()
          local height = math.floor(0.618 * vim.o.lines)
          local width = math.floor(0.8 * vim.o.columns) -- Wider for formatted display
          return {
            border = "rounded",
            anchor = "NW",
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end,
      },
    }

    MiniPick.start({
      source = source,
      options = pick_opts,
    })
  end
end

return M
