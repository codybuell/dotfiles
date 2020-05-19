""""""""""""""""""
"                "
"   indentLine   "
"                "
""""""""""""""""""

if has('autocmd')
  augroup BuellIndentLine
    autocmd!
    " conflicts with vim-markdown conceal / reveal
    autocmd FileType markdown let b:indentLine_enabled = 0
  augroup END
endif
