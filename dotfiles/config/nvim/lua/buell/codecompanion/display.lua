--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Display Configuration                                       --
--                                                                            --
--  This module configures the visual appearance and behavior of              --
--  CodeCompanion's user interface, including:                                --
--    - Action palette: Command and prompt selection interface                --
--    - Chat window: Layout, sizing, and visual elements                      --
--    - Diff display: Code comparison and modification preview                --
--    - Token usage: Progress bars and context window monitoring              --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

----------------------
--  Action Palette  --
----------------------

M.action_palette = {
  width = 95,
  height = 10,
  prompt = "Prompt ",                   -- prompt used for interactive LLM calls
  provider = "mini_pick",               -- default|telescope|mini_pick|snacks|fzf_lua
  opts = {
    show_preset_actions = true,         -- show the builtin actions in the action palette?
    show_preset_prompts = true,         -- show the builtin prompt library in the action palette?
  },
}

------------
--  Diff  --
------------

-- v19 dropped the mini_diff provider and super diff; only the builtin diff
-- remains. Kept disabled to match the previous behavior.
M.diff = {
  enabled = false,
}

------------
--  Chat  --
------------

M.chat = {
  -- general config options
  intro_message = "",
  show_header_separator = false, -- show header separators? set false if using external markdown formatting plugin
  separator = "─",               -- the separator between the different messages in the chat buffer
  show_context = true,           -- show context (from slash commands and editor context) in the chat buffer?
  show_settings = false,         -- show LLM settings at the top of the chat buffer?
  show_token_count = true,       -- show the token count for each response?
  start_in_insert_mode = false,  -- open the chat buffer in insert mode?

  -- default icons (sync_all/sync_diff were pinned_buffer/watched_buffer)
  icons = {
    sync_all =" ",
    sync_diff ="👀 ",
  },

  -- debug window options
  debug_window = {
    ---@return number|fun(): number
    width = vim.o.columns - 5,
    ---@return number|fun(): number
    height = vim.o.lines - 2,
  },

  -- chat buffer options
  window = {
    layout = "vertical",         -- float|vertical|horizontal|buffer
    position = "right",          -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
    border = "single",
    height = 0.8,
    width = 0.45,
    relative = "editor",
    opts = {
      breakindent = true,
      cursorcolumn = false,
      cursorline = false,
      foldcolumn = "0",
      linebreak = true,
      list = false,
      numberwidth = 1,
      signcolumn = "no",
      spell = false,
      wrap = true,
      scrolloff = 4,
    },
  },

  ---token display options
  ---@param tokens number
  ---@param adapter table
  ---@return string
  token_count = function(tokens, adapter)
    -- vim.notify("tokens: " .. vim.inspect(tokens), vim.log.levels.INFO)
    -- vim.notify("adapter: " .. vim.inspect(adapter), vim.log.levels.INFO)
    local total = type(tokens) == "number" and tokens or 0
    local budget = adapter and adapter.schema and adapter.schema.max_tokens
      and adapter.schema.max_tokens.default or 4096
    if type(budget) == "function" then
      budget = budget(adapter)
    end
    if not budget or type(budget) ~= "number" then
      budget = 4096
    end
    if total > budget then
      return string.format(" Estimated tokens (%d) exceed context window (%d)", total, budget)
    end
    local percent = math.min(total / budget, 1)
    local bar_len = 20
    local filled = math.floor(percent * bar_len)
    local empty = bar_len - filled
    local bar = string.rep("█", filled) .. string.rep("░", empty)
    return string.format("%s | %d/%d tokens used", bar, total, budget)
  end,
}

return M
