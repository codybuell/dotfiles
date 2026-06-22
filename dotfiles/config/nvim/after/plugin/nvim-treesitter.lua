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

local has_treesitter, treesitter = pcall(require, 'nvim-treesitter')
if not has_treesitter then
  return
end

---------------------
--  Configuration  --
---------------------

treesitter.setup()

treesitter.install({
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
})

-----------------
--  Highlight  --
-----------------

local disabled_hl = { yaml = true, dockerfile = true, tmux = true }

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if disabled_hl[vim.bo.filetype] then return end
    if vim.fn.getfsize(vim.fn.expand('%')) > (512 * 1024) then return end
    pcall(vim.treesitter.start)
  end,
})

----------------------------
--  Incremental Selection --
----------------------------

vim.keymap.set('x', 'v', function() vim.treesitter.select('parent') end)
vim.keymap.set('x', 'V', function() vim.treesitter.select('child') end)

------------------------------
--  Query Overrides          --
------------------------------

-- load custom markdown highlights query from after/queries/ via the API,
-- which takes absolute priority over any rtp/site file resolution
local query_path = vim.fn.stdpath('config') .. '/after/queries/markdown/highlights.scm'
local qok, qlines = pcall(vim.fn.readfile, query_path)
if qok then
  vim.treesitter.query.set('markdown', 'highlights', table.concat(qlines, '\n'))
end

-----------------
--  Overrides  --
-----------------

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

    " attempt to not conceal emojis as they are flakey with conceallevel=2
    " conceallevel=1 addresses the issue but docs are less readable
    syn match buellEmoji /[\U1F300-\U1F6FF]/ display
  ]]
end

local function extend_gitcommit()
  local ns = vim.api.nvim_create_namespace('buell_gitcommit')

  vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "TextChangedI"}, {
    buffer = 0,
    callback = function()
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
