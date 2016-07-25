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
  " update statusline to use italics
  let l:highlight=functions#italicize_group('StatusLine')
  execute 'highlight User1 ' . l:highlight

  " update matchparen to use italics
  let l:highlight=functions#italicize_group('MatchParen')
  execute 'highlight User2 ' . l:highlight

  " statusline + bold
  let l:highlight=functions#embolden_group('StatusLine')
  execute 'highlight User3 ' . l:highlight

  " make not-current window status lines visible against colorcolumn background
  highlight clear StatusLineNC
  highlight! link StatusLineNC User2
endfunction