--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Strategies Configuration                                    --
--                                                                            --
--  Strategies define how CodeCompanion interacts with different contexts and --
--  how one interacts with CodeCompanion.                                     --
--    - Inline: Direct code modifications within the editor                   --
--    - Chat: Conversational interface with context and tools                 --
--    - Command: Command-line style interactions for quick tasks              --
--                                                                            --
--  This module configures adapters, keymaps, slash commands, and tools       --
--  for each strategy.                                                        --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

--------------
--  Inline  --
--------------

M.inline = {
  adapter = "copilot",
  opts = {
    diff_timeout = 300,
  },
}

------------
--  Chat  --
------------

M.chat = {
  adapter = "copilot",
  opts = {
    completion_provider = "cmp", -- blink | cmp | coc | default
  },
  roles = {
    llm = function(adapter)
      local model_name = adapter.parameters and adapter.parameters.model or "unknown"

      return string.format("CodeCompanion (%s %s)", adapter.formatted_name, model_name)
    end,
    user = "Me",
  },
  keymaps = {
    send = {
      modes = {
        n = "<Localleader>s",
        i = "<Localleader>s",
      },
    },
    close = {
      modes = {
        n = "<Localleader>q",
        i = "<C-c>",
      },
    },
    yolo_mode = {
      modes = {
        n = "<Localleader>T",
      },
    },
    yank_code = {
      modes = { n = "gy" },
      index = 8,
      callback = buell.codecompanion.helpers.smart_yank_code,
      description = "Yank Code",
    },
  },
  slash_commands = {
    ["buffer"] = {
      opts = { provider = "mini_pick" },
      keymaps = {
        modes = {
          i = "<C-b>",
          n = "<C-b>",
        },
      },
    },
    ["help"] = {
      opts = { provider = "mini_pick" },
      keymaps = {
        modes = {
          i = "<C-h>",
        },
      },
    },
    ["file"] = {
      opts = { provider = "mini_pick" },
      keymaps = {
        modes = {
          i = "<C-f>",
          n = "<C-f>",
        },
      },
    },
    ["symbols"] = {
      opts = { provider = "mini_pick" },
      keymaps = {
        modes = {
        },
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
      opts = { contains_code = false },
    },
  },
  tools = {
    opts = {
      default_tools = {},
    },
  },
}

---------------
--  Command  --
---------------

M.cmd = {
  adapter = "copilot",
}

return M
