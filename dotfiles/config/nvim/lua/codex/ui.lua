--------------------------------------------------------------------------------
--                                                                            --
--  Codex UI                                                                  --
--                                                                            --
--  Corpus-style chooser: a prompt float on top, a filtered note list on the  --
--  left, and a live preview of the selected note on the right. Typing       --
--  filters (see codex.query for syntax), <C-j>/<C-k>/<Up>/<Down> move the    --
--  selection, <CR> opens the selection (or creates a note when nothing       --
--  matches), <Esc> dismisses.                                                --
--                                                                            --
--------------------------------------------------------------------------------

local util  = require('codex.util')
local query = require('codex.query')

local ui = {}

-- namespace for list highlights
local ns = vim.api.nvim_create_namespace('codex_ui')

-- cap on rendered list lines, keeps extmark work bounded
local MAX_RENDER = 300

-- preview read cap, keeps cloud storage reads bounded
local MAX_PREVIEW = 200

-- module state
local state = {
  open          = false,
  config        = nil,
  origin_win    = nil,
  bufs          = {},     -- prompt, list, preview
  wins          = {},     -- prompt, list, preview
  augroup       = nil,
  parsed        = nil,
  results       = {},
  selected      = 1,
  content_key   = '',     -- joined content terms currently displayed/pending
  content_paths = nil,    -- set of paths matching content terms, nil = pending
  generation    = 0,
  timer         = nil,
  preview_path  = nil,
  saved_laststatus = nil, -- restored on close / navigate-away
  suppress_snap = false,  -- briefly true during intentional C-hjkl navigate
}

---------------
--  Helpers  --
---------------

-- Layout
--
-- Compute float configs for the three windows. Each float has a rounded
-- border (2 rows/cols of chrome).
--
-- @return table: { prompt = cfg, list = cfg, preview = cfg }
local function layout()
  local box = util.popup_geometry()

  local pane_row     = box.row + 3
  local pane_height  = math.max(box.height - 5, 3)
  local list_width   = math.floor((box.width - 4) * 0.4)
  local preview_width = box.width - 4 - list_width

  return {
    prompt = {
      relative = 'editor',
      row      = box.row,
      col      = box.col,
      width    = box.width - 2,
      height   = 1,
      border   = 'rounded',
      style    = 'minimal',
      title    = ' Codex ',
      title_pos = 'center',
    },
    list = {
      relative = 'editor',
      row      = pane_row,
      col      = box.col,
      width    = list_width,
      height   = pane_height,
      border   = 'rounded',
      style    = 'minimal',
    },
    preview = {
      relative = 'editor',
      row      = pane_row,
      col      = box.col + list_width + 2,
      width    = preview_width,
      height   = pane_height,
      border   = 'rounded',
      style    = 'minimal',
    },
  }
end

-- Define Highlights
--
-- @return nil
local function define_highlights()
  vim.api.nvim_set_hl(0, 'CodexSelected',  { link = 'PmenuSel',            default = true })
  vim.api.nvim_set_hl(0, 'CodexMatch',     { link = 'MiniPickMatchRanges', default = true })
  vim.api.nvim_set_hl(0, 'CodexTitle',     { link = 'Comment',             default = true })
  vim.api.nvim_set_hl(0, 'CodexSearching', { link = 'NonText',             default = true })
end

-- Char to Byte Range
--
-- Convert a 0-based character position into a 0-based byte range for extmark
-- highlighting (titles can contain multibyte characters).
--
-- @param line: string
-- @param pos: int, 0-based character index
-- @return int|nil: byte start
-- @return int|nil: byte end
local function char_to_byte_range(line, pos)
  local ok, start_byte = pcall(vim.str_byteindex, line, 'utf-32', pos)
  if not ok then
    return nil, nil
  end
  local ok2, end_byte = pcall(vim.str_byteindex, line, 'utf-32', pos + 1)
  if not ok2 then
    end_byte = start_byte + 1
  end
  return start_byte, end_byte
end

-- Render Preview
--
-- Fill the preview buffer with the head of the selected note.
--
-- @return nil
local function render_preview()
  local buf = state.bufs.preview
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local result = state.results[state.selected]
  local path   = result and result.record.path or nil

  if path == state.preview_path then
    return
  end
  state.preview_path = path

  local lines = {}
  if path then
    local ok, read = pcall(vim.fn.readfile, path, '', MAX_PREVIEW)
    if ok then
      lines = read
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].syntax = 'markdown'
end

-- Render List
--
-- Fill the list buffer with current results, highlight fuzzy matches and the
-- selection, and update the result count in the border title.
--
-- @return nil
local function render_list()
  local buf = state.bufs.list
  local win = state.wins.list
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local shown = math.min(#state.results, MAX_RENDER)
  local lines = {}
  for i = 1, shown do
    lines[i] = state.results[i].haystack
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local pending = state.parsed and #state.parsed.content > 0 and state.content_paths == nil

  for i = 1, shown do
    local result = state.results[i]
    local line   = result.haystack

    -- dim the title span (separated from the path by two spaces)
    local sep = line:find('  ', 1, true)
    if sep then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, sep - 1, {
        end_col  = #line,
        hl_group = 'CodexTitle',
      })
    end

    -- fuzzy match positions
    for _, pos in ipairs(result.positions) do
      local start_byte, end_byte = char_to_byte_range(line, pos)
      if start_byte and end_byte and end_byte <= #line then
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, start_byte, {
          end_col  = end_byte,
          hl_group = 'CodexMatch',
        })
      end
    end
  end

  -- selection
  if shown > 0 then
    vim.api.nvim_buf_set_extmark(buf, ns, state.selected - 1, 0, {
      line_hl_group = 'CodexSelected',
      hl_eol        = true,
    })
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_cursor(win, { state.selected, 0 })
    end
  elseif pending then
    vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
      virt_text     = { { 'searching…', 'CodexSearching' } },
      virt_text_pos = 'overlay',
    })
  end

  -- result count in the list border title
  if win and vim.api.nvim_win_is_valid(win) then
    local title = string.format(' %d/%d ', #state.results, #require('codex.index').get(state.config))
    vim.api.nvim_win_set_config(win, { title = title, title_pos = 'right' })
  end
end

-- Render
--
-- @return nil
local function render()
  render_list()
  render_preview()
end

-- Refilter
--
-- Run the current parsed query against the index and reset the selection.
--
-- @return nil
local function refilter()
  local records = require('codex.index').get(state.config)
  state.results  = query.filter(records, state.parsed, state.content_paths)
  state.selected = 1
end

-- Run Content Search
--
-- Launch one async ripgrep per content term, intersect the resulting path
-- sets, and re-render if the query has not changed since launch.
--
-- @param terms: array of strings
-- @param generation: int, generation at launch time
-- @return nil
local function run_content_search(terms, generation)
  local remaining = #terms
  local sets      = {}
  local root      = util.realpath(state.config.notes)

  for i, term in ipairs(terms) do
    local cmd = { 'rg', '-l', '--ignore-case', '--fixed-strings', '--follow',
                  '--no-ignore-vcs', '--no-messages',
                  '--glob', '*' .. state.config.extension }
    for _, pattern in ipairs(state.config.ignore or {}) do
      table.insert(cmd, '--glob')
      table.insert(cmd, '!' .. pattern)
    end
    table.insert(cmd, term)
    table.insert(cmd, root)

    vim.system(cmd, { text = true }, function(result)
      local set = {}
      for line in (result.stdout or ''):gmatch('[^\n]+') do
        set[line] = true
      end
      sets[i] = set
      remaining = remaining - 1

      if remaining == 0 then
        vim.schedule(function()
          if not state.open or generation ~= state.generation then
            return
          end

          -- intersect the per-term sets
          local paths = sets[1]
          for k = 2, #sets do
            local intersected = {}
            for path in pairs(sets[k]) do
              if paths[path] then
                intersected[path] = true
              end
            end
            paths = intersected
          end

          state.content_paths = paths
          refilter()
          render()
        end)
      end
    end)
  end
end

-- On Input
--
-- Handle prompt buffer changes: parse, filter synchronously when possible,
-- and debounce content searches.
--
-- @return nil
local function on_input()
  local buf = state.bufs.prompt
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local input = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
  state.parsed = query.parse(input)

  local content_key = table.concat(state.parsed.content, '\n')
  if content_key ~= state.content_key then
    state.content_key   = content_key
    state.content_paths = nil
    state.generation    = state.generation + 1

    if state.timer then
      state.timer:stop()
    end

    if content_key ~= '' then
      local terms      = state.parsed.content
      local generation = state.generation
      state.timer = state.timer or vim.uv.new_timer()
      state.timer:start(120, 0, vim.schedule_wrap(function()
        if state.open and generation == state.generation then
          run_content_search(terms, generation)
        end
      end))
    end
  end

  refilter()
  render()
end

-- Move
--
-- Move the selection.
--
-- @param delta: int
-- @return nil
local function move(delta)
  local shown = math.min(#state.results, MAX_RENDER)
  if shown == 0 then
    return
  end
  state.selected = math.min(math.max(state.selected + delta, 1), shown)
  render()
end

-- Close
--
-- Tear down windows, buffers, autocmds, and timers. Idempotent.
--
-- @return nil
local function close()
  if not state.open then
    return
  end
  state.open = false

  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end

  if state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
    state.augroup = nil
  end

  vim.cmd('stopinsert')

  if state.saved_laststatus ~= nil then
    vim.o.laststatus = state.saved_laststatus
    state.saved_laststatus = nil
  end

  for _, win in pairs(state.wins) do
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  for _, buf in pairs(state.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end

  state.wins         = {}
  state.bufs         = {}
  state.preview_path = nil

  if state.origin_win and vim.api.nvim_win_is_valid(state.origin_win) then
    vim.api.nvim_set_current_win(state.origin_win)
  end
end

-- Choose
--
-- Open the selected note in the origin window, or create a new note from the
-- query when nothing matches.
--
-- @return nil
local function choose(opts)
  opts = opts or {}
  local cmd = opts.tab and 'tabedit' or 'edit'

  if #state.results > 0 then
    local path = state.results[state.selected].record.path
    close()
    vim.cmd(cmd .. ' ' .. vim.fn.fnameescape(path))
  else
    local parsed = state.parsed or { plain = {}, tags = {} }
    local name   = table.concat(parsed.plain, ' ')
    close()
    if name ~= '' then
      if opts.tab then vim.cmd('tabnew') end
      require('codex').new_note(name, { tags = parsed.tags })
    end
  end
end

-- Make Scratch Buffer
--
-- @param name: string, buffer name suffix
-- @return int: buffer handle
local function make_scratch(name)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype   = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile  = false
  vim.api.nvim_buf_set_name(buf, 'codex://' .. name)
  return buf
end

------------
--  Main  --
------------

-- Open
--
-- Build/refresh the index and open the chooser.
--
-- @param config: codex config table
-- @return nil
ui.open = function(config)
  -- already open (left via <C-hjkl> navigation): refresh and refocus rather
  -- than rebuild, preserving the query and selection
  if state.open then
    local prompt_win = state.wins.prompt
    if prompt_win and vim.api.nvim_win_is_valid(prompt_win) then
      local current = vim.api.nvim_get_current_win()
      if current ~= prompt_win then
        state.origin_win = current
      end
      local selected = state.selected
      require('codex.index').build(state.config)
      refilter()
      state.selected = math.max(1, math.min(selected, #state.results, MAX_RENDER))
      render()
      vim.o.laststatus = 0
      vim.api.nvim_set_current_win(prompt_win)
      vim.cmd('startinsert!')
      return
    end
    -- windows are gone (e.g. different tab page); reset and reopen
    close()
  end

  define_highlights()

  state.config     = config
  state.origin_win = vim.api.nvim_get_current_win()

  -- build on first open, cheap refresh afterwards
  local index = require('codex.index')
  if index.is_built() then
    index.build(config)
  else
    index.get(config)
  end

  -- buffers
  state.bufs = {
    prompt  = make_scratch('prompt'),
    list    = make_scratch('list'),
    preview = make_scratch('preview'),
  }

  -- windows — list and preview are non-focusable; only the prompt takes focus
  local cfgs = layout()
  cfgs.list.focusable    = false
  cfgs.preview.focusable = false
  state.wins = {
    list    = vim.api.nvim_open_win(state.bufs.list, false, cfgs.list),
    preview = vim.api.nvim_open_win(state.bufs.preview, false, cfgs.preview),
    prompt  = vim.api.nvim_open_win(state.bufs.prompt, true, cfgs.prompt),
  }

  local whl = 'NormalFloat:Normal,FloatBorder:Normal,FloatTitle:Normal'
  for _, win in pairs(state.wins) do
    vim.wo[win].wrap = false
    vim.wo[win].winhighlight = whl
  end
  vim.wo[state.wins.preview].wrap = true

  -- hide statuslines on all floats by temporarily setting laststatus=0
  state.saved_laststatus = vim.o.laststatus
  vim.o.laststatus = 0

  -- keep completion engines out of the prompt (nvim-cmp attaches buffer-local
  -- mappings on InsertEnter that would steal <Up>/<Down>/<C-j>/<C-k>)
  local has_cmp, cmp = pcall(require, 'cmp')
  if has_cmp then
    cmp.setup.buffer({ enabled = false })
  end
  vim.b[state.bufs.prompt].copilot_enabled = false

  state.open          = true
  state.parsed        = query.parse('')
  state.content_key   = ''
  state.content_paths = nil
  state.selected      = 1

  -- prompt keymaps
  local prompt = state.bufs.prompt
  local opts   = { buffer = prompt, nowait = true }
  for _, mode in ipairs({ 'i', 'n' }) do
    vim.keymap.set(mode, '<CR>',   choose,                                    opts)
    vim.keymap.set(mode, '<C-t>',  function() choose({ tab = true }) end,     opts)
    vim.keymap.set(mode, '<Esc>',  close,                                     opts)
    vim.keymap.set(mode, '<Down>', function() move(1) end,                    opts)
    vim.keymap.set(mode, '<Up>',   function() move(-1) end,                   opts)
    vim.keymap.set(mode, '<C-n>',  function() move(1) end,                    opts)
    vim.keymap.set(mode, '<C-p>',  function() move(-1) end,                   opts)
  end

  -- scroll the preview pane from the prompt
  local t = function(s) return vim.api.nvim_replace_termcodes(s, true, false, true) end
  local function scroll_preview(keys)
    local win = state.wins.preview
    if not (win and vim.api.nvim_win_is_valid(win)) then return end
    vim.api.nvim_win_call(win, function()
      vim.cmd('normal! ' .. keys)
    end)
  end
  local scroll_maps = {
    ['<C-f>'] = t('<C-f>'),  -- page down
    ['<C-b>'] = t('<C-b>'),  -- page up
    ['<C-e>'] = t('<C-e>'),  -- line down
    ['<C-y>'] = t('<C-y>'),  -- line up
  }
  for lhs, keys in pairs(scroll_maps) do
    for _, mode in ipairs({ 'i', 'n' }) do
      vim.keymap.set(mode, lhs, function() scroll_preview(keys) end, opts)
    end
  end

  -- leave the chooser open but hand focus back to the editing window, then
  -- fall through to split/tmux pane navigation
  local navigations = {
    ['<C-h>'] = { cmd = 'TmuxNavigateLeft',  wincmd = 'h' },
    ['<C-j>'] = { cmd = 'TmuxNavigateDown',  wincmd = 'j' },
    ['<C-k>'] = { cmd = 'TmuxNavigateUp',    wincmd = 'k' },
    ['<C-l>'] = { cmd = 'TmuxNavigateRight', wincmd = 'l' },
  }
  for lhs, nav in pairs(navigations) do
    for _, mode in ipairs({ 'i', 'n' }) do
      vim.keymap.set(mode, lhs, function()
        vim.cmd('stopinsert')
        if state.saved_laststatus ~= nil then
          vim.o.laststatus = state.saved_laststatus
        end
        state.suppress_snap = true
        vim.defer_fn(function() state.suppress_snap = false end, 200)
        if state.origin_win and vim.api.nvim_win_is_valid(state.origin_win) then
          vim.api.nvim_set_current_win(state.origin_win)
        end
        if vim.fn.exists(':' .. nav.cmd) == 2 then
          vim.cmd(nav.cmd)
        else
          vim.cmd('wincmd ' .. nav.wincmd)
        end
      end, opts)
    end
  end

  -- autocmds
  state.augroup = vim.api.nvim_create_augroup('CodexUI', { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChanged' }, {
    group    = state.augroup,
    buffer   = prompt,
    callback = on_input,
  })
  vim.api.nvim_create_autocmd('VimResized', {
    group    = state.augroup,
    callback = function()
      if not state.open then return end
      local resized = layout()
      resized.list.focusable    = false
      resized.preview.focusable = false
      for name, win in pairs(state.wins) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_config(win, resized[name])
        end
      end
      render()
    end,
  })

  -- snap focus back to the prompt whenever focus lands anywhere other than
  -- the prompt. Covers:
  --   WinEnter:     mouse click, wincmd, list/preview focus escape
  --   FocusGained:  returning from another tmux pane (terminal regains focus)
  --   BufEnter:     buffer-level focus changes
  -- Suppressed briefly during intentional C-hjkl navigate-away.
  local function snap_to_prompt()
    if not state.open or state.suppress_snap then return end
    local pw = state.wins.prompt
    if not (pw and vim.api.nvim_win_is_valid(pw)) then return end
    local cur = vim.api.nvim_get_current_win()
    if cur ~= pw then
      vim.o.laststatus = 0
      vim.api.nvim_set_current_win(pw)
    end
    if vim.fn.mode() ~= 'i' then
      vim.cmd('startinsert!')
    end
  end
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FocusGained' }, {
    group    = state.augroup,
    callback = snap_to_prompt,
  })

  -- if any codex window is closed externally (:q, :close, mouse), tear down
  -- the entire chooser
  local all_codex_bufs = {
    [state.bufs.prompt]  = true,
    [state.bufs.list]    = true,
    [state.bufs.preview] = true,
  }
  vim.api.nvim_create_autocmd('BufWinLeave', {
    group    = state.augroup,
    callback = function(ev)
      if all_codex_bufs[ev.buf] then
        vim.schedule(close)
      end
    end,
  })

  -- initial render and prompt focus
  refilter()
  render()
  vim.cmd('startinsert')
end

ui.close = close

return ui
