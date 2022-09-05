local nullls = {}

nullls.setup = function()

  local null_ls = require("null-ls")

  -- hacky but does the trick
  vim.diagnostic.config{virtual_text=false}

  local warn_unicode = {
      method = null_ls.methods.DIAGNOSTICS,
      -- filetypes = { "go", "python", "sql", "sh", "json", "yaml", "lua" },
      filetypes = { },
      disabled_filetypes = { "markdown" },
      generator = {
          fn = function(params)
              local diagnostics = {}
              -- sources have access to a params object
              -- containing info about the current file and editor state
              for i, line in ipairs(params.content) do
                  -- lua < 5.1
                  -- local col, end_col = line:find("[^\0-\x7F]")
                  -- lua >= 5.1
                  local col, end_col = line:find("[^%z\1-\127]+")
                  if col and end_col then
                      -- null-ls fills in undefined positions
                      -- and converts source diagnostics into the required format
                      table.insert(diagnostics, {
                          row = i,
                          col = col,
                          end_col = end_col + 1,
                          source = "warn-unicode",
                          message = "Unicode characters found",
                          severity = 3,
                      })
                  end
              end
            return diagnostics
          end,
      },
  }

  null_ls.register(warn_unicode)

end

return nullls
