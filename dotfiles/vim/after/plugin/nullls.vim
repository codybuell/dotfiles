"""""""""""""""
"             "
"   null-ls   "
"             "
"""""""""""""""

" bail if null-ls is not installed
if !buell#helpers#PluginExists('null-ls.nvim')
  finish
endif

lua require'buell.nullls'.setup()
