--------------------------------------------------------------------------------
--                                                                            --
--  Treesitter                                                                --
--                                                                            --
--  https://github.com/nvim-treesitter/nvim-treesitter                        --
--                                                                            --
--  Note you must use expr as the foldmethod for any language you want        --
--  treesitter to handle folding for, eg `setlocal foldmethod=expr` in        --
--  ~/.config/nvim/after/ftplugin/[filetype].vim, also depends on             --
--  `vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'` in init.lua             --
--                                                                            --
--------------------------------------------------------------------------------

local has_treesitter, treesitter = pcall(require, 'nvim-treesitter.configs')
if has_treesitter then

  ---------------------
  --  Configuration  --
  ---------------------

  local config = {
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
      "markdown",
      "markdown_inline",
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
    sync_install   = true,
    auto_install   = true,
    ignore_install = {},
    highlight = {
      enable = true,
      -- native vim syntax highlighting is better
      disable = {
        "yaml",
        "json",
        "jsonc",
        -- "markdown",
        "gitcommit",
        "shellbot",
        "copilot-chat"
      },
      -- disable / stop trying to re-init highlighting on large files
      is_supported = function()
        if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then
          return false
        end
        return true
      end,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        -- init_selection = "gnn",
        node_incremental = "v",
        -- scope_incremental = "grc",
        node_decremental = "V",
      },
    },
    indent = {
      enable = false,
    },
    modules = {},
  }

  -------------
  --  Setup  --
  -------------

  treesitter.setup(config)

  -----------------
  --  Overrides  --
  -----------------

  -- local ts_query = require("vim.treesitter.query")

  -- -- override fenced_code_block_delimiter in markdown to not conceal
  -- -- this requires https://github.com/neovim/neovim/pull/30257
  -- local custom_query = [[
  -- ;; extends
  -- (fenced_code_block_delimiter) @punctuation.delimiter
  -- ]]
  -- ts_query.set("markdown", "highlights", custom_query)

  --------------
  --  Colors  --
  --------------

  local pinnacle = require('wincent.pinnacle')

  -- markdown overrides
  vim.cmd("highlight! link @markup.list.markdown Identifier")
  vim.cmd("highlight! link @markup.raw.markdown_inline Float")
  vim.cmd("highlight! link @markup.quote.markdown Comment")
  pinnacle.set('@markup.strong.markdown_inline', pinnacle.embolden('Tag'))
  pinnacle.set('@punctuation.special.markdown', pinnacle.embolden('Comment'))

end
