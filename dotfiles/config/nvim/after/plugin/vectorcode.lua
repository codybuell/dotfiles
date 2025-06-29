--------------------------------------------------------------------------------
--                                                                            --
--  VectorCode                                                                --
--                                                                            --
--  https://github.com/Davidyz/VectorCode                                     --
--                                                                            --
--------------------------------------------------------------------------------

local has_vectorcode, vectorcode = pcall(require, 'vectorcode')
if has_vectorcode then

  ---------------------
  --  Configuration  --
  ---------------------
  ---

  local config = {
    cli_cmds = {
      vectorcode = "vectorcode",
    },
    async_opts = {
      debounce = 10,
      events = { "BufWritePost", "InsertEnter", "BufReadPost" },
      exclude_this = true,
      n_query = 1,
      notify = false,
      query_cb = require("vectorcode.utils").make_surrounding_lines_cb(-1),
      run_on_register = false,
    },
    async_backend = "default", -- or "lsp"
    exclude_this = true,
    n_query = 1,
    notify = true,
    timeout_ms = 5000,
    on_setup = {
      update = false, -- set to true to enable update when `setup` is called.
      lsp = false,
    },
    sync_log_env_var = false,
  }

  -------------
  --  Setup  --
  -------------

  vectorcode.setup(config)

  ----------------
  --  Mappings  --
  ----------------

end
