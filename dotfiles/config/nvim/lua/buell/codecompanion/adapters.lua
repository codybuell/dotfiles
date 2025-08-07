--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Adapters Configuration                                      --
--                                                                            --
--  This module configures the adapters that connect CodeCompanion into the   --
--  various AI providers / services.                                          --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

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

return M
