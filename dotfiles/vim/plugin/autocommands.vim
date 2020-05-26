" BufEnter       after entering a buffer, good for setting file type options
" BufWinEnter    when a buffer is loaded and also when displayed in a window
" BufWinLeave    when a buffer is removed from the window

if has('autocmd')
  augroup BuellAutocmds

    " reset autocommand group
    autocmd!

    " disable paste mode on leaving insert mode
    au InsertLeave * set nopaste

    " don't insert a new comment character after o/O cmd
    au BufEnter * setlocal formatoptions-=o

    " setting this in vimrc is not working... can't find culprit so set here
    au BufEnter * set foldtext=buell#foldtext#CustomFoldText()

    " close vim/nvim if nerdtee is the only thing left open
    au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " close vim/nvim if quickfix is the only thing left open
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"|q|endif

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
    au VimResized * execute "normal! \<c-w>="

    " flash highlight yanked text
    if exists('##TextYankPost')
      autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank('Substitute', 200)
    endif

    """"""""""""""""""""
    "                  "
    "   focus events   "
    "                  "
    """"""""""""""""""""

    au BufEnter,FocusGained,VimEnter,WinEnter * call buell#statusline#focus_statusline()

    """""""""""""""""""
    "                 "
    "   blur events   "
    "                 "
    """""""""""""""""""

    au FocusLost,WinLeave * call buell#statusline#blur_statusline()

  augroup END
endif
