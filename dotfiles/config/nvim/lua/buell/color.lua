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

  --------------
  --  dap-ui  --
  --------------

  vim.cmd("highlight clear WinBar")
  vim.cmd("highlight! link WinBar Status2")
  vim.cmd("highlight clear WinBarNC")
  vim.cmd("highlight! link WinBarNC Status2")
  pinnacle.set('DapUIPlayPause', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIPlayPause')})
  pinnacle.set('DapUIPlayPauseNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIPlayPauseNC')})
  pinnacle.set('DapUIStepInto', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepInto')})
  pinnacle.set('DapUIStepIntoNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepIntoNC')})
  pinnacle.set('DapUIStepOver', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOver')})
  pinnacle.set('DapUIStepOverNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOverNC')})
  pinnacle.set('DapUIStepOut', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOut')})
  pinnacle.set('DapUIStepOutNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOutNC')})
  pinnacle.set('DapUIStepBack', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepBack')})
  pinnacle.set('DapUIStepBackNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepBackNC')})
  pinnacle.set('DapUIRestart', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIRestart')})
  pinnacle.set('DapUIRestartNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIRestartNC')})
  pinnacle.set('DapUIStop', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStop')})
  pinnacle.set('DapUIStopNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStopNC')})

  ---------------------
  --  miscellaneous  --
  ---------------------

  -- listchar overrides to make them more subtle :h listchar for mapping to characters
  hlg('SpecialKey', 'ctermfg=237 guifg=#3a3a3a')
  hlg('NonText', 'ctermfg=237 guifg=#3a3a3a')
  hlg('Whitespace', 'ctermfg=237 guifg=#3a3a3a')

  -- indent blankline because it's linking to Whitespace hl group before it is being set here
  hlg('IblIndent', 'ctermfg=237 guifg=#3a3a3a')
  hlg('IblWhitespace', 'ctermfg=237 guifg=#3a3a3a')
  pinnacle.set('IblScope', pinnacle.brighten('NonText', 0.05))

  -- overrides for (vim)diffs
  hlg('DiffAdd', 'ctermbg=22 guibg=#222f22')
  hlg('DiffDelete', 'ctermbg=52 guibg=#2f2222')
  hlg('DiffChange', 'ctermbg=24 guibg=#22222f')
  hlg('DiffText', 'ctermbg=24 guibg=#22222f')

  -- make floating windows match pmenu
  vim.cmd("highlight! link NormalFloat Pmenu")
  pinnacle.set('FloatBorder', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('NonText')})

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
  pinnacle.set('PmenuDarker', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('NonText')})

end

return color
