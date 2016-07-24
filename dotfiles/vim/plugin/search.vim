""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Search Plugin                                                                "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" preserve external compatibility options, then enable full vim compatibility
let s:save_cpo = &cpo
set cpo&vim

" mappings
if maparg('/','n') == ""
  nnoremap  <unique>         /   :call HLNextSetTrigger()<CR>/
endif
if maparg('?','n') == ""
  nnoremap  <unique>         ?   :call HLNextSetTrigger()<CR>?
endif
if maparg('n','n') == ""
  nnoremap  <unique><silent> n  n:call HLNext()<CR>
endif
if maparg('N','n') == ""
  nnoremap  <unique><silent> N  N:call HLNext()<CR>
endif

" default highlighting for next match
highlight default HLNext ctermfg=white ctermbg=red

" are we already highlighting next matches?
let g:HLNext_matchnum = 0

" clear previous highlighting and set up new highlighting
function! HLNext ()
  " remove the previous highlighting, if any
  call HLNextOff()

  " add the new highlighting
  let target_pat = '\c\%#\%('.@/.'\)'
  let g:HLNext_matchnum = matchadd('HLNext', target_pat)
endfunction

" clear previous highlighting (if any)
function! HLNextOff ()
  if (g:HLNext_matchnum > 0)
    silent! call matchdelete(g:HLNext_matchnum)
    let g:HLNext_matchnum = 0
  endif
endfunction

" prepare to active next-match highlighting after cursor moves
function! HLNextSetTrigger ()
  augroup HLNext
    autocmd!
    autocmd  CursorMoved  *  :call HLNextMovedTrigger()
  augroup END
endfunction

" highlight and then remove activation of next-match highlighting
function! HLNextMovedTrigger ()
  augroup HLNext
    autocmd!
  augroup END
  call HLNext()
endfunction

" restore previous external compatibility options
let &cpo = s:save_cpo
