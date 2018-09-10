"""""""""""
"         "
"   Ale   "
"         "
"""""""""""

" mappings are defined in plugin/mappings/normal.vim

" keep the sign gutter open
let g:ale_sign_column_always = 1

" remove the background colors for warnings and errors that ale generates
hi clear ALEErrorSign
hi clear ALEWarningSign
highlight! link ALEErrorSign DiffDelete
highlight! link ALEWarningSign Todo

" error and warning signs
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'
