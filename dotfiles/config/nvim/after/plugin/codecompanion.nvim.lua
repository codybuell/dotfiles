--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion                                                             --
--                                                                            --
--  https://codecompanion.olimorris.dev/                                      --
--  https://github.com/olimorris/codecompanion.nvim                           --
--                                                                            --
--  Workflows:                                                                --
--    [visual select]<S-c>[write prompt] - inline ad hoc use codecompanion    --
--      - eg select some func and ask to write a func doc for it              --
--      - add #{buffer} and ask to create a new func to do something          --
--    <leader>2 - open a copilot chat window                                  --
--    <leader>3 - open an anthropic chat window                               --
--    <leader>1 - open the last used chat window else new copilot             --
--    gS - show copilot usage stats                                           --
--    gta - toggle auto tool mode                                             --
--    gd - debug the chat buffer, show full chat history table                --
--                                                                            --
--  Reference:                                                                --
--    temperature: controls randomness in output, lower is more focused       --
--                 higher is more creative, 0 <-> 1                           --
--    top_p: limits the model to consider only the most probable tokens       --
--           whose cumulative probability is ≤ top_p, balances randomness     --
--           and coherence                                                    --
--    n: how many completions (responses) the model should gen per prompt     --
--                                                                            --
--  TBD/Todo:                                                                 --
--    - maintaining a decisions log for a repo/codebase                       --
--    - maintaining and auto loading a workspace config                       --
--    - look into "code workflows" and create some                            --
--    - look into creating some custom prompts for common tasks and map em    --
--    - create custom chat variables eg #{buffer}                             --
--    - create custom chat slack commands eg /git_files                       --
--    - create custom chat tools to execute tasks eg @mytool                  --
--    - create custom chat tool groups eg @vectorcode_toolbox                 --
--    - set default tools                                                     --
--    - add some reporting / insight on token usage / buffer available        --
--    - learn how to use workspaces and auto load workspace file if present?  --
--    - show token status values etc like cline by default, and copilot stats --
--    - update adapter tokens function to return table and show ↑ ↓ and total --
--    - fix bad calculations that show using more tokens than context window  --
--    - consider virtual input windows, github bits:                          --
--      folke/snacks.nvim/blob/main/docs/input.md                             --
--      lucobellic/nvim-config/blob/main/lua/plugins/snacks/snacks-input.lua  --
--    - https://github.com/olimorris/codecompanion.nvim/discussions/1297      --
--                                                                            --
--------------------------------------------------------------------------------

local has_codecompanion, codecompanion = pcall(require, 'codecompanion')
if not has_codecompanion then
  return
end

vim.defer_fn(function()

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
  --  System Prompt  --
  ---------------------

  local system_prompt = function(opts)
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
  end

  ---------------------
  --  Configuration  --
  ---------------------

  -- plugin level configuration
  local config = {
    opts = {
      system_prompt = system_prompt,
    },
    extensions = {
      vectorcode = {
        opts = {
          tool_group = {
            enabled = true,   -- register tool group `@vectorcode_toolbox` containing all 3 tools
            extras = {
              "file_search",  -- extra tools to include in `@vectorcode_toolbox`
            },
            collapse = false, -- whether individual tools should be shown in the chat
          },
          tool_opts = {
            ls = {},
            vectorise = {},
            query = {
              max_num = { chunk = -1, document = -1 },
              default_num = { chunk = 50, document = 10 },
              include_stderr = false,
              use_lsp = true,
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
        opts = {
          diff_timeout = 300, -- timeout in seconds before the diff is discarded
        },
      },
      chat = {
        adapter = "copilot",
        opts = {
          completion_provider = "cmp", -- blink|cmp|coc|default
        },
        roles = {
          llm = function(adapter)
            return string.format("CodeCompanion (%s %s)", adapter.formatted_name, adapter.model.name)
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
            keymaps = {
              modes = {
                i = "<C-b>",
                n = { "<C-b>", "gb" },
              },
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
          ["git_files"] = {
            description = "List git files",
            callback = function(chat)
              local handle = io.popen("git ls-files")
              if handle ~= nil then
                local result = handle:read("*a")
                handle:close()
                chat:add_context({ role = "user", content = result }, "git", "<git_files>")
              else
                return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
              end
            end,
            opts = {
              contains_code = false,
            },
          },
        },
        tools = {
          opts = {
            default_tools = {
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
        provider = "mini_diff",        -- default|mini_diff
      },
      chat = {
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

  -- alias cc to CodeCompanion
  vim.cmd([[cab cc CodeCompanion]])

  -- mapping to close without killing the session (gq) in plugin/autocommand.lua

  -- other maps are in normal.lua
  vim.keymap.set({'n', 'v'}, '<C-c>', smart_chat_add, { noremap = true, silent = true, expr = true })
  vim.keymap.set({'n', 'v'}, '<Leader>c', ':CodeCompanion ', { noremap = true, silent = false })
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

end, 100)
