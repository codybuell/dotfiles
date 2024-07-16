local treesitter = require('nvim-treesitter.configs')

-- Note you must use expr as the foldmethod for any language you want
-- treesitter to handle folding for, eg `setlocal foldmethod=expr` in
-- ~/.config/nvim/after/ftplugin/[filetype].vim, also depends on
-- `vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'` in init.lua

treesitter.setup {
  ensure_installed = {
    "bash",
    "c",
    "cmake",
    "comment",
    "cpp",
    "css",
    "dockerfile",
    "diff",
    "go",
    "gomod",
    "graphql",
    "html",
    "javascript",
    "json",
    "jsonc",
    "lua",
    "php",
    "python",
    "regex",
    "ruby",
    "scss",
    "svelte",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "yaml",
  },
  sync_install = true,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    disable = { "yaml", "json", "jsonc", "markdown" },   -- native vim syntax highlighting is better
    is_supported = function()                            -- disable / stop trying to re-init highlighting on large files
      if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then
        return false
      end
      return true
    end,
  },
  incremental_selection = {
    enable = false,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = false,
  },
  modules = {},
}
