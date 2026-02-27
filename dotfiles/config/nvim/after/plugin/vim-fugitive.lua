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

-- Git Push with MR
--
-- Wraps the provided `git push` command and automatically opens any
-- merge/pull request. Requires Neovim ≥0.10 for `vim.ui.open`.
local function git_push_with_mr(...)
  local args = {...}
  local arg_string = table.concat(args, " ")

  -- Execute git push with redirect
  vim.cmd("redir! > /tmp/lastgitpush")
  if #args > 0 then
    vim.cmd("Git push " .. arg_string)
  else
    vim.cmd("Git push")
  end
  vim.cmd("redir END")

  -- Parse for MR link
  local file = io.open("/tmp/lastgitpush", "r")
  if not file then
    print("Could not read git push output")
    return
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  for i, line in ipairs(lines) do
    local lower_line = line:lower()
    if lower_line:match("create a merge request") or
      lower_line:match("create a pull request") or
      lower_line:match("to create a merge request") or
      lower_line:match("to create a pull request") then

      if i < #lines then
        local next_line = lines[i + 1]
        local fields = {}
        for field in next_line:gmatch("%S+") do
          table.insert(fields, field)
        end
        if fields[2] then
          vim.ui.open(fields[2])
          return
        end
      end
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

-- other flows (gc = checkout, gg = grep, ge = edit/refresh buffer, gq = changed files to quickfix)
vim.keymap.set('n', '<Leader>gc', ':Git checkout<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>gg', ':Ggrep<Space>', {remap = false, silent = false})
vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', {remap = false, silent = true})
vim.keymap.set('n', '<Leader>gq', function()
  local diff_output = vim.fn.systemlist('git diff --unified=0 HEAD')
  local qf_list = {}
  local current_file = nil

  for _, line in ipairs(diff_output) do
    -- match file header: +++ b/path/to/file
    local file = line:match('^%+%+%+ b/(.+)$')
    if file then
      current_file = file
    end
    -- match hunk header: @@ -X,Y +Z,W @@ or @@ -X +Z @@
    -- capture the starting line number from +Z
    local lnum = line:match('^@@ %-%d+,?%d* %+(%d+)')
    if lnum and current_file then
      table.insert(qf_list, {filename = current_file, lnum = tonumber(lnum)})
      current_file = nil -- only take first hunk per file
    end
  end

  vim.fn.setqflist(qf_list)
  vim.cmd('cfirst')
end, {remap = false, silent = true, desc = 'Git changed files to quickfix'})
