scriptencoding utf-8

function! buell#statusline#drawstatusline() abort
  set statusline=%7*                                 " switch to User7 highlight group
  set statusline+=%{buell#statusline#lhs()}          " call lhs statusline autocommand
  set statusline+=%*                                 " reset highlight group
  set statusline+=%4*                                " switch to User4 highlight group (powerline arrow)
  set statusline+=                                  " powerline arrow
  set statusline+=%*                                 " reset highlight group
  set statusline+=\                                  " space
  set statusline+=%<                                 " truncation point, if not enough width available
  set statusline+=%{buell#statusline#fileprefix()}   " relative path to file's directory
  set statusline+=%3*                                " switch to User3 highlight group (bold)
  set statusline+=%t                                 " filename
  set statusline+=%*                                 " reset highlight group
  set statusline+=\                                  " space
  set statusline+=%1*                                " switch to User1 highlight group (italics)

  " Needs to be all on one line:
  "   %(                                               start item group
  "   [                                                left bracket (literal)
  "   %M                                               modified flag: ,+/,- (modified/unmodifiable) or nothing
  "   %R                                               read-only flag: ,RO or nothing
  "   %{buell#statusline#ft()}                         filetype (not using %Y because I don't want caps)
  "   %{buell#statusline#fenc()}                       file-encoding if not UTF-8
  "   ]                                                right bracket (literal)
  "   %)                                               end item group
  set statusline+=%([%M%R%{buell#statusline#ft()}%{buell#statusline#fenc()}]%)

  set statusline+=%*                                 " reset highlight group
  set statusline+=%=                                 " split point for left and right groups

  set statusline+=\                                  " space
  set statusline+=                                  " powerline arrow
  set statusline+=%5*                                " switch to User5 highlight group
  set statusline+=%{buell#statusline#rhs()}          " call rhs statusline autocommand
  set statusline+=%*                                 " reset highlight group
endfunction

function! buell#statusline#gutterpadding() abort
  let l:minwidth=2
  let l:gutterWidth=max([strlen(line('$')) + 1, &numberwidth, l:minwidth])
  "let l:padding=repeat(' ', l:gutterWidth - 1)
  redir => signlist
    silent! execute 'sign place buffer='. bufnr('%')
  redir END
  let l:signColumn=(len(signlist) > 17) ? 2 : 0
  let l:padding=repeat(' ', l:gutterWidth - 1 + &foldcolumn + l:signColumn)
  return l:padding
endfunction

function! buell#statusline#fileprefix() abort
  let l:basename=expand('%:h')
  if l:basename ==# '' || l:basename ==# '.'
    return ''
  else
    " make sure we show $HOME as ~
    return substitute(l:basename . '/', '\C^' . $HOME, '~', '')
  endif
endfunction

function! buell#statusline#ft() abort
  if strlen(&ft)
    return ',' . &ft
  else
    return ''
  endif
endfunction

function! buell#statusline#fenc() abort
  if strlen(&fenc) && &fenc !=# 'utf-8'
    return ',' . &fenc
  else
    return ''
  endif
endfunction

function! buell#statusline#lhs() abort
  let l:line=buell#statusline#gutterpadding()
  " HEAVY BALLOT X - Unicode: U+2718, UTF-8: E2 9C 98
  "let l:line.=&modified ? '✘ ' : '  '
  let l:line.='  '
  return l:line
endfunction

function! buell#statusline#rhs() abort
  let l:rhs=' '
  if winwidth(0) > 80
    let l:column=virtcol('.')
    let l:width=virtcol('$')
    let l:line=line('.')
    let l:height=line('$')

    " add padding to stop rhs from changing too much as we move the cursor
    let l:padding=len(l:height) - len(l:line)
    if (l:padding)
      let l:rhs.=repeat(' ', l:padding)
    endif

    let l:rhs.='ℓ ' " (Literal, \u2113 "SCRIPT SMALL L").
    let l:rhs.=l:line
    let l:rhs.='/'
    let l:rhs.=l:height
    "let l:rhs.=' 𝚌 ' " (Literal, \u1d68c "MATHEMATICAL MONOSPACE SMALL C").
    let l:rhs.=' @ '
    let l:rhs.=l:column
    let l:rhs.='/'
    let l:rhs.=l:width
    let l:rhs.=' '

    " add padding to stop rhs from changing too much as we move the cursor
    if len(l:column) < 2
      let l:rhs.=' '
    endif
    if len(l:width) < 2
      let l:rhs.=' '
    endif
  endif
  return l:rhs
endfunction

let s:default_lhs_color='Identifier'
let s:async_lhs_color='Identifier'
let s:modified_lhs_color='Identifier'
let s:statusline_status_highlight=s:default_lhs_color
let s:async=0

function! buell#statusline#async_start() abort
  let s:async=1
  call buell#statusline#check_modified()
endfunction

function! buell#statusline#async_finish() abort
  let s:async=0
  call buell#statusline#check_modified()
endfunction

function! buell#statusline#check_modified() abort
  if &modified && s:statusline_status_highlight != s:modified_lhs_color
    let s:statusline_status_highlight=s:modified_lhs_color
    call buell#statusline#update_highlight()
  elseif !&modified
    if s:async && s:statusline_status_highlight != s:async_lhs_color
      let s:statusline_status_highlight=s:async_lhs_color
      call buell#statusline#update_highlight()
    elseif !s:async && s:statusline_status_highlight != s:default_lhs_color
      let s:statusline_status_highlight=s:default_lhs_color
      call buell#statusline#update_highlight()
    endif
  endif
endfunction

function! buell#statusline#update_highlight() abort

  " bail if pinnacle not installed
  if !buell#helpers#PluginExists('pinnacle')
    return
  endif

  " update statusline to use italics (used for filetype)
  let l:highlight=pinnacle#italicize('StatusLine')
  execute 'highlight User1 ' . l:highlight

  " update matchparen to use italics (used for blurred statuslines)
  let l:highlight=pinnacle#italicize('MatchParen')
  execute 'highlight User2 ' . l:highlight

  " StatusLine + bold (used for file names).
  let l:highlight=pinnacle#embolden('StatusLine')
  execute 'highlight User3 ' . l:highlight

  " inverted error styling, for left-hand side "powerline" triangle
  let l:fg=pinnacle#extract_fg(s:statusline_status_highlight)
  let l:bg=pinnacle#extract_bg('StatusLine')
  execute 'highlight User4 ' . pinnacle#highlight({'bg': l:bg, 'fg': l:fg})

  " and opposite for the buffer number area
  execute 'highlight User7 ' .
        \ pinnacle#highlight({
        \   'bg': l:fg,
        \   'fg': pinnacle#extract_fg('Normal'),
        \   'term': 'bold'
        \ })

  " right-hand side section
  let l:bg=pinnacle#extract_fg('Cursor')
  let l:fg=pinnacle#extract_fg('User3')
  execute 'highlight User5 ' .
        \ pinnacle#highlight({
        \   'bg': l:fg,
        \   'fg': l:bg,
        \   'term': 'bold'
        \ })

  " right-hand side section + italic (used for %)
  execute 'highlight User6 ' .
        \ pinnacle#highlight({
        \   'bg': l:fg,
        \   'fg': l:bg,
        \   'term': 'bold,italic'
        \ })

  highlight clear StatusLineNC
  highlight! link StatusLineNC User1
endfunction
