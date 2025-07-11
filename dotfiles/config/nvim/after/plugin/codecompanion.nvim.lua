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
    opts = {
      system_prompt = function(opts)
        local language = opts.language or "English"
        return string.format(
          [[You are an AI programming assistant named "CodeCompanion". You are currently plugged into the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user's context is outside your core tasks.
- Minimize additional prose unless clarification is needed.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of each Markdown code block.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's directly relevant to the task at hand. You may omit code that isn't necessary for the solution.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- All non-code text responses must be written in the %s language indicated.
- Code should be wrapped in Markdown code blocks with the appropriate language tag. Don't specify the language on the next line after the opening code block.
- Comments in code should be wrapped at 79 characters.
- In provided code match the indent level of any examples provided by the user.

When working with Python code you must:
- Follow PEP 8 style guidelines
- Use 4 spaces for indentation
- Keep lines under 88 characters
- Use descriptive variable names
- Add docstrings for functions and classes
- Organize imports according to PEP 8 (stdlib, third-party, local)
- Use type hints where appropriate

When given a task:
1. Think step-by-step and, unless the user requests otherwise or the task is very simple, describe your plan in detailed pseudocode.
2. Output the final code in a single code block, ensuring that only relevant code is included.
3. End your response with a short suggestion for the next user turn that directly supports continuing the conversation.
4. Provide exactly one complete reply per conversation turn.]],
          language
        )
      end,
    },
    extensions = {
      vectorcode = {
        opts = {
          tool_group = {
            -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
            enabled = true,
            -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
            -- if you use @vectorcode_vectorise, it'll be very handy to include
            -- `file_search` here.
            extras = {},
            collapse = false, -- whether the individual tools should be shown in the chat
          },
          tool_opts = {
            ls = {},
            vectorise = {},
            query = {
              max_num = { chunk = -1, document = -1 },
              default_num = { chunk = 50, document = 10 },
              include_stderr = false,
              use_lsp = false,
              no_duplicate = true,
              chunk_mode = false,
              summarise = {
                enabled = false,
                adapter = nil,
                query_augmented = true,
              }
            }
          }
        },
      },
    },
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
        token_count = function(tokens, _)
          return " (" .. tokens .. " tokens)"
        end,
      },
    },
    -- temp fix for E350 folding error in v17.7.1
    -- https://github.com/olimorris/codecompanion.nvim/discussions/1788
    config = function(_, opts)
      require("codecompanion").setup(opts)
      local tools = require("codecompanion.strategies.chat.ui.tools")
      local original = tools.create_fold

      tools.create_fold = function(bufnr, start_line)
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_call(win, function()
          local old = vim.wo.foldmethod
          vim.wo.foldmethod = "manual"

          local ok, err = pcall(original, bufnr, start_line)
          if not ok then
            vim.schedule(function()
              vim.wo.foldmethod = old
            end)
            error(err)
          end

          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.wo.foldmethod = old
            end
          end, 50)
        end)
      end
    end,
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
