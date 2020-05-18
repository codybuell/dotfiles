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
