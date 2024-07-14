local treesitter = require('nvim-treesitter.configs')

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
  highlight = {
    enable = true,                       -- false will disable the whole extension
    disable = { "yaml", "json", "jsonc", "markdown" },   -- native vim syntax highlighting is better
    is_supported = function()            -- disable / stop trying to re-init highlighting on large files
      if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then
        return false
      end
      return true
    end,
  },
}
