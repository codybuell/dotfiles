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

-- DISABLED: no longer have github copilot access. Kept for re-enabling; see
-- the commented entries in M.http below.

local copilot_config = function()
  return require("codecompanion.adapters").extend("copilot", {
    schema = {
      model = {
        default = "claude-sonnet-4.5", -- claude-sonnet-4|o3-mini|gpt-4.1|o4-mini|gemini-2.5-pro|gpt-5|gpt-4o
      },
    },
  })
end

local copilot_gpt = function()
  return require("codecompanion.adapters").extend("copilot", {
    schema = {
      model = {
        default = "gpt-4.1", -- claude-sonnet-4|o3-mini|gpt-4.1|o4-mini|gemini-2.5-pro|gpt-5|gpt-4o
      },
    },
  })
end


-- no explicit token: the claude_code adapter shells out to the claude cli,
-- which uses the credentials from `claude /login` (stored in the login
-- keychain by claude code itself). Setting CLAUDE_CODE_OAUTH_TOKEN here would
-- override that session and go stale on every re-login.
--
-- requires the `claude-agent-acp` bridge on $PATH (codecompanion v19+):
--   npm install -g @agentclientprotocol/claude-agent-acp
-- (the older @zed-industries package is abandoned and bundles a claude code
-- too old for current models)
--
-- launched via `env -u` so the subscription is billed, not the API: nvim
-- inherits ANTHROPIC_API_KEY from the shell (05-environment.zsh) and claude
-- code prefers an API key over the login session when one is present. Same
-- reason the zsh `claude()` wrapper in 08-functions.zsh unsets it.
local claude_code_env = { "env", "-u", "ANTHROPIC_API_KEY", "-u", "CLAUDE_CODE_OAUTH_TOKEN" }

local claude_code = function()
  return require("codecompanion.adapters").extend("claude_code", {
    commands = {
      default = vim.list_extend(vim.deepcopy(claude_code_env), { "claude-agent-acp" }),
      yolo    = vim.list_extend(vim.deepcopy(claude_code_env), { "claude-agent-acp", "--yolo" }),
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
  -- copilot     = copilot_config,
  -- copilot_gpt = copilot_gpt,
  opts = {
    hidden = { copilot = true },  -- hide from the change adapter picker
  },
}

M.acp = {
  claude_code = claude_code,
}

return M
