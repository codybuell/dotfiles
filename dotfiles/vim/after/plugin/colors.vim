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
    let s:config = readfile(s:config_file, '', 1)

    " need a way to determine if base16 colorsheme needs dark or light!
    set background=dark

    if filereadable(expand('~/.vim/bundle/base16-vim/colors/base16-' . s:config[0] . '.vim'))
      execute 'color base16-' . s:config[0]
    else
      echoerr 'Bad scheme ' . s:config[0] . ' in ' . s:config_file
    endif
  else " default
    set background=dark
    color base16-tomorrow-night
  endif

  execute 'highlight Comment ' . functions#italicize_group('Comment')

  " Allow for overrides:
  " - `statusline.vim` will re-set User1, User2 etc.
  " - `after/plugin/loupe.vim` will override Search.
  doautocmd ColorScheme
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
