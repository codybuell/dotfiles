""""""""""""""""""""
"                  "
"   deoplete-lsp   "
"                  "
""""""""""""""""""""

" bail if base16-vim is not installed
if !buell#helpers#PluginExists('deoplete-lsp')
  finish
endif

" whether or not to show textDocument/hover for lsp items in completion menu
let g:deoplete#lsp#handler_enabled = v:true
