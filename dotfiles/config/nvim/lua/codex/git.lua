--------------------------------------------------------------------------------
--                                                                            --
--  Codex Git                                                                 --
--                                                                            --
--  Keeps a git-backed notes root in sync with its remote, which other        --
--  writers (the assistant on the server) also commit to:                     --
--                                                                            --
--    pull    on first use and when a note is opened, at most every           --
--            pull_interval seconds; open buffers are reloaded after          --
--    commit  commit_delay seconds after the last save, so a burst of         --
--            :w's becomes one commit; then pull --rebase and push            --
--    quit    a pending commit is flushed before nvim exits                   --
--                                                                            --
--  A rebase that conflicts is aborted, leaving the local commit unpushed     --
--  and the tree as it was; resolve in a shell, then :CodexSync.              --
--                                                                            --
--  Commands: :CodexSync (commit, pull, push now), :CodexPull.                --
--                                                                            --
--------------------------------------------------------------------------------

local git = {}

local state = {
  root      = nil,
  opts      = nil,
  busy      = false,  -- a git sequence is running
  again     = false,  -- a sync was requested while busy
  pulled_at = 0,      -- os.time() of the last successful pull
  timer     = nil,    -- pending commit debounce
}

local defaults = {
  pull_interval = 300,  -- seconds between automatic pulls
  commit_delay  = 30,   -- seconds of quiet after a save before committing
  timeout       = 60,   -- seconds before a git command is abandoned
}

-- Notify
--
-- @param msg: string
-- @param level: integer|nil
-- @return nil
local notify = function(msg, level)
  vim.schedule(function()
    vim.notify('codex: ' .. msg, level or vim.log.levels.INFO)
  end)
end

-- Run
--
-- Run git in the notes root. Never prompts: no terminal, so a credential
-- prompt fails fast instead of hanging. Signing still works through a GUI
-- pinentry.
--
-- @param args: table, git arguments
-- @param on_exit: function(result)
-- @return nil
local run = function(args, on_exit)
  local cmd = vim.list_extend({ 'git', '-C', state.root }, args)
  vim.system(cmd, {
    text    = true,
    timeout = state.opts.timeout * 1000,
    env     = { GIT_TERMINAL_PROMPT = '0' },
  }, on_exit)
end

-- Chain
--
-- Run git commands in order, stopping at the first failure.
--
-- @param steps: table, list of { args = table }
-- @param done: function(ok, result, step)
-- @return nil
local chain
chain = function(steps, done)
  if #steps == 0 then
    return done(true)
  end
  local step = table.remove(steps, 1)
  run(step.args, function(result)
    if result.code ~= 0 then
      return done(false, result, step)
    end
    chain(steps, done)
  end)
end

-- Commit Message
--
-- "Edit People/jess.md" for one file, "Edit 3 notes" with a file list for
-- several, in the repo's existing style.
--
-- @param status: string, `git diff --cached --name-status` output
-- @return table, message lines
local commit_message = function(status)
  local verbs = { A = 'Add', M = 'Edit', D = 'Delete', R = 'Rename', C = 'Copy', T = 'Edit' }
  local files = {}
  for line in status:gmatch('[^\n]+') do
    local code, rest = line:match('^(%a)%d*\t(.+)$')
    if code then
      local path = rest:match('\t(.+)$') or rest  -- renames list old\tnew
      table.insert(files, { verb = verbs[code] or 'Edit', path = path })
    end
  end
  if #files == 1 then
    return { files[1].verb .. ' ' .. files[1].path }
  end
  local lines = { 'Edit ' .. #files .. ' notes', '' }
  for _, f in ipairs(files) do
    table.insert(lines, '- ' .. f.verb .. ' ' .. f.path)
  end
  return lines
end

-- Commit Args
--
-- @param status: string, `git diff --cached --name-status` output
-- @return table, git arguments: subject, then the file list as the body
local commit_args = function(status)
  local msg = commit_message(status)
  local args = { 'commit', '--quiet', '-m', msg[1] }
  if #msg > 2 then
    vim.list_extend(args, { '-m', table.concat(vim.list_slice(msg, 3), '\n') })
  end
  return args
end

-- Reload
--
-- Pick up files a pull changed in open buffers.
--
-- @return nil
local reload = function()
  vim.schedule(function()
    vim.cmd('silent! checktime')
  end)
end

-- Finish
--
-- Release the lock and run a sync that was requested meanwhile.
--
-- @return nil
local finish = function()
  state.busy = false
  if state.again then
    state.again = false
    vim.schedule(git.sync)
  end
end

-- Pull
--
-- Rebase onto the remote, only from a clean tree. Saved-but-uncommitted
-- edits mean a commit is pending (or the tree was edited outside nvim); the
-- sync pulls after committing. Never --autostash: a save landing mid-pull
-- would be stashed, and popping it can write conflict markers into the note
-- while git still exits 0.
--
-- @param opts: table|nil, { force = boolean }
-- @return nil
git.pull = function(opts)
  opts = opts or {}
  if not state.root or state.busy then
    return
  end
  if not opts.force and os.time() - state.pulled_at < state.opts.pull_interval then
    return
  end
  state.busy = true
  run({ 'status', '--porcelain' }, function(status)
    if status.code ~= 0 or vim.trim(status.stdout or '') ~= '' then
      if opts.force then
        notify('uncommitted changes; use :CodexSync to commit and pull', vim.log.levels.WARN)
      end
      return finish()
    end
    run({ 'pull', '--rebase', '--quiet' }, function(result)
      if result.code == 0 then
        state.pulled_at = os.time()
        reload()
        if opts.force then
          notify('pulled')
        end
      else
        return run({ 'rebase', '--abort' }, function()
          notify('pull failed: ' .. vim.trim(result.stderr or ''), vim.log.levels.WARN)
          finish()
        end)
      end
      finish()
    end)
  end)
end

-- Sync
--
-- Commit everything, rebase onto the remote, push.
--
-- @return nil
git.sync = function()
  if not state.root then
    return
  end
  if state.timer then
    state.timer:stop()
  end
  if state.busy then
    state.again = true
    return
  end
  state.busy = true
  run({ 'add', '-A' }, function(added)
    if added.code ~= 0 then
      notify('git add failed: ' .. vim.trim(added.stderr or ''), vim.log.levels.WARN)
      return finish()
    end
    run({ 'diff', '--cached', '--name-status' }, function(diff)
      local steps = {}
      if vim.trim(diff.stdout or '') ~= '' then
        table.insert(steps, { args = commit_args(diff.stdout) })
      end
      table.insert(steps, { args = { 'pull', '--rebase', '--quiet' } })
      table.insert(steps, { args = { 'push', '--quiet' } })
      chain(steps, function(ok, result, step)
        local stderr = (result and result.stderr) or ''
        if ok then
          state.pulled_at = os.time()
          reload()
        elseif step.args[1] == 'pull' and stderr:find('unstaged changes', 1, true) then
          -- a save landed after the commit; its own debounced sync follows
          state.again = state.timer == nil or not state.timer:is_active()
        elseif step.args[1] == 'pull' then
          -- abort before releasing the lock, so nothing reads a half-rebased tree
          return run({ 'rebase', '--abort' }, function()
            reload()
            notify('pull conflicted; committed locally, not pushed — resolve in ' .. state.root ..
              ' then :CodexSync', vim.log.levels.ERROR)
            finish()
          end)
        else
          notify(step.args[1] .. ' failed: ' .. vim.trim(stderr), vim.log.levels.WARN)
        end
        finish()
      end)
    end)
  end)
end

-- Schedule
--
-- (Re)start the commit debounce after a save.
--
-- @return nil
git.schedule = function()
  if not state.timer then
    state.timer = vim.uv.new_timer()
  end
  state.timer:stop()
  state.timer:start(state.opts.commit_delay * 1000, 0, vim.schedule_wrap(git.sync))
end

-- Flush
--
-- On exit: if a commit is pending, commit and push synchronously.
--
-- @return nil
git.flush = function()
  if not state.timer or not state.timer:is_active() then
    return
  end
  state.timer:stop()
  local wait = state.opts.timeout * 1000
  local sh = function(args)
    return vim.system(vim.list_extend({ 'git', '-C', state.root }, args),
      { text = true, env = { GIT_TERMINAL_PROMPT = '0' } }):wait(wait)
  end
  sh({ 'add', '-A' })
  local diff = sh({ 'diff', '--cached', '--name-status' })
  if vim.trim(diff.stdout or '') ~= '' then
    sh(commit_args(diff.stdout))
  end
  if sh({ 'pull', '--rebase', '--quiet' }).code ~= 0 then
    sh({ 'rebase', '--abort' })  -- committed locally; pushed by the next sync
    return
  end
  sh({ 'push', '--quiet' })
end

-- Setup
--
-- @param root: string, realpath of the notes root (a git work tree)
-- @param opts: table|true, overrides for defaults
-- @return nil
git.setup = function(root, opts)
  state.root = root
  state.opts = vim.tbl_extend('force', defaults, type(opts) == 'table' and opts or {})

  local augroup = vim.api.nvim_create_augroup('CodexGit', { clear = true })
  -- skip .git/ (e.g. COMMIT_EDITMSG): syncing there moves HEAD mid-commit
  local under_root = function(path)
    local real = require('codex.util').realpath(path)
    return real and vim.startswith(real, root .. '/')
      and not vim.startswith(real, root .. '/.git/')
  end
  vim.api.nvim_create_autocmd('BufReadPost', {
    group    = augroup,
    callback = function(ev)
      if under_root(ev.match) then
        git.pull()
      end
    end,
  })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group    = augroup,
    callback = function(ev)
      if under_root(ev.match) then
        git.schedule()
      end
    end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', { group = augroup, callback = git.flush })

  vim.api.nvim_create_user_command('CodexSync', git.sync, {})
  vim.api.nvim_create_user_command('CodexPull', function() git.pull({ force = true }) end, {})
end

return git
