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

  ---------------
  --  tabline  --
  ---------------

  vim.cmd("hi clear TabLineSel")
  vim.cmd('hi def link TabLineSel ErrorMsg')

  ---------------------
  --  miscellaneous  --
  ---------------------

  -- listchar overrides to make them more subtle :h listchar for mapping to characters
  pinnacle.set('SpecialKey', { fg = pinnacle.darken('Normal', 0.55).fg })
  pinnacle.set('NonText', { fg = pinnacle.darken('Normal', 0.55).fg })
  pinnacle.set('Whitespace', { fg = pinnacle.darken('Normal', 0.55).fg })

  -- indent blankline because it's linking to Whitespace hl group before it is being set here
  pinnacle.set('IblIndent', { fg = pinnacle.darken('Normal', 0.55).fg })
  pinnacle.set('IblWhitespace', { fg = pinnacle.darken('Normal', 0.55).fg })
  pinnacle.set('IblScope', pinnacle.brighten('NonText', 0.05))

  -- overrides for (vim)diffs
  hlg('DiffAdd', 'ctermbg=22 guibg=#222f22')
  hlg('DiffDelete', 'ctermbg=52 guibg=#2f2222')
  hlg('DiffChange', 'ctermbg=24 guibg=#1b2d4a')
  hlg('DiffText', 'ctermbg=24 guibg=#1b2d4a ctermfg=3 guifg=#f0c674')

  -- make floating windows match pmenu
  vim.cmd("highlight! link NormalFloat Pmenu")
  pinnacle.set('FloatBorder', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.darken('Normal', 0.3).fg})

  -- make popup menu show current line selection
  pinnacle.set('PmenuSel', {
    bg = pinnacle.bg('Normal'),
    fg = pinnacle.fg('CursorLine'),
    bold = true,
  })

  -- italicize comments
  pinnacle.set('Comment', pinnacle.italicize('Comment'))

  -- parentheses match is rough by default
  pinnacle.set('MatchParen', {
    fg = pinnacle.bg('Error'),
    bg = 'None',
    bold = true,
  })

  -- make use of lsp hl group for signature help active param
  pinnacle.set('LspSignatureActiveParameter', pinnacle.decorate('bold,italic', 'WarningMsg'))

  -- used by nvim-cmp and others that want a darker border around popup menus
  vim.cmd("highlight! link PmenuDarker FloatBorder")

end

return color
