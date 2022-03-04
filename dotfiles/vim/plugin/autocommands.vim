" see h:autocmd-events

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
    au BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " dont restore cursor position on gitcommits
    au BufEnter * call buell#helpers#GitCommitBufEnter()

    " close vim/nvim if quickfix is the only thing left open
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"| q |endif

    " close vim/nvim if fugitiveblame is the only thing left open
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&ft") == "fugitiveblame"| q |endif

    " enforce relative numbers on all buffers and tabs
    au BufWinEnter * set nu rnu

    " but not for command-t windows, note that this doesn't seem to trigger the first time command-t is invoked
    au BufWinEnter * if &l:filetype ==? 'command-t' | setlocal signcolumn=no nonu nornu winhighlight=Normal:Visual,NormalNC:Visual | endif
    "au BufWinEnter * setlocal signcolumn=no nonu nornu
    "au BufWinEnter * lua require'buell.helpers'.check_command_t()
    "au BufWinEnter * if commandt#CheckBuffer(bufnr('%')) | setlocal signcolumn=no nonu nornu |endif

    " remember folding / view states
    au BufWinEnter ?* silent! loadview
    au BufWinLeave ?* silent! mkview

    " auto-remove trailing spaces on php and txt files
    au BufWritePre *.php,*.py,*.scss call buell#helpers#ZapWhitespace()

    " create parent directories as needed when saving buffers
    au BufWritePre * :call buell#helpers#CreateNeededDirs(expand('<afile>'), +expand('<abuf>'))

    " override fastfold breaking foldmethod on markdown docs
    au FileType markdown setlocal foldmethod=expr

    " equalize splits on window resize
    au VimResized * execute "normal! \<c-w>="

    " focus events, update statusline
    au BufEnter,FocusGained,VimEnter,WinEnter * call buell#statusline#focus_statusline()

    " blur events, update statusline
    au FocusLost,WinLeave * call buell#statusline#blur_statusline()

    " flash highlight yanked text
    if exists('##TextYankPost')
      au TextYankPost * silent! lua vim.highlight.on_yank {higroup="Substitute", timeout=200}
    endif

    " set a global variable for git branch so we don't have to make constant
    " system calls when rendering the status bar (to show current file branch)
    au BufWinEnter * let b:git_branch=buell#helpers#GitBranch()

    " in quickfix windows open file under cursor in new tab with <C-t>
    autocmd FileType qf nnoremap <buffer> <C-t> <C-W><Enter><C-W>T

  augroup END
endif
