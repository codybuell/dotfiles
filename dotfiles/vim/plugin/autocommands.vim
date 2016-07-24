""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autocommand Configurations                                                   "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('autocmd')
  augroup BuellAutocmds

    " reset autocommand group
    autocmd!

    " enforce relative numbers on all buffers and tabs
    au BufWinEnter * set nu rnu

    " auto-remove trailing spaces on php and txt files
    au BufWritePre *.php,*.txt,*.scss :%s/\s\+$//e

    " remember folding / view states
    au BufWinLeave ?* mkview
    au BufWinEnter ?* silent! loadview

    " dont restore cursor position on gitcommits
    au BufEnter * call functions#GitCommitBufEnter()

  augroup END
endif
