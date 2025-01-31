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

  ---------------------
  --  Configuration  --
  ---------------------

  codecompanion.setup({
    strategies = {
      inline = {
        adapter = "anthropic",
      },
      chat = {
        adapter = "anthropic",
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
            modes = { n = "<C-s>", i = "<C-s>" },
          },
          close = {
            modes = { n = "gq", i = "<C-c>" },
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
        show_settings = false,         -- show LLM settings at the top of the chat buffer?
        show_token_count = true,       -- show the token count for each response?
        start_in_insert_mode = false,  -- open the chat buffer in insert mode?

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
  })

  ----------------
  --  Mappings  --
  ----------------

  -- other maps are in normal.lua
  vim.keymap.set('n', '<C-a>', '<CMD>CodeCompanionChat Add<CR>', { noremap = true, silent = true })
  vim.keymap.set({'n', 'v'}, '<Leader>c', ':CodeCompanionChat ', { noremap = true, silent = false })
  vim.keymap.set('n', '<Leader>a', '<CMD>CodeCompanionActions<CR>', { noremap = true, silent = true })

  ---------------------
  --  Miscellaneous  --
  ---------------------

  -- alias cc to CodeCompanion
  vim.cmd([[cab cc CodeCompanion]])

  -- set syntax to markdown
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "codecompanion",
    callback = function()
      vim.bo.syntax = "markdown"
    end,
  })

end
