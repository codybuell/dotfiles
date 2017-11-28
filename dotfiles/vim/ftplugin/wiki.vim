""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Wiki Filetype                                                                "
"                                                                              "
" Functionality depends on vim-markdown plugin by plasticboy.                  "
"                                                                              "
" related files:                                                               "
"    autoload/wiki.vim                                                         "
"    plugin/wiki.vim                                                           "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent> <enter>             :<C-U>call wiki#CreateFollowWikiLink()<CR>
