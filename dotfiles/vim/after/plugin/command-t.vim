""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Command-T Plugin Configurations                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" supplement vims wildignore for command-t searches
let g:CommandTWildIgnore=&wildignore
let g:CommandTWildIgnore.=',*/.git'
let g:CommandTWildIgnore.=',*/.hg'
let g:CommandTWildIgnore.=',*/bower_components'
let g:CommandTWildIgnore.=',*/node_modules'
let g:CommandTWildIgnore.=',*/vendor'
let g:CommandTWildIgnore.=',*/tmp'
let g:CommandTWildIgnore.=',*.DS_Store'

" use escape key to close out file listing
if &term =~# 'screen' || &term =~# 'xterm'
  let g:CommandTCancelMap=['<ESC>', '<C-c>']
endif

" override default colors
let g:CommandTHighlightColor = 'GitGutterDelete'

" fix arrow mappings
if &term =~# 'screen' || &term =~# 'tmux' || &term =~# 'xterm'
  let g:CommandTSelectNextMap  = ['<C-n>', '<C-j>', '<Down>', '<ESC>OB']
  let g:CommandTSelectPrevMap  = ['<C-p>', '<C-k>', '<Up>', '<ESC>OA']
  let g:CommandTCursorLeftMap  = ['<C-h>', '<Left>', '<ESC>OD']
  let g:CommandTCursorRightMap = ['<C-l>', '<Right>', '<ESC>OC']
endif
