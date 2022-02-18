scriptencoding utf-8

"  LHS > path [buffer info]                session < RHS
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
  "   %{ObsessionStatus()}                             $ if in an active session, S if in a paused session
  "   %M                                               modified flag: ,+/,- (modified/unmodifiable) or nothing
  "   %R                                               read-only flag: ,RO or nothing
  "   %{buell#statusline#ft()}                         filetype (not using %Y because I don't want caps)
  "   %{buell#statusline#fenc()}                       file-encoding and file format
  "   %{buell#statusline#branch()}                     current branch if in a repo
  "   ]                                                right bracket (literal)
  "   %)                                               end item group
  set statusline+=%([%{ObsessionStatus('$','S')}%M%R%{buell#statusline#ft()}%{buell#statusline#fenc()}%{buell#statusline#branch()}]%)

  set statusline+=%4*                                " reset highlight group
  set statusline+=%=                                 " split point for left and right groups

" set statusline+=%{buell#statusline#linterstatus()} " ale warnings and errors
  set statusline+=%*                                 " reset highlight group
  set statusline+=\                                  " space
  set statusline+=%{buell#statusline#sessionname()}  " session name
  set statusline+=                                  " powerline arrow
  set statusline+=%5*                                " switch to User5 highlight group
  set statusline+=%{buell#statusline#rhs()}          " call rhs statusline autocommand
  set statusline+=%*                                 " reset highlight group
endfunction

function! buell#statusline#branch() abort
  let l:branch = get(b:, 'git_branch', '')
  if strlen(l:branch)
    return ',' . l:branch
  endif
endfunc

function! buell#statusline#sessionname() abort
  if exists(':Obsession')
    if exists('v:this_session') && v:this_session != ''
      let l:obsession_string = v:this_session
      let l:obsession_parts = split(l:obsession_string, '/')
      let l:obsession_filename = l:obsession_parts[-1]
      return l:obsession_filename . ' '
    endif
  endif
  return ''
endfunction

function! buell#statusline#lspstatus() abort
  redir => lspstatusverbose
    lua print(vim.inspect(vim.lsp.buf_get_clients()))
  redir END
endfunction
" function! buell#statusline#linterstatus() abort

"       let sl = ''
"       if luaeval('vim.lsp.buf.server_ready()')
"           let sl.='%#MyStatuslineLSP#E:'
"           let sl.='%#MyStatuslineLSPErrors#%{luaeval("vim.lsp.util.buf_diagnostics_count(\"Error\")")}'
"           let sl.='%#MyStatuslineLSP# W:'
"           let sl.='%#MyStatuslineLSPWarnings#%{luaeval("vim.lsp.util.buf_diagnostics_count(\"Warning\")")}'
"       else
"           let sl.='%#MyStatuslineLSPErrors#off'
"       endif
"       return sl


"   " ℓ ℒ ℘ ⨂  ● ○ 	✘ 	⨯  	×  x  	𐆒	𐆓
"   let l:counts = ale#statusline#Count(bufnr(''))
" 
"   let l:all_errors = l:counts.error + l:counts.style_error
"   let l:all_warnings = l:counts.total - l:all_errors
" 
"   return l:counts.total == 0 ? '' : printf(
"         \   '%d:⚠  %d:⤫ ',
"         \   all_warnings,
"         \   all_errors
"         \)
" endfunction

function! buell#statusline#gutterwidth() abort

  " determine how wide our gutter is
  "
  " gutter is comprised of:
  "   - fold indicator - width set by foldcolumn
  "   - signs - 1 by default if sign present or turned on, can be more
  "   - number column - 4 or more chars wide based on doc length
  "   - padding - one space for padding on the right of gutter

  " figure out our number column width by grabbing the largest between:
  "  - strlen(buffer line count) + 1, the digits in our buffers number of
  "    lines + 1, we do this as after about 10K lines or so th number column
  "    gets widew than the default numberwidth of 4 or 8
  "  - numberwidth, 4 or 8 depending on vim/nvim or vi
  "  - 2, a min width
  if &nu || &rnu
    let l:numbercolumn=max([strlen(line('$')) + 1, &numberwidth, 2])
  else
    let l:numbercolumn=0
  endif

  " figure out the sign column width
  if &signcolumn =~ 'auto'
    " if our signcolumn is set to auto check to see if a sign is present
    " todo: signcolumn can be set to a width wider than 1, detect and scale
    "       see :help signcolumn
    redir => signlist
      silent! execute 'sign place buffer='. bufnr('%')
    redir END
    let l:signColumn=(len(signlist) > 17) ? 2 : 0
  elseif &signcolumn !~ 'no'
    " add width if signcolumn is set tak
    " todo: signcolumn can be set to a width wider than 1, detect and scale
    "       see :help signcolumn
    let l:signColumn=(&signcolumn == 'yes') ? 2 : 0
  else
    let l:signColumn=0
  endif

  " put it all together and return the concatenated string
  " let l:padding=repeat(' ', l:numbercolumn + &foldcolumn + l:signColumn + 1)
  let l:width=l:numbercolumn + &foldcolumn + l:signColumn + 1
  return l:width
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
  " if strlen(&fenc) && &fenc !=# 'utf-8'
  "   return ',' . &fenc
  " else
  "   return ''
  " endif
  let l:fenc = ''
  let l:ff = ''
  if strlen(&fenc)
    let l:fenc = ',' . &fenc
  endif
  if strlen(&ff)
    let l:ff = ',' . &ff
  endif
  return l:fenc . l:ff
endfunction

function! buell#statusline#lhs() abort
  let l:gutterwidth = buell#statusline#gutterwidth()
  let l:treesitter  = nvim_treesitter#statusline(1)
  let l:lspclient   = luaeval('#vim.lsp.buf_get_clients() > 0')
  if l:treesitter != v:null || l:lspclient
    let l:line = '  '
    if l:treesitter != v:null
      " let l:line .= '𝒯'
      let l:line .= 'τ'
    endif
    if l:lspclient
      let l:line .= '  ' . luaeval("require('buell.lsp').status()")
    endif
    let l:diff = l:gutterwidth - strlen(l:line) + 2
    if l:diff > 0
      let l:line .= repeat(' ', l:diff)
    endif
  else
    let l:line = repeat(' ', l:gutterwidth)
  endif

  " HEAVY BALLOT X - Unicode: U+2718, UTF-8: E2 9C 98
  "let l:line.=&modified ? '✘   ' : '    '
  "let l:line.='    '
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
    " let l:padding=len(l:height) - len(l:line)
    " if (l:padding)
    "   let l:rhs.=repeat(' ', l:padding)
    " endif

    let l:rhs.='ℓ ' " (Literal, \u2113 "SCRIPT SMALL L").
    let l:rhs.=s:LineNoIndicator()
    " let l:rhs.=l:line
    " let l:rhs.='/'
    " let l:rhs.=l:height
    let l:rhs.=' 𝚌 ' " (Literal, \u1d68c "MATHEMATICAL MONOSPACE SMALL C").
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
  let l:fg=pinnacle#extract_bg('Error')
  let l:bg=pinnacle#extract_bg('Visual')
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

function! buell#statusline#blur_statusline() abort
  " buffer number: filename).
  let l:blurred=repeat('\ ', buell#statusline#gutterwidth())
  let l:blurred.='\ ' " space
  let l:blurred.='%<' " truncation point
  let l:blurred.='%f' " filename
  let l:blurred.='%=' " split left/right halves (makes background cover whole)
  call s:update_statusline(l:blurred, 'blur')
endfunction

function! buell#statusline#focus_statusline() abort
  " `setlocal statusline=` will revert to global 'statusline' setting.
  call s:update_statusline('', 'focus')
endfunction

function! s:update_statusline(default, action) abort
  let l:statusline = s:get_custom_statusline(a:action)
  if type(l:statusline) == type('')
    " apply custom statusline
    execute 'setlocal statusline=' . l:statusline
  elseif l:statusline == 0
    " Do nothing.
    "
    " Note that order matters here because of Vimscript's insane coercion rules:
    " when comparing a string to a number, the string gets coerced to 0, which
    " means that all strings `== 0`. So, we must check for string-ness first,
    " above.
    return
  else
    execute 'setlocal statusline=' . a:default
  endif
endfunction

function! s:get_custom_statusline(action) abort
  if &ft ==# 'command-t'
    " will use Command-T-provided buffer name, but need to escape spaces
    return '\ \ ' . substitute(bufname('%'), ' ', '\\ ', 'g')
  elseif &ft ==# 'diff' && exists('t:diffpanel') && t:diffpanel.bufname ==# bufname('%')
    return 'Undotree\ preview' " less ugly, and nothing really useful to show
  elseif &ft ==# 'tagbar'
    return 0 " don't override, tagbar does its own thing
  elseif &ft ==# 'undotree'
    return 0 " don't override, undotree does its own thing
  elseif &ft ==# 'nerdtree'
    return 0 " don't override, NERDTree does its own thing
  elseif &ft ==? 'fugitiveblame'
    return '\ ' " no status bar for fugitiveblame windows
  elseif &ft ==# 'qf'
    if a:action ==# 'blur'
      return 'Quickfix'
    else
      return g:BuellQuickfixStatusline
    endif
  endif

  " use default
  return 1
endfunction

" taken from https://github.com/drzel/vim-line-no-indicator
function! s:LineNoIndicator() abort
  if has('macunix')
    let l:line_no_indicator_chars = ['⎺', '⎻', '─', '⎼', '⎽']
  else
    let l:line_no_indicator_chars = ['⎺', '⎻', '⎼', '⎽', '⎯']
  end

  " let l:line_no_indicator_chars = [
  "   \  ' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'
  "   \  ]
  " let g:line_no_indicator_chars = [
  "   \ '  ', '░ ', '▒ ', '▓ ', '█ ', '█░', '█▒', '█▓', '██'
  "   \ ]
  " three char wide solid horizontal bar
  " let g:line_no_indicator_chars = [
  "   \ '   ', '▏  ', '▎  ', '▍  ', '▌  ',
  "   \ '▋  ', '▊  ', '▉  ', '█  ', '█▏ ',
  "   \ '█▎ ', '█▍ ', '█▌ ', '█▋ ', '█▊ ',
  "   \ '█▉ ', '██ ', '██▏', '██▎', '██▍',
  "   \ '██▌', '██▋', '██▊', '██▉', '███'
  "   \ ]

  " zero index line number so 1/3 = 0, 2/3 = 0.5, and 3/3 = 1
  let l:current_line = line('.') - 1
  let l:total_lines = line('$') - 1

  if l:current_line == 0
    let l:index = 0
  elseif l:current_line == l:total_lines
    let l:index = -1
  else
    let l:line_no_fraction = floor(l:current_line) / floor(l:total_lines)
    let l:index = float2nr(l:line_no_fraction * len(l:line_no_indicator_chars))
  endif

  return l:line_no_indicator_chars[l:index]
endfunction
