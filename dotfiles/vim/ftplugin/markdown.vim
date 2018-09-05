" used in with vim-markdown to hide bolded text symbols and other bits
setlocal conceallevel=2

" remap enter to create or follow links
nnoremap <silent><buffer>   <enter>           :<C-U>call buell#wiki#createFollowWikiLink()<CR>

" enable spell checking
setlocal spell
