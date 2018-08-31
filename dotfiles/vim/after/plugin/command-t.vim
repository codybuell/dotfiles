"""""""""""""""""
"               "
"   Command-T   "
"               "
"""""""""""""""""

" mappings are defined in plugin/mappings/normal.vim

" supplement vims wildignore for command-t searches
let g:CommandTWildIgnore=&wildignore
let g:CommandTWildIgnore.=',*/.git'
let g:CommandTWildIgnore.=',*/.hg'
let g:CommandTWildIgnore.=',*/bower_components'
let g:CommandTWildIgnore.=',*/node_modules'
let g:CommandTWildIgnore.=',*/vendor'
let g:CommandTWildIgnore.=',*/tmp'
let g:CommandTWildIgnore.=',*.DS_Store'

" also use escape key to close out file listing
let g:CommandTCancelMap=['<ESC>', '<C-c>']
