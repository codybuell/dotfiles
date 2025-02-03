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

  local function extend_markdown()
    vim.cmd [[
      " inline URLs
      syn match buellInlineURL /http[s]\?:\/\/[[:alnum:]%\/_#?&=.-]*/

      " todo items `- [ ] text`
      syn match buellTodo /\v^\s*-\s\[\s\]\s.*$/
      syn region buellTodoText
        \ start=/\v\[\s\]\s/
        \ end=/$/
        \ contained
        \ containedin=buellTodo
        \ contains=buellInlineURL

      " completed todo items `- [x] text`
      syn match buellCompletedTodo      /\v^\s*-\s\[[xX×]\]\s.*$/
      syn region buellCompletedTodoText
        \ start=/\v\[[xX×]\]\s/
        \ end=/$/
        \ contained
        \ containedin=buellCompletedTodo
        \ contains=buellInlineURL

      " code fences are concealed, set a char so we can see something
      syntax match buellCodeFences /^\s*```.*/
      syntax region @conceal
        \ start=/``/
        \ end=/`/
        \ contained
        \ containedin=buellCodeFences
        \ conceal
        \ cchar=≋
    ]]
  end

  local function extend_gitcommit()
    vim.cmd [[
      syntax match buellGitCommitOverLength /\%1l\%>50v.*$/
    ]]
  end

  --------------
  --  Colors  --
  --------------

  local pinnacle = require('wincent.pinnacle')

  -- adjust treesitter markdown highlight groups
  vim.cmd("highlight! link @markup.list.markdown Identifier")
  vim.cmd("highlight! link @markup.raw.markdown_inline Float")
  vim.cmd("highlight! link @markup.quote.markdown Comment")
  pinnacle.set('@markup.heading.1.markdown', pinnacle.embolden('Title'))
  pinnacle.set('@markup.strong.markdown_inline', pinnacle.embolden('Tag'))
  pinnacle.set('@punctuation.special.markdown', pinnacle.embolden('Comment'))
  pinnacle.set('@markup.list.unchecked.markdown', pinnacle.embolden('Directory'))
  pinnacle.set('@markup.list.checked.markdown', pinnacle.darken('Directory', 0.20))

  -- custom markdown highlight groups
  vim.cmd("highlight! link buellInlineURL htmlLink")
  vim.cmd("highlight! link buellTodoText Directory")
  pinnacle.set('buellCompletedTodoText', pinnacle.darken('Directory', 0.30))

  -- git commit over length
  pinnacle.set('buellGitCommitOverLength', pinnacle.darken('Error', 0.30))

  -- darken conceal character text
  pinnacle.set('Conceal', pinnacle.darken('Directory', 0.35))

  --------------------
  --  Autocommands  --
  --------------------

  local augroup = buell.util.augroup
  local autocmd = buell.util.autocmd

  augroup('BuellTreesitter', function()
    autocmd('BufRead,BufNewFile', '*.md', extend_markdown)
    autocmd('BufRead,BufNewFile', 'COMMIT_EDITMSG', extend_gitcommit)
  end)

end
