local unicode = {}
local null_ls = require("null-ls")

unicode.setup = function()

  -- hacky but does the trick
  vim.diagnostic.config{virtual_text=false}

  local warn_unicode = {
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { },
    disabled_filetypes = { "markdown" },
    generator = {
      fn = function(params)
        -- params object contains info about the current file and editor state
        local diagnostics = {}
        for i, line in ipairs(params.content) do
          local col, end_col = line:find("[^%z\1-\127]+")
          if col and end_col then
            table.insert(diagnostics, {
              row = i,
              col = col,
              end_col = end_col + 1,
              source = "null-ls_unicode",
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

return unicode
