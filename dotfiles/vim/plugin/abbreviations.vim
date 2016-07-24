""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Abbreviation Configurations                                                  "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" laravel
abbrev gc   !php artisan generate:controller
abbrev gm   !php artisan generate:model
abbrev gmig !php artisan generate:migration

" open help in a new tab
cnoreabbrev <expr> h    getcmdtype() == ":" && getcmdline() == 'h' ? 'tab help' : 'h'
cnoreabbrev <expr> help getcmdtype() == ":" && getcmdline() == 'help' ? 'tab help' : 'help'
