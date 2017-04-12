""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Color Configurations                                                         "
"                                                                              "
" Must be run in after/plugins else elements will be drawn without the right   "
" colors being applied, i.e. statusbar.                                        "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function s:SetColorScheme()

  let g:base16colorspace=256
  let s:config_file = expand('~/.base16')
  if filereadable(s:config_file)
    let s:config = readfile(s:config_file, '', 2)

    if filereadable(expand('~/.vim/bundle/base16-vim/colors/base16-' . s:config[0] . '.vim'))
      execute 'color base16-' . s:config[0]
      execute 'set background=' . s:config[1]
    else
      echoerr 'Bad scheme ' . s:config[0] . ' in ' . s:config_file
    endif
  else " default
    color base16-tomorrow-night
    set background=dark
  endif

  execute 'highlight Comment ' . functions#italicize_group('Comment')

  " Allow for overrides:
  " - `statusline.vim` will re-set User1, User2 etc.
  " - `after/plugin/loupe.vim` will override Search.
  doautocmd ColorScheme

  " some personal overrides
  hi SpecialKey ctermfg=238
  hi NonText ctermfg=238

endfunction

if v:progname !=# 'vi'
  if has('autocmd')
    augroup BuellAutocolor
      autocmd!
      autocmd FocusGained * call s:SetColorScheme()
    augroup END
  endif

  call s:SetColorScheme()
endif
