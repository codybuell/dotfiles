" cf the default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
if has('statusline')
  call buell#statusline#drawstatusline()

  if has('autocmd')
    augroup BuellStatusline
      autocmd!
      autocmd ColorScheme * call buell#statusline#update_highlight()
    augroup END
  endif
endif
