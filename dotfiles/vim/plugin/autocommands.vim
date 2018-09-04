" BufEnter       after entering a buffer, good for setting file type options
" BufWinEnter    when a buffer is loaded and also when displayed in a window
" BufWinLeave    when a buffer is removed from the window

if has('autocmd')
  augroup BuellAutocmds

    " reset autocommand group
    autocmd!

    " disable paste mode on leaving insert mode
    autocmd InsertLeave * set nopaste

    " don't insert a new comment character after o/O cmd
    autocmd BufEnter * setlocal formatoptions-=o

    " setting this in vimrc is not working... can't find culprit so set here
    autocmd BufEnter * set foldtext=buell#foldtext#CustomFoldText()

    " enforce relative numbers on all buffers and tabs
    au BufWinEnter * set nu rnu

    " auto-remove trailing spaces on php and txt files
    au BufWritePre *.md,*.php,*.txt,*.scss :%s/\s\+$//e

    " override fastfold breaking foldmethod on markdown docs
    " move this to after/ftplugin/markdown.vim??
    au FileType markdown setlocal foldmethod=expr

    " create parent directories as needed when saving buffers
    au BufWritePre * :call buell#helpers#CreateNeededDirs(expand('<afile>'), +expand('<abuf>'))

    " remember folding / view states
    au BufWinLeave ?* silent! mkview
    au BufWinEnter ?* silent! loadview

    " dont restore cursor position on gitcommits
    au BufEnter * call buell#helpers#GitCommitBufEnter()

    " equalize splits on window resize
    autocmd VimResized * execute "normal! \<c-w>="

    """"""""""""""""""""
    "                  "
    "   focus events   "
    "                  "
    """"""""""""""""""""

    autocmd BufEnter,FocusGained,VimEnter,WinEnter * call buell#statusline#focus_statusline()

    """""""""""""""""""
    "                 "
    "   blur events   "
    "                 "
    """""""""""""""""""

    autocmd FocusLost,WinLeave * call buell#statusline#blur_statusline()

  augroup END
endif
