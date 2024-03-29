local ts = {}

ts.setup = function ()

  require'nvim-treesitter.configs'.setup {
    ensure_installed = {                        -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      "bash",                                   -- DON'T FORGET: `setlocal fondmethod=expr` for each lang you want to use tresitter
      "c",                                      --               for, do so under vim/after/ftplugin/[filetype].vim
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
      -- "json",       -- does not respect synmaxcol and so breaks on large single line files
      -- "jsonc",      -- does not respect synmaxcol and so breaks on large single line files
      "lua",
      "php",
      "pug",
      "python",
      "regex",
      "ruby",
      "scss",
      "toml",
      "typescript",
      "vue",
      "yaml",
    },
    --ignore_install = { "javascript" },        -- List of parsers to ignore installing
    highlight = {
      enable = true,                            -- false will disable the whole extension
      disable = { "yaml" },                     -- native vim syntax highlighting is better
    },
  }

end

return ts
