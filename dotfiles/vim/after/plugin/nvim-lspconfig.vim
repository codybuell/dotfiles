""""""""""""""""""""""""""""""""""
"                                "
"   nvim-lsp + diagnostic-nvim   "
"                                "
""""""""""""""""""""""""""""""""""

" bail if not nvim and nvim-lsp is not installed
if !has('nvim') && !buell#helpers#PluginExists('nvim-lsp')
  finish
endif

" override sign column symbols
sign define LspDiagnosticsSignError text=×
sign define LspDiagnosticsSignWarning text=‼
sign define LspDiagnosticsSignInformation text=i
sign define LspDiagnosticsSignHint text=☝

" load nvim-lsp lua config see ~/.vim/lua/buell/lsp.lua
lua require'buell.lsp'.setup()

" handle autocommands that can't be sorted in on_attach
if has('autocmd')
  augroup BuellLSPPreAutocmds
    autocmd!
    autocmd ColorScheme * lua require'buell.lsp'.setup_highlight()
    autocmd WinEnter * lua require'buell.lsp'.bind()
  augroup END
endif
