""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Functions                                                           "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" improve location list navigation (expects prev or next)
function! functions#LocationListNav(direction) abort
  try
    exe 'l' . a:direction
  catch /^Vim\%((\a\+)\)\=:E/
    if v:exception =~#".*E553:.*$"
      if a:direction == "prev"
        llast
      elseif a:direction == "next"
        lfirst
      endif
    else
      echo 'No Errors'
    endif
  endtry
endfunction

" generate random characters
function! functions#RandomCharacters(count) abort
  if a:count > 0
    let l:bits = a:count
  else
    let l:bits = 32
  end
  exe ":normal a" . system("cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c " . l:bits)
endfunction

" toggle error list
function! functions#ToggleErrors() abort
  if empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"'))
       " no location/quickfix list shown, open syntastic error location panel
       Errors
  else
      lclose
  endif
endfunction

" toggle syntax highlighting
function! functions#ToggleSyntaxHL() abort
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
    execute 'highlight Comment ' . functions#italicize_group('Comment')
  endif
endfunction

" setup vert split to wrap a document, sequential splits of one doc
function! functions#SyncSplit() abort
  " setlocal scrollbind in right window
  set nofoldenable
  " save the current scroll off setting to var
  let @z=&so
  " set scrolloff to 0 and clear scrollbind
  set so=0 noscb
  " split window vertically, new window on right
  bo vs
  " jump to bottom of window + 1, scroll to top
  exec "norm Ljzt"
  " setlocal scrollbind in right window
  setl scb
  " jump to previous window
  exec "normal \<C-w>p"
  " setlocal scrollbind in left window
  setl scb
  " restore scrolloff
  let &so=@z
endfunction

" underline text with provided character
"
" :Underline      gives underlining like --------------- (default)
" :Underline =    gives underlining like ===============
" :Underline -=   gives underlining like -=-=-=-=-=-=-=-
" :Underline ~+-  gives underlining like ~+-~+-~+-~+-~+-
function! functions#Underline() abort
  let l:chars = input('Underline Character: ')
  let l:chars = empty(l:chars) ? '-' : l:chars
  let l:nr_columns = virtcol('$') - 1
  let l:uline = repeat(l:chars, (l:nr_columns / len(l:chars)) + 1)
  if !v:shell_error && system("echo -n \"$(uname)\"") == "Linux"
    let put = strpart(l:uline, 0, nr_columns)   " linux
  else
    put = strpart(l:uline, 0, nr_columns)       " osx
  endif
  exe ":normal o"
endfunction

" toggle plain view vs nu, rnu, list, wrap etc...
function! functions#NuListToggle() abort
  setlocal nonu!
  setlocal nornu!
  setlocal nolist!
  setlocal wrap!
  if &foldcolumn
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=2
  endif
endfunction

" don't restore cursor position on git commit messages
function functions#GitCommitBufEnter() abort
  if &filetype == "gitcommit"
    " don't (re)store filepos for git commit message files
    " call setpos('.', [0, 1, 1, 0]) | startinsert
    call setpos('.', [0, 1, 1, 0])
  endif
endfunction

" print color reference
function! functions#ColorReference() abort
  let num = 255
  while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
  endwhile
endfunction

" print highlight groups of element under cursor
function! functions#HighlightGroups() abort
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" remove all trailing whitespace document
function! functions#zap() abort
  let l:pos=getcurpos()
  let l:search=@/
  keepjumps %substitute/\s\+$//e
  let @/=l:search
  nohlsearch
  call setpos('.', l:pos)
endfunction

" replace newlines with spaces
function! functions#sub_newlines(string) abort
  return tr(a:string, "\r\n", '  ')
endfunction

" run command and return captured output as a single line
function! functions#capture_line(command) abort
  redir => l:capture
  execute a:command
  redir END

  return functions#sub_newlines(l:capture)
endfunction

" get the current value of a highlight group
function! functions#capture_highlight(group) abort
  return functions#capture_line('silent highlight ' . a:group)
endfunction

" extract a highlight string from a group, recursively traversing linked
" groups, and returns a string suitable for passing to `:highlight`
function! functions#extract_highlight(group) abort
  let l:group = functions#capture_highlight(a:group)

  " traverse links back to authoritative group
  while l:group =~# 'links to'
    let l:index = stridx(l:group, 'links to') + len('links to')
    let l:linked = strpart(l:group, l:index + 1)
    let l:group = functions#capture_highlight(l:linked)
  endwhile

  " extract the highlighting details (the bit after "xxx")
  let l:matches = matchlist(l:group, '\<xxx\>\s\+\(.*\)')
  let l:original = l:matches[1]
  return l:original
endfunction

" return an italicized copy of `group` suitable for passing to `:highlight`
function! functions#italicize_group(group) abort
  return functions#decorate_group('italic', a:group)
endfunction

" return a bold copy of `group` suitable for passing to `:highlight`
function! functions#embolden_group(group) abort
  return functions#decorate_group('bold', a:group)
endfunction

" return a copy of `group` decorated with `style` (eg. "bold", "italic" etc)
" suitable for passing to `:highlight`
function! functions#decorate_group(style, group) abort
  let l:original = functions#extract_highlight(a:group)

  for l:lhs in ['gui', 'term', 'cterm']
    " check for existing setting
    let l:matches = matchlist(
      \   l:original,
      \   '^\([^ ]\+ \)\?' .
      \   '\(' . l:lhs . '=[^ ]\+\)' .
      \   '\( .\+\)\?$'
      \ )
    if l:matches == []
      " no setting, add one with just a:style in it
      let l:original .= ' ' . l:lhs . '=' . a:style
    else
      " existing setting; check whether a:style is already in it
      let l:start = l:matches[1]
      let l:value = l:matches[2]
      let l:end = l:matches[3]
      if l:value =~# '.*' . a:style . '.*'
        continue
      else
        let l:original = l:start . l:value . ',' . a:style . l:end
      endif
    endif
  endfor

  return functions#sub_newlines(l:original)
endfunction
