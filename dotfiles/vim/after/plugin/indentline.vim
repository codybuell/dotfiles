""""""""""""""""""
"                "
"   indentLine   "
"                "
""""""""""""""""""

" bail if indentline is not installed
if !buell#helpers#PluginExists('indentline')
  finish
endif

" some decent options: | ¦ ┆ ┊
let g:indentLine_char = '¦'

let g:indentLine_fileTypeExclude = ['markdown']
let g:indentLine_bufTypeExclude  = ['help','terminal']
let g:indentLine_bufNameExclude  = ['_.*', 'NERD_tree.*']
let g:indentLine_concealcursor   = 'nc'
let g:indentLine_conceallevel    = 2
