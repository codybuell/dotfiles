--------------------------------------------------------------------------------
--                                                                            --
--  Fugitive                                                                  --
--                                                                            --
--  https://github.com/tpope/vim-fugitive                                     --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':Git') then

  -- Get Branches
  --
  -- Get all branches, both local and remote, for the current repository.
  local function get_branches(file)
    -- get all branches, both local and remote
    local branches = {}
    local raw_branches = vim.fn.systemlist('git branch -a --format="%(refname:short)"')

    -- filter and clean up branch names
    for _, branch in ipairs(raw_branches) do
      -- remove 'remotes/origin/' prefix and duplicates
      branch = branch:gsub('^remotes/origin/', '')
      if not vim.tbl_contains(branches, branch) then
        table.insert(branches, branch)
      end
    end

    return branches
  end

  -- Diff With
  --
  -- Diff the current file with a target, either a branch or a commit hash.
  local diff_with = function(file, target, target_win)
    local function do_diff()
      if target == "[ PREV COMMIT TO FILE ]" then
        -- get the previous commit has where the file changed, HEAD^ is the current commit
        local cmd = "git log HEAD^^ -m --follow -n 1 --format=%H -- " .. vim.fn.shellescape(file)
        local handle = io.popen(cmd)
        if not handle then
          print("Failed to execute git command")
          return
        end

        local commit_hash = handle:read("*a"):gsub("\n", "")
        handle:close()

        if commit_hash == "" then
          print("No previous commit found for file: " .. file)
          return
        end

        print("Diffing with " .. commit_hash)

        -- run :Gvdiffsplit against the last commit
        vim.cmd("Gvdiffsplit " .. commit_hash)
      else
        print("Diffing with " .. target)
        vim.cmd('Gvdiffsplit ' .. target)
      end
      vim.cmd('windo set wrap')
      vim.cmd('wincmd h')
    end

    -- execute in target window if provided, otherwise in current window
    if target_win then
      vim.api.nvim_win_call(target_win, do_diff)
    else
      do_diff()
    end
  end

  -- Smart Diff
  --
  -- Opens a diff split, current version on left, diffed on right. If the file
  -- has been modified in some way it diffs with the HEAD, otherwise it diffs
  -- with a target of your choice. Uses vertical splits, wraps lines, and keeps
  -- focus on the current copy. The splits should be as follows:
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
    -- get the git status of current file
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
      -- file has no changes, prompt for diff target
      local branches = get_branches()
      -- add previous commit option as first choice
      table.insert(branches, 1, "[ PREV COMMIT TO FILE ]")

      -- check if mini.pick is available
      local has_minipick, pick = pcall(require, 'mini.pick')
      if has_minipick then
        -- store the target window before starting picker
        local target_win = vim.api.nvim_get_current_win()

        -- launch mini.pick
        pick.start({
          source = {
            items = branches,
            name = 'Git Diff Target',
            choose = function(choice)
              if choice then
                diff_with(file, choice, target_win)
              end
            end
          }
        })
      else
        -- fallback to vim.ui.select
        vim.ui.select(branches, {
          prompt = "Select diff target:",
          format_item = function(item)
            return item
          end,
        }, function(choice)
          if choice then
            diff_with(file, choice)
          end
        end)
      end
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
  -- show log history for current file
  vim.keymap.set('n', '<Leader>gl', ':silent! 0Gclog!<CR>:bot copen<CR>', {remap = false, silent = true})
  -- show all log history
  vim.keymap.set('n', '<Leader>gL', ':silent! Git log --pretty="format:%h  %ad  %<(16,trunc)%aN %d %s"<CR>', {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gd', smart_diff, {remap = false, silent = true})
  vim.keymap.set('n', '<Leader>gc', ':Git checkout<Space>', {remap = false, silent = false})
  vim.keymap.set('n', '<Leader>gg', ':Ggrep<Space>', {remap = false, silent = false})
  vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', {remap = false, silent = true})

end
