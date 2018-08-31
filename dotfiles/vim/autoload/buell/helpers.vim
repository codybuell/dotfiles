""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Helper Funcsions                                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
" Cycle location list, quick fix and no list.                                  "
"                                                                              "
" @return null                                                                 "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#helpers#CycleLists() abort
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
