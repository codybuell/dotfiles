--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion                                                             --
--                                                                            --
--  https://codecompanion.olimorris.dev/                                      --
--  https://github.com/olimorris/codecompanion.nvim                           --
--                                                                            --
--------------------------------------------------------------------------------

local has_codecompanion, codecompanion = pcall(require, 'codecompanion')
if has_codecompanion then

  ---------------
  --  Helpers  --
  ---------------

  -- smart chat add
  --
  -- Prevent double code entries when calling CodeCompanionChat Add
  local function smart_chat_add()
    local mode = vim.api.nvim_get_mode().mode
    local chat = require('codecompanion.strategies.chat')
    local cmd  = ''

    if mode == 'n' then
      cmd = 'V'
    end

    if chat and chat.last_chat and chat.last_chat() then
      return cmd .. '<CMD>CodeCompanionChat Add<CR>'
    else
      return cmd .. '<CMD>CodeCompanionChat<CR><CR><CR>'
    end
  end

  ---------------------
  --  Configuration  --
  ---------------------

  -- alias cc to CodeCompanion
  vim.cmd([[cab cc CodeCompanion]])

  -- plugin level configuration
  local config = {
    strategies = {
      inline = {
        adapter = "copilot",
      },
      chat = {
        adapter = "copilot",
        roles = {
          ---@type string|fun(adapter: CodeCompanion.Adapter): string
          llm = function(adapter)
            return "CodeCompanion (" .. adapter.formatted_name .. ")"
          end,
          ---@type string
          user = "Me",
        },
        keymaps = {
          send = {
            modes = { n = "<Localleader>s", i = "<Localleader>s" },
          },
          close = {
            modes = { n = "<Localleader>q", i = "<C-c>" },
          },
        },
        slash_commands = {
          ["buffer"] = {
            opts = {
              provider = "mini_pick",
            },
          },
          ["help"] = {
            opts = {
              provider = "mini_pick",
            },
          },
          ["file"] = {
            opts = {
              provider = "mini_pick",
            },
          },
          ["symbolos"] = {
            opts = {
              provider = "mini_pick",
            },
          },
        },
      },
    },
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",                   -- prompt used for interactive LLM calls
        provider = "mini_pick",               -- default|telescope|mini_pick
        opts = {
          show_default_actions = true,        -- show the default actions in the action palette?
          show_default_prompt_library = true, -- show the default prompt library in the action palette?
        },
      },
      chat = {
        -- general config options
        intro_message = "",
        show_header_separator = false, -- show header separators? set false if using external markdown formatting plugin
        separator = "─",               -- the separator between the different messages in the chat buffer
        show_references = true,        -- show references (from slash commands and variables) in the chat buffer?
        show_settings = true,          -- show LLM settings at the top of the chat buffer?
        show_token_count = true,       -- show the token count for each response?
        start_in_insert_mode = true,   -- open the chat buffer in insert mode?

        -- diff provider options
        diff = {
          enabled = true,
          close_chat_at = 240,         -- close an open chat buffer if the total columns of your display are less than...
          layout = "vertical",         -- vertical|horizontal split for default provider
          opts = {
            "internal",
            "filler",
            "closeoff",
            "algorithm:patience",
            "followwrap",
            "linematch:120"
          },
          provider = "default",        -- default|mini_diff
        },

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
          position = nil,              -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
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
          },
        },

        ---token display opttions
        ---@param tokens number
        ---@param adapter CodeCompanion.Adapter
        ---@return string
        token_count = function(tokens, adapter)
          return " (" .. tokens .. " tokens)"
        end,
      },
    },
  }

  -------------
  --  Setup  --
  -------------

  codecompanion.setup(config)

  ----------------
  --  Mappings  --
  ----------------

  -- mapping to close without killing the session (gq) in plugin/autocommand.lua

  -- other maps are in normal.lua
  vim.keymap.set({'n', 'v'}, '<C-c>', smart_chat_add, { noremap = true, silent = true, expr = true })
  vim.keymap.set({'n', 'v'}, '<Leader>c', ':CodeCompanionChat ', { noremap = true, silent = false })
  vim.keymap.set({'n', 'v'}, '<Leader>a', '<CMD>CodeCompanionActions<CR>', { noremap = true, silent = true })

  -- overload send key to go back to normal mode then submit
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
