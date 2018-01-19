""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Supertab Plugin Configurations                                               "
"                                                                              "
" Additional settings found in ~/.vimrc, complete and enter to select.         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" use enter to identify completion selection (C-y is the default)
" let g:SuperTabCrMapping=1

" refine ultisnips / supertab integration, tab for everything? exapand and go to next tabstop, with autocompletion?

" attempt to perform contextual completion (path, file name, etc)
let g:SuperTabDefaultCompletionType     = "context"
" user <cr> to cancel completion mode and preserve current text
let g:SuperTabCrMapping                 = 1
" contextual completion configurations
let g:SuperTabCompletionContexts        = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&completefunc', '&omnifunc']
let g:SuperTabContextDiscoverDiscovery  =  ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

" call chaining for all file types
autocmd FileType *
  \ if &omnifunc != '' |
  \   call SuperTabChain(&omnifunc, "<c-p>") |
  \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
  \ endif
