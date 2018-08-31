""""""""""""""""""""
"                  "
"   Vim-Hardtime   "
"                  "
""""""""""""""""""""

" rules
let g:list_of_normal_keys = ["h", "j", "k", "l", "w", "b"]
let g:list_of_visual_keys = ["h", "j", "k", "l"]
let g:list_of_insert_keys = []
let g:list_of_disabled_keys = []

" timeout enforcement
let g:hardtime_timeout = 1000

" ignore quickfix
let g:hardtime_ignore_quickfix = 1

" allow keys if interspersed with others
let g:hardtime_allow_different_key = 1

" max number of repetative keystrokes
let g:hardtime_maxcount = 3
