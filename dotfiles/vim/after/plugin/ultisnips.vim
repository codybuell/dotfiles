""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Ultisnips Plugin Configurations                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" bindings
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" split window
let g:UltiSnipsEditSplit="vertical"

" setup paths
let g:UltiSnipsSnippetsDir = '~/.vim/ultisnips'
let g:UltiSnipsSnippetDirectories = ['ultisnips']

" ATTEMPT TO USE TAB FOR EVERYTHING
"
" let g:ulti_expand_or_jump_res = 0
" function! Ulti_ExpandOrJump_and_getRes()
"   call UltiSnips#ExpandSnippetOrJump()
"   return g:ulti_expand_or_jump_res
" endfunction

" inoremap <tab> <C-R>=(Ulti_ExpandOrJump_and_getRes() > 0)?"":SuperTab<CR>

"  ----------   OTHER OPTION   -----------

" let g:ulti_expand_or_jump_res = 0
" function! g:UltiSnips_Complete()
"     call UltiSnips#ExpandSnippetOrJump()
"     if g:ulti_expand_or_jump_res == 0
"         echom 'expand or jump failed'
"         if pumvisible()
"             echom 'pum is visible'
"             return "\<C-n>"
"         else
"             echom 'pum not visible'
"             return "\<TAB>"
"         endif
"     endif
"     echom 'expand or jump result: ' . g:ulti_expand_or_jump_res
"     return ""
" endfunction

" au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsListSnippets="<c-e>"
" " this mapping Enter key to <C-y> to chose the current highlight item 
" " and close the selection list, same as other IDEs.
" " CONFLICT with some plugins like tpope/Endwise
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
