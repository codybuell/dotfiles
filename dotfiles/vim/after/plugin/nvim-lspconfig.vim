""""""""""""""""""""""""""""""""""
"                                "
"   nvim-lsp + diagnostic-nvim   "
"                                "
""""""""""""""""""""""""""""""""""

" bail if not nvim and nvim-lsp is not installed
if !has('nvim') && !buell#helpers#PluginExists('nvim-lsp')
  finish
endif

" load nvim-lsp lua config see ~/.vim/lua/buell/lsp.lua
lua require'buell.lsp'.setup()

" call at least once, this is a shim since the au below is not working with my
" current nvim nightly build...
lua require'buell.lsp'.setup_highlight()

" handle autocommands that can't be sorted in on_attach
if has('autocmd')
  augroup BuellLSPPreAutocmds
    autocmd!
    autocmd ColorScheme * lua require'buell.lsp'.setup_highlight()
    autocmd WinEnter * lua require'buell.lsp'.bind()
  augroup END
endif
