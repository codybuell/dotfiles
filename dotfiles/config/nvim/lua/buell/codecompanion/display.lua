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

-- Determine CodeCompanion Width
--
-- Dynamically determine the CodeCompanion chat window width based on the
-- current terminal size.
-- NOTE: Codecompanion currently does not support functions for width. Keeping
-- this here for future usage if that becomes available. For now an autocommand
-- defined in after/plugins/codecompanion.nvim.lua is being used to set the
-- split widths appropriately.
local function determine_cc_width()
  local total_cols = vim.o.columns
  local edit_width = total_cols - buell.util.gutter_width()
  local desired_left_width = 80
  return math.max(30, edit_width - desired_left_width - 2)
end

----------------------
--  Action Palette  --
----------------------

M.action_palette = {
  width = 95,
  height = 10,
  prompt = "Prompt ",                   -- prompt used for interactive LLM calls
  provider = "mini_pick",               -- default|telescope|mini_pick
  opts = {
    show_default_actions = true,        -- show the default actions in the action palette?
    show_default_prompt_library = true, -- show the default prompt library in the action palette?
  },
}

---------------------
--  Diff Provider  --
---------------------

M.diff = {
  enabled = true,
  close_chat_at = 240,           -- close an open chat buffer if the total columns of your display are less than...
  layout = "vertical",           -- vertical|horizontal split for default provider
  opts = {
    "internal",
    "filler",
    "closeoff",
    "algorithm:patience",
    "followwrap",
    "linematch:120"
  },
  provider = "mini_diff",        -- default|mini_diff
}

------------
--  Chat  --
------------

M.chat = {
  -- general config options
  intro_message = "",
  show_header_separator = false, -- show header separators? set false if using external markdown formatting plugin
  separator = "─",               -- the separator between the different messages in the chat buffer
  show_references = true,        -- show references (from slash commands and variables) in the chat buffer?
  show_settings = true,          -- show LLM settings at the top of the chat buffer?
  show_token_count = true,       -- show the token count for each response?
  start_in_insert_mode = false,  -- open the chat buffer in insert mode?

  -- default icons
  icons = {
    pinned_buffer = " ",
    watched_buffer = "👀 ",
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
