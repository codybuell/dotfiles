""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Visual Mode Mappings                                                         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" line sorting
vmap <leader>sl                   !awk '{print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<CR>
vmap <leader>so                   !sort<CR>
