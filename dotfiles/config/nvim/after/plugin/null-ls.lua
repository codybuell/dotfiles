local nullls = require('null-ls')

-- setup builtin sources
nullls.setup({
  sources = {
    -- nullls.builtins.formatting.stylua,
    -- nullls.builtins.diagnostics.eslint,
    -- nullls.builtins.completion.spell,
  },
})

-- register custom sources
buell.nullls.unicode.setup()
