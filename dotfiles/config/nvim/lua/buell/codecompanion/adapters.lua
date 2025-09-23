--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Adapters Configuration                                      --
--                                                                            --
--  This module configures the adapters that connect CodeCompanion into the   --
--  various AI providers / services.                                          --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

---------------
--  Copilot  --
---------------

local copilot_config = function()
  return require("codecompanion.adapters").extend("copilot", {
    schema = {
      model = {
        default = "claude-sonnet-4", -- claude-sonnet-4|o3-mini|gpt-4.1|o4-mini|gemini-2.5-pro|gpt-5|gpt-4o
      },
    },
  })
end

-----------------
--  Anthropic  --
-----------------

-- Example for using a custom env var
-- M.anthropic = function()
--   return require("codecompanion.adapters").extend("anthropic", {
--     env = {
--       api_key = "MY_OTHER_ANTHROPIC_KEY",
--     },
--   })
-- end

--------------
--  OpenAI  --
--------------

-- Example for using a custom default model
-- M.openai = function()
--   return require("codecompanion.adapters").extend("openai", {
--     schema = {
--       model = {
--         default = "gpt-4.1",
--       },
--     },
--   })
-- end

-------------------------
--  Assemble Adapters  --
-------------------------

M.http = {
  copilot = copilot_config(),
}

M.acp = {}

return M
