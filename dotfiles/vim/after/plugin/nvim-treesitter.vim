""""""""""""""""""""""
"                    "
"   nvim-tresitter   "
"                    "
""""""""""""""""""""""

" bail if not nvim and nvim-treesitter is not installed
if !has('nvim') && !buell#helpers#PluginExists('nvim-treesitter')
  finish
endif

lua require'buell.treesitter'.setup()
