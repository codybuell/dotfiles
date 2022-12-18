treesitter = require('nvim-treesitter.configs')

-- Note you must use expr as the foldmethod for any language you want
-- treesitter to handle folding for, eg `setlocal foldmethod=expr` in
-- ~/.config/nvim/after/ftplugin/[filetype].vim, also depends on
-- `vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'` in init.lua

treesitter.setup {
  ensure_installed = {        -- "all", "maintained", or a list of languages
    "bash",
    "c",
    "cmake",
    "comment",
    "cpp",
    "css",
    "dockerfile",
    "go",
    "gomod",
    "graphql",
    "help",
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
    "toml",
    "typescript",
    "vim",
    "vue",
    "yaml",
  },
  highlight = {
    enable = true,            -- false will disable the whole extension
    disable = { "yaml" },     -- native vim syntax highlighting is better
  },
}
