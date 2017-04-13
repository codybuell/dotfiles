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

    " equalize splits on window resize
    autocmd VimResized * execute "normal! \<c-w>="

    " color column bg focus toggling styles
    " if exists('+colorcolumn')
    "   autocmd BufEnter,FocusGained,VimEnter,WinEnter * if autocmds#should_colorcolumn() | let &l:colorcolumn='+' . join(range(0, 254), ',+') | endif
    "   autocmd FocusLost,WinLeave * if autocmds#should_colorcolumn() | let &l:colorcolumn=join(range(1, 255), ',') | endif
    " endif

    " cursor line focus toggling styles
    autocmd InsertLeave,VimEnter,WinEnter * if autocmds#should_cursorline() | setlocal cursorline | endif
    autocmd InsertEnter,WinLeave * if autocmds#should_cursorline() | setlocal nocursorline | endif

    " status line focus toggling styles
    if has('statusline')
      autocmd BufEnter,FocusGained,VimEnter,WinEnter * call autocmds#focus_statusline()
      autocmd FocusLost,WinLeave * call autocmds#blur_statusline()
    endif

    " syntax hl focus toggling styles
    autocmd BufEnter,FocusGained,VimEnter,WinEnter * call autocmds#focus_syntaxhl()
    autocmd FocusLost,WinLeave * call autocmds#blur_syntaxhl()

  augroup END
endif
