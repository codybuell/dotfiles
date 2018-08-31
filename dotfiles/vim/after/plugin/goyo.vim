""""""""""""
"          "
"   Goyo   "
"          "
""""""""""""

" width of text (default: 80)
let g:goyo_width = 160

" height of text (default: 85%)
let g:goyo_height = '85%'

" show line numbers (default: 0)
let g:goyo_linenr = 0

function! s:goyo_enter()
  silent !tmux set status off
  silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set statusline=''
  set laststatus=0
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  call buell#statusline#drawstatusline()
  set laststatus=2
  set showmode
  set showcmd
  set scrolloff=4
  Limelight!
endfunction

" manually calling in buell#helpers#CycleViews to avoid artifacting
"autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" on window resize, if goyo is active, do <c-w>= to resize the window
"autocmd! VimResized * if exists('#goyo') | exe "normal \<c-w>=" | endif
