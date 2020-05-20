""""""""""""""""
"              "
"   vim-json   "
"              "
""""""""""""""""

" bail if goyo is not installed
if !buell#helpers#PluginExists('vim-json')
  finish
endif

let g:vim_json_syntax_conceal = 0
