" used in with vim-markdown to hide bolded text symbols and other bits
setlocal conceallevel=2

" remap enter to create or follow links
nnoremap <silent><buffer>   <enter>           :<C-U>call buell#wiki#createFollowWikiLink()<CR>
xnoremap <silent><buffer>   <enter>           c[<C-r>"]()<Esc>

" " link to whatever is in the system clipboard
" nnoremap <Leader>4 ciw[<C-r>"](<Esc>"*pli)<Esc>
" vnoremap <Leader>4 c[<C-r>"](<Esc>"*pli)<Esc>

" enable spell checking
setlocal spell
