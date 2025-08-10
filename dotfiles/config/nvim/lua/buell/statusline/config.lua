-- lua/buell/statusline/config.lua

local M = {}

-- Validate configuration on load
local function validate_config()
  assert(type(M.symbols) == 'table', 'symbols must be a table')
  assert(type(M.symbols.spinner_frames) == 'table', 'spinner_frames must be a table')
  assert(#M.symbols.spinner_frames > 0, 'spinner_frames cannot be empty')
end

-- Hot reload support
function M.reload()
  package.loaded['buell.statusline.config'] = nil
  return require('buell.statusline.config')
end

-- Core symbols used throughout statusline
M.symbols = {
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
  adapter_symbol           = '⚙',
  token_symbol             = '⛁',
  tools_symbol             = '⚒',
  context_symbol           = '☷',
  watch_symbol             = '◎',
  error_symbol             = '‼',
  complete_symbol          = '✓',
  powerline_left           = '',
  powerline_right          = '',
}

-- LSP client name aliases
M.aliases = {
  pyls_ms = 'MPLS',
}

-- Line position indicators
M.line_indicators = {'⎺', '⎻', '─', '⎼', '⎽'}

-- Highlight group mappings
M.highlights = {
  lhs         = 'StatusLineLeft',
  arrow_left  = 'StatusLineArrowLeft',
  main        = 'StatusLineMiddle',
  main_accent = 'StatusLineMiddleAccent',
  main_bold   = 'StatusLineMiddleBold',
  meta        = 'StatusLineArrowRight',
  rhs         = 'StatusLineRight',
}

-- Validate on load
validate_config()

return M
