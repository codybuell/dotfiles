""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Statusline Configurations                                                    "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

scriptencoding utf-8

" cf the default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
if has('statusline')
  set statusline=%#Error#                         " use the error highlight group
  set statusline+=%{statusline#gutterpadding(1)}  " dynamically pad
  set statusline+=%n                              " buffer number
  set statusline+=\                               " space
  set statusline+=%*                              " reset highlight group
  set statusline+=%4*                             " switch to User4 highlight group
  set statusline+=                               " powerline arrow
  set statusline+=%*                              " reset highlight group
  set statusline+=\                               " space
  set statusline+=%<                              " truncation point, if not enough width available
  set statusline+=%{statusline#fileprefix()}      " relative path to file's directory
  set statusline+=%3*                             " switch to User3 highlight group (bold)
  set statusline+=%t                              " filename
  set statusline+=%*                              " reset highlight group
  set statusline+=\                               " space
  set statusline+=%1*                             " switch to User1 highlight group (italics)

  " needs to be all on one line:
  "   %(                   start item group
  "   [                    left bracket (literal)
  "   %M                   modified flag: ,+/,- (modified/unmodifiable) or nothing
  "   %R                   read-only flag: ,RO or nothing
  "   %{statusline#ft()}   filetype (not using %Y because I don't want caps)
  "   %{statusline#fenc()} file-encoding if not UTF-8
  "   ]                    right bracket (literal)
  "   %)                   end item group
  set statusline+=%([%M%R%{statusline#ft()}%{statusline#fenc()}]%)

  set statusline+=%*                              " reset highlight group
  set statusline+=%=                              " split point for left and right groups
  set statusline+=%#SLErrors#                     " custom highlight group
  set statusline+=%{SyntasticStatuslineFlag()}    " display syntastic errors
  set statusline+=%*                              " reset highlight group
  set statusline+=\                               " space
  set statusline+=                               " powerline arrow
  set statusline+=%5*                             " switch to User5 highlight group
  set statusline+=\                               " space
  set statusline+=ℓ                               " (literal, \u2113 "SCRIPT SMALL L")
  set statusline+=\                               " space
  set statusline+=%l                              " current line number
  set statusline+=/                               " separator
  set statusline+=%L                              " number of lines in buffer
  set statusline+=\                               " space
  set statusline+=@                               " (literal)
  set statusline+=\                               " space
  set statusline+=%c                              " current column number
  set statusline+=%V                              " current virtual column number (-n), if different
  set statusline+=\                               " space
  set statusline+=%6*                             " switch to User6 highlight group (italics)
  set statusline+=%p                              " percentage through buffer
  set statusline+=%%                              " literal %
  set statusline+=\                               " space
  set statusline+=%*                              " reset highlight group

  if has('autocmd')
    augroup BuellStatusline
      autocmd!
      autocmd ColorScheme * call statusline#update_highlight()
    augroup END
  endif
endif
