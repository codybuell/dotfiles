""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Color Configurations                                                         "
"                                                                              "
" Must be run in after/plugins else elements will be drawn without the right   "
" colors being applied, i.e. statusbar.                                        "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function s:SetColorScheme(action)

  let g:base16colorspace  = 256
  let g:base16_shell_path = '~/.shell/base16-shell/scripts/'
  let s:config_file       = expand('~/.base16')
  let s:file_type         = &ft

  " set to whatever the def colorscheme is
  if filereadable(s:config_file)
    let s:config = readfile(s:config_file, '', 2)

    if filereadable(expand('~/.vim/bundle/base16-vim/colors/base16-' . s:config[0] . '.vim'))
      if a:action == 'blur'
        "execute 'color base16-grayscale-' . s:config[1]
      else
        execute 'color base16-' . s:config[0]
        execute 'set background=' . s:config[1]
      endif
    else
      echoerr 'Bad scheme ' . s:config[0] . ' in ' . s:config_file
    endif
  else " default
    if a:action == 'blur'
      "color base16-grayscale-dark
    else
      color base16-tomorrow-night
      set background=dark
    endif
  endif

  execute 'highlight Comment ' . functions#italicize_group('Comment')

  " Allow for overrides:
  " - `statusline.vim` will re-set User1, User2 etc.
  " - `after/plugin/loupe.vim` will override Search.
  doautocmd ColorScheme

  " some personal overrides
  hi SpecialKey ctermfg=238
  hi NonText ctermfg=238
  hi SLWarnings ctermfg=3 ctermbg=19
  hi SLErrors ctermfg=1 ctermbg=19
  hi Search ctermfg=232

  " re-apply the filetype to recover any special syntax highlighting (tmux
  " colour declarations being colored as their value)
  execute 'set ft=' . s:file_type

endfunction

if v:progname !=# 'vi'
  if has('autocmd')
    augroup BuellAutocolor
      autocmd!
      autocmd FocusGained * call s:SetColorScheme('focus')
      autocmd FocusLost,WinLeave * call s:SetColorScheme('blur')
    augroup END
  endif

  " if not in tmux then we need to call focus to set color scheme
  if !exists('$TMUX')
    call s:SetColorScheme('focus')
  endif
endif
