--------------------------------------------------------------------------------
--                                                                            --
--  Fugitive                                                                  --
--                                                                            --
--  https://github.com/tpope/vim-fugitive                                     --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':Git') then

  -- Smart Diff
  --
  -- Opens a diff split, current version on left, diffed on right. If the file
  -- has been modified in some way it diffs with the HEAD, otherwise it diffs
  -- with the last commit. Uses vertical splits, wraps lines, and keeps focus
  -- on the current copy. The splits should be as follows:
  --
  -- Two way diff:
  -- +-----------------+-----------------+
  -- |                 |                 |
  -- |  current state  |    old state    |
  -- |  current file   |                 |
  -- |                 |                 |
  -- +-----------------+-----------------+
  --
  -- Three way diff:
  -- +--------------+-----------------+---------------+
  -- |              |                 |               |
  -- |  cur branch  |    cur state    | merged branch |
  -- |              |    cur file     |               |
  -- |              |                 |               |
  -- +--------------+-----------------+---------------+
  local function smart_diff()
    -- Get the git status of current file
    local file = vim.fn.expand('%:p')
    local status = vim.fn.system('git status --porcelain ' .. vim.fn.shellescape(file))

    if status ~= "" then
      -- file is modified or staged
      vim.cmd('Gvdiffsplit!')

      -- count only diff windows
      local diff_count = 0
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_get_option_value('diff', {win = win}) then
          diff_count = diff_count + 1
        end
      end

      -- only swap on a 2 way diff
      if diff_count == 2 then
        vim.cmd('wincmd r')
      end
    else
      -- file has no changes, diff with previous commit
      vim.cmd('Gvdiffsplit !~1')
      vim.cmd('wincmd h')
      vim.cmd('windo set wrap')
    end
  end

  ---------------------
  --  Configuration  --
  ---------------------

  -- see corresponding syntax defs in after/syntax/qf.vim
  vim.g.fugitive_summary_format = "%ad   %<(16,trunc)%aN%d %s"

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>gs', ':Git<CR>:40wincmd_<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gp', ':Git push<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gl', ':silent! 0Gclog!<CR>:bot copen<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gL', ':silent! Git log --pretty="format:%h  %ad  %<(16,trunc)%aN %d %s"<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gd', smart_diff, {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gc', ':Git checkout<Space>', {remap = false, silent = false})
  vim.keymap.set('n', '<Leader>gg', ':Ggrep<Space>', {remap = false, silent = false})
  vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', {remap = false, silent = true})

end
