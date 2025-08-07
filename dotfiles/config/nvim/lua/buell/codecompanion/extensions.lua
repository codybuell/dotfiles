--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Extensions Configuration                                    --
--                                                                            --
--  This module configures extensions that enhance CodeCompanion's            --
--  capabilities. Extensions provide additional tools and integrations for    --
--  specific workflows.                                                       --
--                                                                            --
--  Currently includes:                                                       --
--    VectorCode: Semantic code search and analysis                           --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

------------------
--  VectorCode  --
------------------

M.vectorcode = {
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
}

return M
