local pinnacle = require('wincent.pinnacle')
local hlg      = buell.util.set_highlight

--------------------------------------------------------------------------------
--                                                                            --
--  Set Terminal Support & Theme                                              --
--                                                                            --
--------------------------------------------------------------------------------

-- configure termguicolors
local supported_terminals = {
  "xterm-256color",
  "tmux-256color",
  "xterm-kitty",
}

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
hlg("Status1", pinnacle.italicize('StatusLine'))
hlg("Status2", pinnacle.extract_highlight('StatusLine'))
hlg("Status3", pinnacle.embolden('StatusLine'))
hlg("Status4", pinnacle.highlight({
  fg = pinnacle.extract_bg('Error'),
  bg = pinnacle.extract_bg('Visual'),
}))
hlg("Status5", pinnacle.highlight({
  fg = pinnacle.extract_fg("Cursor"),
  bg = pinnacle.extract_fg("Status3"),
}))
hlg("Status6", pinnacle.highlight({
  fg = pinnacle.extract_fg("Cursor"),
  bg = pinnacle.extract_fg("Status3"),
  term = 'bold,italic'
}))
hlg("Status7", pinnacle.highlight({
  fg = pinnacle.extract_fg('Normal'),
  bg = pinnacle.extract_bg('Error'),
  term = 'bold',
}))

-- define statusline no color
vim.cmd("highlight clear StatusLineNC")
vim.cmd("highlight! link StatusLineNC Status1")

-----------
--  lsp  --
-----------

-- error
hlg('DiagnosticVirtualTextError', pinnacle.decorate('bold,italic', 'ModeMsg'))
hlg('DiagnosticFloatingError', pinnacle.highlight({fg = pinnacle.extract_fg('ErrorMsg')}))
hlg('DiagnosticSignError', pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('ErrorMsg')}))

-- warning
hlg('DiagnosticVirtualTextWarning', pinnacle.decorate('bold,italic', 'Type'))
hlg('DiagnosticFloatingWarning', pinnacle.highlight({fg = pinnacle.extract_bg('Substitute')}))
hlg('DiagnosticSignWarn', pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_bg('Substitute')}))

-- information
hlg('DiagnosticVirtualTextInformation', pinnacle.decorate('bold,italic', 'Type'))
hlg('DiagnosticFloatingInformation', pinnacle.highlight({fg = pinnacle.extract_fg('Normal')}))
hlg('DiagnosticSignInfo', pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Conceal')}))

-- hint
hlg('DiagnosticVirtualTextHint', pinnacle.decorate('bold,italic', 'Type'))
hlg('DiagnosticFloatingHint', pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
hlg('DiagnosticSignHint', pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Type')}))

-- document_highlight
hlg('LspReferenceText', pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
hlg('LspReferenceRead', pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
hlg('LspReferenceWrite', pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))

----------------
--  markdown  --
----------------

vim.cmd('hi def link buellTodo mkdListItem')
vim.cmd('hi def link buellTodoText Directory')

vim.cmd('hi def link buellInProgressTodo mkdListItem')
vim.cmd('hi def link buellInProgressTodoText Question')

vim.cmd('hi def link buellCompletedTodo mkdListItem')
hlg('buellCompletedTodoText', pinnacle.highlight(pinnacle.adjust_lightness('Ignore', 0.30)))

vim.cmd('hi def link buellDroppedTodo mkdListItem')
hlg('buellDroppedTodoText', pinnacle.decorate('strikethrough', 'buellCompletedTodoText'))

vim.cmd('hi def link buellImportantTodo mkdListItem')
hlg('buellImportantTodoText', pinnacle.decorate('bold', 'Label'))

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
local normal = pinnacle.adjust_lightness('Normal', 0.05)
vim.cmd('highlight! clear NormalFloat')
hlg('NormalFloat', pinnacle.highlight(normal))
normal['fg'] = '#cccccc'
vim.cmd('highlight! clear FloatBorder')
hlg('FloatBorder', pinnacle.highlight(normal) .. ' blend=' .. vim.o.winblend)

-- italicize comments
hlg('Comment', pinnacle.italicize('Comment'))

-- parentheses match is rough by deault
hlg('MatchParen', pinnacle.highlight({
  fg = pinnacle.extract_bg('Error'),
  bg = 'None',
  term = 'bold',
}))

-- make use of lsp hl group for signature help active param
hlg('LspSignatureActiveParameter', pinnacle.decorate('bold'))
