""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Supertab Plugin Configurations                                               "
"                                                                              "
" Additional settings found in ~/.vimrc, complete and enter to select.         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" attempt to perform contextual completion (path, file name, etc)
let g:SuperTabDefaultCompletionType        = "context"

" change the order in which you 'scroll' through completions
let g:SuperTabContextDefaultCompletionType = "<c-n>"

" contextual completion configurations
let g:SuperTabCompletionContexts           = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence    = ['&completefunc', '&omnifunc']
let g:SuperTabContextDiscoverDiscovery     = ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

" call chaining for all file types
autocmd FileType *
  \ if &omnifunc != '' |
  \   call SuperTabChain(&omnifunc, "<c-p>") |
  \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
  \ endif
