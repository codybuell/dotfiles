""""""""""""""""""
"                "
"   indentLine   "
"                "
""""""""""""""""""

" bail if goyo is not installed
if !buell#helpers#PluginExists('indentline')
  finish
endif

let g:indentLine_fileTypeExclude = ['markdown']
let g:indentLine_bufTypeExclude  = ['help','terminal']
let g:indentLine_bufNameExclude  = ['_.*', 'NERD_tree.*']
