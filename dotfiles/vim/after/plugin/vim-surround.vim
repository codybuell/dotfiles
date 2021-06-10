""""""""""""""""""""
"                  "
"   Vim Surround   "
"                  "
""""""""""""""""""""

" bail if vim-surround is not installed
if !buell#helpers#PluginExists('vim-surround')
  finish
endif

" disable insert mode mappings, must be run in init.vim...
"let g:surround_no_insert_mappings = 1
