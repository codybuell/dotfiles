""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Statusline Functions                                                "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! statusline#gutterpadding(subtractBufferNumber) abort
  let l:gutterWidth=max([strlen(line('$')), &numberwidth]) + 1
  let l:bufferNumberWidth=a:subtractBufferNumber ? strlen(winbufnr(0)) : 0
  let l:padding=repeat(' ', l:gutterWidth - l:bufferNumberWidth - 1 + &foldcolumn)
  return l:padding
endfunction

function! statusline#fileprefix() abort
  let l:basename=expand('%:h')
  if l:basename == '' || l:basename == '.'
    return ''
  else
    return l:basename . '/'
  endif
endfunction

function! statusline#ft() abort
  if strlen(&ft)
    return ',' . &ft
  else
    return ''
  endif
endfunction

function! statusline#fenc() abort
  if strlen(&fenc) && &fenc !=# 'utf-8'
    return ',' . &fenc
  else
    return ''
  endif
endfunction

function! statusline#update_highlight() abort
  " determine if gui or terminal
  let l:prefix=has('gui') ? 'gui' : 'cterm'

  " update statusline to use italics
  let l:highlight=functions#italicize_group('StatusLine')
  execute 'highlight User1 ' . l:highlight

  " update matchparen to use italics
  let l:highlight=functions#italicize_group('MatchParen')
  execute 'highlight User2 ' . l:highlight

  " statusline + bold
  let l:highlight=functions#embolden_group('StatusLine')
  execute 'highlight User3 ' . l:highlight

  " inverted error styling, for left-hand side "Powerline" triangle
  let l:prefix=has('gui') ? 'gui' : 'cterm'
  let l:fg=synIDattr(synIDtrans(hlID('Error')), 'bg', l:prefix)
  let l:bg=synIDattr(synIDtrans(hlID('StatusLine')), 'bg', l:prefix)
  execute 'highlight User4 ' . l:prefix . 'fg=' . l:fg . ' ' . l:prefix . 'bg=' . l:bg

  " right-hand side section.
  let l:bg=synIDattr(synIDtrans(hlID('User2')), 'fg', l:prefix)
  let l:fg=synIDattr(synIDtrans(hlID('User3')), 'fg', l:prefix)
  execute 'highlight User5 ' . l:prefix . 'fg=' . l:bg . ' ' . l:prefix . 'bg=' . l:fg

  " right-hand side section + italic (used for %).
  execute 'highlight User6 ' . l:prefix . '=italic ' . l:prefix . 'fg=' . l:bg . ' ' . l:prefix . 'bg=' . l:fg

  " make not-current window status lines visible against colorcolumn background
  highlight clear StatusLineNC
  highlight! link StatusLineNC User2
endfunction
