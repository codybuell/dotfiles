""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Insert Mode Mappings                                                         "
"                                                                              "
" <C-O>  - enters normal mode for one command                                  "
" <C-R>= - insert the result of an expression at the cursor                    "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" overrides

" customizations
imap jj                           <esc>
nnoremap <silent> <leader>c       <C-O>:syntax sync fromstart<CR>

" functions
inoremap <silent> <leader>u       <C-O>:call functions#Underline()<CR>
