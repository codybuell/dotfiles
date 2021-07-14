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
      "yaml",
    },
    --ignore_install = { "javascript" },        -- List of parsers to ignore installing
    highlight = {
      enable = true,                            -- false will disable the whole extension
      -- disable = { "c", "rust" },             -- list of language that will be disabled
      -- additional_vim_regex_highlighting = false,
    },
  }

end

return ts
