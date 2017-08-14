""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Visual Mode Mappings                                                         "
"                                                                              "
" <C-O>  - enters normal mode for one command                                  "
" <C-R>= - insert the result of an expression at the cursor                    "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" line sorting
vmap     <silent> <leader>sl      :'<,'>!awk '{print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<CR>
vmap     <silent> <leader>sa      :'<,'>!sort<CR>

" expand region
vmap              v               <Plug>(expand_region_expand)
vmap              <C-v>           <Plug>(expand_region_shrink)

" improved copy using clipper
vnoremap <silent> y               :<C-u>exe 'call functions#YankOverride()'<CR>
