--------------------------------------------------------------------------------
--                                                                            --
--  Fugitive                                                                  --
--                                                                            --
--  https://github.com/tpope/vim-fugitive                                     --
--                                                                            --
--------------------------------------------------------------------------------

if not vim.fn.exists(':Git') then
  return
end

-----------------
--  Functions  --
-----------------

-- Get Branches
--
-- Get all branches, both local and remote, for the current repository.
local get_branches = function()
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
  local function get_previous_commit_hash()
    local cmd = "git log HEAD^^ -m --follow -n 1 --format=%H -- " .. vim.fn.shellescape(file)
    local handle = io.popen(cmd)
    if not handle then
      print("Failed to execute git command")
      return nil
    end

    local commit_hash = handle:read("*a"):gsub("\n", "")
    handle:close()

    if commit_hash == "" then
      print("No previous commit found for file: " .. file)
      return nil
    end
    return commit_hash
  end

  local function do_diff()
    local diff_target = target
    if target == "[ PREV COMMIT TO FILE ]" then
      diff_target = get_previous_commit_hash()
      if not diff_target then return end
    end

    print("Diffing with " .. diff_target)
    vim.cmd("Gvdiffsplit " .. diff_target)
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
local smart_diff = function()
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

-- Enhanced git push (requires gpb shell function)
local git_push_with_mr = function(args)
  args = args or ""
  local cmd = 'gpb ' .. args

  print("Executing: " .. cmd)

  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            vim.notify(line, vim.log.levels.WARN)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code == 0 then
        print("gpb completed successfully")
      else
        vim.notify("gpb failed with exit code: " .. exit_code, vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  if job_id == 0 then
    vim.notify("Failed to start gpb command", vim.log.levels.ERROR)
  elseif job_id == -1 then
    vim.notify("gpb command not found", vim.log.levels.ERROR)
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

-- `<Leader>gp` - Push with automatic MR link opening
-- `<Leader>gP` - Push with custom arguments and MR link opening
-- `<Leader>gm` - Manually check for and open MR links from recent git output
-- `:GitOpenMR` - Command version of the manual check

-- committing flows (gs = status, gb = blame, gp = push)
vim.keymap.set('n', '<Leader>ga', ':Git commit --amend<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gs', ':Git<CR>:40wincmd_<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gp', function() git_push_with_mr() end, {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gP', function() git_push_with_mr(vim.fn.input('Git push args: ')) end, {remap = false, silent = false})

-- diffing flows (gl = log for file, gL = log for all, gD = smart diff) note <Space>gd is used with minidiff
vim.keymap.set('n', '<Leader>gl', ':silent! 0Gclog!<CR>:bot copen<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gL', ':silent! Git log --pretty="format:%h  %ad  %<(16,trunc)%aN %d %s"<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gD', smart_diff, {remap = false, silent = true})

-- other flows (gc = checkout, gg = grep, ge = edit/refresh buffer)
vim.keymap.set('n', '<Leader>gc', ':Git checkout<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>gg', ':Ggrep<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', {remap = false, silent = true})
