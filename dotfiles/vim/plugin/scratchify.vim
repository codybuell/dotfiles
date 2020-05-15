""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                            "
"  Scrathify                                                                 "
"                                                                            "
"  Author Łukasz Jan Niemier                                                 "
"                                                                            "
"  Quickly create scratch buffers, blank or populated with the contents of   "
"  a shell command or register.  Scratch buffers onece closed do not show    "
"  up in the open buffers list, they are ephemeral and shouldn't impact the  "
"  other work you are doing.                                                 "
"                                                                            "
"  Useful to say take a look at the contents of your register, edit it, then "
"  put it back into the buffer. `:Scratch @a` -> edit -> `"ayy`              "
"                                                                            "
"  Usage:                                                                    "
"                                                                            "
"    :Scratch         open a a new empty scratch buffer                      "
"    :Scratchify      convert the current buffer into a scratch buffer       "
"    :Scratch @a      open a new scratch buffer with contents of register a  "
"    :Scratch ls      open a new scratch buffer with contents of ls cmd      "
"    :Scratch ls -la  same as above but with a more complex command          "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:loaded_scratch')
    finish
endif
let g:loaded_scratch = 1


function! s:scratch(mods, cmd) abort
  if a:cmd is# ''
    let l:output = ''
  elseif a:cmd[0] is# '@'
    if strlen(a:cmd) is# 2
      let l:output = getreg(a:cmd[1], 1, v:true)
    else
      throw 'Invalid register'
    endif
  elseif a:cmd[0] is# '!'
    let l:cmd = a:cmd =~' %' ? substitute(a:cmd, ' %', ' ' . expand('%:p'), '') : a:cmd
    let l:output = systemlist(matchstr(l:cmd, '^!\zs.*'))
  else
    let l:output = split(execute(a:cmd), "\n")
  endif

  execute a:mods . ' new'
  Scratchify
  call setline(1, l:output)
endfunction

command! Scratchify setlocal nobuflisted noswapfile buftype=nofile bufhidden=delete
command! -nargs=1 -complete=command Scratch call <SID>scratch(<q-mods>, <q-args>)
