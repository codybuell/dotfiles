""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Functions                                                           "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"/////////////////////////"
"//                     //"
"//  Random Characters  //"
"//                     //"
"/////////////////////////"

function! functions#RandomCharacters(count) abort
  if a:count > 0
    let l:bits = a:count
  else
    let l:bits = 32
  end
  exe ":normal a" . system("cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c " . l:bits)
endfunction

"//////////////////////////"
"//                      //"
"//  Toggle Errors List  //"
"//                      //"
"//////////////////////////"

function! functions#ToggleErrors() abort
    if empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"'))
         " no location/quickfix list shown, open syntastic error location panel
         Errors
    else
        lclose
    endif
endfunction

"////////////////////////////////////////////////////////////////////////"
"//                                                                    //"
"//  Underline                                                         //"
"//                                                                    //"
"//  Underline current line with provided character.                   //"
"//                                                                    //"
"//  :Underline      gives underlining like --------------- (default)  //"
"//  :Underline =    gives underlining like ===============            //"
"//  :Underline -=   gives underlining like -=-=-=-=-=-=-=-            //"
"//  :Underline ~+-  gives underlining like ~+-~+-~+-~+-~+-            //"
"//                                                                    //"
"////////////////////////////////////////////////////////////////////////"

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

"/////////////////////////////////////////////////////////////////////////"
"//                                                                     //"
"//  Number / List Plugin                                               //"
"//                                                                     //"
"//  Toggle hidden characters, line numbers, and other bits. Switching  //"
"//  in and out of plain views.                                         //"
"//                                                                     //"
"/////////////////////////////////////////////////////////////////////////"

function! functions#NuListToggle() abort
  set nonu!
  set nornu!
  set nolist!
  if &foldcolumn
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=2
  endif
endfunction

"///////////////////////////////"
"//                           //"
"//  Git Commit Cursor Start  //"
"//                           //"
"///////////////////////////////"

function functions#GitCommitBufEnter() abort
  if &filetype == "gitcommit"
    " don't (re)store filepos for git commit message files
    " call setpos('.', [0, 1, 1, 0]) | startinsert
    call setpos('.', [0, 1, 1, 0])
  endif
endfunction

"/////////////////////////////"
"//                         //"
"//  Print Color Reference  //"
"//                         //"
"/////////////////////////////"

function! functions#ColorReference() abort
  let num = 255
  while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
  endwhile
endfunction

"//////////////////////////////////////////////////////////////"
"//                                                          //"
"//  Highlight Groups                                        //"
"//                                                          //"
"//  Print highlight groups of the element under the cursor. //"
"//                                                          //"
"//////////////////////////////////////////////////////////////"

function! functions#HighlightGroups() abort
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

"///////////////////////////////////////////////////////"
"//                                                   //"
"//  Zap                                              //"
"//                                                   //"
"//  Remove all trailing whitespace in the document.  //"
"//                                                   //"
"///////////////////////////////////////////////////////"

" Zap trailing whitespace.
function! functions#zap() abort
  let l:pos=getcurpos()
  let l:search=@/
  keepjumps %substitute/\s\+$//e
  let @/=l:search
  nohlsearch
  call setpos('.', l:pos)
endfunction
