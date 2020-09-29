"""""""""""""""""""""""""
"                       "
"   Vim-Expand-Region   "
"                       "
"""""""""""""""""""""""""

" bail if vim-expand-region is not installed
if !buell#helpers#PluginExists('vim-expand-region')
  finish
endif

vmap                        v                 <Plug>(expand_region_expand)
vmap                        <C-v>             <Plug>(expand_region_shrink)

" " Default settings. (NOTE: Remove comments in dictionary before sourcing)
" let g:expand_region_text_objects = {
"       \ 'iw'  :0,
"       \ 'iW'  :0,
"       \ 'i"'  :0,
"       \ 'i''' :0,
"       \ 'i]'  :1, " Support nesting of square brackets
"       \ 'ib'  :1, " Support nesting of parentheses
"       \ 'iB'  :1, " Support nesting of braces
"       \ 'il'  :0, " 'inside line'. Available through https://github.com/kana/vim-textobj-line
"       \ 'ip'  :0,
"       \ 'ie'  :0, " 'entire file'. Available through https://github.com/kana/vim-textobj-entire
"       \ }
