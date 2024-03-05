local color = {}

local pinnacle = require('wincent.pinnacle')
local hlg      = buell.util.set_highlight

-- configure termguicolors
local supported_terminals = {
  "xterm-256color",
  "tmux-256color",
  "xterm-kitty",
}

color.update = function()
  --------------------------------------------------------------------------------
  --                                                                            --
  --  Set Terminal Support & Theme                                              --
  --                                                                            --
  --------------------------------------------------------------------------------

  -- conditionally set termguicolors
  if buell.util.has_value(supported_terminals, vim.env.TERM) then
    vim.opt.termguicolors = true
  else
    vim.opt.termguicolors = false
  end

  -- determine active base16 shell theme
  local active_theme
  local theme_raw = io.popen('readlink "' .. '$HOME/.base16_theme' ..'"'):read()
  if theme_raw then
    active_theme = string.match(theme_raw, '(base16-[^%/%.]*)%.sh')
  else
    active_theme = 'base16-' .. io.popen('head -1 $HOME/.base16'):read()
  end

  -- set colorscheme
  vim.cmd('colorscheme ' .. active_theme)

  --------------------------------------------------------------------------------
  --                                                                            --
  --  Custom Highlight Groups                                                   --
  --                                                                            --
  --------------------------------------------------------------------------------

  ------------------
  --  statusline  --
  ------------------

  -- define user highlight groups for statusline
  pinnacle.set("Status1", pinnacle.italicize('StatusLine'))
  pinnacle.set("Status2", pinnacle.dump('StatusLine'))
  pinnacle.set("Status3", pinnacle.embolden('StatusLine'))
  pinnacle.set("Status4", {
    fg = pinnacle.bg('Error'),
    bg = pinnacle.bg('Visual'),
  })
  pinnacle.set("Status5", {
    fg = pinnacle.fg("Cursor"),
    bg = pinnacle.fg("Status3"),
  })
  pinnacle.set("Status6", {
    fg = pinnacle.fg("Cursor"),
    bg = pinnacle.fg("Status3"),
    bold = true,
    italic = true,
  })
  pinnacle.set("Status7", {
    fg = pinnacle.fg('Normal'),
    bg = pinnacle.bg('Error'),
    bold = true,
  })

  -- define statusline no color
  vim.cmd("highlight clear StatusLineNC")
  vim.cmd("highlight! link StatusLineNC Status1")

  -----------
  --  lsp  --
  -----------

  -- error
  pinnacle.set('DiagnosticVirtualTextError', pinnacle.decorate('bold,italic', 'ModeMsg'))
  pinnacle.set('DiagnosticFloatingError', {fg = pinnacle.fg('ErrorMsg')})
  pinnacle.set('DiagnosticSignError', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('ErrorMsg')})

  -- warning
  pinnacle.set('DiagnosticVirtualTextWarning', pinnacle.decorate('bold,italic', 'Type'))
  pinnacle.set('DiagnosticFloatingWarning', {fg = pinnacle.bg('Substitute')})
  pinnacle.set('DiagnosticSignWarn', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.bg('Substitute')})

  -- information
  pinnacle.set('DiagnosticVirtualTextInformation', pinnacle.decorate('bold,italic', 'Type'))
  pinnacle.set('DiagnosticFloatingInformation', {fg = pinnacle.fg('Normal')})
  pinnacle.set('DiagnosticSignInfo', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('Conceal')})

  -- hint
  pinnacle.set('DiagnosticVirtualTextHint', pinnacle.decorate('bold,italic', 'Type'))
  pinnacle.set('DiagnosticFloatingHint', {fg = pinnacle.fg('Type')})
  pinnacle.set('DiagnosticSignHint', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('Type')})

  -- document_highlight
  pinnacle.set('LspReferenceText', {fg = pinnacle.fg('Type')})
  pinnacle.set('LspReferenceRead', {fg = pinnacle.fg('Type')})
  pinnacle.set('LspReferenceWrite', {fg = pinnacle.fg('Type')})

  ----------------
  --  markdown  --
  ----------------

  vim.cmd('hi def link buellTodo mkdListItem')
  vim.cmd('hi def link buellTodoText Directory')

  vim.cmd('hi def link buellInProgressTodo mkdListItem')
  vim.cmd('hi def link buellInProgressTodoText Question')

  vim.cmd('hi def link buellCompletedTodo mkdListItem')
  pinnacle.set('buellCompletedTodoText', pinnacle.brighten('Ignore', 0.30))

  vim.cmd('hi def link buellDroppedTodo mkdListItem')
  pinnacle.set('buellDroppedTodoText', pinnacle.decorate('strikethrough', 'buellCompletedTodoText'))

  vim.cmd('hi def link buellImportantTodo mkdListItem')
  pinnacle.set('buellImportantTodoText', pinnacle.decorate('bold', 'Label'))

  ---------------
  --  tabline  --
  ---------------

  vim.cmd("hi clear TabLineSel")
  vim.cmd('hi def link TabLineSel ErrorMsg')

  ---------------------
  --  miscellaneous  --
  ---------------------

  -- listchar overrides to make them more subtle :h listchar for mapping to characters
  hlg('SpecialKey', 'ctermfg=237 guifg=#3a3a3a')
  hlg('NonText', 'ctermfg=237 guifg=#3a3a3a')
  hlg('Whitespace', 'ctermfg=237 guifg=#3a3a3a')

  -- indent blankline because it's linking to Whitespace hl group before it is being set here
  hlg('IndentBlanklineChar', 'ctermfg=237 guifg=#3a3a3a')
  hlg('IndentBlanklineSpaceChar', 'ctermfg=237 guifg=#3a3a3a')
  hlg('IndentBlanklineSpaceChar', 'ctermfg=237 guifg=#3a3a3a')

  -- overrides for (vim)diffs
  hlg('DiffAdd', 'ctermbg=22 guibg=#222f22')
  hlg('DiffDelete', 'ctermbg=52 guibg=#2f2222')
  hlg('DiffChange', 'ctermbg=24 guibg=#22222f')
  hlg('DiffText', 'ctermbg=24 guibg=#22222f')

  -- make floating windows look nicer
  local normal = pinnacle.brighten('Normal', 0.05)
  vim.cmd('highlight! clear NormalFloat')
  pinnacle.set('NormalFloat', normal)
  normal['fg'] = '#cccccc'
  vim.cmd('highlight! clear FloatBorder')
  normal['blend'] = vim.o.winblend
  pinnacle.set('FloatBorder', normal)

  -- italicize comments
  pinnacle.set('Comment', pinnacle.italicize('Comment'))

  -- parentheses match is rough by deault
  pinnacle.set('MatchParen', {
    fg = pinnacle.bg('Error'),
    bg = 'None',
    bold = true,
  })

  -- make use of lsp hl group for signature help active param
  pinnacle.set('LspSignatureActiveParameter', pinnacle.decorate('bold,italic', 'WarningMsg'))
end

return color
