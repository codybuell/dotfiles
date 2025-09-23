--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Memory                                                      --
--                                                                            --
--  This module contains memory configurations for codecompanion.             --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

M.project_docs = {
  description = "Project-specific context and documentation",
  parser = "claude",
  files = {
    "docs/context.md",     -- project overview and goals
    "docs/decisions.md",   -- key architectural decisions
    "docs/patterns.md",    -- code patterns and conventions
  },
}

M.opts = {
  chat = {
    enabled = true,
    default_memory = { "default", "project_docs" },
    default_params = "watch", -- watch|pin when adding a buffer to the chat
  },
}

return M
