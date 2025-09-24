--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Memory                                                      --
--                                                                            --
--  This module contains memory configurations for codecompanion.             --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

M.systemp_prompt_extension = {
  description = "Additions to the default system prompt",
  parser = "claude",
  files = {
    {
      path = "~/.config/nvim/lua/buell/codecompanion/system_prompt.md",
      opts = {
        visible = false, -- Hide this specific file
      },
    },
  },
}

M.project_docs = {
  description = "Project-specific context and documentation",
  parser = "claude",
  files = {
    "docs/context.md",            -- project overview and goals
    "docs/decisions.md",          -- key architectural decisions
    "docs/patterns.md",           -- general code patterns and conventions
    "docs/patterns-backend.md",   -- backend code patterns and conventions
    "docs/patterns-frontend.md",  -- frontend code patterns and conventions
  },
}

M.opts = {
  chat = {
    enabled = true,
    default_memory = { "systemp_prompt_extension", "default", "project_docs" },
    default_params = "watch", -- watch|pin when adding a buffer to the chat
  },
}

return M
