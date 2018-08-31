""""""""""""""""""
"                "
"   Base16-Vim   "
"                "
""""""""""""""""""

" bail if base16-vim is not installed
if !buell#helpers#PluginExists('base16-vim')
  finish
endif

" enable 24bit color in xterm-compatible terminals (bolded text, etc) for nvim
" need to set a condition on this one based on 24bit availability?? iso-8613-3
" as if not set you will see wrong colors in a 24bit compat terminal?? green
" stripes etc... (24-bit true color: neovim 0.1.5+ / vim 7.4.1799+ enable ONLY
" if TERM is set valid and it is NOT under mosh)
function! s:is_mosh()
  let output = system("is_mosh -v")
  if v:shell_error
    return 0
  endif
  return !empty(l:output)
endfunction

function s:auto_termguicolors()
  if !(has("termguicolors"))
    return
  endif

  if (&term == 'xterm-256color' || &term == 'nvim') && !s:is_mosh()
    set termguicolors
  else
    set notermguicolors
  endif
endfunction
call s:auto_termguicolors()

" access colors in 256 colorspace, needed when using base16-shell (as we are)
let base16colorspace=256

" default colorscheme
colorscheme base16-tomorrow-night
