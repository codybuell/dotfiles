local statusline = {}

local diagnostics = require('lsp-status/diagnostics')
local messages    = require('lsp-status/messaging').messages

---------------------------------------------------------------------------------
--                                                                             --
--  Configurations                                                             --
--                                                                             --
---------------------------------------------------------------------------------

-- codecompanion spinner state
local codecompanion_processing = false
local codecompanion_spinner_index = 1

-- symbols for lsp status
local symbols = {
  indicator_ok             = ' ',
  indicator_separator      = ' ',
  indicator_errors         = '×',
  indicator_warnings       = '‼',
  indicator_info           = 'i',
  indicator_hint           = '⚐',
  lsp_status_symbol        = 'Ꮭ',
  copilot_status_symbol    = 'Ꮯ',
  treesitter_status_symbol = 'T',
  line_indicator           = 'ℓ',
  column_indicator         = '𝚌',
  spinner_frames           = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  codecomp_spinner_frames  = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  codecompanion_status_symbol = 'Ꮆ',
}

-- aliases for client names
local aliases = {
  pyls_ms = 'MPLS',
}

--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Integration                                                 --
--                                                                            --
--------------------------------------------------------------------------------

local function init_codecompanion()
  local group = vim.api.nvim_create_augroup("CodeCompanionStatuslineHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        codecompanion_processing = true
      elseif request.match == "CodeCompanionRequestFinished" then
        codecompanion_processing = false
      end
    end,
  })
end

local function codecompanion_spinner()
  if codecompanion_processing then
    codecompanion_spinner_index = (codecompanion_spinner_index % #symbols.codecomp_spinner_frames) + 1
    return symbols.codecomp_spinner_frames[codecompanion_spinner_index] .. ' ' .. symbols.codecompanion_status_symbol
  else
    return nil
  end
end

init_codecompanion()

---------------------------------------------------------------------------------
--                                                                             --
--  Helpers                                                                    --
--                                                                             --
---------------------------------------------------------------------------------

local lspstatus = function(bufnr)
  -- set to buffer 0 if nil passed
  bufnr = bufnr or 0

  -- if no lsp clients registered bail
  if #vim.lsp.get_clients({bufnr = bufnr}) == 0 then
    return ''
  end

  -- setup initial variables
  local buf_diagnostics  = diagnostics(bufnr)
  local buf_messages     = messages()
  local only_hint        = true
  local some_diagnostics = false
  local status_parts     = {}
  local msgs             = {}

  -- if we have lsp errors append them to the status_parts table (symbol + separator + count)
  if buf_diagnostics.errors and buf_diagnostics.errors > 0 then
    table.insert(status_parts, symbols.indicator_errors .. symbols.indicator_separator .. buf_diagnostics.errors)
    only_hint        = false
    some_diagnostics = true
  end

  -- if we have lsp warnings append them to the status_parts table (symbol + separator + count)
  if buf_diagnostics.warnings and buf_diagnostics.warnings > 0 then
    table.insert(status_parts, symbols.indicator_warnings .. symbols.indicator_separator .. buf_diagnostics.warnings)
    only_hint        = false
    some_diagnostics = true
  end

  -- if we have lsp info append them to the status_parts table (symbol + separator + count)
  if buf_diagnostics.info and buf_diagnostics.info > 0 then
    table.insert(status_parts, symbols.indicator_info .. symbols.indicator_separator .. buf_diagnostics.info)
    only_hint        = false
    some_diagnostics = true
  end

  -- if we have lsp hints append them to the status_parts table (symbol + separator + count)
  if buf_diagnostics.hints and buf_diagnostics.hints > 0 then
    table.insert(status_parts, symbols.indicator_hint .. symbols.indicator_separator .. buf_diagnostics.hints)
    some_diagnostics = true
  end

  -- handle messages
  for _, msg in ipairs(buf_messages) do
    local name = aliases[msg.name] or msg.name
    local client_name = '[' .. name .. ']'
    local contents = ''
    -- handle progress type messages
    if msg.progress then
      -- commented out temporarily to try out spinners only
      -- contents = msg.title
      -- if msg.message then
      --   contents = contents .. ' ' .. msg.message
      -- end
      -- if msg.percentage then
      --   contents = contents .. ' (' .. msg.percentage .. ')'
      -- end
      if msg.spinner then
        contents = symbols.spinner_frames[(msg.spinner % #symbols.spinner_frames) + 1] .. ' ' .. contents
      end
    -- handle status type messages
    elseif msg.status then
      contents = msg.content
      if msg.uri then
        local filename = vim.uri_to_fname(msg.uri)
        filename = vim.fn.fnamemodify(filename, ':~:.')
        local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
        if #filename > space then
          filename = vim.fn.pathshorten(filename)
        end

        contents = '(' .. filename .. ') ' .. contents
      end
    -- else general messages
    else
      contents = msg.content
    end

    -- add client messages
    table.insert(msgs, client_name .. ' ' .. contents)
  end

  -- concatenate diagnostics states + messages
  local base_status = vim.trim(table.concat(status_parts, ' ') .. ' ' .. table.concat(msgs, ' '))

  -- prep "lsp on" status symbol with conditional space
  local symbol = symbols.lsp_status_symbol .. ' ' .. ((some_diagnostics and only_hint) and '' or ' ')

  -- return lsp on + diagnostics states if present
  if base_status ~= '' then
    return symbol .. base_status .. ' '
  end

  -- else return lsp on
  return symbol .. symbols.indicator_ok .. ' '
end

local line_indicator = function()

  -- local indicator = {
  --   ' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'
  -- }
  -- local indicator = {
  --   '  ', '░ ', '▒ ', '▓ ', '█ ', '█░', '█▒', '█▓', '██'
  -- }
  -- local indicator = {
  --   '   ', '▏  ', '▎  ', '▍  ', '▌  ',
  --   '▋  ', '▊  ', '▉  ', '█  ', '█▏ ',
  --   '█▎ ', '█▍ ', '█▌ ', '█▋ ', '█▊ ',
  --   '█▉ ', '██ ', '██▏', '██▎', '██▍',
  --   '██▌', '██▋', '██▊', '██▉', '███',
  -- }
  --
  -- local indicator = {'⠁', '⠉', '⠋', '⠛', '⠟', '⠿'}
  --
  local indicator = {'⎺', '⎻', '─', '⎼', '⎽'}

  -- get position and total lines
  local cur_line = vim.fn.line('.')
  local tot_line = vim.fn.line('$')

  local index
  local percentage
  if cur_line == 1 then
    index = 1
  elseif cur_line == tot_line then
    index = #indicator
  else
    percentage = cur_line / tot_line
    index = math.floor((percentage * #indicator) + 0.5)
  end

  -- fix for lua's non-zero indexing
  if index == 0 then
    index = 1
  end

  return indicator[index]
end

statusline.cur_func = function(bufnr)
  -- set to buffer 0 if nil passed
  bufnr = bufnr or 0

  -- if no lsp clients registered bail
  if #vim.lsp.get_clients({bufnr = bufnr}) == 0 then
    return ''
  end

  -- return the current function or ''
  return vim.b.lsp_current_function or ''
end

statusline.lhs = function()
  local gutter_width = buell.util.gutter_width()
  local treesitter   = vim.fn['nvim_treesitter#statusline']({1})
  local lspclient    = #vim.lsp.get_clients({bufnr = 0}) > 0
  local line         = ' '

  -- copilot.vim
  local copilot_client = vim.fn['copilot#Enabled']()
  if copilot_client ~= 0 then
    line = line .. ' ' .. symbols.copilot_status_symbol
  end

  -- copilot.lua
  -- if require("copilot.client").buf_is_attached(0) == true then
  --   line = line .. ' ' .. symbols.copilot_status_symbol
  -- end

  if treesitter ~= vim.NIL or lspclient then
    if treesitter ~= vim.NIL then
      line = line .. ' ' .. symbols.treesitter_status_symbol
    end

    if lspclient then
      line = line .. ' ' .. lspstatus()
    end

    local diff = gutter_width - string.len(line) + 2
    if diff > 0 then
      line = line .. string.rep(" ", diff)
    end
  else
    line = line .. string.rep(" ", gutter_width)
  end

  -- codecompanion spinner
  local cc_spinner = codecompanion_spinner()
  if cc_spinner then
    line = line .. ' ' .. cc_spinner
  end

  return line
end

statusline.path = function()
  local basename = vim.fn.fnamemodify(vim.fn.expand('%:h'), ':p:~:.')
  if basename == '' or basename == '.' then
    return ''
  else
    local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
    local path  = basename:gsub('/$', '') .. '/'
    if #path > space then
      path = vim.fn.pathshorten(path)
    end
    return path
  end
end

statusline.session = function()
  if vim.fn.exists(':Obsession') then
    local session = buell.util.split_str(vim.v.this_session, '/')
    local sname   = session[#session] or ''
    if #sname then
      return sname .. ' '
    end
  end
end

statusline.rhs = function()
  local line = ' '

  if vim.fn.winwidth(0) > 80 then
    local _, c = unpack(vim.api.nvim_win_get_cursor(0))
    local col_pos  = c + 1
    local col_size = vim.fn.strwidth(vim.fn.getline('.'))
    -- local col_pos  = vim.fn.virtcol('.')
    -- local col_size = vim.fn.virtcol('$') - 1
    local horiz_pos = col_pos .. '/' .. col_size

    line = table.concat {
      ' ',
      symbols.line_indicator,
      ' ',
      line_indicator(),
      ' ',
      symbols.column_indicator,
      ' ',
      horiz_pos,
      ' ',
    }

    -- add padding to stop rhs from jumping too much
    local count = 5 - string.len(horiz_pos)
    line = line .. string.rep(' ', count)
  end

  return line
end

statusline.meta = function()
  local states = {}

  -- session
  if vim.fn.exists(':Obsession') then
    local session = vim.v.this_session or ''
    if #session > 0 then
      table.insert(states, 'S')
    end
  end

  -- modified
  if vim.bo.modified then
    table.insert(states, '+')
  end

  -- read only
  if vim.bo.readonly then
    table.insert(states, 'ro')
  end

  -- filetype
  local filetype = vim.bo.filetype
  if #filetype > 0 then
    table.insert(states, filetype)
  end

  -- file encoding
  if vim.bo.fenc and vim.bo.fenc ~= "" then
    table.insert(states, vim.bo.fenc)
  end

  -- file format
  if vim.bo.ff then
    table.insert(states, vim.bo.ff)
  end

  return table.concat(states, ",")
end

---------------------------------------------------------------------------------
--                                                                             --
--  Statusline                                                                 --
--                                                                             --
---------------------------------------------------------------------------------

statusline.default = function()
  return table.concat {
    "%#Status7#",                            -- switch to Status7 highlight group
    "%{v:lua.buell.statusline.lhs()}",       -- render statusline left hand side
    "%#Status4#",                            -- switch to Status4 highlight group
    "",                                     -- powerline arrow
    "%#Status2#",                            -- switch to Status2 highlight group
    " ",                                     -- space
    "%<",                                    -- truncation point if not wide enough
    "%{v:lua.buell.statusline.path()}",      -- relative path to file's directory
    "%#Status3#",                            -- switch to Status3 highlight group
    "%t",                                    -- filename
    " ",                                     -- space
    "%#Status1#",                            -- switch to Status1 highlight group
    "%(",                                    -- start item group
    "[",                                     -- left bracket literal
    "%{v:lua.buell.statusline.meta()}",      -- modified, ro, type, encoding, format
    "]",                                     -- right bracket literal
    "%)",                                    -- end item group
    "%#Status2#",                            -- switch to Status2 highlight group
    "%=",                                    -- split point for left and right groups
    " ",                                     -- space
    "%{v:lua.buell.statusline.cur_func()}",  -- current function under cursor
    -- current_branch(),
    " ",                                     -- space
    "%#Status1#",                            -- switch to Status1 highlight group
    "",                                     -- powerline arrow
    "%#Status5#",                            -- switch to Status5 highlight group
    "%{v:lua.buell.statusline.rhs()}",       -- call rhs statusline autocommand
  }
end

statusline.wordcountprogress = function(words)
  local targetwords = words or 750
  local wordcount   = vim.fn.wordcount().words
  local windowidth  = vim.fn.winwidth(0)

  local padding = string.rep(' ', math.floor((wordcount * windowidth) / targetwords))

  if wordcount >= targetwords then
    return table.concat {
      "%#Normal#",
    }
  else
    return table.concat {
      "%#Status7#",
      padding,
      "%#Status4#",
      "",
    }
  end
end

statusline.update = function()
  local line
  local filetype = vim.bo.filetype

  -- set statusline based on buffer type
  if filetype == 'diff' then
    line = ''
  elseif filetype == 'fugitive' then
    line = table.concat {
      string.rep(' ', buell.util.gutter_width()),
      ' ',
      '%<',
      '%q',
      ' ',
      '[fugitive]',
      '%=',
    }
  elseif filetype == 'qf' then
    line = table.concat {
      string.rep(' ', buell.util.gutter_width()),
      ' ',
      ' ',
      '%<',
      '%q',
      ' ',
      '%{get(w:,"quickfix_title","")}',
      '%=',
    }
  elseif buell.util.has_value({'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches', 'dapui_console'}, filetype) then
    local winname = filetype:sub(7, -1)
    line = table.concat {
      '  [',
      winname,
      ']',
    }
  elseif filetype == 'dap-repl' then
    line = '  [repl]'
  else
    line = "%!luaeval('buell.statusline.default()')"
  end

  vim.wo.statusline = line
end

return statusline
