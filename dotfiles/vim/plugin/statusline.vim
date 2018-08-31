" simple status line
let g:BuellQuickfixStatusline =
      \ 'Quickfix'
      \ . '%<'
      \ . '\ '
      \ . '%='
      \ . '\ '
      \ . 'ℓ'
      \ . '\ '
      \ . '%l'
      \ . '/'
      \ . '%L'
      \ . '\ '
      \ . '@'
      \ . '\ '
      \ . '%c'
      \ . '%V'
      \ . '\ '
      \ . '%1*'
      \ . '%p'
      \ . '%%'
      \ . '%*'

" cf the default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
if has('statusline')
  call buell#statusline#drawstatusline()

  if has('autocmd')
    augroup BuellStatusline
      autocmd!
      autocmd ColorScheme * call buell#statusline#update_highlight()
      autocmd User FerretAsyncStart call buell#statusline#async_start()
      autocmd User FerretAsyncFinish call buell#statusline#async_finish()
      if exists('#TextChangedI')
        autocmd BufWinEnter,BufWritePost,FileWritePost,TextChanged,TextChangedI,WinEnter * call buell#statusline#check_modified()
      else
        autocmd BufWinEnter,BufWritePost,FileWritePost,WinEnter * call buell#statusline#check_modified()
      endif
    augroup END
  endif
endif
