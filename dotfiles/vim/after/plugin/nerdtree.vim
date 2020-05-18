""""""""""""""""
"              "
"   Nerdtree   "
"              "
""""""""""""""""

" bail if nerdtree is not installed
if !buell#helpers#PluginExists('nerdtree')
  finish
endif

" widen the nerdtree window
let g:NERDTreeWinSize = 40

" disable display of '?' text and 'Bookmarks' labels
let g:NERDTreeMinimalUI = 1

" prevent conflict with window pane mappings
let g:NERDTreeMapJumpPrevSibling = '<Nop>'
let g:NERDTreeMapJumpNextSibling = '<Nop>'

" show hidden files in listing
let g:NERDTreeShowHidden = 1

" set tab to toggle directories open or closed
call NERDTreeAddKeyMap({
  \ 'key': '<Tab>',
  \ 'callback': 'NERDTreeTabHandler',
  \ 'quickhelpText': 'toggle directories open or closed',
  \ 'scope': 'DirNode' })

function! NERDTreeTabHandler(dirnode)
  normal o
endfunction
