""""""""""""""""""
"                "
"   Base16-Vim   "
"                "
""""""""""""""""""

" bail if base16-vim is not installed
if !buell#helpers#PluginExists('base16-vim')
  finish
endif

" function to detect mosh sessions
function! s:is_mosh()
  let output = system("is_mosh -v")
  if v:shell_error
    return 0
  endif
  return !empty(l:output)
endfunction

" enable 24bit color in xterm-comp terminals (bolds, guifg, guibg, etc) for nvim
function s:auto_termguicolors()
  if !(has("termguicolors"))
    return
  endif

  if ($TERM == 'xterm-256color' || $TERM == 'tmux-256color') && !s:is_mosh() && has('nvim')
    set termguicolors
  else
    set notermguicolors
  endif
endfunction
call s:auto_termguicolors()

function s:SetColorscheme()
  " access colors in 256 colorspace, needed when using base16-shell (as we are)
  let g:base16colorspace=256

  " grab our shells colorsheme else default to 'tommorow-night'
  let s:config_file = expand('~/.base16')
  if filereadable(s:config_file)
    let s:config = readfile(s:config_file, '', 2)
    if s:config[1] =~# '^dark\|light$'
      execute 'set background=' . s:config[1]
    else
      echoerr 'Bad background ' . s:config[1] . ' in ' . s:config_file
    endif
    if filereadable(expand('~/.vim/pack/bundle/opt/base16-vim/colors/base16-' . s:config[0] . '.vim'))
      execute 'color base16-' . s:config[0]
    else
      echoerr 'Bad scheme ' . s:config[0] . ' in ' . s:config_file
    endif
  else
    set background=dark
    color base16-tomorrow-night
  endif

  " italicize comments
  execute 'highlight Comment ' . pinnacle#italicize('Comment')

" " re-add matches for tabs after all loads so that they highlight correctly
" " on the current line when cursorline is enabled, else hi below is ignored
" " see also the corresponding autocommands in plugins/autocommands.vim
" call matchadd('SpecialKey', '^\s\+', -1)
" call matchadd('SpecialKey', '\s\+$', -1)
" call matchadd('SpecialKey', '\t\+', -1)
" call matchadd('NonText', '^\s\+', -1)
" call matchadd('NonText', '\s\+$', -1)
" call matchadd('NonText', '\t\+', -1)

  " overrides for listchars (lcs)
  " note that changes here need to also be reflected in
  " autoload/buell/helpers ToggleSpecialChars function
  hi SpecialKey ctermfg=236 guifg=#303030
  hi NonText ctermfg=236 guifg=#303030
  hi Whitespace ctermfg=236 guifg=#303030

  " overrides for warnings and errors
  hi slwarnings ctermfg=3 ctermbg=19 guifg=#808000 guibg=#0000af
  hi slerrors ctermfg=1 ctermbg=19 guifg=#800000 guibg=#0000af

  " overrides for search results
  hi Search ctermfg=232 guifg=#080808

  " overrides for (vim)diffs
  hi DiffAdd    ctermbg=22 guibg=#222f22
  hi DiffDelete ctermbg=52 guibg=#2f2222
  hi DiffChange ctermbg=24 guibg=#22222f
  hi DiffText   ctermbg=24 guibg=#22222f

  " overrides for pmenu, trickles down to virtual and preview windows
  " execute 'hi Pmenu ' . pinnacle#highlight({
  "       \   'bg': pinnacle#extract_bg('Visual')
  "       \ })
  
  " run all colorscheme autocommands to ensure consistency
  doautocmd ColorScheme

endfunction

" only run color configs if we are in vim+
if v:progname !=# 'vi'
  " reload colorscheme func on focusgained, needed to allow the following in
  " other plugin config:    autocmd ColorScheme * call s:someFuncForColor()
  if has('autocmd')
    augroup BuellAutocolor
      autocmd!
      autocmd FocusGained * call s:SetColorscheme()
    augroup END
  endif

  call s:SetColorscheme()
endif
