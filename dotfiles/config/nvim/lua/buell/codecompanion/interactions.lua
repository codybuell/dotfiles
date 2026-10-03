--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Interactions Configuration                                  --
--                                                                            --
--  Interactions (formerly strategies) define how CodeCompanion interacts     --
--  with different contexts and how one interacts with CodeCompanion.         --
--    - Inline: Direct code modifications within the editor                   --
--    - Chat: Conversational interface with context and tools                 --
--    - Command: Command-line style interactions for quick tasks              --
--                                                                            --
--  This module configures adapters, keymaps, slash commands, and tools       --
--  for each interaction.                                                     --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

-- chat runs on the claude subscription via claude code (acp, see adapters.lua)
local chat_adapter = "claude_code"

-- inline, cmd and background are http-only interactions (acp adapters aren't
-- supported there), so these bill the anthropic api key
local http_adapter = "anthropic"

------------------
--  Background  --
------------------

-- used for chat titles and the tool approval judge
M.background = {
  adapter = http_adapter,
}

--------------
--  Inline  --
--------------

M.inline = {
  adapter = http_adapter,
}

------------
--  Chat  --
------------

M.chat = {
  adapter = chat_adapter,
  opts = {
    completion_provider = "cmp", -- blink | cmp | coc | default
  },
  roles = {
    llm = function(adapter)
      local model_name = require("codecompanion.adapters.utils").model(adapter)
        or (adapter.parameters and adapter.parameters.model)

      -- acp adapters (claude code) carry no model in their schema
      if not model_name then
        return string.format("CodeCompanion (%s)", adapter.formatted_name)
      end

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
        },
      },
    },
    -- Disabled for now, as it conflicts with 'move to left window' map
    -- ["help"] = {
    --   opts = { provider = "mini_pick" },
    --   keymaps = {
    --     modes = {
    --       i = "<C-h>",
    --     },
    --   },
    -- },
    ["file"] = {
      opts = { provider = "mini_pick" },
      keymaps = {
        modes = {
          i = "<C-f>",
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
  adapter = http_adapter,
}

return M
