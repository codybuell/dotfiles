""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Autocommands                                                        "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:BuellColorColumnBlacklist = ['diff', 'undotree', 'nerdtree', 'qf']
let g:BuellCursorlineBlacklist = ['command-t']
let g:BuellMkviewFiletypeBlacklist = ['diff', 'hgcommit', 'gitcommit']

function! autocmds#attempt_select_last_file() abort
  let l:previous=expand('#:t')
  if l:previous != ''
    call search('\v<' . l:previous . '>')
  endif
endfunction

function! autocmds#should_colorcolumn() abort
  return index(g:BuellColorColumnBlacklist, &filetype) == -1
endfunction

function! autocmds#should_cursorline() abort
  return index(g:BuellCursorlineBlacklist, &filetype) == -1
endfunction

" loosely based on: http://vim.wikia.com/wiki/Make_views_automatic
function! autocmds#should_mkview() abort
  return
        \ &buftype == '' &&
        \ index(g:BuellMkviewFiletypeBlacklist, &filetype) == -1 &&
        \ !exists('$SUDO_USER') " don't create root-owned files
endfunction

function! autocmds#mkview() abort
  if exists('*haslocaldir') && haslocaldir()
    " we never want to save an :lcd command, so hack around it...
    cd -
    mkview
    lcd -
  else
    mkview
  endif
endfunction

function! autocmds#blur_statusline() abort
  " default blurred statusline (buffer number: filename)
  let l:blurred='%{statusline#gutterpadding(0)}'
  let l:blurred.='\ ' " space
  let l:blurred.='\ ' " space
  let l:blurred.='\ ' " space
  let l:blurred.='%<' " truncation point
  let l:blurred.='%f' " filename
  let l:blurred.='%=' " split left/right halves (makes background cover whole)
  call s:update_statusline(l:blurred, 'blur')
endfunction

function! autocmds#focus_statusline() abort
  " `setlocal statusline=` will revert to global 'statusline' setting
  call s:update_statusline('', 'focus')
endfunction

function! s:update_statusline(default, action) abort
  let l:statusline = s:get_custom_statusline(a:action)
  if type(l:statusline) == type('')
    " apply custom statusline
    execute 'setlocal statusline=' . l:statusline
  elseif l:statusline == 0
    " do nothing
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
  if &ft == 'command-t'
    " will use command-t-provided buffer name, but need to escape spaces
    return '\ \ ' . substitute(bufname('%'), ' ', '\\ ', 'g')
  elseif &ft == 'diff' && exists('t:diffpanel') && t:diffpanel.bufname == bufname('%')
    return 'Undotree\ preview' " less ugly, and nothing really useful to show
  elseif &ft == 'undotree'
    return 0 " don't override; undotree does its own thing
  elseif &ft == 'nerdtree'
    return 0 " don't override; nerdtree does its own thing
  elseif &ft == 'qf'
    if a:action == 'blur'
      return 'Quickfix'
    else
      return g:BuellQuickfixStatusline
    endif
  endif

  return 1 " use default
endfunction
