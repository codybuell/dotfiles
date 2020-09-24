"""""""""""""""""
"               "
"   Command-T   "
"               "
"""""""""""""""""

" bail if command-t is not installed
if !buell#helpers#PluginExists('command-t')
  finish
endif

nmap                        <Leader>t         <Plug>(CommandT)
nmap                        <Leader>b         <Plug>(CommandTBuffer)
nmap                        <Leader>j         <Plug>(CommandTJump)
nmap                        <leader>h         <Plug>(CommandTHelp)
nnoremap  <silent>          <leader>.         :CommandT %:p:h<CR>
nnoremap  <silent>          <leader>n         :CommandT {{ Notes }}<CR>
nnoremap  <silent>          <leader>c         :CommandT {{ Codex }}<CR>

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

" use a faster scanner than the default ruby
let g:CommandTFileScanner='find'

" supress max files warning
let g:CommandTSuppressMaxFilesWarning=1
