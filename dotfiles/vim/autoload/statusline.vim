""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Statusline Functions                                                "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! statusline#setstatusline() abort
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
endfunction

function! statusline#gutterpadding(subtractBufferNumber) abort
  let l:gutterWidth=max([strlen(line('$')), &numberwidth]) + 1
  let l:bufferNumberWidth=a:subtractBufferNumber ? strlen(winbufnr(0)) : 0
  " determine if there are any placed signs in the current buffer
  redir => signlist
    silent! execute 'sign place buffer='. bufnr('%')
  redir END
  let l:signColumn=(len(signlist) > 17) ? 2 : 0
  let l:padding=repeat(' ', l:gutterWidth - l:bufferNumberWidth - 1 + &foldcolumn + l:signColumn)
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
  let l:bg=synIDattr(synIDtrans(hlID('Error')), 'fg', l:prefix)
  let l:fg=synIDattr(synIDtrans(hlID('User3')), 'fg', l:prefix)
  execute 'highlight User5 ' . l:prefix . 'fg=' . l:bg . ' ' . l:prefix . 'bg=' . l:fg

  " right-hand side section + italic (used for %).
  execute 'highlight User6 ' . l:prefix . '=italic ' . l:prefix . 'fg=' . l:bg . ' ' . l:prefix . 'bg=' . l:fg

  " make not-current window status lines visible against colorcolumn background
  highlight clear StatusLineNC
  highlight! link StatusLineNC User2
endfunction
