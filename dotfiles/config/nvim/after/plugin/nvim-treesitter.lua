--------------------------------------------------------------------------------
--                                                                            --
--  Treesitter                                                                --
--                                                                            --
--  https://github.com/nvim-treesitter/nvim-treesitter                        --
--                                                                            --
--  Note you must use expr as the foldmethod for any language you want        --
--  treesitter to handle folding for, eg `setlocal foldmethod=expr` in        --
--  ~/.config/nvim/after/ftplugin/[filetype].vim, also depends on             --
--  `vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'`. In this setup go to    --
--  ~/.config/nvim/lua/buell/foldexpr.lua and set the filetype override       --
--  table at the top of the file to specify the foldexpr to be used.          --
--                                                                            --
--------------------------------------------------------------------------------

local has_treesitter, treesitter = pcall(require, 'nvim-treesitter.configs')
if not has_treesitter then
  return
end

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
    "sql",
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
      "dockerfile",
      'tmux',
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
    syn match buellCompletedTodo /\v^\s*-\s\[[xX×]\]\s.*$/
    syn region buellCompletedTodoText
      \ start=/\v\[[xX×]\]\s/
      \ end=/$/
      \ contained
      \ containedin=buellCompletedTodo
      \ contains=buellInlineURL

    " code fences are concealed, set a char so we can see something
    syn match buellCodeFences /^\s*```.*/
    syn region @conceal
      \ start=/``/
      \ end=/`/
      \ contained
      \ containedin=buellCodeFences
      \ conceal
      \ cchar=󰅩

    " attempt to not conceal emojis as they are flakey with conceallevel=2
    " conceallevel=1 addresses the issue but docs are less readable
    syn match buellEmoji /[\U1F300-\U1F6FF]/ display
  ]]
end

-- git commit over length
local function extend_gitcommit()
  -- Create a namespace for our highlights
  local ns = vim.api.nvim_create_namespace('buell_gitcommit')

  vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "TextChangedI"}, {
    buffer = 0,
    callback = function()
      -- Clear existing highlights first
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

      local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
      if #line > 50 then
        vim.hl.range(0, ns, 'buellGitCommitOverLength', {0, 50}, {0, #line}, {
          priority = vim.hl.priorities.user + 10
        })
      end
    end,
  })
end

--------------------
--  Autocommands  --
--------------------

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellTreesitter', function()
  autocmd('BufRead,BufNewFile', '*.md', extend_markdown)
  autocmd('BufRead,BufNewFile', 'COMMIT_EDITMSG', extend_gitcommit)
end)
