""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Visual Mode Mappings                                                         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" line sorting
vmap <leader>sl                   !awk '{print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<CR>
vmap <leader>so                   !sort<CR>

" expand region
vmap         v                    <Plug>(expand_region_expand)
vmap         <C-v>                <Plug>(expand_region_shrink)

" improved copy & paste
vnoremap     <silent> y           y`]
vnoremap     <silent> p           p`]
