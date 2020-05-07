""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Helper Funcsions                                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Delete Vim View                                                              "
"                                                                              "
" Delete temporary view files created by mkview.                               "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" delete temporary view files created by mkview
function! buell#helpers#DeleteVimView() abort
  let path = fnamemodify(bufname('%'),':p')
  " vim's odd =~ escaping for /
  let path = substitute(path, '=', '==', 'g')
  if !empty($HOME)
    let path = substitute(path, '^'.$HOME, '\~', '')
  endif
  let path = substitute(path, '/', '=+', 'g') . '='
  " view directory
  let path = &viewdir.'/'.path
  call delete(path)
  echo "Deleted: ".path
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Double Click Override                                                        "
"                                                                              "
" Switch selection modes so double click yanks will copy entire word.          "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#DblClickOverride() abort
  " set selection to exclusive
  setl selection=exclusive
  " yank the word under the cursor
  exec ":normal yiw"
  " select the word under the cursor
  exec ":normal viw"
  " grab the register and send it to clipper
  exec system('nc localhost 8377', @0)
  " return selection to inclusive
  setl selection=inclusive
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Location List Navigation                                                     "
"                                                                              "
" Improve location list navigation.                                            "
"                                                                              "
" @param {string} direction - expects 'prev' or 'next'                         "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#LocationListNav(direction) abort
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
      echo 'No items found in the location list.'
    endif
  endtry
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Toggle Syntax Highlighting                                                   "
"                                                                              "
" Turn syntax highlighting on and off.                                         "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#ToggleSyntaxHL() abort
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
    execute 'highlight Comment ' . pinnacle#italicize('Comment')
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Sync Split                                                                   "
"                                                                              "
" Create a wrapping vertical split to show more length of a long buffer.       "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#SyncSplit() abort
  " setlocal scrollbind in right window
  setl nofoldenable
  " save the current scroll off setting to var
  let @z=&so
  " set scrolloff to 0 and clear scrollbind
  setl so=0 noscb
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Create Needed Dirs                                                           "
"                                                                              "
" Create directories as needed to backfill a path for the current buffer.      "
"                                                                              "
" @param {string} file - filename                                              "
" @param {string} buf - buffer                                                 "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#CreateNeededDirs(file, buf) abort
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Cycle Sidebars                                                               "
"                                                                              "
" Cycle no side split to NerdTree to Tagbar etc.                               "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#CycleSidebars() abort
  " if nerdtree is open, close it and open tagbar
  if (exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1)
    NERDTreeClose
    TagbarOpen
  " else if tagbar is open, close it
  elseif (exists('t:tagbar_buf_name') && bufwinnr(t:tagbar_buf_name) != -1)
    TagbarClose
  " else open nerdtree
  else
    NERDTree
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Cycle Lists                                                                  "
"                                                                              "
" Cycle location list, quickfix and no list.                                   "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#CycleLists() abort
  if exists("g:buell_quickfix_open") && g:buell_quickfix_open
    " close quickfix
    cclose
    " open loclist if it exists
    try
      lopen
      let g:buell_quickfix_open = 0
      let g:buell_loclist_open  = 1
    catch /\m^Vim\%((\a\+)\)\=:E776/
      " E776: No location list
      let g:buell_quickfix_open = 0
      let g:buell_loclist_open  = 0
    endtry
  elseif exists("g:buell_loclist_open") && g:buell_loclist_open
    " close loclist
    lclose
    let g:buell_quickfix_open = 0
    let g:buell_loclist_open  = 0
  else
    " open quickfix
    copen
    let g:buell_quickfix_open = 1
    let g:buell_loclist_open  = 0
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Cycle Views                                                                  "
"                                                                              "
" Cycle nu, syntax, goyo etc.                                                  "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#CycleViews() abort
  " if goyo is loaded, toggle goyo and rely on GoyoLeave autocommand
  if exists("g:goyo_enabled") && g:goyo_enabled == 1
    Goyo
    let g:goyo_enabled = 0
  " else we need to manually do things to avoid strange artifacting
  " if artifacing gets fixed we can just call Goyo, and rely on GoyoEnter au
  " in the after/plugins/goyo.vim configuration file (see commented bits there)
  else
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
    set statusline=''
    set laststatus=0
    set noshowmode
    set noshowcmd
    set scrolloff=999
    Limelight
    sleep 200m
    Goyo
    let g:goyo_enabled = 1
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Underline                                                                    "
"                                                                              "
" underline text with provided character                                       "
"                                                                              "
" :Underline      gives underlining like --------------- (default)             "
" :Underline =    gives underlining like ===============                       "
" :Underline -=   gives underlining like -=-=-=-=-=-=-=-                       "
" :Underline ~+-  gives underlining like ~+-~+-~+-~+-~+-                       "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#Underline() abort
  let l:chars = input('Underline Character: ')
  let l:chars = empty(l:chars) ? '-' : l:chars
  let l:nr_columns = virtcol('$') - 1
  let l:uline = repeat(l:chars, (l:nr_columns / len(l:chars)) + 1)
  if !v:shell_error && system("echo \"$(uname)\"") == "Linux"
    let put = strpart(l:uline, 0, nr_columns)   " linux
  else
    put = strpart(l:uline, 0, nr_columns)       " osx
  endif
  exe ":normal o"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Random Characters                                                            "
"                                                                              "
" Generate and insert in some random characters at the cursor position.        "
"                                                                              "
" @param {int} number - count of chars to return                               "
" @return string                                                               "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#RandomCharacters(count) abort
  if a:count > 0
    let l:bits = a:count
  else
    let l:bits = 32
  end
  exe ":normal a" . system("cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c " . l:bits)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Open Journal                                                                 "
"                                                                              "
" Open up the current days journal, create the file as needed.                 "
"                                                                              "
" @param {strind} journal - journal to open                                    "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#OpenJournal(journal) abort

  let l:year  = strftime('%Y')
  let l:month = strftime('%m')
  let l:day   = strftime('%d')
  if a:journal == 'work'
    let l:path  = "{{ WorkJournal }}" . "/" . l:year . "/" . l:month
  elseif a:journal == 'personal'
    let l:path  = "{{ PersonalJournal }}" . "/" . l:year . "/" . l:month
  endif
  let l:file  = l:year . "." . l:month . "." . l:day . ".txt"

  if !isdirectory(l:path)
    call mkdir(l:path, "p")
  endif

  execute "edit " . fnameescape(l:path) . "/" . l:file

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Yank Override                                                                "
"                                                                              "
" Override yanks to overload with copying to system clipboard as well          "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#YankOverride() abort
  " set selection to exclusive
  setl selection=exclusive
  " set virtual edit to grab the last char in the line if selected
  setl virtualedit=onemore
  " perform the yank as normal
  exec ":normal `<y`>"
  " if xclip exists send the register there
  if executable('xclip')
    exec system('xclip', @0)
  else
    " else grab the register and send it to clipper
    exec system('nc localhost 8377', @0)
  endif
  " return selection to inclusive
  setl selection=inclusive
  " return virtualedit to default
  setl virtualedit=
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Git Commit Buffer Enter                                                      "
"                                                                              "
" Don't restore cursor position on git commit messages.                        "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function buell#helpers#GitCommitBufEnter() abort
  if &filetype == "gitcommit"
    " don't (re)store filepos for git commit message files
    " call setpos('.', [0, 1, 1, 0]) | startinsert
    call setpos('.', [0, 1, 1, 0])
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Plugin Exists                                                                "
"                                                                              "
" Check that the plugin exists in the runtimepath and that the actual path     "
" exists on the filesystem.                                                    "
"                                                                              "
" @param {string} plugin - name of plugin to check for                         "
" @return int                                                                  "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function buell#helpers#PluginExists(plugin) abort
  if &runtimepath =~ a:plugin
    let l:runtimepaths = split(&rtp,",")
    let l:listlocation = match(l:runtimepaths, a:plugin)
    let l:path = l:runtimepaths[l:listlocation]
    if isdirectory(l:path)
      return 1
    endif
  endif
  return 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Number List Toggle                                                           "
"                                                                              "
" Toggle plain view vs nu, vs rnu, list, wrap, etc...                          "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#NuListToggle() abort
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Color Reference                                                              "
"                                                                              "
" Print color reference.                                                       "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#ColorReference() abort
  let num = 255
  while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
  endwhile
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Highlight Groups / Syntax Stacks                                             "
"                                                                              "
" Print highlight groups of element under the cursor.                          "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#HighlightGroups() abort
  " option 1
  for i1 in synstack(line("."), col("."))
    let i2 = synIDtrans(i1)
    let n1 = synIDattr(i1, "name")
    let n2 = synIDattr(i2, "name")
    echo n1 "->" n2
  endfor

  " " option 2
  " if !exists("*synstack")
  "   return
  " endif
  " echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

  " " option 3
  " echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  "   \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  "   \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Remove Trailing Spaces                                                       "
"                                                                              "
" Remove trailing whitespace from the current document.                        "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#RemoveTrailingSpaces() abort
  let l:pos=getcurpos()
  let l:search=@/
  keepjumps %substitute/\s\+$//e
  let @/=l:search
  nohlsearch
  call setpos('.', l:pos)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Substitute Newlines                                                          "
"                                                                              "
" Replace newlines with spaces.                                                "
"                                                                              "
" @param {string} string - text to remove newlines from                        "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#SubNewlines(string) abort
  return tr(a:string, "\r\n", '  ')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Capture Line                                                                 "
"                                                                              "
" Run command and return the captured output as a single line.                 "
"                                                                              "
" @param {string} command - command to exetue and capture output from          "
" @return {string} - output of command in a single line                        "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" run command and return captured output as a single line
function! buell#helpers#CaptureLine(command) abort
  redir => l:capture
  execute a:command
  redir END

  return buell#helpers#sub_newlines(l:capture)
endfunction
